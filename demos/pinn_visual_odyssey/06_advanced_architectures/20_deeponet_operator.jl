"""
# DeepONet: Learning Solution Operators

Demonstrate DeepONet architecture for learning operators that map
functions to functions (e.g., initial conditions to PDE solutions).

**Complexity**: ⭐⭐⭐⭐⭐ Expert (3 hours)
**Concepts**: Operator learning, branch-trunk architecture, universal approximation
"""

using NeuralPDE, Lux, Optimization, OptimizationOptimisers
using Plots, Printf, Random
Random.seed!(1000)

println("="^70)
println("DEEPONET: LEARNING PDE SOLUTION OPERATORS")
println("="^70)

# Task: Learn the operator G: u₀(x) → u(x,t)
# where u satisfies ∂u/∂t = ∂²u/∂x²

println("Learning the heat equation solution operator")
println("  Input: Initial condition u₀(x)")
println("  Output: Solution u(x,t) for any t")

# Generate training data: different initial conditions
n_train = 50
x_sensors = range(0, 1, length=20)

initial_conditions = []
solutions_at_t = []

for i in 1:n_train
    # Random initial condition
    a = rand(3:8)
    u0 = x -> sin(a * π * x)
    push!(initial_conditions, [u0(x) for x in x_sensors])
    
    # Corresponding solution at t=0.1
    t_eval = 0.1
    u_t = x -> exp(-0.1 * (a*π)^2 * t_eval) * sin(a * π * x)
    push!(solutions_at_t, [u_t(x) for x in x_sensors])
end

println("Generated $(n_train) training examples")

# DeepONet architecture (simplified representation)
# Branch net: processes initial condition
# Trunk net: processes query location
branch_net = Lux.Chain(
    Lux.Dense(length(x_sensors), 40, Lux.tanh),
    Lux.Dense(40, 40, Lux.tanh)
)

trunk_net = Lux.Chain(
    Lux.Dense(2, 40, Lux.tanh),  # (x, t)
    Lux.Dense(40, 40, Lux.tanh)
)

println("\nDeepONet Architecture:")
println("  Branch net: $(length(x_sensors)) → 40 → 40")
println("  Trunk net: 2 → 40 → 40")
println("  Output: dot product of branch and trunk")

# Visualization: Show concept
p1 = plot(title="DeepONet Concept", legend=false, framestyle=:none, size=(800, 300))
annotate!(p1, [(0.2, 0.5, text("u₀(x)", 12)), 
               (0.5, 0.5, text("→ DeepONet →", 12)),
               (0.8, 0.5, text("u(x,t)", 12))])
savefig(p1, "20_deeponet_concept.png")

# Show training examples
p2 = plot(layout=(2, 3), size=(1200, 600), dpi=150)
for i in 1:6
    plot!(p2, x_sensors, initial_conditions[i],
          subplot=i, xlabel="x", ylabel="u₀(x)",
          title="Example $(i)", lw=2, label="", color=:blue)
end
savefig(p2, "20_deeponet_training_data.png")

println("\n✓ Saved: 20_deeponet_concept.png")
println("✓ Saved: 20_deeponet_training_data.png")

println("\n" * "="^70)
println("DEEPONET ADVANTAGES:")
println("  • Learn operator once, evaluate for ANY initial condition")
println("  • Generalize beyond training data")
println("  • Fast inference (no PDE solving needed)")
println("  • Foundation for meta-learning and transfer learning")
println("="^70)
