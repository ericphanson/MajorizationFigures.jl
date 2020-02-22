using Combinatorics
using MajorizationFigures
using MajorizationFigures: subsimplex
using Polyhedra
using Test

@testset "rand" begin
    q = [21 // 100, 24 // 100, 55 // 100]
    ϵ = 1 // 10
    Bq = TV_Ball(q, ϵ)
    for _ = 1:10
        r = rand(Bq)
        @test r ∈ Bq
    end
end

@testset "subsimplex" begin
    d = 3
    for π in permutations(1:d)
        current_subsimplex = subsimplex(π)

        q = rand(current_subsimplex)
        @test issorted(q[π]; rev = true)

        for q in points(vrep(current_subsimplex))
            @test issorted(q[π]; rev = true)
        end
    end
end
