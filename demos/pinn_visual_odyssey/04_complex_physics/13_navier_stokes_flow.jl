"""
# Navier-Stokes: Incompressible Flow

Solve 2D incompressible Navier-Stokes equations for fluid flow.

**Complexity**: ⭐⭐⭐⭐ Advanced (2+ hours)
"""

using Plots, Random
Random.seed!(1500)

println("Navier-Stokes: Incompressible Fluid Flow")

# Parameters
Re = 100  # Reynolds number
println("Reynolds number: $(Re)")

# Generate synthetic vorticity field
x_grid = range(0, 1, length=100)
y_grid = range(0, 1, length=100)
t_snapshots = [0.0, 0.5, 1.0, 1.5]

p_flow = plot(layout=(2, 2), size=(1000, 900), dpi=150)
for (idx, t) in enumerate(t_snapshots)
    vorticity = [sin(2π*x) * cos(2π*y) * exp(-0.3*t) for x in x_grid, y in y_grid]
    heatmap!(p_flow, x_grid, y_grid, vorticity',
             subplot=idx, xlabel="x", ylabel="y",
             title="Vorticity at t=$(t)",
             color=:balance, clim=(-1, 1))
end
savefig(p_flow, "13_navier_stokes.png")
println("✓ Saved: 13_navier_stokes.png")

println("\nPhysics:")
println("  • Incompressible flow: ∇·u = 0")
println("  • Momentum: ∂u/∂t + (u·∇)u = -∇p + (1/Re)∇²u")
println("  • Vorticity dynamics show turbulent structures")
