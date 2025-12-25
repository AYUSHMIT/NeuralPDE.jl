#!/usr/bin/env julia

"""
Test Runner for PINN Visual Odyssey Demos

This script helps test individual demos or categories.
Usage:
    julia test_runner.jl [demo_number or category]

Examples:
    julia test_runner.jl 01        # Run demo 01
    julia test_runner.jl getting   # Run all getting started demos
    julia test_runner.jl all       # Run all demos (long!)
"""

using Pkg

# Activate the demo environment
Pkg.activate(".")

println("="^70)
println("PINN Visual Odyssey - Demo Test Runner")
println("="^70)

# Get command line arguments
args = ARGS
if isempty(args)
    println("\nUsage: julia test_runner.jl [demo_number or category]")
    println("\nExamples:")
    println("  julia test_runner.jl 01        # Run demo 01")
    println("  julia test_runner.jl getting   # Run all getting started demos")
    println("  julia test_runner.jl classical # Run all classical PDE demos")
    println("  julia test_runner.jl all       # Run all demos")
    exit(0)
end

target = args[1]

# Map categories to directories
categories = Dict(
    "getting" => "01_getting_started",
    "classical" => "02_classical_pdes",
    "training" => "03_training_dynamics",
    "complex" => "04_complex_physics",
    "inverse" => "05_inverse_problems",
    "advanced" => "06_advanced_architectures",
    "highdim" => "07_high_dimensional",
    "realworld" => "08_real_world_applications",
    "interactive" => "09_interactive_playground"
)

function run_demo(filepath)
    println("\n" * "="^70)
    println("Running: $(filepath)")
    println("="^70)
    try
        include(filepath)
        println("\n✓ Demo completed successfully!")
        return true
    catch e
        println("\n✗ Demo failed with error:")
        println(e)
        return false
    end
end

function run_category(category_dir)
    files = sort([joinpath(category_dir, f) for f in readdir(category_dir) if endswith(f, ".jl")])
    println("\nFound $(length(files)) demos in $(category_dir)")
    
    success_count = 0
    for file in files
        if run_demo(file)
            success_count += 1
        end
    end
    
    println("\n" * "="^70)
    println("Results: $(success_count)/$(length(files)) demos passed")
    println("="^70)
end

# Determine what to run
if target == "all"
    println("\nRunning ALL demos (this will take a while)...")
    for (_, category_dir) in sort(categories)
        run_category(category_dir)
    end
elseif haskey(categories, target)
    run_category(categories[target])
elseif occursin(r"^\d+$", target)
    # Find demo by number
    demo_num = lpad(target, 2, '0')
    found = false
    for (_, category_dir) in categories
        demo_file = joinpath(category_dir, "$(demo_num)_*.jl")
        matches = glob(demo_file)
        if !isempty(matches)
            run_demo(matches[1])
            found = true
            break
        end
    end
    if !found
        println("Demo $(demo_num) not found")
    end
else
    println("Unknown target: $(target)")
    println("Use 'getting', 'classical', 'training', 'complex', 'inverse',")
    println("'advanced', 'highdim', 'realworld', 'interactive', or 'all'")
end
