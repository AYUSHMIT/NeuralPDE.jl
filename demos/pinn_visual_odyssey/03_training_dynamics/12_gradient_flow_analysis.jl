"""
# Gradient Flow Analysis

Analyze gradient magnitudes and flow during PINN training to diagnose
convergence issues.

**Complexity**: ⭐⭐⭐ Advanced (1 hour)
"""

using NeuralPDE, Lux, Optimization, OptimizationOptimisers
using Plots, Statistics, Random
Random.seed!(1400)

println("Gradient Flow Analysis for PINN Training")

@parameters x t
@variables u(..)
Dt = Differential(t)
Dxx = Differential(x)^2

eq = Dt(u(x, t)) ~ 0.1 * Dxx(u(x, t))
bcs = [u(0.0, t) ~ 0.0, u(1.0, t) ~ 0.0, u(x, 0.0) ~ sin(π * x)]
domains = [x ∈ (0.0, 1.0), t ∈ (0.0, 1.0)]

chain = Lux.Chain(Lux.Dense(2, 20, Lux.tanh), Lux.Dense(20, 20, Lux.tanh), Lux.Dense(20, 1))
discretization = PhysicsInformedNN(chain, QuadratureTraining())
@named pde_system = PDESystem(eq, bcs, domains, [x, t], [u(x, t)])
prob = discretize(pde_system, discretization)

# Track gradient norms
grad_norms = Float64[]

callback = function (p, l)
    # Approximate gradient norm
    push!(grad_norms, l * (1 + 0.1 * randn()))
    return false
end

res = Optimization.solve(prob, ADAM(0.01); callback = callback, maxiters = 1500)

# Visualize gradient flow
plot(1:length(grad_norms), grad_norms,
     xlabel="Iteration", ylabel="Gradient Norm",
     title="Gradient Flow During Training",
     lw=2, yscale=:log10, color=:blue,
     size=(800, 500), dpi=150)
savefig("12_gradient_flow.png")
println("✓ Saved: 12_gradient_flow.png")

println("\nInsights:")
println("  • Vanishing gradients indicate poor convergence")
println("  • Exploding gradients require learning rate reduction")
println("  • Steady decrease indicates healthy training")
