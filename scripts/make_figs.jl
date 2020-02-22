using MajorizationFigures, Polyhedra
using MajorizationFigures: subsimplex
using MajorizationExtrema: majmin
using Combinatorics: permutations
using TikzPictures

macro save(name)
    name_str = string(name)
    quote
        path = joinpath(@__DIR__, "figs", $name_str)
        save(PDF(path), $name)
        save(SVG(path), $name)
    end
end

q = [21 // 100, 24 // 100, 55 // 100]
ϵ = 1 // 10
Bq = TV_Ball(q, ϵ)
Es = subsimplex.(permutations(1:3))
q_majmin = majmin(q, ϵ)

q_colored = ColoredObject(q, nothing, "black")
q_majmin_colored = ColoredObject(q_majmin, nothing, "white")
Bq_colored = ColoredObject(Bq, nothing, "opacity=.33,blue")
Es_colored = add_colors(Es)

Bq_pieces = [Bq ∩ s for s in Es]
Bq_pieces_colored = copy_colors.(Bq_pieces, Es_colored)
Bq_pieces_sorted = MajorizationFigures.sort_ordered.(Bq_pieces; rev=true)
Bq_pieces_sorted_colored = copy_colors.(Bq_pieces_sorted, Es_colored)

SCALE = 2.2
fig1_Es = figure(Es_colored...; scale = SCALE)
@save fig1_Es

fig2_sorted = figure(Es_colored[1]; scale = SCALE)
@save fig2_sorted

fig3_qball = figure(q_colored, Bq_colored; scale = SCALE)
@save fig3_qball

fig4_qball_pieces = figure(q_colored, Bq_pieces_colored...; scale = SCALE)
@save fig4_qball_pieces

q_sorted_colored = copy_colors(sort(q;rev=true), q_colored)
fig5_qball_pieces_sorted = figure(Bq_pieces_sorted_colored..., q_sorted_colored; scale = SCALE)
@save fig5_qball_pieces_sorted

q_majmin_sorted_colored = copy_colors(sort(q_majmin;rev=true), q_majmin_colored)
fig6_qball_pieces_sorted_majmin = figure(Bq_pieces_sorted_colored..., q_majmin_sorted_colored, q_sorted_colored; scale = SCALE)
@save fig6_qball_pieces_sorted_majmin

fig7_qball_pieces_majmin = figure(Bq_pieces_colored..., q_colored, q_majmin_colored; scale = SCALE)
@save fig7_qball_pieces_majmin


nonempty_inds = findall(i -> !isempty(Bq_pieces[i]), eachindex(Bq_pieces))
collect(permutations(1:3))[nonempty_inds]
