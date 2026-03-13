"""
# Burgers' Equation - Shock Wave Formation

Solve the viscous Burgers' equation demonstrating shock wave formation:

    ∂u/∂t + u ∂u/∂x = ν ∂²u/∂x²

This nonlinear PDE models shock waves, traffic flow, and fluid dynamics.

**Complexity**: ⭐⭐⭐ Intermediate (1.5 hours)
**Concepts**: Nonlinear PDEs, shock formation, viscosity effects
"""

using NeuralPDE, Lux, Optimization, OptimizationOptimisers
using Plots, Printf
using Random
Random.seed!(400)

println("="^70)
println("BURGERS' EQUATION - SHOCK WAVE FORMATION")
println("="^70)

# Viscosity coefficient
ν = 0.01

@parameters x t
@variables u(..)
Dt = Differential(t)
Dx = Differential(x)
Dxx = Differential(x)^2

# Burgers' equation: ∂u/∂t + u ∂u/∂x = ν ∂²u/∂x²
eq = Dt(u(x, t)) + u(x, t) * Dx(u(x, t)) ~ ν * Dxx(u(x, t))

# Initial condition: smooth sine wave
initial_condition(x) = sin(π * x)

# Periodic-like boundary conditions
bcs = [
    u(0.0, t) ~ 0.0,
    u(1.0, t) ~ 0.0,
    u(x, 0.0) ~ initial_condition(x)
]

domains = [
    x ∈ (0.0, 1.0),
    t ∈ (0.0, 1.0)
]

# Network architecture
chain = Lux.Chain(
    Lux.Dense(2, 40, Lux.tanh),
    Lux.Dense(40, 40, Lux.tanh),
    Lux.Dense(40, 40, Lux.tanh),
    Lux.Dense(40, 1)
)

discretization = PhysicsInformedNN(chain, QuadratureTraining())
@named pde_system = PDESystem(eq, bcs, domains, [x, t], [u(x, t)])
prob = discretize(pde_system, discretization)

losses = Float64[]
callback = function (p, l)
    push!(losses, l)
    if length(losses) % 100 == 0
        @printf("Iteration %d: Loss = %.6e\n", length(losses), l)
    end
    return false
end

println("\nTraining PINN for Burgers' equation...")
println("  Viscosity ν = $(ν)")
println("  Initial condition: u(x,0) = sin(πx)")
@time res = Optimization.solve(prob, ADAM(0.01); callback = callback, maxiters = 3000)

phi = discretization.phi

# Visualization
x_grid = range(0, 1, length=200)
t_grid = range(0, 1, length=100)

println("\nGenerating visualizations...")

# Spatiotemporal heatmap
u_field = [first(phi([x, t], res.minimizer)) for x in x_grid, t in t_grid]

p_heatmap = heatmap(x_grid, t_grid, u_field',
                    xlabel="Position x", ylabel="Time t",
                    title="Burgers' Equation Solution",
                    color=:RdBu, clim=(-1, 1),
                    size=(800, 600), dpi=150)
savefig(p_heatmap, "06_burgers_heatmap.png")

# Solution snapshots at different times
times_snapshot = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]
p_snapshots = plot(layout=(2, 3), size=(1200, 800), dpi=150)

for (idx, t_snap) in enumerate(times_snapshot)
    u_snap = [first(phi([x, t_snap], res.minimizer)) for x in x_grid]
    
    plot!(p_snapshots, x_grid, u_snap,
          subplot=idx, xlabel="x", ylabel="u(x,t)",
          title="t = $(round(t_snap, digits=2))s",
          lw=2, label="", color=:blue,
          ylim=(-1, 1))
end

savefig(p_snapshots, "06_burgers_snapshots.png")

# Animation
t_frames = range(0, 1, length=60)
anim = @animate for t_val in t_frames
    u_frame = [first(phi([x, t_val], res.minimizer)) for x in x_grid]
    
    plot(x_grid, u_frame,
         xlabel="Position x", ylabel="Velocity u",
         title="Burgers' Equation - t = $(round(t_val, digits=3))s",
         lw=3, label="", color=:blue,
         ylim=(-1.2, 1.2), xlim=(0, 1),
         size=(800, 500), dpi=100,
         legend=false)
    
    # Add zero line
    hline!([0], color=:black, linestyle=:dash, lw=1)
end

gif(anim, "06_burgers_animation.gif", fps=15)

println("  ✓ Saved: 06_burgers_heatmap.png")
println("  ✓ Saved: 06_burgers_snapshots.png")
println("  ✓ Saved: 06_burgers_animation.gif")

# Shock detection: find max gradient
max_gradients = Float64[]
for t_val in t_frames
    u_snap = [first(phi([x, t_val], res.minimizer)) for x in x_grid]
    gradients = diff(u_snap) ./ diff(collect(x_grid))
    push!(max_gradients, maximum(abs.(gradients)))
end

p_gradient = plot(t_frames, max_gradients,
                  xlabel="Time", ylabel="Max |∂u/∂x|",
                  title="Shock Strength Evolution",
                  lw=2, label="", color=:red,
                  size=(800, 400), dpi=150)
savefig(p_gradient, "06_burgers_shock_strength.png")
println("  ✓ Saved: 06_burgers_shock_strength.png")

# Loss evolution
p_loss = plot(1:length(losses), losses,
              xlabel="Iteration", ylabel="Loss",
              title="Training Loss",
              lw=2, label="", color=:green,
              yscale=:log10, size=(800, 400), dpi=150)
savefig(p_loss, "06_burgers_loss.png")
println("  ✓ Saved: 06_burgers_loss.png")

println("\n" * "="^70)
println("PHYSICS INSIGHTS:")
println("  1. Smooth initial condition develops into shock wave")
println("  2. Nonlinear advection (u ∂u/∂x) causes wave steepening")
println("  3. Viscosity (ν ∂²u/∂x²) prevents infinite gradients")
println("  4. Balance between steepening and diffusion creates shock")
println("  5. Lower viscosity → sharper shock")
println("  6. Burgers' equation models traffic flow, gas dynamics")
println("="^70)

println("\n" * "="^70)
println("NUMERICAL INSIGHTS:")
println("  Final loss: $(losses[end])")
println("  Max shock gradient: $(maximum(max_gradients))")
println("  Training converged after $(length(losses)) iterations")
println("="^70)
