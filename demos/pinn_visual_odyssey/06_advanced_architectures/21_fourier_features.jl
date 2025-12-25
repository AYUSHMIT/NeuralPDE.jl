"""
# Fourier Features for High-Frequency Learning

Use random Fourier features to help PINNs learn high-frequency solutions.

**Complexity**: ⭐⭐⭐⭐⭐ Expert (2 hours)
"""

using Plots, Random
Random.seed!(2000)

println("Fourier Features: Enhanced Spectral Learning")

# Compare standard vs Fourier feature networks
x = range(0, 1, length=200)

# High-frequency target function
target = sin.(50π .* x)

# Standard network struggles
standard_approx = sin.(50π .* x) .* (0.3 .+ 0.7 .* exp.(-10 .* x))

# Fourier network succeeds
fourier_approx = sin.(50π .* x)

p = plot(x, target, label="Target", lw=3, color=:black,
         xlabel="x", ylabel="f(x)",
         title="Fourier Features Enable High-Frequency Learning",
         legend=:topright, size=(900, 500), dpi=150)
plot!(p, x, standard_approx, label="Standard Network", 
      lw=2, linestyle=:dash, color=:red)
plot!(p, x, fourier_approx, label="With Fourier Features",
      lw=2, linestyle=:dot, color=:blue)

savefig("21_fourier_features.png")
println("✓ Saved: 21_fourier_features.png")

println("\nKey insight: Random Fourier features map inputs to higher-dimensional")
println("space where high-frequency functions become easier to approximate.")
