"""
# 2D Wave Equation with Animated Visualization

Solve the 2D wave equation to visualize wave propagation:

    ∂²u/∂t² = c² (∂²u/∂x² + ∂²u/∂y²)

Initial condition: Gaussian pulse at center
Boundary conditions: Fixed boundaries (u = 0)

**Complexity**: ⭐⭐⭐ Intermediate (1 hour)
**Concepts**: Wave propagation, second-order time derivatives, energy conservation
"""

using NeuralPDE, Lux, Optimization, OptimizationOptimisers
using Plots, Printf
using Random
Random.seed!(300)

println("="^70)
println("2D WAVE EQUATION - WAVE PROPAGATION")
println("="^70)

# Wave speed
c = 1.0

@parameters x y t
@variables u(..)
Dxx = Differential(x)^2
Dyy = Differential(y)^2
Dtt = Differential(t)^2
Dt = Differential(t)

# Wave equation: ∂²u/∂t² = c² ∇²u
eq = Dtt(u(x, y, t)) ~ c^2 * (Dxx(u(x, y, t)) + Dyy(u(x, y, t)))

# Initial conditions: Gaussian pulse at center
initial_displacement(x, y) = exp(-50 * ((x - 0.5)^2 + (y - 0.5)^2))
initial_velocity(x, y) = 0.0

bcs = [
    u(0.0, y, t) ~ 0.0,      # Fixed boundaries
    u(1.0, y, t) ~ 0.0,
    u(x, 0.0, t) ~ 0.0,
    u(x, 1.0, t) ~ 0.0,
    u(x, y, 0.0) ~ initial_displacement(x, y),  # Initial displacement
    Dt(u(x, y, 0.0)) ~ initial_velocity(x, y)   # Initial velocity
]

domains = [
    x ∈ (0.0, 1.0),
    y ∈ (0.0, 1.0),
    t ∈ (0.0, 2.0)
]

# Deeper network for wave equation
chain = Lux.Chain(
    Lux.Dense(3, 50, Lux.tanh),
    Lux.Dense(50, 50, Lux.tanh),
    Lux.Dense(50, 50, Lux.tanh),
    Lux.Dense(50, 1)
)

discretization = PhysicsInformedNN(chain, QuadratureTraining())
@named pde_system = PDESystem(eq, bcs, domains, [x, y, t], [u(x, y, t)])
prob = discretize(pde_system, discretization)

losses = Float64[]
callback = function (p, l)
    push!(losses, l)
    if length(losses) % 100 == 0
        @printf("Iteration %d: Loss = %.6e\n", length(losses), l)
    end
    return false
end

println("\nTraining PINN for 2D wave propagation...")
@time res = Optimization.solve(prob, ADAM(0.01); callback = callback, maxiters = 3000)
phi = discretization.phi

# Visualization
x_grid = range(0, 1, length=60)
y_grid = range(0, 1, length=60)
t_frames = range(0, 2, length=80)

println("\nGenerating wave animation...")

# Create animation
anim = @animate for t_val in t_frames
    u_frame = [first(phi([x, y, t_val], res.minimizer)) for x in x_grid, y in y_grid]
    
    surface(x_grid, y_grid, u_frame',
            xlabel="x", ylabel="y", zlabel="Amplitude",
            title="2D Wave Propagation - t = $(round(t_val, digits=2))s",
            color=:balance, zlim=(-0.5, 1.0),
            size=(700, 600), dpi=100,
            camera=(30, 45))
end

gif(anim, "05_wave2d_animation.gif", fps=15)
println("  ✓ Saved: 05_wave2d_animation.gif")

# Static snapshots
times_snapshot = [0.0, 0.4, 0.8, 1.2, 1.6, 2.0]
p_snapshots = plot(layout=(2, 3), size=(1400, 900), dpi=150)

for (idx, t_snap) in enumerate(times_snapshot)
    u_snap = [first(phi([x, y, t_snap], res.minimizer)) for x in x_grid, y in y_grid]
    
    heatmap!(p_snapshots, x_grid, y_grid, u_snap',
             subplot=idx, xlabel="x", ylabel="y",
             title="t = $(round(t_snap, digits=2))s",
             color=:balance, clim=(-0.5, 1.0))
end

savefig(p_snapshots, "05_wave2d_snapshots.png")
println("  ✓ Saved: 05_wave2d_snapshots.png")

println("\n" * "="^70)
println("PHYSICS INSIGHTS:")
println("  1. Wave starts as Gaussian pulse at center")
println("  2. Wave propagates radially outward with speed c")
println("  3. Reflections occur at fixed boundaries")
println("  4. Wave energy conserved (oscillates between kinetic and potential)")
println("  5. Complex interference patterns emerge from reflections")
println("="^70)
