# MajorizationFigures

[![Build Status](https://github.com/ericphanson/MajorizationFigures.jl/workflows/CI/badge.svg)](https://github.com/ericphanson/MajorizationFigures.jl/actions)
[![Coverage](https://codecov.io/gh/ericphanson/MajorizationFigures.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/ericphanson/MajorizationFigures.jl)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://ericphanson.github.io/MajorizationFigures.jl/dev)

Generate publication-quality pictures of points and polyhedra in the probability
simplex in ℝ³ via Tikz, by using Polyhedra.jl and TikzPictures.jl. This package
is mostly aimed at generating figures for my thesis.

There are a couple interesting polytopes in the probability simplex:

* The total variation distance ball around a probability vector
* The infinity-norm ball around a probability vector
* The set of probability vectors majorized by a given probability vector

This package depends on the unregistered package `MajorizationExtrema`.

![](scripts/figs/fig1_Es.svg)
![](scripts/figs/fig2_sorted.svg)
![](scripts/figs/fig3_qball.svg)
![](scripts/figs/fig4_qball_pieces.svg)
![](scripts/figs/fig5_qball_pieces_sorted.svg)
![](scripts/figs/fig6_qball_pieces_sorted_majmin.svg)
![](scripts/figs/fig7_qball_pieces_majmin.svg)
