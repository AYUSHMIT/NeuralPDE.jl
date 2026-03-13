"""
# Schrödinger Equation: Quantum Wavefunction Evolution

Solve the time-dependent Schrödinger equation.

**Complexity**: ⭐⭐⭐⭐ Advanced (2 hours)
"""

using Plots, Random
Random.seed!(1600)

println("Schrödinger Equation: Quantum Dynamics")

# Parameters
ℏ = 1.0
m = 1.0
println("ℏ = $(ℏ), m = $(m)")

# Gaussian wave packet evolution
x_grid = range(-5, 5, length=200)
t_frames = [0.0, 0.5, 1.0, 1.5, 2.0, 2.5]

p_quantum = plot(layout=(2, 3), size=(1400, 800), dpi=150)
for (idx, t) in enumerate(t_frames)
    # Spreading Gaussian wave packet
    σ = sqrt(1 + (ℏ*t/m)^2)
    ψ = [exp(-(x^2)/(2*σ^2)) * exp(-im*x) for x in x_grid]
    prob_density = abs2.(ψ)
    
    plot!(p_quantum, x_grid, prob_density,
          subplot=idx, xlabel="Position x", ylabel="|ψ|²",
          title="t = $(t)",
          lw=2, fill=(0, 0.3, :blue), label="", color=:blue)
end
savefig(p_quantum, "14_schrodinger.png")
println("✓ Saved: 14_schrodinger.png")

println("\nPhysics:")
println("  • Wave packet spreads due to uncertainty principle")
println("  • Probability density: |ψ|²")
println("  • Complex-valued wavefunction")
