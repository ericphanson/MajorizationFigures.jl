const SIMPLEX_COLOR = RGB{Colors.N0f8}(229/255, 169/255, 171/255)

struct Simplex end

function print_tex(io::IO, v::AbstractVector{<:Rational})
    print(io, "(")
    d = length(v)
    for i = 1:d-1
        print(io, v[i].num, "/", v[i].den, ",")
    end
    print(io, v[d].num, "/", v[d].den, ")")
end

# https://github.com/KristofferC/PGFPlotsX.jl/blob/198565d2d1dc664322637058de233d13c6bcbdc5/src/requires.jl
function _rgb_for_printing(c::Colors.Colorant)
    rgb = convert(Colors.RGB{Float64}, c)
    # round colors since tikz cannot parse scientific notation, eg 1e-10
    round.((Colors.red(rgb), Colors.green(rgb), Colors.blue(rgb)); digits = 4)
end
function print_tex(io::IO, c::Tuple{String, Colors.Colorant})
    name, color = c
    rgb_64 = _rgb_for_printing(color)
    print(io, "\\definecolor{$name}{rgb}{$(rgb_64[1]), $(rgb_64[2]), $(rgb_64[3])}")
end


function draw(io::IO, preamble_io::IO, v::AbstractVector{<:Rational})
    print(io,"\\draw[fill=black]")
    print_tex(io, v)
    print(io, "circle(\\rad cm);\n")
end


function draw(io::IO, preamble_io::IO, ::Simplex)
    print(io, L"""
    \def\laxis{1.2}
    \def\ltriangle{1}
    \def\rad{.02}

    %%% axes
    \draw [->] (0,0,0) -- (\laxis,0,0) node [below] {$x$};
    \draw [->] (0,0,0) -- (0,\laxis,0) node [right] {$y$};
    \draw [->] (0,0,0) -- (0,0,\laxis) node [left] {$z$};

    % simplex
    \filldraw [opacity=.8,red!30] (\ltriangle,0,0) -- (0,\ltriangle,0)
    -- (0,0,\ltriangle) -- cycle;
    """)
end

function draw(io::IO, preamble_io::IO, p::Polyhedron, color = "blue")
    print(io, "\\filldraw [opacity=.33, $color]\n")
    ps = planar_contour(p)
    d = length(ps)
    print_tex(io, ps[1])
    print(io, " -- \n")
    for i = 2:d-1
        print_tex(io, ps[i])
        print(io, " -- \n")
    end
    print_tex(io, ps[d])
    print(io, ";\n")
end



function draw(io::IO, preamble_io::IO, Ps::Vector{<:Polyhedron})
    Ps = filter(!isempty, Ps)
    n = length(Ps)

    cs = Colors.distinguishable_colors(n+1, SIMPLEX_COLOR)
    popfirst!(cs) # remove SIMPLEX_COLOR
    for (i,c) in enumerate(cs)
        print_tex(preamble_io, ("c$i", c))
        println(preamble_io)
    end

    for (i, P) in enumerate(Ps)
        draw(io, preamble_io, P, "c$i")
    end
end

function figure(args...; scale = 4)
    io = IOBuffer()
    preamble_io = IOBuffer()
    print(preamble_io, raw"""
    \usepackage{tikz-3dplot}
    \usetikzlibrary{backgrounds}
    \tdplotsetmaincoords{70}{130}
    """)

    draw(io, preamble_io, Simplex())

    for arg in args
        draw(io, preamble_io, arg)
    end
    str = String(take!(io))
    preamble = String(take!(preamble_io))

    TikzPicture(str,
        options="tdplot_main_coords,scale=$scale",
    preamble=preamble)
end
