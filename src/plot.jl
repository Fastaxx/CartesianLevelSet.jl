function plot_cut_cells_levelset_intersections_and_midpoints(cut_cells, values, intersection_points, midpoints)
    # Ajouter la Level Set comme une ligne de contour
    contour!(values, levels=[0], color=:red)

    # Ajouter chaque cellule coupée au tracé
    for cell in cut_cells
        # Calculer les coordonnées du coin inférieur gauche de la cellule
        x = cell[1]
        y = cell[2]

        # Ajouter un carré représentant la cellule au tracé
        plot!([x, x+1, x+1, x, x], [y, y, y+1, y+1, y], fill = true, color = :blue, alpha=0.5)
    end

    # Ajouter les points médians au tracé
    for point in midpoints
        scatter!([point[1]], [point[2]], color=:yellow, markersize=4)
    end

    # Afficher le tracé
    
end

# Définir une fonction pour tracer une SignedDistanceFunction 2D
function plot_sdf_2d(sdf, resolution=100)
    x_min, y_min = sdf.domain[1]
    x_max, y_max = sdf.domain[2]
    x_range = LinRange(x_min, x_max, resolution)
    y_range = LinRange(y_min, y_max, resolution)
    contour(x_range, y_range, (x, y) -> evaluate_sdf(sdf, x, y), levels=[0], color=:black, xlabel="x", ylabel="y", aspect_ratio=:equal, xlims=(x_min, x_max), ylims=(y_min, y_max))
end