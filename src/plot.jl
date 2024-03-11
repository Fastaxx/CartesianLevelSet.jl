function plot_cut_cells_levelset_intersections_and_midpoints(cut_cells, values, intersection_points, midpoints)
    """
    # Créer un tracé de maillage
    p = heatmap(values, color=:grays, legend=false)
    """
    # Ajouter la Level Set comme une ligne de contour
    contour!(values, levels=[0], color=:red)

    # Ajouter chaque cellule coupée au tracé
    for cell in cut_cells
        # Calculer les coordonnées du coin inférieur gauche de la cellule
        x = cell[2]
        y = cell[1]

        # Ajouter un carré représentant la cellule au tracé
        plot!([x, x+1, x+1, x, x], [y, y, y+1, y+1, y], fill = true, color = :blue, alpha=0.5)
    end

    """
    # Ajouter les points d'intersection au tracé
    for point in intersection_points
        scatter!([point[1]], [point[2]], color=:green, markersize=4)
    end
    """
    # Ajouter les points médians au tracé
    for point in midpoints
        scatter!([point[1]], [point[2]], color=:yellow, markersize=4)
    end

    # Afficher le tracé
    readline()
end
