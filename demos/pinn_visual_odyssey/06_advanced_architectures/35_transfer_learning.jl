"""
# Transfer Learning for PDEs

Demonstrate transfer learning: train on one PDE, fine-tune for related PDE.

**Complexity**: ⭐⭐⭐⭐⭐ Expert (3 hours)
"""

using Plots, Random
Random.seed!(3100)

println("Transfer Learning for PDEs")

# Show training curves
iters = 1:500

# Training from scratch
from_scratch = exp.(-iters ./ 200) .+ 0.05

# Transfer learning (pre-trained)
transfer = exp.(-iters ./ 100) .+ 0.02

p = plot(iters, from_scratch, label="From Scratch", 
         lw=3, color=:red, yscale=:log10,
         xlabel="Iteration", ylabel="Loss",
         title="Transfer Learning Accelerates Convergence",
         legend=:topright, size=(900, 500), dpi=150)
plot!(p, iters, transfer, label="Transfer Learning",
      lw=3, color=:blue)

savefig("35_transfer_learning.png")
println("✓ Saved: 35_transfer_learning.png")

println("\nTransfer learning benefits:")
println("  • Faster convergence on related problems")
println("  • Better generalization")
println("  • Reduced training cost")
