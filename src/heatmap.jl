const InputDimensionError = ArgumentError(
    "heatmapping assumes the convention (features, input length, batch dimension) for input array dimensions, where the feature dimension is optional.
    Please reshape your input to match this format if your model doesn't adhere to this convention.",
)

"""
    heatmap(x::AbstractArray, tokens)
    heatmap(x::AbstractArray, tokens, pipeline)

Visualize an array as a heatmap of tokens,
where the background color of each token is determined by its corresponding value.

If `tokens` is a vector of strings, `x` is a single sample
of size `(input_length,)` or `(features, input_length)` and a single heatmap is returned.
If `tokens` is a vector containing vectors of strings, one for each sample, `x` is a batch
of size `(input_length, batchsize)` or `(features, input_length, batchsize)`
and a vector of heatmaps is returned.

Unless a `pipeline` is passed, `x` is assumed to contain a single signed value for each token,
which is visualized using `CenteredNormalization` and the diverging `:berlin`.
"""
function heatmap(
        x::AbstractArray{<:Real},
        tokens::AbstractVector{<:AbstractString},
        pipe::AbstractTransform,
    )
    ndims(x) in (1, 2) || throw(InputDimensionError)
    return TextHeatmap(tokens, apply(pipe, x))
end
function heatmap(
        x::AbstractArray{<:Real},
        texts::AbstractVector{<:AbstractVector{<:AbstractString}},
        pipe::AbstractTransform,
    )
    ndims(x) in (2, 3) || throw(InputDimensionError)
    xs = Batch(x)
    batchsize = length(eachsample(xs))
    batchsize != length(texts) && throw(
        ArgumentError("Batchsize $batchsize doesn't match number of texts $(length(texts))."),
    )
    return unwrap(apply(pipe, xs), texts)
end
# The default pipeline expects a single value per token and applies no pooling.
# Attributions with a feature dimension need a pipeline with a pooling function.
const FeatureDimensionError = ArgumentError(
    "the default pipeline expects a single value per token, i.e. an array without a feature dimension.
    To reduce a feature dimension, pass a pipeline with a pooling function, e.g. `SumPooling() |> CenteredNormalization() |> Colormap()`.",
)

function heatmap(x::AbstractArray{<:Real}, tokens::AbstractVector{<:AbstractString})
    ndims(x) == 1 || throw(FeatureDimensionError)
    return heatmap(x, tokens, DEFAULT_PIPELINE)
end
function heatmap(
        x::AbstractArray{<:Real}, texts::AbstractVector{<:AbstractVector{<:AbstractString}}
    )
    ndims(x) == 2 || throw(FeatureDimensionError)
    return heatmap(x, texts, DEFAULT_PIPELINE)
end

# Return heatmaps as a vector of text heatmaps
function unwrap(colors::Batch, texts::AbstractVector{<:AbstractVector{<:AbstractString}})
    return [TextHeatmap(tokens, copy(c)) for (tokens, c) in zip(texts, eachsample(colors))]
end

##================#
# XAIBase support #
##================#

"""
    heatmap(attr::Attribution, text)
    heatmap(attr::Attribution, text, pipeline)

Visualize `Attribution` from XAIBase as text heatmaps.
Assumes the convention `(input_length, batchsize)` or `(features, input_length, batchsize)` for `attr.val`.
`text` should be a vector containing vectors of tokens, one for each sample in the batch.
For a batch containing a single sample, `text` can also be a vector of tokens.

Unless a `pipeline` is passed, this will use the default heatmapping pipeline
for the attribution pooling function `attr.pooling`, see [`default_pipeline`](@ref).
"""
function heatmap(
        attr::Attribution,
        texts::AbstractVector{<:AbstractVector{<:AbstractString}},
        pipe::AbstractTransform,
    )
    return heatmap(attr.val, texts, pipe)
end
function heatmap(attr::Attribution, tokens::AbstractVector{<:AbstractString}, pipe::AbstractTransform)
    return heatmap(attr, [tokens], pipe)
end
function heatmap(attr::Attribution, texts::AbstractVector{<:AbstractVector{<:AbstractString}})
    return heatmap(attr, texts, default_pipeline(attr))
end
function heatmap(attr::Attribution, tokens::AbstractVector{<:AbstractString})
    return heatmap(attr, tokens, default_pipeline(attr))
end

"""
    heatmap(input, analyzer::AbstractXAIMethod, text)

Compute an `Attribution` for a given `input` using the XAI method `analyzer` and visualize it
as text heatmaps.
This will use the default heatmapping pipeline for the attribution pooling function `attr.pooling`.
"""
function heatmap(input, analyzer::AbstractXAIMethod, text, analyze_args...; analyze_kwargs...)
    attr = analyze(input, analyzer, analyze_args...; analyze_kwargs...)
    return heatmap(attr, text)
end
