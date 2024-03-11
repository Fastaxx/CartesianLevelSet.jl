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

end # module