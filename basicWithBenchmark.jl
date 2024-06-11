push!(LOAD_PATH, joinpath(@__DIR__, ".."))

using BenchmarkTools
using CUDA
using Oceananigans
using Oceananigans.Utils: oceananigans_versioninfo, versioninfo_with_gpu
using CairoMakie
using Dates

#anything that you may wish to modify goes here
gridSizes = [(32, 32), (64, 64), (128, 128), (256, 256), (512, 512)]

#helper functions 
function writeTrial(B)

        date = string(Dates.now())
        callDetails = "Oceananigans Benchmark:" * date * "\nOceananigans version:" * oceananigans_versioninfo() * "\nOceananigans GPU version:" * versioninfo_with_gpu() * (CUDA.has_cuda_gpu() ? "\nCuda version:" * CUDA.versioninfo() : "") * "\n"
        callName = "Oceananigans_Benchmark:" * date

        open(callName, "w") do io
                write(io, callDetails)
                write(io, "\n \nModel \t Grid type \t Grid size \t MinTime \t MedianTime \t MeanTime \t MaxTime \t Memory \t Allocs \t Num Samples\n")
                for trialDict in B
                        t = trialDict["trial"]
                        trialInfo = trialDict["model"] * "\t" * trialDict["gridType"] * "\t" * trialDict["gridSize"] * "\t" * string(minimum(t.times)) * "\t" * string(median(t.times)) * "\t" * string(mean(t.times)) * "\t" * string(maximum(t.times)) * "\t" * string(t.memory) * "\t" * string(t.allocs) * "\t" * string(t.params.samples) * "\n"

                        write(io, trialInfo)
                end
        end
end


m = "Hydrostatic"#"Nonhydrostatic" #Alternatives: "Hydrostatic" "ShallowWater"

#main code 
completedBenchmarks = []

for g in gridSizes
        println("Starting Case ", string(g))

        if (m == "Nonhydrostatic")
                grid = RectilinearGrid(size=g, x=(0, 2 * 3.14), y=(0, 2 * 3.14), topology=(Periodic, Periodic, Flat))
                model = NonhydrostaticModel(; grid, advection=WENO())

                e(e, y) = 2rand() - 1
                set!(model, u=e, v=e)
        elseif (m == "Hydrostatic")
                grid = RectilinearGrid(size=(g[1], g[2], 1), extent=(1, 1, 1))
                model = HydrostaticFreeSurfaceModel(; grid)

        elseif (m == "ShallowWater")
                grid = RectilinearGrid(size=g, x=(0, 2 * 3.14), y=(0, 2 * 3.14), topology=(Periodic, Periodic, Flat), halo=(3, 3))
                model = ShallowWaterModel(grid=grid, gravitational_acceleration=1.0)
                set!(model, h=1)
        else
                println("Invalid choice of model")
                break
        end

        trial = @benchmark begin
                time_step!($model, 1)
        end samples = 10

        push!(completedBenchmarks, Dict("trial" => trial, "model" => m, "gridType" => "RectilinearGrid", "gridSize" => string(g))
        )
end

writeTrial(completedBenchmarks)

