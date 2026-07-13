using TextHeatmaps
using ColorSchemes
using Colors
using FixedPointNumbers

using Test
using ReferenceTests

@testset "TextHeatmaps.jl" begin
    @testset verbose = true "Linting" begin
        @info "Running linting tests..."
        include("linting.jl")
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
