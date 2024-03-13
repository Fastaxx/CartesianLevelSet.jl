using CartesianLevelSet
using Plots
Plots.default(show = true)
# Définition d'une grille cartésienne 2D
grid = CartesianGrid((10, 10), (2.0, 2.0)) # Crée une grille 2D de 10x10 avec un espacement de 1.0
mesh = generate_mesh(grid, false) # Génère un maillage collocated
x, y = mesh # Décompose le maillage en ses composantes x et y
domain = ((minimum(x), minimum(y)), (maximum(x), maximum(y))) # Définit le domaine de la fonction SDF

# Définition d'une SDF
function circle(x, y, _ = 0) # Le 3e argument est obligatoire pour VOFI 
    return sqrt((x-1)^2 + (y-1)^2) - 0.5
end

cercle = SignedDistanceFunction(circle, domain) # Crée une instance de SignedDistanceFunction pour le cercle
rectangle = SignedDistanceFunction((x, y, _ = 0) -> max(abs(x-0.5)-0.5, abs(y-0.5)-0.5), domain) # Crée une instance de SignedDistanceFunction pour le rectangle

# Évalue la SDF à un point spécifique
x_test, y_test = 0.5, 0.5
println("SDF au point ($x_test, $y_test): ", evaluate_sdf(cercle, x_test, y_test))

# Calcule l'union des deux SDF
union_sdf = cercle ⊔ rectangle

# Calcule l'intersection des deux SDF
intersection_sdf = cercle ⊓ rectangle

# Calcule la différence entre les deux SDF
difference_sdf = cercle ⊖ rectangle

# Calcule le complément de la SDF du cercle
complement_sdf = complement(cercle)

# Tracer les SDF
plot_sdf_2d(cercle)
readline()

plot_sdf_2d(rectangle)
readline()

plot_sdf_2d(union_sdf)
readline()

plot_sdf_2d(intersection_sdf)
readline()

plot_sdf_2d(difference_sdf)
readline()

plot_sdf_2d(complement_sdf)
readline()

# Calcule la normale à la SDF du cercle à un point spécifique
nx, ny = compute_normal(cercle, 0.5, 0.5)
println("Normale au point (0.5, 0.5): ($nx, $ny)")

# Calcule le volume de la grille
volume = calculate_volume(grid)
println("Volume : $volume")

# Evalue la SDF sur le maillage
values = evaluate_levelset(cercle.sdf_function, mesh)

# Calcule les cellules coupées par la SDF
cut_cells = get_cut_cells(evaluate_levelset(cercle.sdf_function, mesh))
println("Cellules coupées: $cut_cells")

# Calcule les points d'intersection de la SDF
intersection_points = get_intersection_points(values, cut_cells)

# Calcule les points médians des segments d'intersection
midpoints = get_segment_midpoints(values, cut_cells, intersection_points)

# Trace les cellules coupées, les points d'intersection et les points médians
plot_cut_cells_levelset_intersections_and_midpoints(cut_cells, values, intersection_points, midpoints)
readline()


"""


mesh = generate_mesh(grid, false) # Génère un maillage 
x, y = mesh

# Définir une fonction SDF simple en 2D (un cercle) : LE 3e Arguments EST OBLIGATORI POUR VOFI METTRE _=0


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
"""