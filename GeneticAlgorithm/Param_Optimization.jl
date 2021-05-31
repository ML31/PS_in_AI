using JSON
using CSV
include("edit_distance.jl")
include("GA.jl")


# define parameter grid
N_pop_params = [150]
n_max_params = [150]
cre_p_params = [0.25]
dupl_p_params = [0.25]
mut_p_params = [0, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5]
cross_p_params = 0.5 .- mut_p_params

# best params = (150, 150, 0.23, 0.2, 0.35, 0.22)

# parameter experiments
using DataFrames
function test(path; max_sol_length=20)
    results = DataFrame(file=String[], best=String[], score=Int[], time=Float64[], n_pop=Int[], n_max=Int[], cre_p=Float32[], dupl_p=Float32[], mut_p=Float32[], cross_p=Float32[], run=Int[])
    mat = zeros(Int,100,100)
    @progress for file in readdir(path)
        if occursin(".txt", file)
            problem = JSON.parsefile(path * "/" * file)
            abc = problem["alphabet"]
            strs = Vector{String}(problem["strings"])
            for pop in N_pop_params
                for max in n_max_params
                    for cre in cre_p_params
                        for dupl in dupl_p_params
                            for mut in mut_p_params
                                for cross in cross_p_params
                                    # run it 5 times to get median results
                                    for i in 1:5
                                        best, t, = @timed GeneticOptimization(abc, strs, N_pop=pop, max_length=max_sol_length,n_max=max,cre_p=cre,dupl_p=dupl,mut_p=mut,cross_p=cross, warm_start=false)
                                        score = sum(edit_distance(best, s, mat) for s in strs)
                                        push!(results, [file, best, score, t, pop, max, cre, dupl, mut, cross, i])
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return results
end

res1 = test("C:/Users/basti/Documents/GitHub/PS_in_AI/instances/benchmark", max_sol_length = 30)
