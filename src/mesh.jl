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
    up_x = grid.nx
    up_y = grid.ny
    if staggered
        x = [grid.dx * ((2*(i-lo) + 1) / (2*(up_x-lo+1))) for i in 0:grid.nx+1]
        y = [grid.dy * ((2*(i-lo) + 1) / (2*(up_y-lo+1))) for i in 0:grid.ny+1]
    else
        x = [grid.dx * ((i-lo) / (up_x-lo+1)) for i in 0:grid.nx]
        y = [grid.dy * ((i-lo) / (up_y-lo+1)) for i in 0:grid.ny]
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