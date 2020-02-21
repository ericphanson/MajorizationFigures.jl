function Random.rand(rng::AbstractRNG, S::Random.SamplerTrivial{<:Polyhedron{Rational{T}}}) where {T}
    P = S.self
    removevredundancy!(P)
    verts = points(vrep(P))
    d = length(verts)
    dist = randprobvec(rng, d, T(10_000)) # a little ad-hoc
    result = zero(first(verts))
    for (i,v) in enumerate(verts)
        result += v * dist[i]
    end
    return result
end
