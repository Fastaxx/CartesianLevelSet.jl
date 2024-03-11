using CartesianLevelSet
using Test

@testset "CartesianLevelSet.jl" begin
    
grid = CartesianGrid(20, 20 , 1., 1.)
mesh = generate_mesh(grid, false) # Génère un maillage 
x, y = mesh

# Définir une fonction SDF simple en 2D (un cercle) : LE 3e Arguments EST OBLIGATORI POUR VOFI METTRE _=0
function circle_sdf(x, y, _ = 0)
    return sqrt(x^2 + y^2) - 1.0
end

domain = ((minimum(x), minimum(y)), (maximum(x), maximum(y)))
circle = SignedDistanceFunction((x, y, _=0) -> sqrt(x^2+y^2) - 1.0 , domain)

values = evaluate_levelset(circle.sdf_function, mesh)

levelset = HyperSphere(0.25, (0.5, 0.5))
V, bary = integrate(Tuple{0}, circle.sdf_function, mesh, T, nan)
As = integrate(Tuple{1}, circle.sdf_function, mesh, T, zero)
Ws = integrate(Tuple{0}, circle.sdf_function, mesh, T, zero, bary)
Bs = integrate(Tuple{1}, circle.sdf_function, mesh, T, zero, bary)
@show Bs
@show V

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
