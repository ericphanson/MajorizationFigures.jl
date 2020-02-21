module MajorizationFigures

using CDDLib
using Colors
using Combinatorics
using LinearAlgebra: cross, dot
using MajorizationExtrema
using Polyhedra
using Printf
using Random
using TikzPictures

export Colored
export figure
export TV_Ball

function permpoly(v::AbstractVector)
    if eltype(v) <: AbstractFloat
        lib = CDDLib.Library()
    else
        lib = CDDLib.Library(:exact)
    end
    polyhedron(vrep(collect(permutations(v))), lib)
end

function TV_Ball(q, ϵ)
    T = promote_type(eltype(q), typeof(ϵ))
    Polyhedra.translate(permpoly([T(ϵ), -T(ϵ), 0]), T.(q))
end

include("planar_contour.jl")
include("rand.jl")
include("tikz_draw.jl")
include("sort.jl")

end
