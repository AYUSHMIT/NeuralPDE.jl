"""
# Stochastic PDE: Adding Noise

Solve stochastic heat equation with random forcing.

**Complexity**: ⭐⭐⭐⭐ Advanced (2 hours)
"""

using Plots, Random
Random.seed!(3000)

println("Stochastic PDE: Heat Equation with Noise")

# Stochastic trajectories
x_grid = range(0, 1, length=100)
t_vals = [0.0, 0.5, 1.0]

p_stoch = plot(layout=(1, 3), size=(1400, 450), dpi=150)

for (idx, t) in enumerate(t_vals)
    # Multiple stochastic realizations
    for i in 1:10
        u_path = sin.(π .* x_grid) .* exp.(-0.1*π^2*t) .+ 
                 0.1 .* randn(length(x_grid)) .* sqrt(t)
        plot!(p_stoch, x_grid, u_path,
              subplot=idx, xlabel="x", ylabel="u(x,t)",
              title="t = $(t)",
              lw=1, alpha=0.5, label="", color=:blue)
    end
end

savefig(p_stoch, "34_stochastic_pde.png")
println("✓ Saved: 34_stochastic_pde.png")
println("\nStochastic PDEs model uncertainty and random fluctuations")
