struct Hull{T<:AbstractVector}
    vertices::Vector{T}
    k::Int
    converged::Bool
end

Hull(::Type{T},k::Int) where {T<:AbstractVector} = Hull(T[],k, false)

function is_left(p0,p1,p2)
    return ((p1[1] - p0[1]) * (p2[2] - p0[2]) - (p2[1] -  p0[1]) * (p1[2] - p0[2]))
end

function in_hull(p, hull::Hull)
    wn = 0
    nv = length(hull.vertices)
    @inbounds for i = 1:nv
        current = hull.vertices[i]
        next = hull.vertices[mod1(i + 1, nv)]
        if current[2] <= p[2]
            if next[2] > p[2]
                if is_left(current, next, p) > 0.0
                    wn += 1
                end
            end
        else
            if next[2] <= p[2]
                if is_left(current, next, p) < 0.0
                    wn -= 1
                end
            end
        end
    end

    return wn != 0
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
