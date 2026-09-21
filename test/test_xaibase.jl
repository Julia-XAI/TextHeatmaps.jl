using TextHeatmaps
using XAIBase

using Test
using ReferenceTests

# StyledStrings only emits ANSI escapes for color-capable streams,
# so render the terminal output with a color context.
isdefined(@__MODULE__, :textplain) ||
    (textplain(h) = repr("text/plain", h; context = (:color => true)))

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

    # Identity poolings are no-ops on text attributions and are dropped from the pipeline
    pipe = TextHeatmaps.default_pipeline(SignedNoPooling())
    @test repr(pipe) == repr(CenteredNormalization() |> Colormap(:berlin))
    pipe = TextHeatmaps.default_pipeline(UnsignedNoPooling())
    @test repr(pipe) == repr(ExtremaNormalization() |> Colormap(:batlow))
end

@testset "Unsigned pooling" begin
    attr = Attribution(val, input, output, output_selection, NormPooling())
    h = heatmap(attr, text)
    @test_reference "references/norm_pooling1.txt" textplain(h[1])
    @test_reference "references/norm_pooling2.txt" textplain(h[2])

    # Single samples can be passed a single text
    attr = Attribution(
        val[:, 1:1], input, output[:, 1:1], output_selection[1:1], NormPooling()
    )
    h = heatmap(attr, text[1])
    @test_reference "references/norm_pooling1.txt" textplain(only(h))
end

@testset "Signed pooling" begin
    attr = Attribution(val, input, output, output_selection, SumPooling())
    h = heatmap(attr, text)
    @test_reference "references/sum_pooling1.txt" textplain(h[1])
    @test_reference "references/sum_pooling2.txt" textplain(h[2])

    # Custom pipelines
    h = heatmap(attr, text, SumPooling() |> ExtremaNormalization() |> Colormap(:seismic))
    @test_reference "references/sum_pooling1_extrema.txt" textplain(h[1])
    @test_reference "references/sum_pooling2_extrema.txt" textplain(h[2])
end

@testset "Feature dimension" begin
    # Attributions of size (features, input length, batch dimension) are pooled over features
    val3 = cat(val, 2 * val; dims = 3)
    val3 = permutedims(val3, (3, 1, 2)) # features sum up to `3 * val`
    attr = Attribution(val3, input, output, output_selection, SumPooling())
    h = heatmap(attr, text)
    @test_reference "references/sum_pooling1.txt" textplain(h[1])
    @test_reference "references/sum_pooling2.txt" textplain(h[2])
end

struct DummyAnalyzer <: AbstractXAIMethod end
function XAIBase.call_analyzer(input, ::DummyAnalyzer, ::AbstractOutputSelector; kwargs...)
    return Attribution(input, input, output, output_selection, SumPooling())
end

@testset "Analyzers" begin
    h = heatmap(val, DummyAnalyzer(), text)
    @test_reference "references/sum_pooling1.txt" textplain(h[1])
    @test_reference "references/sum_pooling2.txt" textplain(h[2])
end

@testset "Error handling" begin
    attr = Attribution(val, input, output, output_selection, SumPooling())
    @test_throws ArgumentError heatmap(attr, text[1:1])
    attr = Attribution(rand(2, 2, 3, 2), input, output, output_selection, SumPooling())
    @test_throws ArgumentError heatmap(attr, text)
end
