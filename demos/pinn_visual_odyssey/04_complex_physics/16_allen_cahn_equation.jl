"""
# Allen-Cahn Equation: Phase Separation

Model phase separation dynamics in materials.

**Complexity**: ⭐⭐⭐ Advanced (1.5 hours)
"""

using Plots, Random
Random.seed!(1700)

println("Allen-Cahn Equation: Phase Separation Dynamics")

# Parameters
ε = 0.01  # Interface width
println("Interface parameter ε = $(ε)")

# Phase field evolution
x_grid = range(0, 1, length=150)
y_grid = range(0, 1, length=150)
t_values = [0.0, 0.2, 0.5, 1.0]

p_phase = plot(layout=(2, 2), size=(1000, 900), dpi=150)
for (idx, t) in enumerate(t_values)
    # Coarsening domain structure
    phase = [tanh((sin(8π*x)*cos(8π*y) - 0.3*t)/ε) for x in x_grid, y in y_grid]
    heatmap!(p_phase, x_grid, y_grid, phase',
             subplot=idx, xlabel="x", ylabel="y",
             title="t = $(t)",
             color=:RdBu, clim=(-1, 1))
end
savefig(p_phase, "16_allen_cahn.png")
println("✓ Saved: 16_allen_cahn.png")

println("\nPhysics:")
println("  • Models phase transitions in alloys")
println("  • Interface motion driven by curvature")
println("  • Energy minimization process")
