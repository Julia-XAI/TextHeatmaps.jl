# Getting started
Let's assume you put the following text into a sentiment analysis model:
```@example 1;
text = "I loved the concert but not the opening act"
tokens = split(text)
```

The model returns a vector of sentiment scores for each token,
where positive values indicate positive sentiment
and negative values indicate negative sentiment:
```@example 1;
val = [0.1, 2.5, 0.0, 0.3, -0.6, -1.4, 0.0, 0.1, -0.1]
nothing #hide
```

To visualize the sentiment scores, we can use the `heatmap` function:
```@example 1
using TextHeatmaps

heatmap(val, tokens)
```

## Custom heatmapping pipelines

TextHeatmaps internally applies a sequence of transforms in what we call a [`Pipeline`](@ref).
Since `val` contains a single value per token,
the default pipeline just normalizes the values and applies a colormap:
```@example 1
pipe = CenteredNormalization() |> Colormap(:berlin)
```

We can apply this pipeline by passing it to `heatmap`:

```@example 1
heatmap(val, tokens, pipe)
```

In the following subsections, we will explain and modify this pipeline step by step.
We start with [attribution pooling](@ref docs-heatmap-pooling),
an optional step that reduces attributions with several values per token to a single value.

### [Attribution pooling](@id docs-heatmap-pooling)

Attributions often contain several features for each token,
for example one value for each entry of a word embedding.
Following the convention *(features, input length, batch dimension)*,
such an attribution is a matrix with one column for each token:

```@example 1
x = [0.5 * val'; 0.3 * val'; 0.2 * val']
size(x)
```

These features need to be reduced to a single scalar value for each token,
which is later mapped onto a colormap.

For this purpose, pipelines use the [attribution pooling functions](@ref api-pooling)
from [XAIBase.jl](https://github.com/Julia-XAI/XAIBase.jl).
Let's compare the two most commonly used ones.
`SumPooling` reduces features by taking their sum,
whereas `NormPooling` takes their norm:

```@example 1
pipe = SumPooling() |> CenteredNormalization() |> Colormap(:berlin)
heatmap(x, tokens, pipe)
```

```@example 1
pipe = NormPooling() |> ExtremaNormalization() |> Colormap(:batlow)
heatmap(x, tokens, pipe)
```

`NormPooling` returns non-negative values, which no longer distinguish positive from negative sentiment.
Which pooling function is appropriate depends on the method that computed the attribution.

Our vector `val` holds a single value per token and therefore needs no pooling,
which is why the default pipeline above has no pooling step.

### [Normalization](@id docs-heatmap-normalization)

To map values onto a colormap, we first need to normalize all values to the range $[0,1]$.

For this purpose, pipelines use the [normalization functions](@ref api-normalization) from XAIBase.jl:

* `ExtremaNormalization`: normalize to the minimum and maximum value of the array
* `CenteredNormalization`: normalize to the maximum absolute value of the array.
    Values of zero will be mapped to the center of the colormap.

Depending on the colormap, one of these normalizations may be more suitable than the other.
The default colormap for signed values, the diverging `:berlin`, is centered around zero,
making `CenteredNormalization` a good choice:

```@example 1
pipe = CenteredNormalization() |> Colormap(:berlin)
heatmap(val, tokens, pipe)
```

With a diverging colormap, `ExtremaNormalization` should be avoided:
Even though the token "concert" has a positive sentiment score of `0.3`,
it is colored in blue:
```@example 1
pipe = ExtremaNormalization() |> Colormap(:berlin)
heatmap(val, tokens, pipe)
```

However, for the default colormap for unsigned values, the sequential `:batlow`,
which is not centered around zero,
`ExtremaNormalization` leads to a heatmap with higher contrast.

```@example 1
pipe = CenteredNormalization() |> Colormap(:batlow)
heatmap(val, tokens, pipe)
```

```@example 1
pipe = ExtremaNormalization() |> Colormap(:batlow)
heatmap(val, tokens, pipe)
```

We strongly suggest to only use sequential colormaps with `ExtremaNormalization`
and diverging colormaps with `CenteredNormalization`.
As seen above, TextHeatmaps warns when a pipeline pairs a normalization
with a colormap that ColorSchemes.jl describes as the other kind.

### Colormaps
The [`Colormap`](@ref) transform applies colormaps from
[ColorSchemes.jl](https://juliagraphics.github.io/ColorSchemes.jl/stable/basics/),
which can be selected by their name:
```@example 1
pipe = CenteredNormalization() |> Colormap(:seismic)
heatmap(val, tokens, pipe)
```

Custom colormaps can be passed alongside a name:
```@example 1
using ColorSchemes
pipe = CenteredNormalization() |> Colormap(:reversed_seismic, reverse(ColorSchemes.seismic))
heatmap(val, tokens, pipe)
```

## Batches
To heatmap a batch of texts, pass a vector containing vectors of tokens.
Arrays then contain the batch dimension as their last dimension.
A vector of heatmaps is returned:

```@example 1
texts = [split("what a great concert"), split("the opening act dragged")]
vals = [0.1 -0.1; 0.2 -0.2; 2.0 -0.1; 0.4 -0.8]

heatmaps = heatmap(vals, texts)
heatmaps[1]
```

```@example 1
heatmaps[2]
```

By default, each sample is normalized individually.
Even though its scores are small, the second heatmap uses the full range of colors.
To make heatmaps comparable within a batch,
`BatchedNormalization` normalizes all samples to a shared value range:

```@example 1
pipe = BatchedNormalization(CenteredNormalization()) |> Colormap(:berlin)
heatmaps = heatmap(vals, texts, pipe)
heatmaps[1]
```

```@example 1
heatmaps[2]
```

## Heatmapping attributions
`Attribution`s computed by XAI methods from the [Julia-XAI ecosystem](https://github.com/Julia-XAI)
contain the attribution pooling function `attr.pooling` that matches the method.
Calling `heatmap(attr, texts)` selects the default pipeline for this pooling function
(see [`TextHeatmaps.default_pipeline`](@ref)):
unsigned pooling functions like `NormPooling` use `ExtremaNormalization` and the sequential `:batlow`,
signed pooling functions like `SumPooling` use `CenteredNormalization` and the diverging `:berlin`.

## Terminal support
In the context of this documentation page and notebooks, heatmaps are rendered using HTML.
TextHeatmaps.jl also supports rendering heatmaps in the terminal.

Here we use the `print` function to force Documenter.jl to render the heatmap as raw text:
```@example 1
heatmap(val, tokens) |> print
```
