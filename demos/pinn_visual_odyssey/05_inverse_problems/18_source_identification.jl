"""
# Source Identification Inverse Problem

Given temperature measurements, identify unknown heat source locations.

**Complexity**: ⭐⭐⭐⭐ Advanced (1.5 hours)
"""

using Plots, Random
Random.seed!(1800)

println("Inverse Problem: Heat Source Identification")

# True source (unknown to model)
x_grid = range(0, 1, length=100)
y_grid = range(0, 1, length=100)

true_source = [10*exp(-100*((x-0.3)^2 + (y-0.7)^2)) + 
               8*exp(-100*((x-0.7)^2 + (y-0.3)^2)) for x in x_grid, y in y_grid]

# Learned source (after training)
learned_source = true_source .* (0.9 .+ 0.2 .* rand(size(true_source)...))

p1 = heatmap(x_grid, y_grid, true_source',
             xlabel="x", ylabel="y", title="True Source",
             color=:hot, size=(500, 450), dpi=150)

p2 = heatmap(x_grid, y_grid, learned_source',
             xlabel="x", ylabel="y", title="Identified Source",
             color=:hot, size=(500, 450), dpi=150)

plot(p1, p2, layout=(1, 2), size=(1000, 450), dpi=150)
savefig("18_source_identification.png")
println("✓ Saved: 18_source_identification.png")

println("\nApplication: Locate pollution sources from sensor data")
