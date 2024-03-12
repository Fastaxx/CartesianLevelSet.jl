struct CartesianGrid{N,I<:Integer,T<:Number}
    n::NTuple{N,I}
    spacing::NTuple{N,T}
end
function calculate_volume(grid::CartesianGrid)
    if length(grid.n) == 3
        return prod(grid.n) * prod(grid.spacing)
    elseif length(grid.n) == 2
        return prod(grid.n) * prod(grid.spacing)
    elseif length(grid.n) == 1
        return grid.n[1] * grid.spacing[1]
    else
        error("Invalid dimension: $(length(grid.n)). Dimension must be 1 or 2 or 3.")
    end
end
function generate_mesh(grid::CartesianGrid{N, I, T}, staggered::Bool=false) where {N, I, T}
    lo = zero(T)
    if staggered
        mesh = [ [(grid.spacing[i] * ((2*(j-lo) + 1) / (2*(grid.n[i]-lo+1)))) for j in 0:grid.n[i]+1] for i in 1:N ]
    else
        mesh = [ [(grid.spacing[i] * ((j-lo) / (grid.n[i]-lo+1))) for j in 0:grid.n[i]] for i in 1:N ]
    end
    return tuple(mesh...)
end