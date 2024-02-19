module TextHeatmaps

using Crayons: Crayon
using FixedPointNumbers: N0f8
using Colors: Colorant, RGB, hex
using ColorSchemes: ColorScheme, colorschemes, get, seismic
using Requires: @require

include("heatmap.jl")

if !isdefined(Base, :get_extension)
    using Requires
    function __init__()
        @require XAIBase = "9b48221d-a747-4c1b-9860-46a1d8ba24a7" include(
            "../ext/TextHeatmapsXAIBaseExt.jl"
        )
    end
end

export heatmap

end # module
