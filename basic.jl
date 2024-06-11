push!(LOAD_PATH, joinpath(@__DIR__, ".."))

using BenchmarkTools
using CUDA
using Oceananigans
using CairoMakie

grid = RectilinearGrid(size=(256, 256), x=(0, 2 * 3.14), y=(0, 2 * 3.14), topology=(Periodic, Periodic, Flat))
model = NonhydrostaticModel(; grid, advection=WENO())

e(e, y) = 2rand() - 1
set!(model, u=e, v=e)

simulation = Simulation(model; Δt=0.01, stop_iteration=500)
time_step!(simulation)

u, v, w = model.velocities
ζ = Field(∂x(v) - ∂y(u))
compute!(ζ)

heatmap(interior(ζ, :, :, 1))
