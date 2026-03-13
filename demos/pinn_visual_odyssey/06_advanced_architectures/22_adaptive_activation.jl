"""
# Adaptive Activation Functions

Implement learnable adaptive activation functions for improved convergence.

**Complexity**: ⭐⭐⭐⭐⭐ Expert (2 hours)
"""

using Plots, Random
Random.seed!(2100)

println("Adaptive Activation Functions")

# Show activation function evolution during training
x = range(-3, 3, length=200)

# Initial: standard tanh
act_initial = tanh.(x)

# After training: adapted
act_trained = tanh.(1.5 .* x) .* (1 .+ 0.2 .* sin.(2 .* x))

p = plot(x, act_initial, label="Initial (tanh)", lw=3, color=:blue,
         xlabel="x", ylabel="σ(x)",
         title="Adaptive Activation Evolution",
         legend=:bottomright, size=(800, 500), dpi=150)
plot!(p, x, act_trained, label="Adapted", lw=3, color=:red)

savefig("22_adaptive_activation.png")
println("✓ Saved: 22_adaptive_activation.png")

println("\nBenefit: Network learns optimal nonlinearities for specific PDE")
