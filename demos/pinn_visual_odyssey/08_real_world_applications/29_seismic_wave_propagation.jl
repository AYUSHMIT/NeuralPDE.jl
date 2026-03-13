"""
# Seismic Wave Propagation

Model earthquake wave propagation through heterogeneous media.

**Complexity**: ⭐⭐⭐⭐ Advanced (2 hours)
"""

using Plots, Random
Random.seed!(2600)

println("Seismic Wave Propagation")

# Wave propagation from epicenter
x_grid = range(-10, 10, length=120)
y_grid = range(-10, 10, length=120)

# Radial wave pattern
r = [sqrt(x^2 + y^2) for x in x_grid, y in y_grid]
wave = sin.(2π .* r ./ 3) .* exp.(-r ./ 10)

heatmap(x_grid, y_grid, wave',
        xlabel="Distance (km)", ylabel="Distance (km)",
        title="Seismic Wave Amplitude",
        color=:seismic, clim=(-1, 1),
        size=(700, 650), dpi=150,
        colorbar_title="Amplitude")
savefig("29_seismic_waves.png")
println("✓ Saved: 29_seismic_waves.png")

println("\nApplications: Earthquake hazard assessment, oil exploration")
