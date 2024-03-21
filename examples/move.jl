using CartesianLevelSet
using ForwardDiff
using Plots
Plots.default(show=true)

struct SignedDistanceFunction{T}
    sdf_function::Function  # La fonction qui calcule la SDF
    transform::Function  # Transformation de coordonnées
    domain::T  # Domaine de définition de la fonction
    is_moving::Bool  # Indique si la géométrie est en mouvement
end
# Définir une fonction pour évaluer la SDF à un point donné
function evaluate_sdf(sdf::SignedDistanceFunction, t, x...)
    if sdf.is_moving
        transformed_coordinates = sdf.transform(x..., t)
    else
        transformed_coordinates = x
    end
    return sdf.sdf_function(transformed_coordinates...)
end

# Définir une fonction SDF simple en 2D (un cercle)
function circle_sdf(x, y)
    return sqrt(x^2 + y^2) - 1.0
end

# Définir une fonction SDF simple en 3D (une sphère)
function sphere_sdf(x, y, z)
    return sqrt(x^2 + y^2 + z^2) - 1.0
end

function square_sdf(x::Float64, y::Float64, side_length::Float64)
    dx = abs(x) - side_length / 2
    dy = abs(y) - side_length / 2
    return max(dx, dy)
end

# Définir une fonction de transformation qui effectue une rotation et un déplacement
function rotate_and_translate(x, y, t)
    θ = t  # Utiliser le temps comme angle de rotation
    rotated = [cos(θ)*x - sin(θ)*y, sin(θ)*x + cos(θ)*y]
    return [rotated[1] + 0.1*t, rotated[2]]  # Ajouter le déplacement
end

function translate(x, y, t)
    dx = 0.1 * t  # Déplacement en x
    dy = 0.2 * t  # Déplacement en y
    return [x + dx, y + dy]
end

stationary_transform(x, t) = x

function evaluate_levelset(sdf::SignedDistanceFunction, t, mesh::NTuple{2,AbstractVector})
    x, y = mesh
    [evaluate_sdf(sdf, t, xi, yi) for xi in x, yi in y]
end


grid = CartesianGrid((10, 10), (2.0, 2.0)) # Crée une grille 2D de 10x10 avec un espacement de 2.0
mesh = generate_mesh(grid, false) # Génère un maillage collocated

# Créer une grille de points
x = y = range(-2, stop=2, length=100)

# Créer une SDF avec une fonction de transformation
sdf = SignedDistanceFunction(circle_sdf, rotate_and_translate, ((-2.0, 2.0), (-2.0, 2.0)), true)

# Cas instationnaire
for t = 0:1:5
    # Évaluer la level set aux points de la grille fixe
    values = evaluate_levelset(sdf, t, mesh)    
    cut_cells = get_cut_cells(values)
    intersection_points = get_intersection_points(values, cut_cells)
    midpoints = get_segment_midpoints(values, cut_cells, intersection_points)
end

# Cas stationnaire
sdf = SignedDistanceFunction(circle_sdf, rotate_and_translate, ((-2.0, 2.0), (-2.0, 2.0)), false)
values = evaluate_levelset(sdf, 0.0, mesh)
cut_cells = get_cut_cells(values)
intersection_points = get_intersection_points(values, cut_cells)
midpoints = get_segment_midpoints(values, cut_cells, intersection_points)

# Cas Plusieurs géométries

"""
# Définir une fonction pour calculer la vitesse ẋ de la transformation ξ=m(x,t):
# Dm/Dt=0 => ṁ + (dm/dx)ẋ = 0 donc ẋ =-(dm/dx)/ṁ
function compute_velocity(transform, x, t)
    # Calculer le jacobien J
    J = ForwardDiff.jacobian(transform(x, t), x)
    @show J
    # Calculer la dérivée dot
    dot = ForwardDiff.derivative(transform(x, t), t)
    @show dot
    # Calculer la vitesse
    velocity = -J / dot
    @show velocity
    return velocity
end

# Calculer la vitesse de la transformation à un point spécifique
x_test, y_test = 0.5, 0.5
compute_velocity(rotate_and_translate, [x_test, y_test], 2.0)
"""