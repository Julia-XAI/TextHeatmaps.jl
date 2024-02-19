module TextHeatmaps

using Crayons: Crayon
using FixedPointNumbers: N0f8
using Colors: Colorant, RGB, hex
using ColorSchemes: ColorScheme, colorschemes, get, seismic
using XAIBase: Explanation, AbstractXAIMethod, analyze

include("heatmap.jl")
include("xaibase.jl")

export heatmap

end # module
