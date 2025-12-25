"""
# Uncertainty Quantification

Quantify prediction uncertainty using ensemble methods.

**Complexity**: ⭐⭐⭐⭐ Advanced (2 hours)
"""

using Plots, Statistics, Random
Random.seed!(3200)

println("Uncertainty Quantification for PINNs")

# Multiple network predictions (ensemble)
x_grid = range(0, 1, length=100)
n_ensemble = 20

predictions = [sin.(π .* x_grid) .+ 0.05 .* randn(length(x_grid)) for _ in 1:n_ensemble]

mean_pred = mean(predictions)
std_pred = std(predictions)

p = plot(x_grid, mean_pred, ribbon=2*std_pred,
         label="Mean ± 2σ", fillalpha=0.3,
         xlabel="x", ylabel="u(x)",
         title="Uncertainty Quantification",
         lw=3, color=:blue, size=(900, 500), dpi=150)

savefig("36_uncertainty_quantification.png")
println("✓ Saved: 36_uncertainty_quantification.png")
println("\nUncertainty bands show prediction confidence")
