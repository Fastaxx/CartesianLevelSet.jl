function evaluate_levelset(levelset, mesh)
    x, y = mesh
    values = [levelset(x[i], y[j]) for i in 1:length(x), j in 1:length(y)]
    return values
end

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


function get_segment_midpoints(values, cut_cells, intersection_points)
    # Initialiser un tableau vide pour stocker les points médians
    midpoints::Vector{Tuple{Float64, Float64}} = []

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