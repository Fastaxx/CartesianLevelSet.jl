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

grid = CartesianGrid(10, 10 , 1., 1.)
mesh = generate_mesh(grid, false) # Génère un maillage décalé

# define level set
const R = 0.25
const a, b = 0.5, 0.5

levelset = HyperSphere(R, (a, b))

function evaluate_levelset(levelset::HyperSphere, mesh)
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
            # Vérifier si la Level Set change de signe à l'intérieur de cette cellule
            if values[i, j] * values[i+1, j+1] < 0 || values[i+1, j] * values[i, j+1] < 0
                # Si c'est le cas, ajouter cette cellule à la liste
                push!(cut_cells, CartesianIndex(i, j))
            end
        end
    end

    return cut_cells
end

cut_cells = get_cut_cells(values)
@show cut_cells

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
    dx = (x_query - x[i]) / (x[i+1] - x[i])
    dy = (y_query - y[j]) / (y[j+1] - y[j])

    # Effectuer l'interpolation bilinéaire
    return (1 - dx) * (1 - dy) * values[i, j] +
           dx * (1 - dy) * values[i+1, j] +
           (1 - dx) * dy * values[i, j+1] +
           dx * dy * values[i+1, j+1]
end

function compute_interface_barycenters(x, y, values)
    # Récupérer les indices des cellules coupées par la Level Set
    cut_cells = get_cut_cells(values)

    # Initialiser un tableau pour stocker les barycentres
    barycenters = []

    # Parcourir toutes les cellules coupées
    for index in cut_cells
        i, j = index[1], index[2]

        # Initialiser un tableau pour stocker les points d'intersection
        intersections = []

        # Parcourir toutes les arêtes de la cellule
        for (di, dj) in [(0, 1), (1, 0), (0, -1), (-1, 0)]
            # Vérifier que les indices sont dans les limites de la matrice
            if 1 <= i+di <= size(values, 1) && 1 <= j+dj <= size(values, 2)
                # Si la Level Set change de signe sur cette arête
                if values[i, j] * values[i+di, j+dj] < 0 || values[i,j] * values[i+di, j] < 0 || values[i,j] * values[i, j+dj] < 0
                    # Calculer le point d'intersection avec la Level Set
                    t = values[i, j] / (values[i, j] - values[i+di, j+dj])
                    x_intersect = x[j] + t * (x[j+dj] - x[j])
                    y_intersect = y[i] + t * (y[i+di] - y[i])

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
end # module