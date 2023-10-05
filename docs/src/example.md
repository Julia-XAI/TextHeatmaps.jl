# Getting started
Let's assume you put the following text into a sentiment analysis model:
```@example 1;
text = "I loved the concert but not the opening act"
words = split(text)
```

The model returns a vector of sentiment scores for each word, 
where positive values indicate positive sentiment 
and negative values indicate negative sentiment:
```@example 1;
val = [0.1, 2.5, 0.0, 0.3, -0.6, -1.4, 0.0, 0.1, -0.1]
nothing #hide
```

To visualize the sentiment scores, we can use the `heatmap` function:
```@example 1
using TextHeatmaps

heatmap(val, words)
```

## Color schemes
We can use a custom color scheme from ColorSchemes.jl using the keyword argument cs:
```@example 1
using ColorSchemes
heatmap(val, words; cs=ColorSchemes.jet)
```
```@example 1
heatmap(val, words; cs=ColorSchemes.inferno)
```

## Mapping values onto the color scheme
To map values onto a color scheme, we first need to normalize all values to the range $[0,1]$.

For this purpose, two presets are available through the `rangescale` keyword argument:

* `:extrema`: normalize to the minimum and maximum value of the explanation
* `:centered`: normalize to the maximum absolute value of the explanation. 
    Values of zero will be mapped to the center of the color scheme.

Depending on the color scheme, one of these presets may be more suitable than the other. The default color scheme, `seismic`, is centered around zero, making `:centered` a good choice:

```@example 1
heatmap(val, words; rangescale=:centered)
```

With the `seismic` colorscheme, the `:extrema` rangescale should be avoided:
Even though the word "concert" has a positive sentiment score of `0.3`,
it is colored in blue:
```@example 1
heatmap(val, words; rangescale=:extrema)
```

However, for the `inferno` color scheme, which is not centered around zero, `:extrema` leads to a heatmap with higher contrast.

```@example 1
heatmap(val, words; cs=ColorSchemes.inferno, rangescale=:centered)
```

```@example 1
heatmap(val, words; cs=ColorSchemes.inferno, rangescale=:extrema)
```

## Terminal support
In the context of this documentation page and notebooks, heatmaps are rendered using HTML.
TextHeatmaps.jl also supports rendering heatmaps in the terminal.

Here we use the `print` function to force Documenter.jl to render the heatmap as raw text:
```@example 1
heatmap(val, words) |> print
```
