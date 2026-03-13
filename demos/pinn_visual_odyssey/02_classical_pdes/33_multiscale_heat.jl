"""
# Multi-Scale Heat Equation

Solve heat equation with multiple spatial scales (fine and coarse features).

**Complexity**: ⭐⭐⭐ Advanced (1.5 hours)
"""

using NeuralPDE, Lux, Optimization, OptimizationOptimisers
using Plots, Random
Random.seed!(2900)

println("Multi-Scale Heat Equation")

@parameters x t
@variables u(..)
Dt = Differential(t)
Dxx = Differential(x)^2

# Heat equation
eq = Dt(u(x, t)) ~ 0.1 * Dxx(u(x, t))

# Multi-scale initial condition
multiscale_ic(x) = sin(2π*x) + 0.3*sin(20π*x)

bcs = [
    u(0.0, t) ~ 0.0,
    u(1.0, t) ~ 0.0,
    u(x, 0.0) ~ multiscale_ic(x)
]

domains = [x ∈ (0.0, 1.0), t ∈ (0.0, 0.5)]

chain = Lux.Chain(Lux.Dense(2, 50, Lux.tanh), Lux.Dense(50, 50, Lux.tanh), Lux.Dense(50, 1))
discretization = PhysicsInformedNN(chain, QuadratureTraining())
@named pde_system = PDESystem(eq, bcs, domains, [x, t], [u(x, t)])
prob = discretize(pde_system, discretization)

res = Optimization.solve(prob, ADAM(0.01); maxiters = 2000)
phi = discretization.phi

x_grid = range(0, 1, length=200)
u_init = multiscale_ic.(x_grid)
u_final = [first(phi([x, 0.5], res.minimizer)) for x in x_grid]

p = plot(x_grid, u_init, label="Initial (multiscale)", lw=2, color=:blue,
         xlabel="x", ylabel="u(x,t)", title="Multi-Scale Diffusion",
         legend=:topright, size=(900, 500), dpi=150)
plot!(p, x_grid, u_final, label="Final (smoothed)", lw=2, color=:red)

savefig("33_multiscale_heat.png")
println("✓ Saved: 33_multiscale_heat.png")
println("\nFine-scale features diffuse faster than coarse-scale features")
