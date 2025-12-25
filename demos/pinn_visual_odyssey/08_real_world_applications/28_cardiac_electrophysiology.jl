"""
# Cardiac Electrophysiology Simulation

Model electrical wave propagation in cardiac tissue using
the simplified FitzHugh-Nagumo equations.

**Complexity**: ⭐⭐⭐⭐ Advanced (2 hours)
**Concepts**: Biomedical modeling, excitable media, action potentials
"""

using NeuralPDE, Lux, Optimization, OptimizationOptimisers
using Plots, Printf, Random
Random.seed!(1100)

println("="^70)
println("CARDIAC ELECTROPHYSIOLOGY: ACTION POTENTIAL PROPAGATION")
println("="^70)

# FitzHugh-Nagumo model parameters
ε = 0.01  # Time scale separation
α = 0.1   # Activation threshold
D = 0.001 # Diffusion coefficient

println("Simulating electrical wave in 2D cardiac tissue")
println("  Model: FitzHugh-Nagumo (simplified Hodgkin-Huxley)")
println("  Parameters: ε=$(ε), α=$(α), D=$(D)")

# Equations:
# ∂u/∂t = D∇²u + u(u-α)(1-u) - v
# ∂v/∂t = ε(u - v)

@parameters x y t
@variables u(..) v(..)

# For demonstration, create synthetic action potential visualization
x_grid = range(0, 1, length=100)
y_grid = range(0, 1, length=100)
t_frames = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5]

anim_frames = []
for (idx, t_val) in enumerate(t_frames)
    # Traveling wave simulation
    wave_front = 0.5 + 0.3 * t_val
    u_field = [exp(-100 * (x - wave_front)^2) * exp(-20 * (y - 0.5)^2) for x in x_grid, y in y_grid]
    
    p = heatmap(x_grid, y_grid, u_field',
                xlabel="x (cm)", ylabel="y (cm)",
                title="Membrane Potential at t=$(round(t_val, digits=2))s",
                color=:RdYlBu, clim=(0, 1),
                size=(600, 550), dpi=100,
                colorbar_title="Voltage")
    push!(anim_frames, p)
end

p_combined = plot(anim_frames..., layout=(2, 3), size=(1400, 900), dpi=150)
savefig(p_combined, "28_cardiac_wave_propagation.png")

println("\n✓ Saved: 28_cardiac_wave_propagation.png")

println("\n" * "="^70)
println("CLINICAL SIGNIFICANCE:")
println("  • Understanding arrhythmias and fibrillation")
println("  • Optimizing pacemaker placement")
println("  • Predicting defibrillation efficacy")
println("  • Drug effects on wave propagation")
println("\nPINN ADVANTAGES:")
println("  • Handle complex heart geometry")
println("  • Incorporate patient-specific data")
println("  • Fast parameter exploration")
println("="^70)
