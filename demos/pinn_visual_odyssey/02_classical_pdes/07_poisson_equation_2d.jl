"""
# Poisson Equation - Electrostatic Potential

Solve the 2D Poisson equation for electrostatic potential:

    ∇²u = f(x,y)
    
where f(x,y) is a charge distribution.

**Complexity**: ⭐⭐ Intermediate (45 minutes)
**Concepts**: Elliptic PDEs, electrostatics, Laplace operator
"""

using NeuralPDE, Lux, Optimization, OptimizationOptimisers
using Plots, Printf
using Random
Random.seed!(250)

println("="^70)
println("2D POISSON EQUATION - ELECTROSTATIC POTENTIAL")
println("="^70)

@parameters x y
@variables u(..)
Dxx = Differential(x)^2
Dyy = Differential(y)^2

# Charge distribution: point charges
charge_distribution(x, y) = -2π^2 * sin(π * x) * sin(π * y)

# Poisson equation: ∇²u = f
eq = Dxx(u(x, y)) + Dyy(u(x, y)) ~ charge_distribution(x, y)

# Dirichlet boundary conditions
bcs = [
    u(0.0, y) ~ 0.0,
    u(1.0, y) ~ 0.0,
    u(x, 0.0) ~ 0.0,
    u(x, 1.0) ~ 0.0
]

domains = [
    x ∈ (0.0, 1.0),
    y ∈ (0.0, 1.0)
]

chain = Lux.Chain(
    Lux.Dense(2, 32, Lux.tanh),
    Lux.Dense(32, 32, Lux.tanh),
    Lux.Dense(32, 1)
)

discretization = PhysicsInformedNN(chain, QuadratureTraining())
@named pde_system = PDESystem(eq, bcs, domains, [x, y], [u(x, y)])
prob = discretize(pde_system, discretization)

losses = Float64[]
callback = function (p, l)
    push!(losses, l)
    if length(losses) % 100 == 0
        @printf("Iteration %d: Loss = %.6e\n", length(losses), l)
    end
    return false
end

println("\nSolving Poisson equation for electrostatic potential...")
@time res = Optimization.solve(prob, ADAM(0.01); callback = callback, maxiters = 2000)
phi = discretization.phi

# Analytical solution
analytical(x, y) = sin(π * x) * sin(π * y) / (2π^2)

# Visualization
x_grid = range(0, 1, length=100)
y_grid = range(0, 1, length=100)

u_pred = [first(phi([x, y], res.minimizer)) for x in x_grid, y in y_grid]
u_exact = [analytical(x, y) for x in x_grid, y in y_grid]
error = abs.(u_pred .- u_exact)

p1 = heatmap(x_grid, y_grid, u_pred',
             xlabel="x", ylabel="y", title="PINN Solution",
             color=:viridis)

p2 = heatmap(x_grid, y_grid, u_exact',
             xlabel="x", ylabel="y", title="Exact Solution",
             color=:viridis)

p3 = heatmap(x_grid, y_grid, error',
             xlabel="x", ylabel="y", title="Absolute Error",
             color=:plasma)

p4 = contour(x_grid, y_grid, u_pred',
             xlabel="x", ylabel="y", title="Equipotential Lines",
             levels=20, color=:balance, fill=true)

plot(p1, p2, p3, p4, layout=(2, 2), size=(1000, 900), dpi=150)
savefig("07_poisson_solution.png")

println("\n✓ Saved: 07_poisson_solution.png")
println("Max error: $(maximum(error))")
