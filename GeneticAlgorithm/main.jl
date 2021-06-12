using JSON
include("edit_distance.jl")
include("GA.jl")


problem = JSON.parsefile("C:/Users/basti/Documents/GitHub/PS_in_AI/instances/p2/p2_15_3-3.txt")


alphabet = problem["alphabet"]
strs = Vector{String}(problem["strings"])
problem["str_length"]

best = GeneticOptimization(alphabet, strs,
    N_pop=150, max_length=30, n_max=150,
    cre_p=0.23, dupl_p=0.2, mut_p=0.35, cross_p=0.23, warm_start=true)
