using CartesianLevelSet
using Test

@testset "CartesianLevelSet.jl" begin
    grid = CartesianGrid(20, 20 , 1., 1.)
    mesh = generate_mesh(grid, false) # Génère un maillage 
    x, y = mesh
    
    # define level set
    const R = 0.25
    const a, b = 0.5, 0.5

    levelset = HyperSphere(R, (a, b))

    values = evaluate_levelset(levelset, mesh)

    cut_cells = get_cut_cells(values)
    @show cut_cells

    intersection_points = get_intersection_points(values, cut_cells)
    @show intersection_points

    midpoints = get_segment_midpoints(values, cut_cells, intersection_points)
    @show size(cut_cells)
    @show size(intersection_points)
    @show size(midpoints)
    @show midpoints

    plot_cut_cells_levelset_intersections_and_midpoints(cut_cells, values, intersection_points, midpoints)

end
