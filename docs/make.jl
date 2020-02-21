using MajorizationFigures
using Documenter

makedocs(;
    modules=[MajorizationFigures],
    authors="Eric P. Hanson",
    repo="https://github.com/ericphanson/MajorizationFigures.jl/blob/{commit}{path}#L{line}",
    sitename="MajorizationFigures.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://ericphanson.github.io/MajorizationFigures.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/ericphanson/MajorizationFigures.jl",
)
