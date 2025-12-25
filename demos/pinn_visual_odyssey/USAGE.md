# Usage Guide: PINN Visual Odyssey

## Quick Start

### 1. Installation

```bash
cd demos/pinn_visual_odyssey

# Activate the demo environment
julia --project=.

# Install all dependencies (first time only)
julia> using Pkg
julia> Pkg.instantiate()
```

This will download and install all required packages (~5-10 minutes).

### 2. Running Your First Demo

```bash
# Still in julia --project=.
julia> include("01_getting_started/01_simple_ode.jl")
```

Expected output:
- Training progress printed to console
- Final metrics and validation results
- Generated PNG: `01_simple_ode_solution.png`

### 3. Running Multiple Demos

Use the test runner:

```bash
julia --project=. test_runner.jl getting
```

## Demo Categories

### 🌱 Beginner Friendly (Start Here!)

```bash
julia --project=. -e 'include("01_getting_started/01_simple_ode.jl")'
julia --project=. -e 'include("01_getting_started/02_heat_equation_1d.jl")'
julia --project=. -e 'include("01_getting_started/03_pinn_vs_traditional.jl")'
```

**Time:** 1-2 hours total  
**Prerequisites:** Basic calculus, some Julia familiarity

### 🔥 Classical PDEs

```bash
julia --project=. test_runner.jl classical
```

Or individually:
```bash
julia --project=. -e 'include("02_classical_pdes/04_heat_equation_2d_animated.jl")'
```

**Time:** 3-5 hours  
**Prerequisites:** PDEs, numerical methods

### 📊 Training Dynamics

```bash
julia --project=. test_runner.jl training
```

**Time:** 3-4 hours  
**Prerequisites:** Neural networks, optimization

### 🌀 Complex Physics

```bash
julia --project=. test_runner.jl complex
```

**Time:** 6-8 hours  
**Prerequisites:** Advanced PDEs, physics

### 🔍 Inverse Problems

```bash
julia --project=. test_runner.jl inverse
```

**Time:** 4-6 hours  
**Prerequisites:** Parameter estimation, data assimilation

### 🏗️ Advanced Architectures

```bash
julia --project=. test_runner.jl advanced
```

**Time:** 8-12 hours  
**Prerequisites:** Deep learning, neural architecture design

### 📐 High-Dimensional PDEs

```bash
julia --project=. test_runner.jl highdim
```

**Time:** 6-10 hours  
**Prerequisites:** High-dimensional optimization

### 🌍 Real-World Applications

```bash
julia --project=. test_runner.jl realworld
```

**Time:** 6-8 hours  
**Prerequisites:** Domain-specific knowledge

## Running with GPU Acceleration

If you have an NVIDIA GPU with CUDA:

```julia
# Check GPU availability
using CUDA
CUDA.functional()  # Should return true

# GPU will be used automatically by Lux
```

Without GPU, demos will run on CPU (slower but still functional).

## Troubleshooting

### Issue: Package installation fails

```julia
# Try updating registry
using Pkg
Pkg.Registry.update()
Pkg.instantiate()
```

### Issue: Out of memory

Some demos require significant memory. Solutions:
- Reduce network size (fewer layers/neurons)
- Reduce training iterations
- Close other applications
- Use smaller spatial grids

### Issue: Training is very slow

- Reduce `maxiters` parameter
- Use GPU acceleration
- Try simpler problems first

### Issue: Plots don't display

```julia
# Install plotting backend
using Pkg
Pkg.add("GR")  # or "PlotlyJS" for interactive plots

# Then retry the demo
```

## Customization

### Modify Network Architecture

In any demo, find the chain definition:

```julia
chain = Lux.Chain(
    Lux.Dense(2, 32, Lux.tanh),  # Input layer
    Lux.Dense(32, 32, Lux.tanh), # Hidden layer
    Lux.Dense(32, 1)             # Output layer
)
```

Try:
- More layers: Add more `Dense` layers
- Wider networks: Increase 32 → 64
- Different activations: `Lux.tanh` → `Lux.σ` or `Lux.relu`

### Adjust Training

```julia
# Change optimizer
res = Optimization.solve(prob, ADAM(0.01); maxiters = 2000)

# Try:
# - Different learning rate: 0.01 → 0.001
# - More iterations: 2000 → 5000
# - Different optimizer: ADAM → LBFGS()
```

### Export Results

```julia
# Save trained model
using BSON
BSON.@save "my_model.bson" res

# Load later
BSON.@load "my_model.bson" res
```

## Performance Tips

1. **Start small**: Begin with lower `maxiters` to verify code works
2. **Profile first**: Use `@time` to identify bottlenecks
3. **Batch mode**: Run multiple demos overnight
4. **Save checkpoints**: Save intermediate results
5. **Use GPU**: 5-10x speedup for larger problems

## Output Files

Each demo generates visualization files:
- `.png` - Static plots and heatmaps
- `.gif` - Animations (some demos)
- `.html` - Interactive plots (optional)

Location: Same directory as the script

## Getting Help

- **Documentation**: [NeuralPDE.jl Docs](https://docs.sciml.ai/NeuralPDE/stable/)
- **Forum**: [Julia Discourse](https://discourse.julialang.org/)
- **Chat**: [Julia Zulip](https://julialang.zulipchat.com/)
- **Issues**: [GitHub Issues](https://github.com/SciML/NeuralPDE.jl/issues)

## Next Steps

After completing demos:
1. Read the foundational papers (see README.md references)
2. Try modifying parameters and PDEs
3. Apply PINNs to your own problems
4. Contribute new demos back to the community!

## Citation

If you use these demos in your research or teaching:

```bibtex
@misc{pinnvisualodyssey2025,
  title={PINN Visual Odyssey: Comprehensive Demonstrations of Physics-Informed Neural Networks},
  author={AYUSHMIT},
  year={2025},
  url={https://github.com/AYUSHMIT/NeuralPDE.jl}
}
```

---

**Happy learning! 🚀**
