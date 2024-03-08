module CartesianLevelSet
using CartesianGeometry
using Plots
Plots.default(show = true)

# Write your package code here.
struct CartesianGrid
    nx::Int
    ny::Int
    nz::Int
    dx::Float64
    dy::Float64
    dz::Float64
    dimension::Int

    # Constructeur pour un maillage 3D
    CartesianGrid(nx::Int, ny::Int, nz::Int, dx::Float64, dy::Float64, dz::Float64) = new(nx, ny, nz, dx, dy, dz, 3)

    # Constructeur pour un maillage 2D
    CartesianGrid(nx::Int, ny::Int, dx::Float64, dy::Float64) = new(nx, ny, 0, dx, dy, 0.0, 2)
end
function calculate_volume(grid::CartesianGrid)
    if grid.dimension == 3
        return grid.nx * grid.dx * grid.ny * grid.dy * grid.nz * grid.dz
    elseif grid.dimension == 2
        return grid.nx * grid.dx * grid.ny * grid.dy
    else
        error("Invalid dimension: $(grid.dimension). Dimension must be 2 or 3.")
    end
end
function generate_mesh(grid::CartesianGrid, staggered::Bool=false)
    lo = 0
    up = grid.nx

    if staggered
        x = [grid.dx * ((2*(i-lo) + 1) / (2*(up-lo+1))) for i in 0:grid.nx+1]
        y = [grid.dy * ((2*(i-lo) + 1) / (2*(up-lo+1))) for i in 0:grid.ny+1]
    else
        x = [grid.dx * ((i-lo) / (up-lo+1)) for i in 0:grid.nx]
        y = [grid.dy * ((i-lo) / (up-lo+1)) for i in 0:grid.ny]
    end

    if grid.dimension == 3
        up = grid.nz
        if staggered
            z = [grid.dz * ((2*(i-lo) + 1) / (2*(up-lo+1))) for i in 0:grid.nz+1]
        else
            z = [grid.dz * ((i-lo) / (up-lo+1)) for i in 0:grid.nz]
        end
        return (x, y, z)
    else
        return (x, y)
    end
end

grid = CartesianGrid(20, 20 , 1., 1.)
mesh = generate_mesh(grid, false) # Génère un maillage 
x, y = mesh
# define level set
const R = 0.25
const a, b = 0.5, 0.5

levelset = HyperSphere(R, (a, b))

function evaluate_levelset(levelset, mesh)
    x, y = mesh
    values = [levelset(x[i], y[j]) for i in 1:length(x), j in 1:length(y)]
    return values
end

values = evaluate_levelset(levelset, mesh)

function get_cut_cells(values)
    # Initialiser un tableau vide pour stocker les indices des cellules coupées
    cut_cells = CartesianIndex[]

    # Parcourir toutes les cellules
    for i in 1:size(values, 1)-1
        for j in 1:size(values, 2)-1
            # Vérifier si la Level Set change de signe le long de n'importe quelle arête de cette cellule
            if values[i, j] * values[i+1, j] < 0 || values[i, j] * values[i, j+1] < 0 || values[i+1, j] * values[i+1, j+1] < 0 || values[i, j+1] * values[i+1, j+1] < 0 
                # Si c'est le cas, ajouter cette cellule à la liste
                push!(cut_cells, CartesianIndex(i, j))
            end
        end
    end

    return cut_cells
end

cut_cells = get_cut_cells(values)
@show cut_cells

function get_intersection_points(values, cut_cells)
    # Initialiser un tableau vide pour stocker les points d'intersection
    intersection_points = []

    # Parcourir toutes les cellules coupées
    for cell in cut_cells
        i, j = cell.I

        # Parcourir toutes les arêtes de la cellule
        for (di, dj) in [(0, 1), (1, 0), (0, -1), (-1, 0)]
            # Vérifier si la Level Set change de signe le long de cette arête
            if values[i, j] * values[i+di, j+dj] < 0
                # Si c'est le cas, calculer le point d'intersection
                t = values[i, j] / (values[i, j] - values[i+di, j+dj])
                x_intersect = j + t * dj
                y_intersect = i + t * di

                # Ajouter le point d'intersection à la liste
                push!(intersection_points, (x_intersect, y_intersect))
            end
        end
    end

    return intersection_points
end

intersection_points = get_intersection_points(values, cut_cells)
@show intersection_points

function get_segment_midpoints(values, cut_cells, intersection_points)
    # Initialiser un tableau vide pour stocker les points médians
    midpoints = []

    # Parcourir toutes les cellules coupées
    for cell in cut_cells
        i, j = cell.I

        # Récupérer les points d'intersection sur cette cellule
        cell_points = [point for point in intersection_points if point[1] >= j && point[1] <= j+1 && point[2] >= i && point[2] <= i+1]

        # Calculer le point médian de tous les points d'intersection sur cette cellule
        x_mid = sum(point[1] for point in cell_points) / length(cell_points)
        y_mid = sum(point[2] for point in cell_points) / length(cell_points)
        midpoint = (x_mid, y_mid)

        # Ajouter le point médian à la liste
        push!(midpoints, midpoint)
    end

    return midpoints
end

midpoints = get_segment_midpoints(values, cut_cells, intersection_points)
@show size(cut_cells)
@show size(intersection_points)
@show size(midpoints)

function plot_cut_cells_levelset_intersections_and_midpoints(cut_cells, values, intersection_points, midpoints)
    """
    # Créer un tracé de maillage
    p = heatmap(values, color=:grays, legend=false)
    """
    # Ajouter la Level Set comme une ligne de contour
    contour!(values, levels=[0], color=:red)

    # Ajouter chaque cellule coupée au tracé
    for cell in cut_cells
        # Calculer les coordonnées du coin inférieur gauche de la cellule
        x = cell[2]
        y = cell[1]

        # Ajouter un carré représentant la cellule au tracé
        plot!([x, x+1, x+1, x, x], [y, y, y+1, y+1, y], fill = true, color = :blue, alpha=0.5)
    end

    """
    # Ajouter les points d'intersection au tracé
    for point in intersection_points
        scatter!([point[1]], [point[2]], color=:green, markersize=4)
    end
    """
    # Ajouter les points médians au tracé
    for point in midpoints
        scatter!([point[1]], [point[2]], color=:yellow, markersize=4)
    end

    # Afficher le tracé
    readline()
end

plot_cut_cells_levelset_intersections_and_midpoints(cut_cells, values, intersection_points, midpoints)

"""
function get_cut_edges(values, cut_cells)
    # Initialiser un tableau vide pour stocker les arêtes coupées
    cut_edges = []

    # Parcourir toutes les cellules coupées
    for cell in cut_cells
        i, j = cell.I  # Récupérer les indices de la cellule

        # Parcourir toutes les arêtes de la cellule
        for (di, dj) in [(0, 1), (1, 0), (0, -1), (-1, 0)]
            # Vérifier que les indices sont dans les limites de la matrice
            if 1 <= i+di <= size(values, 1) && 1 <= j+dj <= size(values, 2)
                # Si la Level Set change de signe sur cette arête
                if values[i, j] * values[i+di, j+dj] < 0
                    # Ajouter cette arête à la liste
                    push!(cut_edges, ((i, j), (i+di, j+dj)))
                end
            end
        end
    end

    return cut_edges
end

cut_edges = get_cut_edges(values, cut_cells)
@show cut_edges

function plot_levelset(levelset, mesh)
    # Évaluer la Level Set sur le maillage
    values = evaluate_levelset(levelset, mesh)

    # Extraire les coordonnées x et y du maillage
    x, y = mesh

    # Créer un contour plot de la Level Set
    contour(x, y, values)
    readline()
end

plot_levelset(levelset, mesh)

function bilinear_interpolation(x, y, values, x_query, y_query)
    # Trouver les indices des points de grille entourant (x_query, y_query)
    i = findlast(x .<= x_query)
    j = findlast(y .<= y_query)

    # Calculer les poids pour l'interpolation
    dx = i < length(x) ? (x_query - x[i]) / (x[i+1] - x[i]) : 0
    dy = j < length(y) ? (y_query - y[j]) / (y[j+1] - y[j]) : 0

    # Initialiser les valeurs aux coins
    f00 = values[i, j]
    f10 = i < size(values, 1) ? values[i+1, j] : f00
    f01 = j < size(values, 2) ? values[i, j+1] : f00
    f11 = (i < size(values, 1) && j < size(values, 2)) ? values[i+1, j+1] : f00

    # Effectuer l'interpolation bilinéaire
    return (1 - dx) * (1 - dy) * f00 +
           dx * (1 - dy) * f10 +
           (1 - dx) * dy * f01 +
           dx * dy * f11
end

function interpolate_levelset_corners(values, x, y)
    # Initialiser un tableau vide pour stocker les valeurs interpolées
    interpolated_values = zeros(size(values) .+ 1)

    # Parcourir chaque cellule
    for i in 1:size(values, 1), j in 1:size(values, 2)
        # Interpoler la valeur aux quatre coins de la cellule
        for di in 0:1, dj in 0:1
            if 1 <= i+di <= size(values, 1) && 1 <= j+dj <= size(values, 2)
                interpolated_values[i+di, j+dj] = bilinear_interpolation(x, y, values, x[i+di], y[j+dj])
            end
        end
    end

    return interpolated_values
end

interpolated_values = interpolate_levelset_corners(values, x, y)
@show interpolated_values

function compute_interface_barycenters(x, y, values)
    # Récupérer les indices des cellules coupées par la Level Set
    cut_cells = get_cut_cells(values)

    # Initialiser un tableau pour stocker les barycentres
    barycenters = []

    # Parcourir toutes les cellules coupées
    for index in cut_cells
        i, j = index[1], index[2]
        @show i, j
        # Initialiser un tableau pour stocker les points d'intersection
        intersections = []

        # Parcourir toutes les arêtes de la cellule
        for (di, dj) in [(0, -1), (-1, 0), (0, 1), (1, 0)]
            # Vérifier que les indices sont dans les limites de la matrice
            if 1 <= i+di <= size(values, 1) && 1 <= j+dj <= size(values, 2)
                @show values[i, j]*values[i+di, j]
                @show values[i, j]*values[i, j+dj]
                @show values[i, j]*values[i+di, j+dj]
                # Si la Level Set change de signe sur cette arête
                if values[i, j] * values[i + di, j] < 0 || values[i, j] * values[i, j + dj] < 0 || values[i, j] * values[i + di, j + dj] < 0
                    # Calculer le point d'intersection avec la Level Set
                    t = values[i, j] / (values[i, j] - values[i+di, j+dj])
                    x_intersect = x[j] + t * (x[j+dj] - x[j])
                    y_intersect = y[i] + t * (y[i+di] - y[i])
                    @show x_intersect, y_intersect
                    #readline()
                    # Ajouter le point d'intersection à la liste
                    push!(intersections, (x_intersect, y_intersect))
                end
            end
        end

        # Calculer le barycentre des points d'intersection si la liste contient exactement deux points
        if length(intersections) == 2
            # Le barycentre est le milieu des deux points d'intersection
            barycenter_x = (intersections[1][1] + intersections[2][1]) / 2
            barycenter_y = (intersections[1][2] + intersections[2][2]) / 2

            # Ajouter le barycentre à la liste
            push!(barycenters, (barycenter_x, barycenter_y))
       end
    end

    return barycenters
end

x,y = mesh
barycenters = compute_interface_barycenters(x,y , values)
@show size(cut_cells)
@show size(barycenters)

function plot_levelset_with_barycenters_and_edges(levelset, mesh, barycenters)
    # Évaluer la Level Set sur le maillage
    values = evaluate_levelset(levelset, mesh)

    # Extraire les coordonnées x et y du maillage
    x, y = mesh

    # Ajouter une ligne où la Level Set est égale à 0
    contour!(x, y, values, levels=[0], color=:black, label="Level Set = 0")
    
    # Extraire les coordonnées x et y des barycentres
    barycenter_x = [b[1] for b in barycenters]
    barycenter_y = [b[2] for b in barycenters]

    # Ajouter les barycentres au plot
    scatter!(barycenter_x, barycenter_y, color=:red, label="Barycenters")

    # Ajouter les arêtes des cellules au plot
    for i in 1:length(y)-1
        for j in 1:length(x)-1
            plot!([x[j], x[j+1]], [y[i], y[i]], color=:blue, label="")
            plot!([x[j], x[j]], [y[i], y[i+1]], color=:blue, label="")
        end
    end

    readline()
end

plot_levelset_with_barycenters_and_edges(levelset, mesh, barycenters)
"""
end # module