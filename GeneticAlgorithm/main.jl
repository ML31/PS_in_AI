using JSON
using Printf
include("edit_distance.jl")
include("GA.jl")

println("Path to problem instance:")
path = readline()

problem = JSON.parsefile(path)


alphabet = problem["alphabet"]
strs = Vector{String}(problem["strings"])
problem["str_length"]
println("Problem:")
println("Alphabet: $alphabet")
println("Input strings:")
for str in strs
    println("\t", str)
end

#Random.seed!(0)
(best, ), t, = @timed GeneticOptimization(alphabet, strs,
    N_pop=150, max_length=30, n_max=150,
    cre_p=0.23, dupl_p=0.20, mut_p=0.35, cross_p=0.22, warm_start=true)


d = sum(edit_distance(best, s, zeros(Int,100,100)) for s in strs)
println(@sprintf "Found %s with edit distance %d and length %d in %.2fs." best d length(best) t)
