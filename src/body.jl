# Définir une structure générique SignedDistanceFunction
struct SignedDistanceFunction{T}
    sdf_function::Function  # La fonction qui calcule la SDF
    domain::T  # Domaine de définition de la fonction
end
# Définir une fonction pour évaluer la SDF à un point donné
function evaluate_sdf(sdf::SignedDistanceFunction, x...)
    return sdf.sdf_function(x...)
end

# Définir une fonction SDF simple en 2D (un cercle)
function circle_sdf(x, y)
    return sqrt(x^2 + y^2) - 1.0
end
# Définir une fonction SDF simple en 3D (une sphère)
function sphere_sdf(x, y, z)
    return sqrt(x^2 + y^2 + z^2) - 1.0
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
