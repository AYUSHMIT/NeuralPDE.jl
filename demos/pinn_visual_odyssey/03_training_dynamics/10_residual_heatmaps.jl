"""
# PDE Residual Heatmaps

Visualize where the PINN struggles to satisfy the PDE by plotting
residual magnitudes across the domain.

**Complexity**: ⭐⭐⭐ Advanced (45 minutes)
**Concepts**: Residual analysis, error localization, training diagnostics
"""

using NeuralPDE, Lux, Optimization, OptimizationOptimisers
using Plots, Printf, ForwardDiff
using Random
Random.seed!(600)

println("="^70)
println("PDE RESIDUAL HEATMAP VISUALIZATION")
println("="^70)

# Solve 2D Poisson equation
@parameters x y
@variables u(..)
Dxx = Differential(x)^2
Dyy = Differential(y)^2

f(x, y) = -2π^2 * sin(π * x) * sin(π * y)
eq = Dxx(u(x, y)) + Dyy(u(x, y)) ~ f(x, y)

bcs = [u(0.0, y) ~ 0.0, u(1.0, y) ~ 0.0, u(x, 0.0) ~ 0.0, u(x, 1.0) ~ 0.0]
domains = [x ∈ (0.0, 1.0), y ∈ (0.0, 1.0)]

chain = Lux.Chain(Lux.Dense(2, 20, Lux.tanh), Lux.Dense(20, 20, Lux.tanh), Lux.Dense(20, 1))
discretization = PhysicsInformedNN(chain, QuadratureTraining())
@named pde_system = PDESystem(eq, bcs, domains, [x, y], [u(x, y)])
prob = discretize(pde_system, discretization)

# Train with intermediate checkpoints
checkpoints = [500, 1000, 2000]
results = []
iters = 0

for target in checkpoints
    global iters
    remaining = target - iters
    res = Optimization.solve(prob, ADAM(0.01); maxiters = remaining)
    prob = remake(prob, u0 = res.minimizer)
    push!(results, res.minimizer)
    iters = target
    println("Checkpoint at iteration $(target)")
end

phi = discretization.phi
x_grid = range(0, 1, length=80)
y_grid = range(0, 1, length=80)

# Compute residuals at each checkpoint
p_residuals = plot(layout=(1, 3), size=(1400, 450), dpi=150)

for (idx, (params, iter)) in enumerate(zip(results, checkpoints))
    # Compute PDE residual: |∇²u - f|
    residual = zeros(length(x_grid), length(y_grid))
    for (i, xi) in enumerate(x_grid)
        for (j, yj) in enumerate(y_grid)
            # Finite difference approximation of Laplacian
            h = 0.001
            u_center = first(phi([xi, yj], params))
            u_left = first(phi([xi-h, yj], params))
            u_right = first(phi([xi+h, yj], params))
            u_down = first(phi([xi, yj-h], params))
            u_up = first(phi([xi, yj+h], params))
            
            laplacian = (u_left + u_right + u_down + u_up - 4*u_center) / h^2
            residual[i, j] = abs(laplacian - f(xi, yj))
        end
    end
    
    heatmap!(p_residuals, x_grid, y_grid, residual',
             subplot=idx, xlabel="x", ylabel="y",
             title="Iteration $(iter)",
             color=:hot, clim=(0, maximum(residual)))
end

savefig(p_residuals, "10_residual_heatmaps.png")
println("\n✓ Saved: 10_residual_heatmaps.png")

println("\n" * "="^70)
println("INSIGHTS:")
println("  • Residuals decrease as training progresses")
println("  • High residuals indicate where PINN struggles")
println("  • Can guide adaptive sampling strategies")
println("="^70)
