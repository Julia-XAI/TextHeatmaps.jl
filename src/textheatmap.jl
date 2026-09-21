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

# StyledStrings renders the background color and reset codes, and only emits ANSI
# escapes when the output stream declares color support (`get(io, :color, false)`).
function print_heatmap(io::IO, h::TextHeatmap)
    for (word, color) in zip(h.words, h.colors)
        print(io, styled"{$(word_face(color)):$word} ")
    end
    return
end

word_face(c::Colorant) = word_face(convert(RGB{N0f8}, c))
function word_face(bg::RGB{N0f8})
    foreground = is_background_bright(bg) ? :black : :white
    background = SimpleColor((r = bg.r.i, g = bg.g.i, b = bg.b.i))
    return Face(; foreground, background)
end

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
