using TextHeatmaps
using XAIBase

using Test
using ReferenceTests

input = 42
val = output = [1 6; 2 5; 3 4]
text = [["Test", "Text", "Heatmap"], ["another", "dummy", "input"]]
output_selection = [CartesianIndex(1, 2), CartesianIndex(3, 4)] # irrelevant

@testset "Default pipelines" begin
    pipe = TextHeatmaps.default_pipeline(NormPooling())
    @test repr(pipe) == repr(NormPooling() |> ExtremaNormalization() |> Colormap(:batlow))
    pipe = TextHeatmaps.default_pipeline(SumPooling())
    @test repr(pipe) == repr(SumPooling() |> CenteredNormalization() |> Colormap(:berlin))

    attr = Attribution(val, input, output, output_selection, SumPooling())
    @test repr(TextHeatmaps.default_pipeline(attr)) == repr(pipe)
end

@testset "Unsigned pooling" begin
    attr = Attribution(val, input, output, output_selection, NormPooling())
    h = heatmap(attr, text)
    @test_reference "references/norm_pooling1.txt" repr("text/plain", h[1])
    @test_reference "references/norm_pooling2.txt" repr("text/plain", h[2])

    # Single samples can be passed a single text
    attr = Attribution(
        val[:, 1:1], input, output[:, 1:1], output_selection[1:1], NormPooling()
    )
    h = heatmap(attr, text[1])
    @test_reference "references/norm_pooling1.txt" repr("text/plain", only(h))
end

@testset "Signed pooling" begin
    attr = Attribution(val, input, output, output_selection, SumPooling())
    h = heatmap(attr, text)
    @test_reference "references/sum_pooling1.txt" repr("text/plain", h[1])
    @test_reference "references/sum_pooling2.txt" repr("text/plain", h[2])

    # Custom pipelines
    h = heatmap(attr, text, SumPooling() |> ExtremaNormalization() |> Colormap(:seismic))
    @test_reference "references/sum_pooling1_extrema.txt" repr("text/plain", h[1])
    @test_reference "references/sum_pooling2_extrema.txt" repr("text/plain", h[2])
end

@testset "Feature dimension" begin
    # Attributions of size (features, input length, batch dimension) are pooled over features
    val3 = cat(val, 2 * val; dims = 3)
    val3 = permutedims(val3, (3, 1, 2)) # features sum up to `3 * val`
    attr = Attribution(val3, input, output, output_selection, SumPooling())
    h = heatmap(attr, text)
    @test_reference "references/sum_pooling1.txt" repr("text/plain", h[1])
    @test_reference "references/sum_pooling2.txt" repr("text/plain", h[2])
end

struct DummyAnalyzer <: AbstractXAIMethod end
function XAIBase.call_analyzer(input, ::DummyAnalyzer, ::AbstractOutputSelector; kwargs...)
    return Attribution(input, input, output, output_selection, SumPooling())
end

@testset "Analyzers" begin
    h = heatmap(val, DummyAnalyzer(), text)
    @test_reference "references/sum_pooling1.txt" repr("text/plain", h[1])
    @test_reference "references/sum_pooling2.txt" repr("text/plain", h[2])
end

@testset "Error handling" begin
    attr = Attribution(val, input, output, output_selection, SumPooling())
    @test_throws ArgumentError heatmap(attr, text[1:1])
    attr = Attribution(rand(2, 2, 3, 2), input, output, output_selection, SumPooling())
    @test_throws ArgumentError heatmap(attr, text)
end
