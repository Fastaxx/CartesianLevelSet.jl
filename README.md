# CartesianLevelSet

[![Build Status](https://github.com/Fastaxx/CartesianLevelSet.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/Fastaxx/CartesianLevelSet.jl/actions/workflows/CI.yml?query=branch%3Amain)

## Overview

CartesianLevelSet is a Julia package for working with level set geometry on Cartesian grids. It provides functionality for defining signed distance functions (SDFs), generating Cartesian grids, evaluating level sets, computing normals, and visualizing level sets and their intersections with grid cells.

## Installation

You can install CartesianLevelSet using the Julia package manager. In the Julia REPL, type `]` to enter the package manager mode, then run:

```julia
pkg> add CartesianLevelSet
```

## Usage

```julia
using CartesianLevelSet
using Plots

# Define a Cartesian grid
grid = CartesianGrid(20, 20, 1.0, 1.0)

# Generate a mesh from the grid
mesh = generate_mesh(grid)
domain =  ((-2.0, -2.0), (2.0, 2.0))

# Define a signed distance function (SDF) for a circle
circle_sdf_function = (x, y, _=0) -> sqrt(x^2 + y^2) - 1.0

# Create a SignedDistanceFunction object for the circle
circle_sdf = SignedDistanceFunction(circle_sdf_function, domain)
circle_sdf2 = SignedDistanceFunction((x, y, _=0) -> sqrt((x-0.5)^2 + (y-0.5)^2) - 1.0, domain)
union_circle = circle1 ⊔ circle2

# Evaluate the SDF at a specific point
x_test, y_test = 0.5, 0.5
sdf_value = evaluate_sdf(circle_sdf, x_test, y_test)

# Compute the normal at a specific point
nx, ny = compute_normal(circle_sdf, x_test, y_test)

# Evaluate the level set on the mesh
levelset_values = evaluate_levelset(circle_sdf, mesh)

# Get the cut cells where the level set intersects the grid
cut_cells = get_cut_cells(levelset_values)

# Get intersection points between the level set and the grid cells
intersection_points = get_intersection_points(levelset_values, cut_cells)

# Get midpoints of segments formed by intersected grid cells
midpoints = get_segment_midpoints(levelset_values, cut_cells, intersection_points)

# Plot the level set, cut cells, intersection points, and midpoints
plot_cut_cells_levelset_intersections_and_midpoints(levelset_values, cut_cells, intersection_points, midpoints)
```

## TODO
- Compute Curvature (Hessian)
- Sdf -> Sdf(x,t) : Map t + Velocity
- Driver for VOFI/CartesianGeometry
- Docs
- Notebooks

## Contributing

If you find any bugs or have suggestions for improvements, please open an issue on the GitHub repository.

## License

CartesianLevelSet is licensed under the MIT License. See the LICENSE file for more information.
