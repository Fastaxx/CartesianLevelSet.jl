function evaluate_levelset(f::Function, mesh::Tuple{AbstractVector})
    x = mesh[1]
    [f(i) for i in x]
end

function evaluate_levelset(f::Function, mesh::NTuple{2,AbstractVector})
    x, y = mesh
    [f(i, j) for i in x, j in y]
end

function evaluate_levelset(f::Function, mesh::NTuple{3,AbstractVector})
    x, y, z = mesh
    [f(i, j, k) for i in x, j in y, k in z]
end

function get_cut_cells(values::AbstractVector)
    cut_cells = similar(values, CartesianIndex{1}, 0)

    for i in axes(values, 1)[begin:end-1]
        values[i] * values[i+1] < 0 &&
            push!(cut_cells, CartesianIndex(i))
    end

    cut_cells
end

function get_cut_cells(values::AbstractMatrix)
    cut_cells = similar(values, CartesianIndex{2}, 0)

    for j in axes(values, 2)[begin:end-1]
        for i in axes(values, 1)[begin:end-1]
            (values[i, j] * values[i+1, j] < 0 ||
             values[i, j] * values[i, j+1] < 0 ||
             values[i+1, j] * values[i+1, j+1] < 0 ||
             values[i, j+1] * values[i+1, j+1] < 0) &&
                push!(cut_cells, CartesianIndex(i, j))
        end
    end

    cut_cells
end

function get_cut_cells(values::AbstractArray{<:Any,3})
    cut_cells = similar(values, CartesianIndex{3}, 0)

    for k in axes(values, 3)[begin:end-1]
        for j in axes(values, 2)[begin:end-1]
            for i in axes(values, 1)[begin:end-1]
                (values[i, j, k] * values[i+1, j, k] < 0 ||
                 values[i, j, k] * values[i, j+1, k] < 0 ||
                 values[i, j, k] * values[i, j, k+1] < 0 ||
                 values[i+1, j, k] * values[i+1, j+1, k] < 0 ||
                 values[i+1, j, k] * values[i+1, j, k+1] < 0 ||
                 values[i, j+1, k] * values[i, j+1, k+1] < 0 ||
                 values[i, j, k+1] * values[i+1, j, k+1] < 0 ||
                 values[i, j, k+1] * values[i, j+1, k+1] < 0 ||
                 values[i+1, j+1, k] * values[i+1, j+1, k+1] < 0) &&
                    push!(cut_cells, CartesianIndex(i, j, k))
            end
        end
    end

    cut_cells
end

function get_intersection_points(values::AbstractVector{T}, cut_cells) where {T}
    # Initialiser un tableau vide pour stocker les points d'intersection
    intersection_points = similar(cut_cells, Tuple{T}, 0)

    # Parcourir toutes les cellules coupées
    for index in cut_cells
        i, = Tuple(index)

        # Vérifier si la Level Set change de signe le long de cette arête
        if values[i] * values[i+1] < 0
            # Si c'est le cas, calculer le point d'intersection
            t = values[i] / (values[i] - values[i+1])
            x_intersect = i + t

            # Ajouter le point d'intersection à la liste
            push!(intersection_points, (x_intersect,))
        end
    end

    intersection_points
end

function get_intersection_points(values::AbstractMatrix{T}, cut_cells) where {T}
    # Initialiser un tableau vide pour stocker les points d'intersection
    intersection_points = similar(cut_cells, NTuple{2,T}, 0)

    # Parcourir toutes les cellules coupées
    for index in cut_cells
        i, j = Tuple(index)

        # Parcourir toutes les arêtes de la cellule
        for (di, dj) in ((0, 1), (1, 0), (0, -1), (-1, 0))
            # Vérifier si la Level Set change de signe le long de cette arête
            if 1<=i+di<= size(values, 1) && 1 <= j+dj <= size(values, 2)
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
    end

    intersection_points
end

function get_intersection_points(values::AbstractArray{T,3}, cut_cells) where {T}
    # Initialiser un tableau vide pour stocker les points d'intersection
    intersection_points = similar(cut_cells, NTuple{3,T}, 0)

    # Parcourir toutes les cellules coupées
    for index in cut_cells
        i, j, k = Tuple(index)

        # Parcourir toutes les arêtes de la cellule
        for (di, dj, dk) in ((0, 1, 0), (1, 0, 0), (0, -1, 0), (-1, 0, 0), (0, 0, 1), (0, 0, -1))
            # Vérifier si la Level Set change de signe le long de cette arête
            if 1<=i+di<= size(values, 1) && 1 <= j+dj <= size(values, 2) && 1 <= k+dk <= size(values, 3)
                if values[i, j, k] * values[i+di, j+dj, k+dk] < 0
                    # Si c'est le cas, calculer le point d'intersection
                    t = values[i, j, k] / (values[i, j, k] - values[i+di, j+dj, k+dk])
                    x_intersect = j + t * dj
                    y_intersect = i + t * di
                    z_intersect = k + t * dk

                    # Ajouter le point d'intersection à la liste
                    push!(intersection_points, (x_intersect, y_intersect, z_intersect))
                end
            end
        end
    end

    intersection_points
end

function get_segment_midpoints(values::AbstractVector, cut_cells, intersection_points)
    # Initialiser un tableau vide pour stocker les points médians
    midpoints = similar(intersection_points, 0)

    # Parcourir toutes les cellules coupées
    for index in cut_cells
        i, = Tuple(index)

        # Récupérer les points d'intersection sur cette cellule
        cell_points = [point for point in intersection_points if point[1] >= i && point[1] <= i+1]

        # Calculer le point médian de tous les points d'intersection sur cette cellule
        x_mid = sum(point[1] for point in cell_points) / length(cell_points)
        midpoint = (x_mid,)

        # Ajouter le point médian à la liste
        push!(midpoints, midpoint)
    end

    midpoints
end

function get_segment_midpoints(values::AbstractMatrix, cut_cells, intersection_points)
    # Initialiser un tableau vide pour stocker les points médians
    midpoints = similar(intersection_points, 0)

    # Parcourir toutes les cellules coupées
    for index in cut_cells
        i, j = Tuple(index)

        # Récupérer les points d'intersection sur cette cellule
        cell_points = [point for point in intersection_points if point[1] >= j && point[1] <= j+1 && point[2] >= i && point[2] <= i+1]

        # Calculer le point médian de tous les points d'intersection sur cette cellule
        x_mid = sum(point[1] for point in cell_points) / length(cell_points)
        y_mid = sum(point[2] for point in cell_points) / length(cell_points)
        midpoint = (x_mid, y_mid)

        # Ajouter le point médian à la liste
        push!(midpoints, midpoint)
    end

    midpoints
end

function get_segment_midpoints(values::AbstractArray{<:Any,3}, cut_cells, intersection_points)
    # Initialiser un tableau vide pour stocker les points médians
    midpoints = similar(intersection_points, 0)

    # Parcourir toutes les cellules coupées
    for index in cut_cells
        i, j, k = Tuple(index)

        # Récupérer les points d'intersection sur cette cellule
        cell_points = [point for point in intersection_points if point[1] >= j && point[1] <= j+1 && point[2] >= i && point[2] <= i+1 && point[3] >= k && point[3] <= k+1]

        # Calculer le point médian de tous les points d'intersection sur cette cellule
        x_mid = sum(point[1] for point in cell_points) / length(cell_points)
        y_mid = sum(point[2] for point in cell_points) / length(cell_points)
        z_mid = sum(point[3] for point in cell_points) / length(cell_points)
        midpoint = (x_mid, y_mid, z_mid)

        # Ajouter le point médian à la liste
        push!(midpoints, midpoint)
    end

    return midpoints
end
