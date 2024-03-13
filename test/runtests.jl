using Test
using CartesianLevelSet

function tests_CartesianGrid()
    @testset "Tests for CartesianGrid" begin
        grid = CartesianGrid((10, 10), (1.0, 1.0))
        @test ndims(grid) == 2
        @test size(grid) == (10, 10)
        @test calculate_volume(grid) == 100.0

        grid = CartesianGrid((10, 10, 10), (1.0, 1.0, 1.0))
        @test ndims(grid) == 3
        @test size(grid) == (10, 10, 10)
        @test calculate_volume(grid) == 1000.0
    end
end

function tests_generate_mesh()
    @testset "Tests for generate_mesh" begin
        grid = CartesianGrid((10, 10), (1.0, 1.0))
        mesh = generate_mesh(grid)
        @test length(mesh) == 2
        @test all([length(m) == 11 for m in mesh])

        grid = CartesianGrid((10, 10, 10), (1.0, 1.0, 1.0))
        mesh = generate_mesh(grid)
        @test length(mesh) == 3
        @test all([length(m) == 11 for m in mesh])
    end
end

function tests_evaluate_levelset()
    @testset "Tests for evaluate_levelset" begin
        @test evaluate_levelset((x,) -> x^2, ([1, 2, 3],)) == [1, 4, 9]
        @test evaluate_levelset((x, y) -> x*y, ([1, 2], [3, 4])) == [3 4; 6 8]
    end
end
function tests_get_cut_cells()
    @testset "Tests for get_cut_cells" begin
        @testset "2D array" begin
            values = [1 2 3; -1 -2 -3; 1 2 3]
            expected = [CartesianIndex(1, 1), CartesianIndex(1, 2), CartesianIndex(2, 1), CartesianIndex(2, 2)]
            @test sort(get_cut_cells(values)) == sort(expected)
        end

        @testset "3D array" begin
            values = reshape([1, 2, 3, -1, -2, -3, 1, 2, 3, -1, -2, -3, 1, 2, 3, -1, -2, -3], (2, 3, 3))
            expected = [CartesianIndex(1, 1, 1), CartesianIndex(1, 2, 1), CartesianIndex(1, 1, 2), CartesianIndex(1, 2, 2)]
            @test sort(get_cut_cells(values)) == sort(expected)
        end
    end
end

function run_tests()
    tests_CartesianGrid()
    tests_generate_mesh()
    tests_evaluate_levelset()
    tests_get_cut_cells()
end

run_tests()
