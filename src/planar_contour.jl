# This file contains code modified from Polyhedra.jl
# See `LICENSE` for its MIT license.

function getsemihull(ps::Vector{PT}, sign_sense, counterclockwise, yray = nothing) where PT
    hull = PT[]
    if length(ps) == 0
        return hull
    end
    prev = sign_sense == 1 ? first(ps) : last(ps)
    cur = prev
    for j in (sign_sense == 1 ? (2:length(ps)) : ((length(ps)-1):-1:1))
        while prev != cur && counterclockwise(cur - prev, ps[j] - prev) >= 0
            cur = prev
            pop!(hull)
            if !isempty(hull)
                prev = last(hull)
            end
        end
        if yray !== nothing && counterclockwise(ps[j] - cur, yray) >= 0
            break
        else
            push!(hull, cur)
            prev = cur
            cur = ps[j]
        end
    end
    push!(hull, cur)
    hull
end

function planar_contour(p::Polyhedron)
    removevredundancy!(p)
    if hasallrays(p)
        error("Rays not supported yet in the 2D plotting recipe.")
    end
    ps = collect(points(p))
    if isempty(ps)
        error("Plotting empty polyhedron is not supported.")
    end
    sort!(ps, by = x -> x[1])
    counterclockwise(p1, p2) = dot(cross([p1[1:2]; 0], [p2[1:2]; 0]), [0, 0, 1])
    top = getsemihull(ps,  1, counterclockwise)
    bot = getsemihull(ps, -1, counterclockwise)
    if !isempty(top) && !isempty(bot)
        @assert top[end] == bot[1]
        pop!(top)
    end
    if !isempty(bot) && !isempty(top)
        @assert bot[end] == top[1]
        pop!(bot)
    end
    hull = [top; bot]
    push!(hull, hull[1])  # ensure shape is closed
    return hull
end
