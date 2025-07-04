const DEFAULT_COLORSCHEME = :seismic
const DEFAULT_RANGESCALE = :centered
const DEFAULT_REDUCE = :sum

"""
    heatmap(values::AbstractArray, words)

Create a heatmap of words where the background color of each word is determined by its corresponding value.
Arguments `values` and `words` (and optionally `colors`) must have the same size.

## Keyword arguments
- `colorscheme::Union{ColorScheme,Symbol}`: color scheme from ColorSchemes.jl.
  Defaults to `ColorSchemes.seismic`.
- `rangescale::Symbol`: selects how the color channel reduced heatmap is normalized
  before the color scheme is applied. Can be either `:extrema` or `:centered`.
  Defaults to `:centered` for use with the default color scheme `seismic`.
"""
function heatmap(
    val::AbstractArray{<:Real}, words::AbstractArray{<:AbstractString}; kwargs...
)
    return TextHeatmap(val, words; kwargs...)
end

# Defining a `TextHeatmap` struct allows us to dispatch `Base.show` based on MIME types,
# such that we can show the heatmap both in the terminal and as HTML output in notebooks.

struct TextHeatmap{
    V<:AbstractArray{<:Real},W<:AbstractArray{<:AbstractString},C<:AbstractArray{<:RGB}
}
    val::V
    words::W
    colors::C
    function TextHeatmap(val, words, colors)
        if size(words) != size(val) || size(words) != size(colors)
            throw(ArgumentError("Sizes of values, words and colors don't match"))
        end
        colors = convert.(RGB, colors)
        return new{typeof(val),typeof(words),typeof(colors)}(val, words, colors)
    end
end

function TextHeatmap(
    val,
    words;
    colorscheme::Union{ColorScheme,Symbol}=DEFAULT_COLORSCHEME,
    rangescale=DEFAULT_RANGESCALE,
)
    if size(val) != size(words)
        throw(ArgumentError("Sizes of values and words don't match"))
    end
    colorscheme = get_colorscheme(colorscheme)
    colors = get(colorscheme, val, rangescale)
    return TextHeatmap(val, words, colors)
end

get_colorscheme(c::ColorScheme) = c
get_colorscheme(s::Symbol)::ColorScheme = colorschemes[s]

#==================#
# Show in terminal #
#==================#

Base.show(io::IO, h::TextHeatmap) = print_heatmap(io, h)

function print_heatmap(io::IO, h::TextHeatmap)
    for (word, color) in zip(h.words, h.colors)
        print(io, set_crayon(color), word)
        print(io, Crayon(; reset=true), " ")
    end
end

set_crayon(c::Colorant) = set_crayon(convert(RGB{N0f8}, c))
function set_crayon(bg::RGB{N0f8})
    background = get_color_indices(bg)
    foreground = is_background_bright(bg) ? :black : :white
    return Crayon(; background=background, foreground=foreground)
end

get_color_indices(c::RGB{N0f8}) = (c.r.i, c.g.i, c.b.i)

is_background_bright(bg::RGB) = luma(bg) > 0.5
luma(c::RGB) = 0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b # using BT. 709 coefficients

#==================#
# Show HTML output #
#==================#

# Used e.g. in Pluto notebooks
function Base.show(io::IO, ::MIME"text/html", h::TextHeatmap)
    # wrap lines and break on whitespace
    div_style = "display: flex; flex-wrap: wrap; gap: 5px 0px; align-items: flex-start;"
    print(io, """<div id="heatmap" style="$div_style">""")
    for (word, color) in zip(h.words, h.colors)
        bg = hex(color)
        fg = is_background_bright(color) ? "black" : "white"
        word_style = "background-color: #$bg; color: $fg; padding: 0.1em 0.3em;"
        print(io, """<heatmap-word style="$word_style">$word</heatmap-word>""")
    end
    print(io, "</div>")
end
