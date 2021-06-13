using JSON
using CSV
include("edit_distance.jl")
include("GA.jl")

# best params = (150, 150, 0.23, 0.2, 0.35, 0.22)

# plotting
using DataFrames
function plots(path; max_sol_length=20)
    results = DataFrame(type=String[], iteration=Int[], best=String[], score=Int[], run=Int[])
    mat = zeros(Int,100,100)
    @progress for file in readdir(path)
        if occursin(".txt", file)
            problem = JSON.parsefile(path * "/" * file)
            abc = problem["alphabet"]
            strs = Vector{String}(problem["strings"])
            # run it 10 times to get median results
            println("We are at problem $file")
            for i in 1:10
                # try different parameter configurations to visiualize
                best_opt, best_hist_opt = GeneticOptimization(abc, strs, N_pop=150, max_length=max_sol_length,n_max=151,cre_p=0.23,dupl_p=0.2,mut_p=0.35,cross_p=0.22, warm_start=true)
                best_opt, best_hist_opt_cold = GeneticOptimization(abc, strs, N_pop=150, max_length=max_sol_length,n_max=151,cre_p=0.23,dupl_p=0.2,mut_p=0.35,cross_p=0.22, warm_start=false)
                best_opt, best_hist_1 = GeneticOptimization(abc, strs, N_pop=150, max_length=max_sol_length,n_max=151,cre_p=0.0,dupl_p=0.3,mut_p=0.3,cross_p=0.3, warm_start=true)
                best_opt, best_hist_2 = GeneticOptimization(abc, strs, N_pop=150, max_length=max_sol_length,n_max=151,cre_p=0.0,dupl_p=0.0,mut_p=0.5,cross_p=0.5, warm_start=true)
                best_opt, best_hist_3 = GeneticOptimization(abc, strs, N_pop=150, max_length=max_sol_length,n_max=151,cre_p=0.5,dupl_p=0.0,mut_p=0.5,cross_p=0.0, warm_start=true)
                best_opt, best_hist_4 = GeneticOptimization(abc, strs, N_pop=150, max_length=max_sol_length,n_max=151,cre_p=0.0,dupl_p=0.5,mut_p=0.0,cross_p=0.5, warm_start=true)

                for j in 1:150
                    score_opt = sum(edit_distance(best_hist_opt[j], s, mat) for s in strs)
                    score_opt_cold = sum(edit_distance(best_hist_opt_cold[j], s, mat) for s in strs)
                    score_opt_1 = sum(edit_distance(best_hist_1[j], s, mat) for s in strs)
                    score_opt_2 = sum(edit_distance(best_hist_2[j], s, mat) for s in strs)
                    score_opt_3 = sum(edit_distance(best_hist_3[j], s, mat) for s in strs)
                    score_opt_4 = sum(edit_distance(best_hist_4[j], s, mat) for s in strs)

                    push!(results, ["opt", j, best_hist_opt[j], score_opt, i])
                    push!(results, ["opt-cold", j, best_hist_opt_cold[j], score_opt_cold, i])
                    push!(results, ["1", j, best_hist_1[j], score_opt_1, i])
                    push!(results, ["2", j, best_hist_2[j], score_opt_2, i])
                    push!(results, ["3", j, best_hist_3[j], score_opt_3, i])
                    push!(results, ["4", j, best_hist_4[j], score_opt_4, i])
                end
            end
        end
    end
    return results
end

res1 = plots("C:/Users/basti/Documents/GitHub/PS_in_AI/instances/plots", max_sol_length = 30)
