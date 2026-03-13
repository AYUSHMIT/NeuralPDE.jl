"""
# Advection-Diffusion Equation

Model contaminant transport in fluid flow combining advection and diffusion.

**Complexity**: ⭐⭐ Intermediate (1 hour)
"""

using NeuralPDE, Lux, Optimization, OptimizationOptimisers
using Plots, Random
Random.seed!(1200)

println("Advection-Diffusion: Contaminant Transport")

@parameters x t
@variables u(..)
Dt = Differential(t)
Dx = Differential(x)
Dxx = Differential(x)^2

v = 0.5  # Flow velocity
D = 0.01 # Diffusion coefficient

eq = Dt(u(x, t)) + v * Dx(u(x, t)) ~ D * Dxx(u(x, t))
bcs = [u(0.0, t) ~ 0.0, u(1.0, t) ~ 0.0, u(x, 0.0) ~ exp(-100*(x-0.3)^2)]
domains = [x ∈ (0.0, 1.0), t ∈ (0.0, 2.0)]

chain = Lux.Chain(Lux.Dense(2, 30, Lux.tanh), Lux.Dense(30, 30, Lux.tanh), Lux.Dense(30, 1))
discretization = PhysicsInformedNN(chain, QuadratureTraining())
@named pde_system = PDESystem(eq, bcs, domains, [x, t], [u(x, t)])
prob = discretize(pde_system, discretization)

res = Optimization.solve(prob, ADAM(0.01); maxiters = 2000)
phi = discretization.phi

x_grid = range(0, 1, length=100)
t_grid = range(0, 2, length=100)
u_field = [first(phi([x, t], res.minimizer)) for x in x_grid, t in t_grid]

heatmap(x_grid, t_grid, u_field', xlabel="Position", ylabel="Time",
        title="Advection-Diffusion", color=:viridis, size=(800, 600), dpi=150)
savefig("08_advection_diffusion.png")
println("✓ Saved: 08_advection_diffusion.png")
