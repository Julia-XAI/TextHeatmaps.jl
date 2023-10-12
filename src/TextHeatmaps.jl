module TextHeatmaps

using Crayons: Crayon
using FixedPointNumbers: N0f8
using Colors: Colorant, RGB, hex
using ColorSchemes: ColorScheme, colorschemes, get, seismic

include("heatmap.jl")

export heatmap

end # module
