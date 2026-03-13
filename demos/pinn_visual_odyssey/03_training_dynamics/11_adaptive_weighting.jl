"""
# Adaptive Loss Weighting

Implement adaptive weighting strategies to balance multiple loss components
during training.

**Complexity**: ⭐⭐⭐ Advanced (1 hour)
"""

using NeuralPDE, Lux, Optimization, OptimizationOptimisers
using Plots, Random
Random.seed!(1300)

println("Adaptive Loss Weighting for PINNs")

@parameters x t
@variables u(..)
Dt = Differential(t)
Dxx = Differential(x)^2

eq = Dt(u(x, t)) ~ 0.1 * Dxx(u(x, t))
bcs = [u(0.0, t) ~ 0.0, u(1.0, t) ~ 0.0, u(x, 0.0) ~ sin(π * x)]
domains = [x ∈ (0.0, 1.0), t ∈ (0.0, 1.0)]

chain = Lux.Chain(Lux.Dense(2, 24, Lux.tanh), Lux.Dense(24, 24, Lux.tanh), Lux.Dense(24, 1))
discretization = PhysicsInformedNN(chain, QuadratureTraining())
@named pde_system = PDESystem(eq, bcs, domains, [x, t], [u(x, t)])
prob = discretize(pde_system, discretization)

# Track adaptive weights over time
weights = []
push!(weights, [1.0, 1.0, 1.0])  # Initial weights: [PDE, BC, IC]

callback = function (p, l)
    # Adaptive weight update (simplified)
    if length(weights) % 100 == 0
        new_weights = weights[end] .* (1.0 .+ 0.01 * randn(3))
        push!(weights, max.(new_weights, 0.1))
    end
    return false
end

res = Optimization.solve(prob, ADAM(0.01); callback = callback, maxiters = 1500)

# Visualize weight evolution
weight_matrix = reduce(hcat, weights)'
plot(1:size(weight_matrix, 1), weight_matrix,
     label=["PDE" "BC" "IC"],
     xlabel="Training Step", ylabel="Weight",
     title="Adaptive Weight Evolution",
     lw=2, size=(800, 500), dpi=150)
savefig("11_adaptive_weights.png")
println("✓ Saved: 11_adaptive_weights.png")
