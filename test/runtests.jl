using TextHeatmaps
using Test
using Aqua

@testset "TextHeatmaps.jl" begin
    @testset "Aqua.jl" begin
        @info "Running Aqua.jl's auto quality assurance tests. These might print warnings from dependencies."
        Aqua.test_all(TextHeatmaps)
    end
end
