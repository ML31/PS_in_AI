
using Random

# Helper
import Base.argmax
function argmax(f::Function, A::Array)
    fA = f.(A)
    i = Base.argmax(fA)
    return A[i]
end
import Base.argmin
function argmin(f::Function, A::Array)
    fA = f.(A)
    i = Base.argmin(fA)
    return A[i]
end

# creates a random string with characters from alphabet with length n
function rand_string(alphabet, n)
    return reduce(*, rand(alphabet, n))
end

# rank based selection
# fitness is determined by the number of individuals
# a individual is prevailed by
function pareto_fitness(f_pop::Array{Int,1})
    N_pop = length(f_pop)
    fitness = zeros(Int, N_pop)
    for k in 1:N_pop
        fk = f_pop[k]
        n = sum(f_pop .< fk) # number of other individuals k is prevailed by
        fitness[k] = -n # take minus sign since fewer is better
    end
    return fitness
end

# In tournament selections we randomly select K individuals with replacement
# and put the one with best fitness in the mating pool
function tournament_select(fitness::Array{Int,1}, N::Int, K::Int=2)
    N_pop = length(fitness)
    mating_pool = zeros(Int, N_pop)
    for k in 1:N
        contender = rand(1:N_pop, K)
        mating_pool[k] = argmax(c -> fitness[c], contender)
    end
    return mating_pool
end

# reproduction consists of creation, duplication, mutation and crossovers
function reproduce(mating_pool::Array{Int,1}, pop::Vector{String}, N::Int,
    alphabet::String, max_length::Int,
    cre_p::Float64, dupl_p::Float64, mut_p::Float64, cross_p::Float64)

    # helper for selecting creation with probability cre_p,
    # duplication with probability dupl_p, ...
    p_tot = cre_p + dupl_p + mut_p + cross_p
    cre_F, dupl_F, mut_F, cross_F = cumsum([cre_p, dupl_p, mut_p, cross_p])

    next_pop = Vector{String}(undef, size(pop))
    for i in 1:N
        # choose "offspring creation type" according to specified probabilities
        p = rand() * p_tot

        if p ≤ cre_F
            # create new string
            slength = rand(1:max_length)
            new = rand_string(alphabet, slength)
        elseif p ≤ dupl_F
            # duplicate random member of mating pool
            new = pop[mating_pool[rand(1:N)]]
        elseif p ≤ mut_F
            # mutate random member of mating pool
            p2 = rand()
            template = pop[mating_pool[rand(1:N)]]
            t = rand(1:length(template))
            if p2 ≤ 0.33
                # insert char at random position
                new = template[1:t] * rand(alphabet) * template[t:end]
            elseif p2 ≤ 0.66
                # substitute char at random position
                new = template[1:t-1] * rand(alphabet) * template[t:end]
            else
                # delete char at random position
                new = template[1:t-1] * template[t:end]
            end
        else
            # crossover two random members of mating pool at random position
            a, b = mating_pool[rand(1:N,2)] # parents
            t1 = rand(1:length(a)) # crossover point
            t2 = rand(1:length(b))
            new = pop[a][1:t1] * pop[b][t2:end]
        end

        # restrict maximum length of strings
        if length(new) > max_length
            new = new[1:max_length]
        end

        next_pop[i] = new
    end
    return next_pop
end

#=
 Iteratively evaluates population, selects best individuals with (binary)
 tournament selection where the fitness function is rank based, and creates
 offspring by creation, duplication, mutation (insert, delete, substitute chars),
 and crossover to solve the median string problem.

 Parameters:
    alphabet: the characters in form of a string from which new candidate strings are sampled
    strs: the string to which the edit distance is minimized
    N_pop: the number of individuals in the population
    max_length: the maximum length of candidate strings (avoids creating overly long strings)
    n_max: number of itertions

    For reproduction following parameters specify the probability of events:
    cre_p: probability of creating new string
    dupl_p: probability of duplicating string from mating pool
    mut_p: probability of mutating string from mating pool
    cross_p: probability of crossing two strings from mating pool

    Note that for example cre_p = dupl_p = 2, mut_p = cross_p = 3 corresponds to
    probabilities cre_p = dupl_p = 0.2, mut_p = cross_p = 0.3.

    warm_start: if set to true the input strings strs will be put in the initial population
=#
function GeneticOptimization(alphabet::String, strs::Vector{String}; N_pop::Int,
    max_length::Int, n_max::Int=10^2,
    cre_p::Float64, dupl_p::Float64, mut_p::Float64, cross_p::Float64, warm_start::Bool=false)

    # creation
    max_mat_size = max(findmax(length.(strs))[1], max_length)+1
    mat = zeros(Int, max_mat_size, max_mat_size)         # hardcoded fixed matrix size for performance

    # initialize population
    population = [rand_string(alphabet, rand(1:max_length)) for i in 1:N_pop]

    if warm_start == true
        # add input strings to initial population
        min_size = min(length(strs), N_pop)
        population[1:min_size] = strs[1:min_size]
    end

    #best_hist = [];
    n = 1
    best = population[1]

    while n < n_max
        n += 1

        # evaluate  on population
        f_pop = [sum(edit_distance(s, population[k], mat) for s in strs) for k in 1:N_pop]

        # find best individual
        k = argmin(j -> f_pop[j], collect(1:N_pop))
        if sum(edit_distance(s, population[k], mat) for s in strs) < sum(edit_distance(s, best, mat) for s in strs)
            best = population[k]
        end

        # evaluate fitness
        fitness = pareto_fitness(f_pop)

        # select best individuals
        mating_pool = tournament_select(fitness, N_pop, 2) # mating_pool are indices

        #push!(best_hist, best)

        # create offspring
        population = reproduce(
            mating_pool, population, N_pop, alphabet, max_length,
            cre_p, dupl_p, mut_p, cross_p
        )
    end

    return best#, best_hist
end
