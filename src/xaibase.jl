using TextHeatmaps, XAIBase

struct HeatmapConfig
    colorscheme::Symbol
    reduce::Symbol
    rangescale::Symbol
end

const DEFAULT_HEATMAP_PRESET = HeatmapConfig(
    DEFAULT_COLORSCHEME, DEFAULT_REDUCE, DEFAULT_RANGESCALE
)

const HEATMAP_PRESETS = Dict{Symbol,HeatmapConfig}(
    :attribution => HeatmapConfig(:seismic, :sum, :centered),
    :sensitivity => HeatmapConfig(:grays, :norm, :extrema),
    :cam         => HeatmapConfig(:jet, :sum, :extrema),
)

# Select HeatmapConfig preset based on heatmapping style in Explanation
function get_heatmapping_config(heatmap::Symbol)
    return get(HEATMAP_PRESETS, heatmap, DEFAULT_HEATMAP_PRESET)
end

# Override HeatmapConfig preset with keyword arguments
function get_heatmapping_config(expl::Explanation; kwargs...)
    c = get_heatmapping_config(expl.heatmap)

    colorscheme = get(kwargs, :colorscheme, c.colorscheme)
    rangescale  = get(kwargs, :rangescale, c.rangescale)
    reduce      = get(kwargs, :reduce, c.reduce)
    return HeatmapConfig(colorscheme, reduce, rangescale)
end

"""
    heatmap(expl::Explanation, text)

Visualize `Explanation` from XAIBase as text heatmap.
Text should be a vector containing vectors of strings, one for each input in the batched explanation.

This will use the default heatmapping style for the given type of explanation.
Defaults can be overridden via keyword arguments.
"""
function TextHeatmaps.heatmap(
    expl::Explanation, texts::AbstractVector{<:AbstractVector{<:AbstractString}}; kwargs...
)
    ndims(expl.val) != 2 && throw(
        ArgumentError(
            "To heatmap text, `explanation.val` must be 2D array of shape `(input_length, batchsize)`. Got array of shape $(size(x)) instead.",
        ),
    )
    batchsize = size(expl.val, 2)
    textsize = length(texts)
    batchsize != textsize && throw(
        ArgumentError("Batchsize $batchsize doesn't match number of texts $textsize.")
    )

    c = get_heatmapping_config(expl; kwargs...)
    return [
        TextHeatmaps.heatmap(v, t; colorscheme=c.colorscheme, rangescale=c.rangescale) for
        (v, t) in zip(eachcol(expl.val), texts)
    ]
end

function TextHeatmaps.heatmap(
    expl::Explanation, text::AbstractVector{<:AbstractString}; kwargs...
)
    return heatmap(expl, [text]; kwargs...)
end
