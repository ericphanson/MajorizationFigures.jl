module MajorizationFigures

using CDDLib
using Colors
using Combinatorics
using LinearAlgebra: cross, dot
using MajorizationExtrema
using Polyhedra
using Random
using TikzPictures

export figure
export TV_Ball

permpoly(v::AbstractVector) =
    polyhedron(vrep(collect(permutations(v))), CDDLib.Library(:exact))

TV_Ball(q, ϵ) = Polyhedra.translate(permpoly([ϵ, -ϵ, 0]), q)

include("planar_contour.jl")
include("rand.jl")
include("tikz_draw.jl")
include("sort.jl")

end
