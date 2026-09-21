# Pipelines of transforms are defined and composed in XAIBase.jl,
# TextHeatmaps defines how they are applied.

# Batches are passed through the pipeline as a whole,
# such that each transform can act on the entire batch.
apply(pipe::Pipeline, x::AbstractArray) = apply_sequentially(pipe, x)
apply(pipe::Pipeline, xs::Batch) = apply_sequentially(pipe, xs)

function apply_sequentially(pipe::Pipeline, x)
    for t in pipe.transforms
        x = apply(t, x)
    end
    return x
end

##============================#
# Presets for XAIBase support #
##============================#

"""
    default_pipeline(attr::Attribution)
    default_pipeline(pooling::AbstractPooling)

Return the default heatmapping pipeline for an `Attribution` from XAIBase.jl,
chosen based on its attribution pooling function `attr.pooling`:
- `UnsignedPooling` (e.g. `NormPooling`) uses `ExtremaNormalization` and the sequential `:batlow`
- `SignedPooling` (e.g. `SumPooling`) uses `CenteredNormalization` and the diverging `:berlin`
"""
default_pipeline(attr::Attribution) = default_pipeline(attr.pooling)
function default_pipeline(pooling::AbstractPooling)
    return pooling |> default_normalization(pooling) |> default_colormap(pooling)
end

default_colormap(::UnsignedPooling) = Colormap(:batlow)
default_colormap(::SignedPooling) = Colormap(:berlin)

# Arrays are assumed to contain a single signed value per word
const DEFAULT_PIPELINE = default_pipeline(SignedNoPooling())
