using JSON
using CSV
include("edit_distance.jl")
include("GA.jl")


# define parameter grid
N_pop_params = [10, 100]
n_max_params = [50, 100]
cre_p_params = [0.1,0.25,0.5]
dupl_p_params = [0.1,0.25,0.5]
mut_p_params = [0.1,0.25,0.5]
cross_p_params = [0.1,0.25,0.5]

# param_grid = zeros(3,6,5,5,5,5)

# parameter experiments
using DataFrames
function test(path; max_sol_length=20)
    results = DataFrame(file=String[], best=String[], score=Int[], time=Float64[])
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
                                    best, t, = @timed GeneticOptimization(abc, strs, N_pop=pop, max_length=max_sol_length,n_max=max,cre_p=cre,dupl_p=dupl,mut_p=mut,cross_p=cross)
                                    score = sum(edit_distance(best, s, mat) for s in strs)
                                    #println("Found $best with score $score in $t seconds")
                                    push!(results, [file, best, score, t])
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

res1 = test("C:/Users/basti/Documents/GitHub/PS_in_AI/instances/benchmark", max_sol_length = 20)
