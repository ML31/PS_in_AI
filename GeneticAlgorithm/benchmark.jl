using JSON
using CSV
include("edit_distance.jl")
include("GA.jl")

# best params = (150, 150, 0.23, 0.2, 0.35, 0.22)

# parameter experiments
using DataFrames

function bench(path; max_sol_length=20)
    results = DataFrame(file=String[], best=String[], score=Int[], time=Float64[], run=Int[])
    mat = zeros(Int,100,100)

    # read every instance one by one and store the results in the DataFrame
    @progress for file in readdir(path)
        if occursin(".txt", file)
            problem = JSON.parsefile(path * "/" * file)
            abc = problem["alphabet"]
            strs = Vector{String}(problem["strings"])
            # run it 10 times to get median results
            println("We are at problem $file")
            for i in 1:10
                best, t, = @timed GeneticOptimization(abc, strs, N_pop=150, max_length=max_sol_length,n_max=150,cre_p=0.23,dupl_p=0.2,mut_p=0.35,cross_p=0.22, warm_start=true)
                score = sum(edit_distance(best, s, mat) for s in strs)
                print("Best: $best \nscore: $score \ntime: $t\n\n")
                push!(results, [file, best, score, t, i])
            end
        end
    end
    return results
end

res1 = bench("C:/Users/basti/Documents/GitHub/PS_in_AI/instances/benchmark", max_sol_length = 30)
