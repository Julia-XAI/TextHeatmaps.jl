using TextHeatmaps
using XAIBase
using ColorSchemes

using Test
using ReferenceTests

words = ["Test", "TextHeatmaps"]
val = [4.2, -1.0]

seismic = ColorSchemes.seismic
cmin = get(seismic, 0) # blue
cmax = get(seismic, 1) # red

@testset "Default pipeline" begin
    h = heatmap(val, words)
    @test h.colors[1] ≈ get(ColorSchemes.berlin, 1)
    @test_reference "references/berlin_centered.txt" repr("text/plain", h)
    @test_reference "references/berlin_centered_html.txt" repr("text/html", h)

    # Scalar values need no pooling, so the default pipeline drops the identity pooling
    pipe = CenteredNormalization() |> Colormap(:berlin)
    @test repr(TextHeatmaps.DEFAULT_PIPELINE) == repr(pipe)
    @test heatmap(val, words, pipe).colors == h.colors

    # An explicit identity pooling is a no-op on scalar values
    pooled = SignedNoPooling() |> CenteredNormalization() |> Colormap(:berlin)
    @test heatmap(val, words, pooled).colors == h.colors
end

@testset "Normalization" begin
    h = heatmap(val, words, CenteredNormalization() |> Colormap(:seismic))
    @test h.colors[1] ≈ cmax
    @test h.colors[2] != cmin
    @test_reference "references/seismic_centered.txt" repr("text/plain", h)
    @test_reference "references/seismic_centered_html.txt" repr("text/html", h)

    h = heatmap(val, words, ExtremaNormalization() |> Colormap(:seismic))
    @test h.colors[1] ≈ cmax
    @test h.colors[2] ≈ cmin
    @test_reference "references/seismic_extrema.txt" repr("text/plain", h)
end

@testset "Colormaps" begin
    h = heatmap(val, words, CenteredNormalization() |> Colormap(:inferno))
    @test_reference "references/inferno_centered.txt" repr("text/plain", h)
    h = heatmap(val, words, ExtremaNormalization() |> Colormap(:inferno))
    @test_reference "references/inferno_extrema.txt" repr("text/plain", h)

    # Custom colormaps
    h = heatmap(
        val, words, ExtremaNormalization() |> Colormap(:custom, ColorSchemes.inferno)
    )
    @test_reference "references/inferno_extrema.txt" repr("text/plain", h)

    @test Colormap() == Colormap(:batlow)
    @test repr(Colormap(:inferno)) == "Colormap(:inferno)"
end

@testset "Colormap and normalization pairing" begin
    default_colormap = TextHeatmaps.default_colormap
    @test default_colormap(ExtremaNormalization()) == Colormap(:batlow)
    @test default_colormap(CenteredNormalization()) == Colormap(:berlin)
    @test default_colormap(BatchedNormalization(CenteredNormalization())) ==
        Colormap(:berlin)

    # Matching and unknown kinds of colormaps don't warn
    @test_logs ExtremaNormalization() |> Colormap(:batlow)
    @test_logs CenteredNormalization() |> Colormap(:berlin)
    @test_logs ExtremaNormalization() |> Colormap(:jet)
    @test_logs NormPooling() |> Colormap(:berlin)

    # Mismatched kinds of colormaps warn
    @test_logs (:warn, r"diverging colormap") CenteredNormalization() |> Colormap()
    @test_logs (:warn, r"sequential colormap") ExtremaNormalization() |> Colormap(:berlin)
    @test_logs (:warn, r"diverging colormap") SumPooling() |>
        BatchedNormalization(CenteredNormalization()) |>
        Colormap(:viridis)
end

@testset "Attribution pooling" begin
    # Features are the first dimension and are pooled: the columns of `x` sum up to `val`
    x = [4.0 1.0; 0.2 -2.0]
    pipe = SumPooling() |> CenteredNormalization() |> Colormap(:seismic)
    h = heatmap(x, words, pipe)
    @test_reference "references/seismic_centered.txt" repr("text/plain", h)

    # Arrays without a feature dimension are pooled as if they had a single feature
    h = heatmap(val, words, pipe)
    @test_reference "references/seismic_centered.txt" repr("text/plain", h)
    h1 = heatmap(val, words, NormPooling() |> ExtremaNormalization() |> Colormap(:seismic))
    h2 = heatmap(abs.(val), words, ExtremaNormalization() |> Colormap(:seismic))
    @test h1.colors == h2.colors

    # The default pipeline has no pooling and rejects a feature dimension
    @test_throws ArgumentError heatmap(x, words)
end

@testset "Batches" begin
    texts = [words, ["another", "input"]]
    vals = [4.2 -0.5; -1.0 2.1]
    hs = heatmap(vals, texts)
    @test length(hs) == 2
    @test_reference "references/berlin_centered.txt" repr("text/plain", hs[1])

    # By default, samples are normalized individually
    pipe = CenteredNormalization() |> Colormap(:seismic)
    hs = heatmap(vals, texts, pipe)
    @test_reference "references/seismic_centered.txt" repr("text/plain", hs[1])
    @test hs[2].colors == heatmap(vals[:, 2], texts[2], pipe).colors
    @test hs[2].colors[2] ≈ cmax

    # Batched normalization uses a shared value range
    pipe = BatchedNormalization(CenteredNormalization()) |> Colormap(:seismic)
    hs_batched = heatmap(vals, texts, pipe)
    @test hs_batched[1].colors == hs[1].colors
    @test hs_batched[2].colors != hs[2].colors
    @test hs_batched[2].colors[2] ≈ get(seismic, 0.75)

    # Batches with a feature dimension
    xs = cat([4.0 1.0; 0.2 -2.0], [-1.0 2.0; 0.5 0.1]; dims = 3)
    pipe = SumPooling() |> CenteredNormalization() |> Colormap(:seismic)
    @test [h.colors for h in heatmap(xs, texts, pipe)] == [h.colors for h in hs]
end

@testset "Error handling" begin
    # Mismatching number of words
    @test_throws ArgumentError heatmap(val, ["Test", "Text", "Heatmaps"])
    @test_throws ArgumentError heatmap([4.2 -0.5; -1.0 2.1], [words, ["too", "many", "words"]])
    # Mismatching number of texts
    @test_throws ArgumentError heatmap([4.2 -0.5; -1.0 2.1], [words])
    # Unsupported array dimensions
    @test_throws ArgumentError heatmap(rand(2, 2, 2), words)
    @test_throws ArgumentError heatmap(rand(2), [words])
    @test_throws ArgumentError heatmap(rand(2, 2, 2, 1), [words])
    # Pipelines have to return colors
    @test_throws ArgumentError heatmap(val, words, CenteredNormalization())
    # Inner constructor
    @test_throws ArgumentError TextHeatmaps.TextHeatmap(words, [cmin, cmax, cmax])
end
