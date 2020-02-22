const SIMPLEX_COLOR = RGB{Colors.N0f8}(229 / 255, 169 / 255, 171 / 255)

struct Simplex end

"""
    struct ColoredObject{V,T<:Union{Colors.Colorant,Nothing}}
        object::V
        color::T
        color_name::String
    end

An object to draw along with the color to draw it in.
Set `color` to a `Colors.Colorant` to add the color to the
LaTeX picture via `\\definecolor` with a name given by
the `color_name` field. Otherwise, set `color` to `nothing`
and use `color_name` directly as the color in the LaTeX code.
"""
struct ColoredObject{V,T<:Union{Colors.Colorant,Nothing}}
    object::V
    color::T
    color_name::String
end

colored_simplex() = ColoredObject(Simplex(), SIMPLEX_COLOR, "SIMPLEX_COLOR")

function print_tex(io::IO, v::AbstractVector)
    print(io, "(")
    d = length(v)
    for i = 1:d-1
        print_tex(io, v[i])
        print(io, ",")
    end
    print_tex(io, v[d])
    print(io, ")")
end

function print_tex(io::IO, r::Rational)
    if r.den > 10_000
        print_tex(io, float(r))
    else
        print(io, r.num, "/", r.den)
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
function print_tex(io::IO, c::Tuple{String,Colors.Colorant})
    name, color = c
    rgb_64 = _rgb_for_printing(color)
    print(
        io,
        "\\definecolor{$name}{rgb}{$(rgb_64[1]), $(rgb_64[2]), $(rgb_64[3])}",
    )
end


"""
    draw(io::IO, preamble_io::IO, object, color_name::AbstactString) -> Nothing

Prints the Tikz code needed to draw the object to `io`, possibly also printing
to `preamble_io` to define commands necessary for the drawing.
"""
function draw end

function draw(
    io::IO,
    preamble_io::IO,
    v::AbstractVector{<:Rational},
    color_name,
)
    print(io, "\\draw[fill=$color_name]")
    print_tex(io, v)
    print(io, "circle(\\rad cm);\n")
end

function draw(io::IO, preamble_io::IO, ::Simplex, color_name)
    print(
        io,
        """
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
""",
    )
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

# Define the color if necessary and then dispach to `draw`
function draw_colored(io::IO, preamble_io::IO, c::ColoredObject)
    if c.color !== nothing
        print_tex(preamble_io, (c.color_name, c.color))
    end
    draw(io, preamble_io, c.object, c.color_name)
end

"""
    figure(objects...; scale = 4) -> TikzPicture

Creates a `TikzPicture` by drawing each object to the scene,
in order. If the objects are [`ColoredObject`](@ref), their colors
are used. Otherwise, the objects are all assigned colors
(via [`add_colors`](@ref)). The keyword argument `scale` is
passed to the final `TikzPicture`.

Each object in `objects` must have a [`draw`](@ref) method.
"""
function figure end

function figure(objects::ColoredObject...; scale = 4)
    io = IOBuffer()
    preamble_io = IOBuffer()
    print(
        preamble_io,
        raw"""
\usepackage{tikz-3dplot}
\usetikzlibrary{backgrounds}
\tdplotsetmaincoords{70}{130}
""",
    )

    draw_colored(io, preamble_io, colored_simplex())

    for obj in objects
        draw_colored(io, preamble_io, obj)
    end
    str = String(take!(io))
    preamble = String(take!(preamble_io))

    TikzPicture(
        str,
        options = "tdplot_main_coords,scale=$scale",
        preamble = preamble,
    )
end

function figure(objects...; kwargs...)
    colored_objects = add_colors(objects)
    figure(colored_objects...; kwargs...)
end


"""
    add_colors(objects) -> Vector{<:ColoredObject}

Returns a vector of [`ColoredObject`](@ref) wrappers of
the objects, where the colors are chosen by
`Colors.distinguishable_colors`.
"""
function add_colors(objects)
    n = length(objects)
    cs = Colors.distinguishable_colors(n + 1, SIMPLEX_COLOR)
    popfirst!(cs) # remove SIMPLEX_COLOR
    return [ColoredObject(objects[i], cs[i], "c$i") for i in eachindex(objects)]
end


"""
    copy_colors(to, from::ColoredObject) -> ColoredObject

Creates a [`ColoredObject`](@ref) wrapper of `to` by
copying the colors from `from`.
"""
function copy_colors(to, from::ColoredObject)
    ColoredObject(to, from.color, from.color_name)
end
