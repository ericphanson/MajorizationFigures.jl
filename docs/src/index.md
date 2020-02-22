```@meta
CurrentModule = MajorizationFigures
```

# MajorizationFigures

## Examples

```@example 1
using MajorizationFigures, Polyhedra
using MajorizationFigures: subsimplex
using MajorizationExtrema: majmin
using Combinatorics: permutations

q = [21 // 100, 24 // 100, 55 // 100]
ϵ = 1 // 10
Bq = TV_Ball(q, ϵ)
Es = subsimplex.(permutations(1:3))

Bq_colored = ColoredObject(Bq, nothing, "opacity=.33,blue")
Es_colored = add_colors(Es)

Bq_pieces = [Bq ∩ s for s in Es]
Bq_pieces_colored = copy_colors.(Bq_pieces, Es_colored)
Bq_pieces_sorted = MajorizationFigures.sort_ordered.(Bq_pieces; rev=true)
Bq_pieces_sorted_colored = copy_colors.(Bq_pieces_sorted, Es_colored)

figure(Es_colored...)
```

```@example 1
figure(Es_colored[1])
```

```@example 1
q_colored = ColoredObject(q, nothing, "black")
figure(q_colored, Bq_colored)
```

```@example 1
figure(q_colored, Bq_pieces_colored...)
```

```@example 1
q_sorted_colored = copy_colors(sort(q;rev=true), q_colored)
figure(Bq_pieces_sorted_colored..., q_sorted_colored)
```

```@example 1
q_majmin = majmin(q, ϵ)
q_majmin_colored = ColoredObject(q_majmin, nothing, "white")
q_majmin_sorted_colored = copy_colors(sort(q_majmin;rev=true), q_majmin_colored)
figure(Bq_pieces_sorted_colored..., q_majmin_sorted_colored, q_sorted_colored)
```

```@example 1
figure(Bq_pieces_colored..., q_colored, q_majmin_colored)
```

## Reference

```@index
```

### Drawing

```@docs
MajorizationFigures.figure
MajorizationFigures.draw
MajorizationFigures.ColoredObject
MajorizationFigures.add_colors
MajorizationFigures.copy_colors
```

### Sorting

```@docs
MajorizationFigures.sortpoly
MajorizationFigures.subsimplex
```

### Other

```@docs
MajorizationFigures.TV_Ball
Random.rand(::AbstractRNG,::Random.SamplerTrivial{<:Polyhedron{Rational{T}}}) where {T}
```
