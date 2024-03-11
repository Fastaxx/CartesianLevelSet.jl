# Créer une instance de SignedDistanceFunction pour le cercle avec un domaine de [-2, 2] x [-2, 2] en 2D
circle_sdf_2d = SignedDistanceFunction(circle_sdf, ((-2.0, -2.0), (2.0, 2.0)))

# Créer une instance de SignedDistanceFunction pour la sphère avec un domaine de [-2, 2] x [-2, 2] x [-2, 2] en 3D
sphere_sdf_3d = SignedDistanceFunction(sphere_sdf, ((-2.0, -2.0, -2.0), (2.0, 2.0, 2.0)))


# Tracer la SignedDistanceFunction 2D du cercle
plot_sdf_2d(circle_sdf_2d)

# Tester l'évaluation de la SDF à un point spécifique en 2D
x_test, y_test = 0.5, 0.5
println("SDF au point ($x_test, $y_test): ", evaluate_sdf(circle_sdf_2d, x_test, y_test))

# Tester l'évaluation de la SDF à un point spécifique en 3D
x_test, y_test, z_test = 0.5, 0.5, 0.5
println("SDF au point ($x_test, $y_test, $z_test): ", evaluate_sdf(sphere_sdf_3d, x_test, y_test, z_test))


# Créer deux SignedDistanceFunction pour deux cercles
circle1 = SignedDistanceFunction((x, y) -> sqrt(x^2 + y^2) - 1.0, ((-2.0, -2.0), (2.0, 2.0)))
circle2 = SignedDistanceFunction((x, y) -> sqrt((x-1)^2 + (y-1)^2) - 1.0, ((-2.0, -2.0), (2.0, 2.0)))

# Calculer l'union des deux cercles
union_circle = circle1 ⊔ circle2

# Tester l'union avec un point situé à l'intérieur de l'un des cercles
x_test, y_test = 0.5, 0.5
println("SDF (Union) au point ($x_test, $y_test): ", evaluate_sdf(union_circle, x_test, y_test))  # devrait être égal à -0.5

# Calculer l'intersection des deux cercles
intersection_circle = circle1 ⊓ circle2

# Tester l'intersection avec un point situé à l'intérieur des deux cercles
x_test, y_test = 0.5, 0.5
println("SDF (Intersection) au point ($x_test, $y_test): ", evaluate_sdf(intersection_circle, x_test, y_test))  # devrait être égal à 0.5

# Calculer la différence entre le premier et le deuxième cercle
difference_circle = circle1 ⊖ circle2

# Tester la différence avec un point situé à l'intérieur du premier cercle mais à l'extérieur du deuxième
x_test, y_test = 1.5, 0.5
println("SDF (Difference) au point ($x_test, $y_test): ", evaluate_sdf(difference_circle, x_test, y_test))  # devrait être égal à 0.5

# Calculer le complément du premier cercle
complement_circle1 = complement(circle1)

# Tester le complément avec un point situé à l'intérieur du premier cercle
x_test, y_test = 0.5, 0.5
println("SDF (Complément) au point ($x_test, $y_test): ", evaluate_sdf(complement_circle1, x_test, y_test))  # devrait être égal à 1.0

plot_sdf_2d(intersection_circle)
plot_sdf_2d(union_circle)
plot_sdf_2d(difference_circle)
plot_sdf_2d(complement_circle1)