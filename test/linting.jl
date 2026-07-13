# Shared code-quality (Aqua.jl), type-stability (JET.jl) and import-hygiene
# (ExplicitImports.jl) checks.
# Kept consistent across the Julia-XAI packages — see REFACTOR.md.
using TextHeatmaps
using Test
using Aqua
using JET
using ExplicitImports

@testset "Aqua.jl" begin
    @info "Running Aqua.jl code-quality tests. These might print warnings from dependencies."
    Aqua.test_all(TextHeatmaps; ambiguities = false)
end

@testset "ExplicitImports.jl" begin
    @info "Running ExplicitImports.jl import-hygiene tests."
    @test check_no_stale_explicit_imports(TextHeatmaps) === nothing
    @test check_all_explicit_imports_via_owners(TextHeatmaps) === nothing
    @test check_all_qualified_accesses_via_owners(TextHeatmaps) === nothing
    @test check_no_self_qualified_accesses(TextHeatmaps) === nothing
end

# JET's v0.11 series supports Julia v1.12 and above only.
if VERSION >= v"1.12"
    @testset "JET.jl" begin
        @info "Running JET.jl type-stability tests."
        JET.test_package(TextHeatmaps; target_defined_modules = true)
    end
end
