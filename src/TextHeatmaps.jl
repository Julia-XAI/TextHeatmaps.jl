module TextHeatmaps

using Crayons: Crayon
using FixedPointNumbers: N0f8
using Colors: Colorant, RGB, hex
using ColorSchemes: ColorScheme, colorschemes, get
using XAIBase: Attribution, AbstractXAIMethod, analyze
using XAIBase: AbstractTransform, Pipeline
using XAIBase: Batch, eachsample, mapsamples
using XAIBase: AbstractPooling, UnsignedPooling, SignedPooling, pool
using XAIBase: SumPooling, MaxPooling, SignedNoPooling, UnsignedNoPooling
using XAIBase: SumAbsPooling, AbsSumPooling, MaxAbsPooling, NormPooling, SquaredNormPooling
using XAIBase: AbstractNormalization, ExtremaNormalization, CenteredNormalization
using XAIBase: BatchedNormalization
using XAIBase: normalize, default_normalization

include("transforms.jl")
export Colormap

# Re-export transforms, pipelines, attribution pooling and normalization functions from XAIBase
export AbstractTransform, Pipeline
export SumPooling, MaxPooling, SignedNoPooling, UnsignedNoPooling
export SumAbsPooling, AbsSumPooling, MaxAbsPooling, NormPooling, SquaredNormPooling
export ExtremaNormalization, CenteredNormalization, BatchedNormalization

include("pipeline.jl")

include("textheatmap.jl")
include("heatmap.jl")
export heatmap

end # module
