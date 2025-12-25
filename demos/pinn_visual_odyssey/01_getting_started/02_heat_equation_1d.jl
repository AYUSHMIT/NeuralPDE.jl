"""
# 1D Heat Equation with PINNs

Solve the classic 1D heat diffusion equation with Dirichlet boundary conditions:

    ∂u/∂t = α ∂²u/∂x²,  for x ∈ [0,1], t ∈ [0,1]
    
Boundary conditions:
    u(0,t) = 0,  u(1,t) = 0
    
Initial condition:
    u(x,0) = sin(πx)

**Complexity**: ⭐⭐ Beginner (30 minutes)
**Concepts**: 2D problems, boundary conditions, heat diffusion physics
"""

using NeuralPDE, Lux, Optimization, OptimizationOptimisers
using Plots, Printf, LaTeXStrings
using Random
Random.seed!(100)

# Problem parameters
α = 0.1  # Thermal diffusivity

# Define the PDE symbolically
@parameters x t
@variables u(..)
Dt = Differential(t)
Dxx = Differential(x)^2

# Heat equation: ∂u/∂t = α ∂²u/∂x²
eq = Dt(u(x, t)) ~ α * Dxx(u(x, t))

# Boundary and initial conditions
bcs = [
    u(0.0, t) ~ 0.0,           # Left boundary
    u(1.0, t) ~ 0.0,           # Right boundary
    u(x, 0.0) ~ sin(π * x)     # Initial condition
]

# Space and time domains
domains = [
    x ∈ (0.0, 1.0),
    t ∈ (0.0, 1.0)
]

# Neural network architecture
chain = Lux.Chain(
    Lux.Dense(2, 20, Lux.tanh),
    Lux.Dense(20, 20, Lux.tanh),
    Lux.Dense(20, 20, Lux.tanh),
    Lux.Dense(20, 1)
)

# Discretization with quadrature training
discretization = PhysicsInformedNN(chain, QuadratureTraining())

@named pde_system = PDESystem(eq, bcs, domains, [x, t], [u(x, t)])
prob = discretize(pde_system, discretization)

# Training with progress tracking
losses = Float64[]
callback = function (p, l)
    push!(losses, l)
    if length(losses) % 200 == 0
        @printf("Iteration %d: Loss = %.6e\n", length(losses), l)
    end
    return false
end

println("Solving 1D Heat Equation: ∂u/∂t = α ∂²u/∂x²")
println("="^70)
println("Parameters:")
println("  Thermal diffusivity α = $(α)")
println("  Domain: x ∈ [0,1], t ∈ [0,1]")
println("  Initial condition: u(x,0) = sin(πx)")
println("="^70)

# Training
@time res = Optimization.solve(prob, ADAM(0.01); callback = callback, maxiters = 2000)

phi = discretization.phi

# Analytical solution: u(x,t) = exp(-α π² t) sin(πx)
analytical(x, t) = exp(-α * π^2 * t) * sin(π * x)

# Create spatial and temporal grids for visualization
x_grid = 0.0:0.02:1.0
t_grid = 0.0:0.02:1.0

# Compute solutions
u_pred = [first(phi([x, t], res.minimizer)) for x in x_grid, t in t_grid]
u_exact = [analytical(x, t) for x in x_grid, t in t_grid]
error = abs.(u_pred .- u_exact)

# Statistics
println("\n" * "="^70)
println("Results:")
println("  Max absolute error: $(maximum(error))")
println("  Mean absolute error: $(sum(error) / length(error))")
println("="^70)

# Visualization: Solution at different times
times = [0.0, 0.2, 0.5, 1.0]
p_solutions = plot(layout=(2, 2), size=(900, 700), dpi=150)

for (i, t_snap) in enumerate(times)
    u_pred_snap = [first(phi([x, t_snap], res.minimizer)) for x in x_grid]
    u_exact_snap = [analytical(x, t_snap) for x in x_grid]
    
    plot!(p_solutions, x_grid, u_exact_snap, 
          subplot=i, label="Exact", lw=3, color=:blue,
          xlabel="Position x", ylabel="Temperature u(x,t)",
          title="t = $(t_snap)", legend=:topright)
    plot!(p_solutions, x_grid, u_pred_snap, 
          subplot=i, label="PINN", lw=2, linestyle=:dash, color=:red)
end

savefig(p_solutions, "02_heat_equation_snapshots.png")

# Heatmap comparison
p_heatmap = plot(layout=(1, 3), size=(1200, 400), dpi=150)

heatmap!(p_heatmap, x_grid, t_grid, u_pred',
         subplot=1, xlabel="Position x", ylabel="Time t",
         title="PINN Solution", color=:viridis, clim=(0, 1))

heatmap!(p_heatmap, x_grid, t_grid, u_exact',
         subplot=2, xlabel="Position x", ylabel="Time t",
         title="Exact Solution", color=:viridis, clim=(0, 1))

heatmap!(p_heatmap, x_grid, t_grid, error',
         subplot=3, xlabel="Position x", ylabel="Time t",
         title="Absolute Error", color=:plasma)

savefig(p_heatmap, "02_heat_equation_heatmap.png")

# Loss evolution
p_loss = plot(1:length(losses), losses, 
              xlabel="Iteration", ylabel="Loss",
              title="Training Loss Evolution",
              label="", lw=2, color=:green,
              yscale=:log10, size=(800, 400), dpi=150)
savefig(p_loss, "02_heat_equation_loss.png")

println("\nPlots saved:")
println("  - 02_heat_equation_snapshots.png (solution at different times)")
println("  - 02_heat_equation_heatmap.png (spatiotemporal heatmaps)")
println("  - 02_heat_equation_loss.png (training progress)")

println("\n" * "="^70)
println("Physics Insights:")
println("  1. Heat diffuses from high to low temperature")
println("  2. Solution decays exponentially: exp(-α π² t)")
println("  3. Boundary conditions maintained throughout time")
println("  4. PINNs capture the smooth diffusion process accurately")
println("="^70)
