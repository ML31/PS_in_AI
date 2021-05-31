

using JSON
include("edit_distance.jl")
include("GA.jl")


problem = JSON.parsefile("C:/Users/basti/Documents/GitHub/PS_in_AI/instances/p2/p2_15_3-4.txt")


alphabet = problem["alphabet"]
strs = Vector{String}(problem["strings"])
problem["str_length"]


#Random.seed!(0)
@time best = GeneticOptimization(alphabet, strs,
    N_pop=150, max_length=30, n_max=150,
    cre_p=1., dupl_p=0., mut_p=0., cross_p=0., warm_start=false)


sum(edit_distance(best, s, zeros(Int,100,100)) for s in strs)
length(best)


using BenchmarkTools

#@btime sum(edit_distance(best, s, zeros(Int,100,100)) for s in strs)
