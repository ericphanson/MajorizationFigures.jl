"""
    subsimplex(perm) -> Polyhedron

Returns the polyhedron consisting of the subset of the probability
simplex that is sorted according to the permutation `perm`, in the
sense that for `q ∈ subsimplex(perm)`, `issorted(q[perm]; rev=true) == true`.
"""
function subsimplex(perm)
    d = length(perm)
    region = permpoly([i == 1 for i = 1:d]) # the probability simplex
    for i = 1:d-1
        v = [j == perm[i] ? -1 : j == perm[i+1] ? 1 : 0 for j = 1:d]
        region = region ∩ HalfSpace(v, 0)
    end
    removevredundancy!(region)
    return region
end


function sort_ordered(p::Polyhedron; rev = true)
    isempty(p) && return p
    q = polyhedron(vrep(sort.(points(vrep(p)); rev = true)), library(p))
    hrep(q)
    q
end

"""
    sortpoly(p::Polyhedron; rev = true) -> Vector{Polyhedron}

Returns a collection of polyhedra whose union gives the set equal
to sorting each element in `p` elementwise. Defaults to sorting
from most to least (set `rev = false` to match the default
behavior of `Base.sort`).
"""
function sortpoly(p::Polyhedron; rev = true)
    d = fulldim(p)
    subsimplices = subsimplex.(permutations(1:d))
    [sort_ordered(p ∩ s; rev = true) for s in subsimplices]
end
