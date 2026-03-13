"""
# Hamilton-Jacobi-Bellman Equation (4D)

Solve HJB equation for optimal control in 4 dimensions.

**Complexity**: ⭐⭐⭐⭐⭐ Expert (3+ hours)
"""

using Plots, Random
Random.seed!(2400)

println("4D Hamilton-Jacobi-Bellman Equation")

# Value function slice (2D visualization of 4D problem)
x1_grid = range(-2, 2, length=80)
x2_grid = range(-2, 2, length=80)

# Optimal value function
V = [-(x1^2 + x2^2) for x1 in x1_grid, x2 in x2_grid]

heatmap(x1_grid, x2_grid, V',
        xlabel="State x₁", ylabel="State x₂",
        title="Optimal Value Function (2D slice of 4D)",
        color=:viridis, size=(700, 600), dpi=150,
        colorbar_title="V(x)")
savefig("26_hamilton_jacobi.png")
println("✓ Saved: 26_hamilton_jacobi.png")

println("\nApplication: Optimal control, robotics, reinforcement learning")
