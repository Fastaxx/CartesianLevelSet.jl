# Définir une structure générique SignedDistanceFunction
struct SignedDistanceFunction{T}
    sdf_function::Function  # La fonction qui calcule la SDF
    domain::T  # Domaine de définition de la fonction
end
# Définir une fonction pour évaluer la SDF à un point donné
function evaluate_sdf(sdf::SignedDistanceFunction, x...)
    return sdf.sdf_function(x...)
end

# Définir une fonction d'union pour les SignedDistanceFunction
function ⊔(a::SignedDistanceFunction{T}, b::SignedDistanceFunction{T}) where T
    sdf(x::Vararg{Float64}) = min(a.sdf_function(x...), b.sdf_function(x...))
    SignedDistanceFunction(sdf, a.domain)
end

# Définir une fonction d'intersection pour les SignedDistanceFunction
function ⊓(a::SignedDistanceFunction{T}, b::SignedDistanceFunction{T}) where T
    sdf(x::Vararg{Float64}) = max(a.sdf_function(x...), b.sdf_function(x...))
    SignedDistanceFunction(sdf, a.domain)
end

# Définir une fonction de différence pour les SignedDistanceFunction
function ⊖(a::SignedDistanceFunction{T}, b::SignedDistanceFunction{T}) where T
    sdf(x::Vararg{Float64}) = max(a.sdf_function(x...), -b.sdf_function(x...))
    SignedDistanceFunction(sdf, a.domain)
end

# Définir une fonction de complément pour les SignedDistanceFunction
function complement(a::SignedDistanceFunction{T}) where T
    sdf(x::Vararg{Float64}) = -a.sdf_function(x...)
    SignedDistanceFunction(sdf, a.domain)
end

function compute_normal(sdf::SignedDistanceFunction, x, y)
    # Envelopper la fonction SDF dans une fonction prenant un seul argument
    sdf_func = (p) -> sdf.sdf_function(p[1], p[2])

    # Calculer la distance et le gradient de la SDF au point (x, y)
    nx, ny = ForwardDiff.gradient(sdf_func, [x, y])
    # Normaliser le gradient pour obtenir la normale
    norm = sqrt(nx^2 + ny^2)
    nx = nx / norm
    ny = ny / norm

    return nx, ny
end
function compute_normal(sdf::SignedDistanceFunction, x, y, z)
    # Envelopper la fonction SDF dans une fonction prenant un seul argument
    sdf_func = (p) -> sdf.sdf_function(p[1], p[2], p[3])

    # Calculer la distance et le gradient de la SDF au point (x, y)
    nx, ny, nz = ForwardDiff.gradient(sdf_func, [x, y, z])
    # Normaliser le gradient pour obtenir la normale
    norm = sqrt(nx^2 + ny^2 + nz^2)
    nx = nx / norm
    ny = ny / norm
    nz = nz / norm

    return nx, ny, nz
end

function compute_curvatures(sdf::SignedDistanceFunction, x, y)
    # Envelopper la fonction SDF dans une fonction prenant un seul argument
    sdf_func = (p) -> sdf.sdf_function(p[1], p[2])

    # Calculer la distance et le gradient de la SDF au point (x, y)
    _, grad = ForwardDiff.gradient(sdf_func, [x, y])
    # Calculer la dérivée seconde de la SDF
    d2sdf = ForwardDiff.hessian(sdf_func, [x, y])

    H,K = 0.5*tr(d2sdf)
    return H, K
end
function compute_curvatures(sdf::SignedDistanceFunction, x, y, z)
    # Envelopper la fonction SDF dans une fonction prenant un seul argument
    sdf_func = (p) -> sdf.sdf_function(p[1], p[2], p[3])

    # Calculer la distance et le gradient de la SDF au point (x, y)
    _, grad = ForwardDiff.gradient(sdf_func, [x, y, z])
    # Calculer la dérivée seconde de la SDF
    d2sdf = ForwardDiff.hessian(sdf_func, [x, y, z])

    # En 3D, K=tr(minor(A)) et K=0 en 2D.
    H = 0.5*tr(d2sdf)
    K = d2sdf[1,1]*d2sdf[2,2]+d2sdf[1,1]*d2sdf[3,3]+d2sdf[2,2]*d2sdf[3,3]-d2sdf[1,2]^2-d2sdf[1,3]^2-d2sdf[2,3]^2
end

"""
function sdf_to_curve(X, curve)
    # Define a function to calculate the distance between a point X and the curve for a given t
    squared_distance(t) = sum((X - curve(t)).^2)
    
    # Find the t value that minimizes the squared distance
    result = optimize(squared_distance, 0, 1)  # Use optimization to find minimum
    
    # Calculate the signed distance and corresponding t value
    t_min = result.minimizer
    distance = sqrt(result.minimum)
    
    # Determine the sign of the distance
    t_before = max(0, t_min - 0.01)
    t_after = min(1, t_min + 0.01)
    point_before = curve(t_before)
    point_after = curve(t_after)
    cross_product_z = (point_after[1] - point_before[1]) * (X[2] - point_before[2]) - (point_after[2] - point_before[2]) * (X[1] - point_before[1])
    sign = cross_product_z >= 0 ? -1 : 1

    # Return the signed distance
    signed_distance = sign * distance
    return signed_distance
end"""