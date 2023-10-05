# TextHeatmaps

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://Julia-XAI.github.io/TextHeatmaps.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://Julia-XAI.github.io/TextHeatmaps.jl/dev/)
[![Build Status](https://github.com/Julia-XAI/TextHeatmaps.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/Julia-XAI/TextHeatmaps.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/Julia-XAI/TextHeatmaps.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/Julia-XAI/TextHeatmaps.jl)

TextHeatmaps.jl is a lightweight Julia package for visualization of numerical values associated with text.

## Installation
To install this package and its dependencies, open the Julia REPL and run

```julia-repl
]add TextHeatmaps
```

## Example
Assume you have the following values associated with words in a sentence:
```julia
text = "I loved the concert but not the opening act"
words = split(text)
val = [0.1, 2.5, 0.0, 0.3, -0.6, -1.4, 0.0, 0.1, -0.1]
```

These values could for example come from a sentiment analysis model.

Using the heatmap function, we can visualize the values:

![Heatmap in Julia-REPL][heatmap-repl]

This not only works in the REPL, but also as HTML output in notebooks and on websites:

![Heatmap in Pluto][heatmap-pluto]

The color scheme of the `heatmap` is customizable:

![Heatmap in Documenter][heatmap-settings]

For more information, refer to the [package documentation](https://Julia-XAI.github.io/TextHeatmaps.jl/stable/).

[heatmap-repl]: https://raw.githubusercontent.com/Julia-XAI/TextHeatmaps.jl/gh-pages/assets/heatmap_repl.png
[heatmap-pluto]: https://raw.githubusercontent.com/Julia-XAI/TextHeatmaps.jl/gh-pages/assets/heatmap_pluto.png
[heatmap-settings]: https://raw.githubusercontent.com/Julia-XAI/TextHeatmaps.jl/gh-pages/assets/heatmap_settings.png
