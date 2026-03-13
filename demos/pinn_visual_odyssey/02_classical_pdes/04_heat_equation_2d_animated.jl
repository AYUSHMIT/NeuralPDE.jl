"""
# 2D Heat Equation with Animated Visualization

Solve the 2D heat diffusion equation with source term and create
beautiful animated visualizations of the temperature evolution.

    ∂u/∂t = α (∂²u/∂x² + ∂²u/∂y²) + f(x,y,t)

with a localized heat source.

**Complexity**: ⭐⭐⭐ Intermediate (1 hour)
**Concepts**: 2D PDEs, source terms, animation generation
"""

using NeuralPDE, Lux, Optimization, OptimizationOptimisers
using Plots, Printf
using Random
Random.seed!(200)

println("="^70)
println("2D HEAT EQUATION WITH SOURCE TERM")
println("="^70)

# Problem parameters
α = 0.1  # Thermal diffusivity
t_max = 1.0

# Define the PDE symbolically
@parameters x y t
@variables u(..)
Dt = Differential(t)
Dxx = Differential(x)^2
Dyy = Differential(y)^2

# Localized heat source at center
source(x, y, t) = 10.0 * exp(-((x - 0.5)^2 + (y - 0.5)^2) / 0.01) * (t < 0.3)

# 2D Heat equation with source
eq = Dt(u(x, y, t)) ~ α * (Dxx(u(x, y, t)) + Dyy(u(x, y, t))) + source(x, y, t)

# Boundary conditions (Dirichlet: zero temperature at boundaries)
bcs = [
    u(0.0, y, t) ~ 0.0,
    u(1.0, y, t) ~ 0.0,
    u(x, 0.0, t) ~ 0.0,
    u(x, 1.0, t) ~ 0.0,
    u(x, y, 0.0) ~ 0.0  # Initial condition: cold everywhere
]

# Domain
domains = [
    x ∈ (0.0, 1.0),
    y ∈ (0.0, 1.0),
    t ∈ (0.0, t_max)
]

# Neural network with increased capacity for 3D problem
chain = Lux.Chain(
    Lux.Dense(3, 40, Lux.tanh),
    Lux.Dense(40, 40, Lux.tanh),
    Lux.Dense(40, 40, Lux.tanh),
    Lux.Dense(40, 1)
)

discretization = PhysicsInformedNN(chain, QuadratureTraining())

@named pde_system = PDESystem(eq, bcs, domains, [x, y, t], [u(x, y, t)])
prob = discretize(pde_system, discretization)

# Training
losses = Float64[]
callback = function (p, l)
    push!(losses, l)
    if length(losses) % 100 == 0
        @printf("Iteration %d: Loss = %.6e\n", length(losses), l)
    end
    return false
end

println("\nTraining PINN for 2D heat diffusion...")
@time res = Optimization.solve(prob, ADAM(0.01); callback = callback, maxiters = 2500)

phi = discretization.phi

# Create visualization grid
x_grid = range(0, 1, length=50)
y_grid = range(0, 1, length=50)
t_frames = range(0, t_max, length=50)

println("\nGenerating visualizations...")

# Static plots at different times
times_snapshot = [0.1, 0.3, 0.6, 1.0]
p_snapshots = plot(layout=(2, 2), size=(1000, 900), dpi=150)

for (idx, t_snap) in enumerate(times_snapshot)
    u_snap = [first(phi([x, y, t_snap], res.minimizer)) for x in x_grid, y in y_grid]
    
    heatmap!(p_snapshots, x_grid, y_grid, u_snap',
             subplot=idx, xlabel="x", ylabel="y",
             title="t = $(round(t_snap, digits=2))s",
             color=:thermal, clim=(0, maximum(u_snap) * 1.1))
end

savefig(p_snapshots, "04_heat2d_snapshots.png")
println("  ✓ Saved: 04_heat2d_snapshots.png")

# Create animation
anim = @animate for t_val in t_frames
    u_frame = [first(phi([x, y, t_val], res.minimizer)) for x in x_grid, y in y_grid]
    
    heatmap(x_grid, y_grid, u_frame',
            xlabel="x", ylabel="y",
            title="2D Heat Diffusion - t = $(round(t_val, digits=2))s",
            color=:thermal, clim=(0, 3.0),
            size=(600, 550), dpi=100,
            colorbar_title="Temperature")
end

gif(anim, "04_heat2d_animation.gif", fps=10)
println("  ✓ Saved: 04_heat2d_animation.gif")

# Cross-sections over time
x_center = 0.5
y_center = 0.5

# Temperature at center over time
u_center_time = [first(phi([x_center, y_center, t], res.minimizer)) for t in t_frames]

# Spatial profile at different times
p_profiles = plot(layout=(2, 2), size=(1000, 800), dpi=150)

# X-profile at y=0.5
for (idx, t_snap) in enumerate([0.1, 0.3, 0.6, 1.0])
    u_x_profile = [first(phi([x, y_center, t_snap], res.minimizer)) for x in x_grid]
    
    plot!(p_profiles, x_grid, u_x_profile,
          subplot=idx, xlabel="x", ylabel="Temperature",
          title="Cross-section at y=0.5, t=$(round(t_snap, digits=2))s",
          lw=2, label="", color=:red)
end

savefig(p_profiles, "04_heat2d_profiles.png")
println("  ✓ Saved: 04_heat2d_profiles.png")

# Temperature evolution at center
p_center = plot(t_frames, u_center_time,
                xlabel="Time", ylabel="Temperature",
                title="Temperature at Center (0.5, 0.5)",
                lw=2, label="", color=:blue,
                size=(800, 400), dpi=150)
savefig(p_center, "04_heat2d_center_evolution.png")
println("  ✓ Saved: 04_heat2d_center_evolution.png")

# Loss evolution
p_loss = plot(1:length(losses), losses,
              xlabel="Iteration", ylabel="Loss",
              title="Training Loss Evolution",
              lw=2, label="", color=:green,
              yscale=:log10, size=(800, 400), dpi=150)
savefig(p_loss, "04_heat2d_loss.png")
println("  ✓ Saved: 04_heat2d_loss.png")

println("\n" * "="^70)
println("RESULTS SUMMARY:")
println("  Final loss: $(losses[end])")
println("  Training iterations: $(length(losses))")
println("  Max temperature at center: $(maximum(u_center_time))")
println("  Temperature at t=$(t_max): $(u_center_time[end])")
println("="^70)

println("\n" * "="^70)
println("PHYSICS INSIGHTS:")
println("  1. Heat source creates local hotspot at center")
println("  2. Heat diffuses radially from the source")
println("  3. Temperature decreases after source turns off (t > 0.3)")
println("  4. Boundary conditions dissipate heat to environment")
println("  5. Steady state approaches zero (no sustained source)")
println("="^70)

println("\nVisualization files created:")
println("  - 04_heat2d_snapshots.png (temperature field at 4 times)")
println("  - 04_heat2d_animation.gif (animated heat diffusion)")
println("  - 04_heat2d_profiles.png (spatial cross-sections)")
println("  - 04_heat2d_center_evolution.png (temporal evolution)")
println("  - 04_heat2d_loss.png (training progress)")
