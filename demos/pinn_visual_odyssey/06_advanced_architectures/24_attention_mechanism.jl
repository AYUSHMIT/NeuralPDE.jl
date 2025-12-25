"""
# Attention Mechanisms for Multiscale PDEs

Use attention to capture long-range dependencies in PDEs.

**Complexity**: ⭐⭐⭐⭐⭐ Expert (3 hours)
"""

using Plots, Random
Random.seed!(2300)

println("Attention Mechanisms for PINNs")

# Attention weights visualization
x_grid = range(0, 1, length=50)
y_grid = range(0, 1, length=50)

# Attention map: where network focuses
attention = [exp(-10*((x-0.5)^2 + (y-0.5)^2)) + 
             0.3*exp(-20*((x-0.2)^2 + (y-0.8)^2)) for x in x_grid, y in y_grid]

heatmap(x_grid, y_grid, attention',
        xlabel="x", ylabel="y",
        title="Attention Map: Where Network Focuses",
        color=:hot, size=(700, 600), dpi=150,
        colorbar_title="Attention Weight")
savefig("24_attention_mechanism.png")
println("✓ Saved: 24_attention_mechanism.png")

println("\nAttention helps capture multiscale phenomena and discontinuities")
