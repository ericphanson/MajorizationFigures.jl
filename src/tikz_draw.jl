const SIMPLEX_COLOR = RGB{Colors.N0f8}(229/255, 169/255, 171/255)

struct Simplex end

struct Colored{V, T}
    object::V
    color::T
    color_name::String
end

colored_simplex() = Colored(Simplex(), SIMPLEX_COLOR, "SIMPLEX_COLOR")

function print_tex(io::IO, v::AbstractVector)
    print(io, "(")
    d = length(v)
    for i = 1:d-1
        print_tex(io, v[i])
        print(io, ",")
    end
    print_tex(io, v[d])
    print(io,")")
end

function print_tex(io::IO, r::Rational)
    if r.den > 10_000
        print_tex(io, float(r))
    else
        print(io,  r.num, "/", r.den)
    end
end

function print_tex(io::IO, r::AbstractFloat)
    @printf(io, "%.4f", r)
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

function draw(io::IO, preamble_io::IO, v::AbstractVector{<:Rational}, color_name)
    print(io,"\\draw[fill=$color_name]")
    print_tex(io, v)
    print(io, "circle(\\rad cm);\n")
end


function draw(io::IO, preamble_io::IO, ::Simplex, color_name)
    print(io, """
    \\def\\laxis{1.2}
    \\def\\ltriangle{1}
    \\def\\rad{.02}

    %%% axes
    \\draw [->] (0,0,0) -- (\\laxis,0,0) node [below] {\$x\$};
    \\draw [->] (0,0,0) -- (0,\\laxis,0) node [right] {\$y\$};
    \\draw [->] (0,0,0) -- (0,0,\\laxis) node [left] {\$z\$};

    % simplex
    \\filldraw [opacity=.8, $color_name] (\\ltriangle,0,0) -- (0,\\ltriangle,0)
    -- (0,0,\\ltriangle) -- cycle;
    """)
end

function draw(io::IO, preamble_io::IO, p::Polyhedron, color_name)
    isempty(p) && return
    print(io, "\\filldraw [opacity=.33, $color_name]\n")
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

function draw_colored(io::IO, preamble_io::IO, c::Colored)
    if c.color isa Colors.Colorant
        print_tex(preamble_io, (c.color_name, c.color))
    end
    draw(io, preamble_io, c.object, c.color_name)
end

function figure(args::Colored...; scale = 4)
    io = IOBuffer()
    preamble_io = IOBuffer()
    print(preamble_io, raw"""
    \usepackage{tikz-3dplot}
    \usetikzlibrary{backgrounds}
    \tdplotsetmaincoords{70}{130}
    """)

    draw_colored(io, preamble_io, colored_simplex())

    for arg in args
        draw_colored(io, preamble_io, arg)
    end
    str = String(take!(io))
    preamble = String(take!(preamble_io))

    TikzPicture(str,
        options="tdplot_main_coords,scale=$scale",
    preamble=preamble)
end

function add_colors(items)
    n = length(items)
    cs = Colors.distinguishable_colors(n+1, SIMPLEX_COLOR)
    popfirst!(cs) # remove SIMPLEX_COLOR
    return ( Colored(items[i], cs[i], "c$i") for i = eachindex(items) )
end

function figure(args...; kwargs...)
    colored_args = add_colors(args)
    figure(colored_args...; kwargs...)
end

# function add_colors_grouped(groups)
#     indices = UnitRange{Int64}[]
#     flat = []
#     counter = 1
#     for g in groups
#         append!(flat, g)
#         push!(indices, counter:(counter += length(g)-1))
#         counter += 1
#     end
#     colored_flat = collect(add_colors(flat))
#     colored_groups = [ colored_flat[I] for I in indices ]
# end
