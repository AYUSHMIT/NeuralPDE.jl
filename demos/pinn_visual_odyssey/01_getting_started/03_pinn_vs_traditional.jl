"""
# PINN vs Traditional Solver Comparison

Compare Physics-Informed Neural Networks with traditional numerical methods
for solving the 1D heat equation. This demonstrates:
- Speed comparison
- Accuracy comparison
- Memory efficiency
- Flexibility for different queries

**Complexity**: ⭐⭐ Beginner (45 minutes)
**Concepts**: Benchmarking, traditional FDM, PINN advantages
"""

using NeuralPDE, Lux, Optimization, OptimizationOptimisers
using DifferentialEquations, OrdinaryDiffEq
using Plots, Printf, Statistics
using Random
Random.seed!(123)

# Problem: 1D Heat Equation
# ∂u/∂t = α ∂²u/∂x²
# u(0,t) = u(1,t) = 0
# u(x,0) = sin(2πx)

α = 0.05  # Thermal diffusivity

println("="^70)
println("BENCHMARK: PINN vs Traditional Finite Difference Method")
println("="^70)
println("Problem: 1D Heat Equation with Dirichlet BCs")
println("  ∂u/∂t = α ∂²u/∂x²")
println("  Domain: x ∈ [0,1], t ∈ [0,0.5]")
println("  Initial: u(x,0) = sin(2πx)")
println("="^70)

# ============================================================================
# Method 1: Traditional Finite Difference Method (FDM)
# ============================================================================

function solve_heat_fdm(nx, nt, α)
    dx = 1.0 / (nx - 1)
    dt = 0.5 / (nt - 1)
    
    x = range(0, 1, length=nx)
    t = range(0, 0.5, length=nt)
    
    u = zeros(nx, nt)
    u[:, 1] = sin.(2π .* x)
    
    # Stability check: CFL condition
    cfl = α * dt / dx^2
    if cfl > 0.5
        @warn "CFL condition violated: CFL = $(cfl) > 0.5"
    end
    
    # Time stepping
    for n in 1:nt-1
        for i in 2:nx-1
            u[i, n+1] = u[i, n] + α * dt / dx^2 * (u[i-1, n] - 2*u[i, n] + u[i+1, n])
        end
        # Boundary conditions
        u[1, n+1] = 0.0
        u[nx, n+1] = 0.0
    end
    
    return x, t, u
end

println("\n[1/2] Solving with Finite Difference Method...")
@time x_fdm, t_fdm, u_fdm = solve_heat_fdm(101, 101, α)
println("  Grid size: 101 × 101 points")
println("  Memory: ~$(round(sizeof(u_fdm) / 1024, digits=2)) KB")

# ============================================================================
# Method 2: Physics-Informed Neural Network (PINN)
# ============================================================================

@parameters x t
@variables u(..)
Dt = Differential(t)
Dxx = Differential(x)^2

eq = Dt(u(x, t)) ~ α * Dxx(u(x, t))

bcs = [
    u(0.0, t) ~ 0.0,
    u(1.0, t) ~ 0.0,
    u(x, 0.0) ~ sin(2π * x)
]

domains = [
    x ∈ (0.0, 1.0),
    t ∈ (0.0, 0.5)
]

chain = Lux.Chain(
    Lux.Dense(2, 32, Lux.tanh),
    Lux.Dense(32, 32, Lux.tanh),
    Lux.Dense(32, 1)
)

discretization = PhysicsInformedNN(chain, QuadratureTraining())

@named pde_system = PDESystem(eq, bcs, domains, [x, t], [u(x, t)])
prob = discretize(pde_system, discretization)

println("\n[2/2] Solving with Physics-Informed Neural Network...")
losses = Float64[]
callback = function (p, l)
    push!(losses, l)
    return false
end

@time res = Optimization.solve(prob, ADAM(0.01); callback = callback, maxiters = 1500)
phi = discretization.phi

println("  Network parameters: ~$(length(res.minimizer))")
println("  Memory: ~$(round(sizeof(res.minimizer) / 1024, digits=2)) KB")

# ============================================================================
# Comparison and Visualization
# ============================================================================

# Analytical solution
analytical(x, t) = exp(-α * (2π)^2 * t) * sin(2π * x)

# Test points
x_test = range(0, 1, length=100)
t_test = range(0, 0.5, length=100)

# Compute errors
error_fdm = zeros(length(x_test), length(t_test))
error_pinn = zeros(length(x_test), length(t_test))

for (i, x_val) in enumerate(x_test)
    for (j, t_val) in enumerate(t_test)
        u_true = analytical(x_val, t_val)
        
        # FDM error (interpolate)
        i_fdm = argmin(abs.(x_fdm .- x_val))
        j_fdm = argmin(abs.(t_fdm .- t_val))
        u_fdm_interp = u_fdm[i_fdm, j_fdm]
        error_fdm[i, j] = abs(u_fdm_interp - u_true)
        
        # PINN error
        u_pinn = first(phi([x_val, t_val], res.minimizer))
        error_pinn[i, j] = abs(u_pinn - u_true)
    end
end

# Statistics
println("\n" * "="^70)
println("ACCURACY COMPARISON:")
println("  FDM  - Max error: $(round(maximum(error_fdm), digits=6))")
println("  FDM  - Mean error: $(round(mean(error_fdm), digits=6))")
println("  PINN - Max error: $(round(maximum(error_pinn), digits=6))")
println("  PINN - Mean error: $(round(mean(error_pinn), digits=6))")
println("="^70)

# Visualization
p1 = heatmap(x_test, t_test, error_fdm',
             xlabel="Position x", ylabel="Time t",
             title="FDM Error", color=:plasma, clim=(0, maximum([error_fdm; error_pinn])))

p2 = heatmap(x_test, t_test, error_pinn',
             xlabel="Position x", ylabel="Time t",
             title="PINN Error", color=:plasma, clim=(0, maximum([error_fdm; error_pinn])))

# Solution comparison at t=0.25
t_compare = 0.25
u_true_snap = [analytical(x, t_compare) for x in x_test]
u_pinn_snap = [first(phi([x, t_compare], res.minimizer)) for x in x_test]

i_t = argmin(abs.(t_fdm .- t_compare))
u_fdm_snap = [u_fdm[argmin(abs.(x_fdm .- x)), i_t] for x in x_test]

p3 = plot(x_test, u_true_snap, label="Analytical", lw=3, color=:black,
          xlabel="Position x", ylabel="u(x, t=$(t_compare))",
          title="Solution Comparison at t=$(t_compare)", legend=:topright)
plot!(p3, x_test, u_fdm_snap, label="FDM", lw=2, linestyle=:dash, color=:blue)
plot!(p3, x_test, u_pinn_snap, label="PINN", lw=2, linestyle=:dot, color=:red)

# Loss evolution
p4 = plot(1:length(losses), losses, 
          xlabel="Iteration", ylabel="Loss",
          title="PINN Training Loss",
          label="", lw=2, color=:green, yscale=:log10)

plot(p1, p2, p3, p4, layout=(2, 2), size=(1000, 800), dpi=150)
savefig("03_comparison_pinn_vs_fdm.png")

println("\n" * "="^70)
println("KEY INSIGHTS:")
println("\n✓ PINN Advantages:")
println("  - Mesh-free: query solution at ANY point (x,t)")
println("  - No CFL stability constraints")
println("  - Compact representation (few KB vs large grids)")
println("  - Naturally handles complex geometries")
println("  - Can incorporate data and physics simultaneously")
println("\n✗ PINN Limitations:")
println("  - Training time can be longer")
println("  - Requires hyperparameter tuning")
println("  - Non-deterministic (depends on initialization)")
println("\n✓ Traditional Method Advantages:")
println("  - Well-understood convergence properties")
println("  - Fast for simple geometries")
println("  - Deterministic solutions")
println("\n✗ Traditional Method Limitations:")
println("  - Requires mesh generation")
println("  - Stability constraints (CFL condition)")
println("  - Memory grows with resolution")
println("  - Difficult for complex/high-dimensional problems")
println("="^70)

println("\nPlot saved as '03_comparison_pinn_vs_fdm.png'")
