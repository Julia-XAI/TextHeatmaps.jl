```@meta
CurrentModule = TextHeatmaps
```

# TextHeatmaps.jl

Documentation for [TextHeatmaps.jl](https://github.com/Julia-XAI/TextHeatmaps.jl).

## Installation
To install this package and its dependencies, open the Julia REPL and run

```julia-repl
]add TextHeatmaps
```

## API

```@docs
heatmap
default_pipeline
```

### Pipelines
Transforms are composed into pipelines using `|>`.
[`Pipeline`](@ref) and [`AbstractTransform`](@ref) are defined in XAIBase.jl
and re-exported by TextHeatmaps:
```@docs
Pipeline
AbstractTransform
TextHeatmaps.apply
```

```@meta
CurrentModule = XAIBase
```

### [Attribution pooling](@id api-pooling)
Pipelines reduce features using the attribution pooling functions from
[XAIBase.jl](https://github.com/Julia-XAI/XAIBase.jl),
which are re-exported by TextHeatmaps:
```@docs
NormPooling
SumPooling
MaxPooling
SumAbsPooling
AbsSumPooling
MaxAbsPooling
SquaredNormPooling
SignedNoPooling
UnsignedNoPooling
```

Pooling functions are subtypes of:
```@docs
AbstractPooling
UnsignedPooling
SignedPooling
```

and can be called using
```@docs
pool
```

### [Normalization](@id api-normalization)
Before applying a colormap, pipelines normalize values onto the unit interval
using the normalization functions from XAIBase.jl,
which are re-exported by TextHeatmaps:
```@docs
ExtremaNormalization
CenteredNormalization
BatchedNormalization
AbstractNormalization
XAIBase.normalize
normalization_bounds
default_normalization
```

### Batches
Heatmapping pipelines are applied to batches of type `XAIBase.Batch`.
By default, transforms are applied to each sample individually:
```@docs
XAIBase.Batch
XAIBase.eachsample
XAIBase.mapsamples
```

```@meta
CurrentModule = TextHeatmaps
```

### Colormaps
Turn numerical arrays into arrays of colors by applying colormaps:
```@docs
Colormap
```
