using TextHeatmaps
using ColorSchemes
using Colors
using FixedPointNumbers

using Test
using ReferenceTests
using Aqua

@testset "TextHeatmaps.jl" begin
    @testset "Aqua.jl" begin
        @info "Running Aqua.jl's auto quality assurance tests. These might print warnings from dependencies."
        Aqua.test_all(TextHeatmaps)
    end
    @testset "Heatmap" begin
        words = ["Test", "TextHeatmaps"]
        val = [4.2, -1.0]

        cs = TextHeatmaps.seismic
        cmin = get(cs, 0) # red
        cmax = get(cs, 1) # blue

        # Test default ColorScheme seismic
        h = heatmap(val, words)
        @test h.colors[1] ≈ cmax
        @test h.colors[2] != cmin
        @test_reference "references/seismic_centered.txt" repr("text/plain", h)
        @test_reference "references/seismic_centered_html.txt" repr("text/html", h)

        h = heatmap(val, words; rangescale=:extrema)
        @test h.colors[1] ≈ cmax
        @test h.colors[2] ≈ cmin
        @test_reference "references/seismic_extrema.txt" repr("text/plain", h)

        # Test other colorschemes
        cs = ColorSchemes.inferno
        h = heatmap(val, words; cs=cs, rangescale=:centered)
        @test_reference "references/inferno_centered.txt" repr("text/plain", h)
        h = heatmap(val, words; cs=cs, rangescale=:extrema)
        @test_reference "references/inferno_extrema.txt" repr("text/plain", h)

        # Test errors
        @test_throws ArgumentError heatmap(val, ["Test", "Text", "Heatmaps"])
        # Test inner constructor
        @test_throws ArgumentError TextHeatmaps.TextHeatmap(val, words, [cmin, cmax, cmax])
    end
end
