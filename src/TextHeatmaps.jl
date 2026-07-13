module TextHeatmaps

using Crayons: Crayon
using FixedPointNumbers: N0f8
using Colors: Colorant, RGB, hex
using ColorSchemes: ColorScheme, colorschemes, get
using XAIBase: Explanation

include("heatmap.jl")
include("xaibase.jl")

export heatmap

end # module
