"""
# Drug Diffusion in Tissue

Model pharmaceutical transport and absorption in biological tissue.

**Complexity**: ⭐⭐⭐⭐ Advanced (1.5 hours)
"""

using Plots, Random
Random.seed!(2700)

println("Drug Diffusion in Tissue")

# Drug concentration over time
x_grid = range(0, 5, length=100)  # mm
t_vals = [0.0, 1.0, 5.0, 10.0]  # hours

p_drug = plot(layout=(2, 2), size=(1000, 800), dpi=150)
for (idx, t) in enumerate(t_vals)
    # Diffusion from injection site at x=0
    concentration = [exp(-x^2 / (4*0.1*(t+0.1))) / sqrt(π*0.1*(t+0.1)) for x in x_grid]
    
    plot!(p_drug, x_grid, concentration,
          subplot=idx, xlabel="Distance (mm)", ylabel="Concentration (mg/mL)",
          title="t = $(t) hours",
          lw=3, fill=(0, 0.2, :blue), label="", color=:blue)
end

savefig(p_drug, "30_drug_diffusion.png")
println("✓ Saved: 30_drug_diffusion.png")

println("\nApplications: Optimizing drug delivery, dosage design")
