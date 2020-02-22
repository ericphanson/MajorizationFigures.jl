```@meta
CurrentModule = MajorizationFigures
```

# MajorizationFigures

```@example 1
using MajorizationFigures, Polyhedra
using MajorizationFigures: E
using MajorizationExtrema
using Combinatorics

q = [21 // 100, 24 // 100, 55 // 100]
ϵ = 1 // 10
Bq = TV_Ball(q, ϵ)
Es = E.(permutations(1:3))
figure(Es...)
```

```@example 1
polys = Polyhedron[]
push!(polys, E((1, 2, 3)))
append!(polys, sort(Bq; rev = true))
append!(polys, [Bq ∩ s for s in Es])
figure(q, polys...)
```

```@example 1
figure(q, majmin(q, ϵ), polys...)
```

```@example 1
figure(q, sort(majmin(q, ϵ); rev = true), polys...)
```

```@example 1
figure(q)
```

# Reference
```@index
```

```@autodocs
Modules = [MajorizationFigures]
```
