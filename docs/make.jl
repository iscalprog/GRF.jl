using GRF
using Documenter

DocMeta.setdocmeta!(GRF, :DocTestSetup, :(using GRF); recursive=true)

makedocs(;
    modules=[GRF],
    authors="António Saragga Seabra",
    repo="https://github.com/ASaragga/GRF.jl/blob/{commit}{path}#{line}",
    sitename="GRF.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://ASaragga.github.io/GRF.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/ASaragga/GRF.jl",
)
