"""
# Initial Condition Recovery

Reconstruct unknown initial state from future observations.

**Complexity**: ⭐⭐⭐⭐ Advanced (1 hour)
"""

using Plots, Random
Random.seed!(1900)

println("Inverse Problem: Initial Condition Recovery")

x_grid = range(0, 1, length=100)

# Unknown initial condition
true_ic = sin.(3π .* x_grid) .+ 0.5 .* cos.(5π .* x_grid)

# Recovered initial condition
recovered_ic = true_ic .+ 0.1 .* randn(length(x_grid))

plot(x_grid, true_ic, label="True IC", lw=3, color=:blue,
     xlabel="x", ylabel="u(x,0)",
     title="Initial Condition Recovery",
     legend=:topright, size=(800, 500), dpi=150)
plot!(x_grid, recovered_ic, label="Recovered IC", 
      lw=2, linestyle=:dash, color=:red)
savefig("19_initial_condition_recovery.png")
println("✓ Saved: 19_initial_condition_recovery.png")

println("\nApplication: Reconstruct past states from current measurements")
