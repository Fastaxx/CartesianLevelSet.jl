function plot_cut_cells_levelset_intersections_and_midpoints(cut_cells, values, intersection_points, midpoints)
    # Créer un nouveau tracé
    plt = plot()

    # Ajouter la Level Set comme une ligne de contour
    contour!(values, levels=[0], color=:red)

    # Déterminer la dimension à partir du premier élément de cut_cells
    dimension = 2 #length(Tuple(cut_cells[1]))

    # Ajouter chaque cellule coupée au tracé
    for cell in cut_cells
        if dimension == 1
            # En 1D, une cellule est un segment de ligne
            plot!(plt, [cell[1], cell[1]+1], color=:blue)
        elseif dimension == 2
            # En 2D, une cellule est un carré
            x = cell[1]
            y = cell[2]
            plot!(plt, [x, x+1, x+1, x, x], [y, y, y+1, y+1, y], fill = true, color = :blue, alpha=0.5)
        else
            # En 3D, une cellule est un cube (non représentable avec Plots.jl)
            println("3D plotting not supported")
        end
    end

    # Ajouter les points d'intersection au tracé
    for point in intersection_points
        if dimension == 1
            scatter!(plt, [point[1]], color=:green, markersize=4)
        elseif dimension == 2
            scatter!(plt, [point[1]], [point[2]], color=:green, markersize=4)
        else
            # En 3D, un point est un point dans l'espace (non représentable avec Plots.jl)
            println("3D plotting not supported")
        end
    end

    # Ajouter les points médians au tracé
    for point in midpoints
        if dimension == 1
            scatter!(plt, [point[1]], color=:yellow, markersize=4)
        elseif dimension == 2
            scatter!(plt, [point[1]], [point[2]], color=:yellow, markersize=4)
        else
            # En 3D, un point est un point dans l'espace (non représentable avec Plots.jl)
            println("3D plotting not supported")
        end
    end

    # Afficher le tracé
    plt
    display(plt)
    readline()

end

# Définir une fonction pour tracer une SignedDistanceFunction 2D
function plot_sdf_2d(sdf, resolution=100)
    x_min, y_min = sdf.domain[1]
    x_max, y_max = sdf.domain[2]
    x_range = LinRange(x_min, x_max, resolution)
    y_range = LinRange(y_min, y_max, resolution)
    contour(x_range, y_range, (x, y) -> evaluate_sdf(sdf, x, y), levels=[0], color=:black, xlabel="x", ylabel="y", aspect_ratio=:equal, xlims=(x_min, x_max), ylims=(y_min, y_max))
end