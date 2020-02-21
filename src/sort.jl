"""
    E(perm) -> Polyedron

Returns the polyhedron consisting of the subset of the probability
simplex that is sorted according to the permutation `perm`, in the
sense that for `q ∈ E(perm)`, `issorted(q[perm]; rev=true) == true`.
"""
function E(perm)
    d = length(perm)
    region = permpoly([i == 1 for i = 1:d]) # the probability simplex
    for i = 1:d-1
        v = [j == perm[i] ? -1 : j == perm[i+1] ? 1 : 0 for j = 1:d]
        region = region ∩ HalfSpace(v, 0)
    end
    removevredundancy!(region)
    return region
end


function sort_ordered(p::Polyhedron; kwargs...)
    isempty(p) && return p
    q = polyhedron(vrep(sort.(points(vrep(p)); kwargs...)), library(p))
    hrep(q)
    q
end

"""
    Base.sort(p::Polyhedron; kwargs...) -> Vector{Polyhedron}

Returns a collection of polyhedra whose union gives the set equal
to sorting each element in `p` elementwise.
"""
function Base.sort(p::Polyhedron; kwargs...)
    d = fulldim(p)
    Es = E.(permutations(1:d))
    [sort_ordered(p ∩ s; kwargs...) for s in Es]
end
