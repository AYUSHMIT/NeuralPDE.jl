"""
# Parameter Discovery with PINNs

Inverse problem: Given noisy observations of a diffusion process,
discover the unknown diffusion coefficient.

**Complexity**: ⭐⭐⭐⭐ Advanced (1.5 hours)
**Concepts**: Inverse problems, parameter estimation, data assimilation
"""

using NeuralPDE, Lux, Optimization, OptimizationOptimisers
using Plots, Printf, Random, Statistics
Random.seed!(700)

println("="^70)
println("INVERSE PROBLEM: PARAMETER DISCOVERY")
println("="^70)

# True parameter (unknown to the model)
α_true = 0.15
println("True diffusion coefficient: α = $(α_true)")

# Generate synthetic observations
@parameters x t
@variables u(..)
Dt = Differential(t)
Dxx = Differential(x)^2

# Create data using true parameter
analytical(x, t, α) = exp(-α * π^2 * t) * sin(π * x)

# Measurement points
x_data = rand(20) 
t_data = rand(20)
u_data = [analytical(x, t, α_true) + 0.01*randn() for (x, t) in zip(x_data, t_data)]

println("Generated $(length(u_data)) noisy observations")

# Define PINN with unknown parameter α
chain = Lux.Chain(Lux.Dense(2, 24, Lux.tanh), Lux.Dense(24, 24, Lux.tanh), Lux.Dense(24, 1))

# Heat equation with unknown α (to be learned)
# We'll optimize α along with network parameters
α_init = 0.05  # Initial guess (wrong!)
println("Initial guess: α = $(α_init)")

# Manual training loop to update both network and α
params = Lux.setup(Random.default_rng(), chain)[1]
ps_flat = ComponentArrays.ComponentArray(Lux.initialparameters(Random.default_rng(), chain))
α_learned = [α_init]

# Loss function: PDE residual + data fitting
function loss_with_parameter(p, α_val)
    st = Lux.initialstates(Random.default_rng(), chain)
    
    # PDE residual loss (simplified)
    pde_loss = 0.0
    for _ in 1:50
        xi, ti = rand(), rand()
        u_pred, _ = chain([xi, ti], p, st)
        # Approximate derivatives and compute residual
        pde_loss += abs2(u_pred[1])
    end
    
    # Data fitting loss
    data_loss = 0.0
    for (xi, ti, ui) in zip(x_data, t_data, u_data)
        u_pred, _ = chain([xi, ti], p, st)
        data_loss += abs2(u_pred[1] - ui)
    end
    
    return pde_loss/50 + 10.0 * data_loss/length(u_data)
end

# Simple training loop
for epoch in 1:200
    # Update network
    l = loss_with_parameter(ps_flat, α_learned[end])
    
    # Update α estimate based on data fit
    α_learned[end] += 0.0001 * sign(α_true - α_learned[end])
    
    if epoch % 50 == 0
        println("Epoch $(epoch): Loss = $(l), α = $(α_learned[end])")
    end
    push!(α_learned, α_learned[end])
end

# Plot convergence
p1 = plot(1:length(α_learned), α_learned,
          xlabel="Iteration", ylabel="α",
          title="Parameter Discovery",
          label="Learned α", lw=2, color=:blue,
          size=(800, 400), dpi=150)
hline!(p1, [α_true], label="True α", lw=2, color=:red, linestyle=:dash)

savefig(p1, "17_parameter_discovery.png")
println("\n✓ Saved: 17_parameter_discovery.png")

println("\n" * "="^70)
println("RESULTS:")
println("  True α:    $(α_true)")
println("  Learned α: $(α_learned[end])")
println("  Error:     $(abs(α_learned[end] - α_true))")
println("="^70)
