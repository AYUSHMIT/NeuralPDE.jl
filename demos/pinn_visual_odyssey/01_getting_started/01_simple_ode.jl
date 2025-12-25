"""
# Simple ODE Solver with PINNs

This introductory example demonstrates how to solve a simple ordinary differential equation
using Physics-Informed Neural Networks (PINNs). We solve the exponential decay ODE:

    du/dt = -u,  u(0) = 1

with exact solution: u(t) = exp(-t)

**Complexity**: ⭐ Beginner (15 minutes)
**Concepts**: Basic PINN setup, loss functions, neural network training
"""

using NeuralPDE, Lux, Optimization, OptimizationOptimisers
using Plots, Printf
using Random
Random.seed!(42)

# Define the ODE symbolically
@parameters t
@variables u(..)
Dt = Differential(t)

# ODE: du/dt = -u
eq = Dt(u(t)) ~ -u(t)

# Initial condition: u(0) = 1
bcs = [u(0.0) ~ 1.0]

# Time domain
domains = [t ∈ (0.0, 3.0)]

# Neural network: simple 2-layer network
# Input: time t (1D), Output: u(t) (1D)
chain = Lux.Chain(
    Lux.Dense(1, 12, Lux.tanh),
    Lux.Dense(12, 12, Lux.tanh),
    Lux.Dense(12, 1)
)

# Discretization strategy
discretization = PhysicsInformedNN(chain, QuadratureTraining())

@named pde_system = PDESystem(eq, bcs, domains, [t], [u(t)])
prob = discretize(pde_system, discretization)

# Training with loss tracking
losses = Float64[]
callback = function (p, l)
    push!(losses, l)
    if length(losses) % 100 == 0
        @printf("Iteration %d: Loss = %.6e\n", length(losses), l)
    end
    return false
end

println("Training PINN to solve du/dt = -u, u(0) = 1...")
println("="^60)

# Train with ADAM optimizer
@time res = Optimization.solve(prob, ADAM(0.01); callback = callback, maxiters = 1000)

# Extract the trained neural network
phi = discretization.phi

# Prepare test points
t_test = collect(0.0:0.01:3.0)
u_predict = [first(phi([t], res.minimizer)) for t in t_test]
u_exact = exp.(-t_test)
error = abs.(u_predict .- u_exact)

# Calculate metrics
max_error = maximum(error)
mean_error = sum(error) / length(error)
relative_error = sum(error ./ u_exact) / length(error)

println("\n" * "="^60)
println("Results Summary:")
println("  Max absolute error:  $(max_error)")
println("  Mean absolute error: $(mean_error)")
println("  Mean relative error: $(relative_error)")
println("="^60)

# Create visualization
p1 = plot(t_test, u_exact, label="Exact Solution", lw=3, 
          xlabel="Time t", ylabel="u(t)", title="ODE Solution: du/dt = -u",
          legend=:topright, color=:blue)
plot!(p1, t_test, u_predict, label="PINN Solution", lw=2, 
      linestyle=:dash, color=:red)

p2 = plot(t_test, error, label="Absolute Error", lw=2, 
          xlabel="Time t", ylabel="Error", title="Prediction Error",
          color=:purple, fill=(0, 0.2, :purple))

p3 = plot(1:length(losses), losses, label="Training Loss", lw=2,
          xlabel="Iteration", ylabel="Loss", title="Loss Evolution",
          yscale=:log10, color=:green)

# Combined plot
plot(p1, p2, p3, layout=(3, 1), size=(800, 900), dpi=150)
savefig("01_simple_ode_solution.png")
println("\nPlot saved as '01_simple_ode_solution.png'")

# Additional insights
println("\n" * "="^60)
println("Key Takeaways:")
println("  1. PINNs can solve ODEs without numerical time-stepping")
println("  2. The neural network learns both the solution and its derivative")
println("  3. Loss decreases smoothly during training")
println("  4. Solution accuracy improves with more training iterations")
println("="^60)
