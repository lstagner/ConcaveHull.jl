struct Hull{T<:AbstractVector}
    vertices::Vector{T}
    k::Int
end

Hull(::Type{T},k::Int) where {T<:AbstractVector} = Hull(T[],k)

function is_left(p0,p1,p2)
    return ((p1[1] - p0[1]) * (p2[2] - p0[2]) - (p2[1] -  p0[1]) * (p1[2] - p0[2]))
end

function in_hull(p,hull::Hull)

    v = copy(hull.vertices)
    push!(v,hull.vertices[1])
    nv = length(v)
    wn = 0
    @inbounds for i = 1:nv-1
        if v[i][2] <= p[2]
            if v[i+1][2] > p[2]
                if is_left(v[i],v[i+1],p) > 0.0
                    wn = wn +1
                end
            end
        else
            if v[i+1][2] <= p[2]
                if is_left(v[i],v[i+1],p) < 0.0
                    wn = wn - 1
                end
            end
        end
    end
    if wn == 0
        return false
    else
        return true
    end
end

function signed_area(h::Hull)
    v = h.vertices
    if v[end] == v[1]
        n = length(v)-1
    else
        n = length(v)
    end

    n < 3 && return 0.0

    A1 = 0.0
    @inbounds for i=1:n-1
        A1 = A1 + v[i][1]*v[i+1][2]
    end
    A1 = A1 + v[n][1]*v[1][2]

    A2 = 0.0
    @inbounds for i=1:n-1
        A2 = A2 + v[i+1][1]*v[i][2]
    end
    A2 = A2 + v[1][1]*v[n][2]

    return (A1 - A2)/2
end

area(h::Hull) = abs(signed_area(h))

orientation(h::Hull) = sign(signed_area(h))

function Base.show(io::IO, hull::Hull)
    println(io, typeof(hull))
    println(io, "  Number of vertices: ", length(hull.vertices))
    println(io, "  Number of neighbors used: ", hull.k)
end
