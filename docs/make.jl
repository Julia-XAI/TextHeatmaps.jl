using TextHeatmaps
using Documenter

DocMeta.setdocmeta!(TextHeatmaps, :DocTestSetup, :(using TextHeatmaps); recursive=true)

makedocs(;
    modules=[TextHeatmaps],
    authors="Adrian Hill <gh@adrianhill.de>",
    repo="https://github.com/Julia-XAI/TextHeatmaps.jl/blob/{commit}{path}#{line}",
    sitename="TextHeatmaps.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://Julia-XAI.github.io/TextHeatmaps.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=["Home" => "index.md", "Getting started" => "example.md"],
)

deploydocs(; repo="github.com/Julia-XAI/TextHeatmaps.jl", devbranch="main")
