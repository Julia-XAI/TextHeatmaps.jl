using TextHeatmaps
using ColorSchemes
using Colors
using FixedPointNumbers

using Test
using ReferenceTests
using Aqua
using JuliaFormatter

@testset "TextHeatmaps.jl" begin
    @testset "Aqua.jl" begin
        @info "Running Aqua.jl's auto quality assurance tests. These might print warnings from dependencies."
        Aqua.test_all(TextHeatmaps)
    end
    @testset "JuliaFormatter.jl" begin
        @info "Running JuliaFormatter's code formatting tests."
        @test format(TextHeatmaps; verbose=false, overwrite=false)
    end
    @testset "Heatmap" begin
        @info "Testing heatmaps..."
        include("test_heatmap.jl")
    end
    @testset "XAIBase Explanations" begin
        @info "Testing heatmaps on XAIBase explanations..."
        include("test_xaibase.jl")
    end
end
