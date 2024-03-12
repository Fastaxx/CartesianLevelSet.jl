function evaluate_levelset(f::Function, mesh::Tuple{AbstractVector{T}}) where T
    x = mesh[1]
    values = [f(x[i]) for i in 1:length(x)]
    return values
end
function evaluate_levelset(f::Function, mesh::NTuple{2,AbstractVector{T}}) where T
    x, y = mesh
    values = [f(x[i], y[j]) for i in 1:length(x), j in 1:length(y)]
    return values
end
function evaluate_levelset(f::Function, mesh::NTuple{3,AbstractVector{T}}) where T
    x, y, z = mesh
    values = [f(x[i], y[j], z[k]) for i in 1:length(x), j in 1:length(y), k in 1:length(z)]
    return values
end

function get_cut_cells(values::AbstractArray{T, 1}) where T
    cut_cells = CartesianIndex[]
    for i in 1:length(values)-1
        if values[i] * values[i+1] < 0
            push!(cut_cells, CartesianIndex(i))
        end
    end
    return cut_cells
end
function get_cut_cells(values::AbstractArray{T, 2}) where T
    cut_cells = CartesianIndex[]
    for i in 1:size(values, 1)-1
        for j in 1:size(values, 2)-1
            if values[i, j] * values[i+1, j] < 0 || values[i, j] * values[i, j+1] < 0 || values[i+1, j] * values[i+1, j+1] < 0 || values[i, j+1] * values[i+1, j+1] < 0 
                push!(cut_cells, CartesianIndex(i, j))
            end
        end
    end
    return cut_cells
end
function get_cut_cells(values::AbstractArray{T, 3}) where T
    cut_cells = CartesianIndex[]
    for i in 1:size(values, 1)-1
        for j in 1:size(values, 2)-1
            for k in 1:size(values, 3)-1
                if values[i, j, k] * values[i+1, j, k] < 0 || values[i, j, k] * values[i, j+1, k] < 0 || values[i, j, k] * values[i, j, k+1] < 0 || 
                   values[i+1, j, k] * values[i+1, j+1, k] < 0 || values[i+1, j, k] * values[i+1, j, k+1] < 0 || values[i, j+1, k] * values[i, j+1, k+1] < 0 || 
                   values[i, j, k+1] * values[i+1, j, k+1] < 0 || values[i, j, k+1] * values[i, j+1, k+1] < 0 || values[i+1, j+1, k] * values[i+1, j+1, k+1] < 0
                    push!(cut_cells, CartesianIndex(i, j, k))
                end
            end
        end
    end
    return cut_cells
end

function get_intersection_points(values::AbstractArray{T,1}, cut_cells) where T
    # Initialiser un tableau vide pour stocker les points d'intersection
    intersection_points = Tuple{Float64}[]

    # Parcourir toutes les cellules coupées
    for index in cut_cells
        i = index.I[1]
        # Vérifier si la Level Set change de signe le long de cette arête
        if values[i] * values[i+1] < 0
            # Si c'est le cas, calculer le point d'intersection
            t = values[i] / (values[i] - values[i+1])
            x_intersect = i + t

            # Ajouter le point d'intersection à la liste
            push!(intersection_points, (x_intersect,))
        end
    end

    return intersection_points
end
function get_intersection_points(values::AbstractArray{T,2}, cut_cells) where T
    # Initialiser un tableau vide pour stocker les points d'intersection
    intersection_points = Tuple{Float64, Float64}[]

    # Parcourir toutes les cellules coupées
    for cell in cut_cells
        i, j = cell.I

        # Parcourir toutes les arêtes de la cellule
        for (di, dj) in [(0, 1), (1, 0), (0, -1), (-1, 0)]
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

    return intersection_points
end
function get_intersection_points(values::AbstractArray{T, 3}, cut_cells) where T
    # Initialiser un tableau vide pour stocker les points d'intersection
    intersection_points = Tuple{Float64, Float64, Float64}[]

    # Parcourir toutes les cellules coupées
    for cell in cut_cells
        i, j, k = cell.I

        # Parcourir toutes les arêtes de la cellule
        for (di, dj, dk) in [(0, 1, 0), (1, 0, 0), (0, -1, 0), (-1, 0, 0), (0, 0, 1), (0, 0, -1)]
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

    return intersection_points
end

function get_segment_midpoints(values::AbstractArray{T,1}, cut_cells, intersection_points) where T
    # Initialiser un tableau vide pour stocker les points médians
    midpoints::Vector{Tuple{Float64}} = []

    # Parcourir toutes les cellules coupées
    for cell in cut_cells
        i = cell.I[1]

        # Récupérer les points d'intersection sur cette cellule
        cell_points = [point for point in intersection_points if point[1] >= i && point[1] <= i+1]

        # Calculer le point médian de tous les points d'intersection sur cette cellule
        x_mid = sum(point[1] for point in cell_points) / length(cell_points)
        midpoint = (x_mid,)

        # Ajouter le point médian à la liste
        push!(midpoints, midpoint)
    end

    return midpoints
end
function get_segment_midpoints(values::AbstractArray{T,2}, cut_cells, intersection_points) where T
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
function get_segment_midpoints(values::AbstractArray{T,3}, cut_cells, intersection_points) where T
    # Initialiser un tableau vide pour stocker les points médians
    midpoints::Vector{Tuple{Float64, Float64, Float64}} = []

    # Parcourir toutes les cellules coupées
    for cell in cut_cells
        i, j, k = cell.I

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