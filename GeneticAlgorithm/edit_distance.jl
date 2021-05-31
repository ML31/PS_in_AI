
function edit_distance(s1::String, s2::String, Dist::Array{Int64,2})
    n1 = length(s1)+1
    n2 = length(s2)+1

    Dist[1:n1,1] = 0:(n1-1)
    Dist[1,1:n2] = 0:(n2-1)

    for i in 2:n1, j in 2:n2
        Dist[i,j] = min(Dist[i-1,j]+1, Dist[i,j-1]+1, Dist[i-1,j-1] + (s1[i-1] == s2[j-1] ? 0 : 2))
    end

    return Dist[n1,n2]
end
