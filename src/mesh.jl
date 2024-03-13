struct InvalidDimensionException{N} <: Exception end

Base.showerror(io::IO, ::InvalidDimensionException{N}) where {N} =
    print(io, "Dimension is not valid: $(N).")

struct CartesianGrid{N,I<:Integer,T<:Number}
    n::NTuple{N,I}
    spacing::NTuple{N,T}

    function CartesianGrid(n::NTuple{N,I}, spacing::NTuple{N,T}) where {N,I<:Integer,T<:Number}
        0 < N < 4 || throw(InvalidDimensionException{N}())
        new{N,I,T}(n, spacing)
    end
end

Base.ndims(::CartesianGrid{N}) where {N} = N
Base.size(grid::CartesianGrid) = grid.n
spacing(grid::CartesianGrid) = grid.spacing

calculate_volume(grid::CartesianGrid) =
    prod(size(grid)) * prod(spacing(grid))

function generate_mesh(grid::CartesianGrid{N,I}, staggered::Bool=false) where {N,I}
    lo = zero(I)

    if staggered
        map(size(grid), spacing(grid)) do n, h
            [h * (2(i-lo) + 1) / (2(n-lo+1)) for i in 0:n+1]
        end
    else
        map(size(grid), spacing(grid)) do n, h
            [(h * ((i-lo) / (n-lo+1))) for i in 0:n]
        end
    end
end
