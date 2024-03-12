module CartesianLevelSet

using Plots
Plots.default(show = true)
using ForwardDiff

export CartesianGrid, SignedDistanceFunction
export circle_sdf, sphere_sdf, evaluate_sdf, ⊔, ⊓, ⊖, complement, compute_normal
export calculate_volume, generate_mesh
export evaluate_levelset, get_cut_cells, get_intersection_points, get_segment_midpoints
export plot_cut_cells_levelset_intersections_and_midpoints

include("mesh.jl")
include("geometry.jl")
include("plot.jl")
include("body.jl")

grid = CartesianGrid((20, 20, 20) , (1.,1., 1.))
mesh = generate_mesh(grid, false) # Génère un maillage
x,y,z = mesh
domain = ((minimum(x), minimum(y)), (maximum(x), maximum(y)), (maximum(z), maximum(z)))
circle = SignedDistanceFunction((x, y, z) -> sqrt((x-0.5)^2+(y-0.5)^2+(z-0.5)^2)-0.25, domain)
values = evaluate_levelset(circle.sdf_function, mesh)
@show values
cut_cells = get_cut_cells(values)
@show cut_cells
intersection_points = get_intersection_points(values, cut_cells)
@show intersection_points
midpoints = get_segment_midpoints(values, cut_cells, intersection_points)
@show midpoints

grid = CartesianGrid((20, 20) , (1.,1.))
mesh = generate_mesh(grid, false) # Génère un maillage
x,y = mesh
domain = ((minimum(x), minimum(y)), (maximum(x), maximum(y)))
circle = SignedDistanceFunction((x, y, _=0) -> sqrt((x-0.5)^2+(y-0.5)^2)-0.25, domain)
values = evaluate_levelset(circle.sdf_function, mesh)
@show values
cut_cells = get_cut_cells(values)
@show cut_cells
intersection_points = get_intersection_points(values, cut_cells)
@show intersection_points
midpoints = get_segment_midpoints(values, cut_cells, intersection_points)
@show midpoints
"""
grid = CartesianGrid((20, ) , (1.,))
mesh = generate_mesh(grid, false) # Génère un maillage
x = mesh
domain = (minimum(x), minimum(y))
circle = SignedDistanceFunction((x, _=0) -> sqrt((x-0.5)^2)-0.25, domain)
values = evaluate_levelset(circle.sdf_function, mesh)
@show values
cut_cells = get_cut_cells(values)
@show cut_cells
intersection_points = get_intersection_points(values, cut_cells)
@show intersection_points
midpoints = get_segment_midpoints(values, cut_cells, intersection_points)
@show midpoints
"""
end # module