# Defining a `TextHeatmap` struct allows us to dispatch `Base.show` based on MIME types,
# such that we can show the heatmap both in the terminal and as HTML output in notebooks.

struct TextHeatmap{W <: AbstractVector{<:AbstractString}, C <: AbstractVector{<:RGB}}
    words::W
    colors::C
    function TextHeatmap(words::AbstractVector{<:AbstractString}, colors::AbstractVector)
        eltype(colors) <: Colorant || throw(
            ArgumentError(
                "heatmapping pipeline returned values of type $(eltype(colors)) instead of colors. Add a `Colormap` to the pipeline.",
            ),
        )
        if size(words) != size(colors)
            throw(ArgumentError("Sizes of words and colors don't match"))
        end
        colors = convert.(RGB, colors)
        return new{typeof(words), typeof(colors)}(words, colors)
    end
end

#==================#
# Show in terminal #
#==================#

Base.show(io::IO, h::TextHeatmap) = print_heatmap(io, h)

function print_heatmap(io::IO, h::TextHeatmap)
    for (word, color) in zip(h.words, h.colors)
        print(io, set_crayon(color), word)
        print(io, Crayon(; reset = true), " ")
    end
    return
end

set_crayon(c::Colorant) = set_crayon(convert(RGB{N0f8}, c))
function set_crayon(bg::RGB{N0f8})
    background = get_color_indices(bg)
    foreground = is_background_bright(bg) ? :black : :white
    return Crayon(; background = background, foreground = foreground)
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
    return print(io, "</div>")
end
