function cross2d(x,y)
    return x[1]*y[2] - x[2]*y[1]
end

function intersect_line(ls1::NTuple{2,T},ls2::NTuple{2,S}) where {T<:AbstractVector,S<:AbstractVector}
    r = ls1[2] - ls1[1]
    s = ls2[2] - ls2[1]
    qmp = ls2[1]-ls1[1]
    d = cross2d(r,s)
    un = cross2d(qmp,r)
    d == 0.0 && (return un == 0.0)
    return (0 < un/d < 1) && (0 < cross2d(qmp, s)/d < 1)
end

function get_angle(p_pro,p_cur,p_pre)
    r = p_pro - p_cur
    p = p_pre - p_cur
    t = atan(cross2d(p,r),dot(p,r))
    return t > 0 ? t : t + 2pi
end

function intersect_hull(ls, hull)
    v = hull.vertices
    np = length(v)
    if np < 3
        return false
    end
    for i = 1:(np-2)
        if intersect_line(ls,(v[i+1],v[i]))
            return true
        end
    end
    return false
end

# In Julia v0.7 and above, indmax cannot be used with generators.
# In a future version, we should be able to replace this function
# with Base.argmax(f, itr)
function indmax_f(f::Function, itr::AbstractVector)
    imax = firstindex(itr)
    vmax = f(itr[imax])
    for i in (firstindex(itr)+1):lastindex(itr)
        v = f(itr[i])
        if v > vmax
            vmax = v
            imax = i
        end
    end
    imax
end

function concave_hull(tree::KDTree, k::Int)
    npoints = length(tree.data)
    k = clamp(k, 3, npoints-1)
    hull = Hull(eltype(tree.data), k)

    #Start at point with largest x value
    i0 = indmax_f(v -> v[1], tree.data)

    ishull = zeros(Bool,npoints)
    ishull[i0] = true

    #Initiate hull
    p0 = copy(tree.data[i0])
    push!(hull.vertices,p0)

    #Allocate point arrays
    p_cur = copy(p0)
    p_pre = p_cur + [1, 0]
    p_pro = copy(p0)

    nstep = 1
    npick = 1
    while npick < npoints
        if nstep == 3
            npick = npick - 1
            ishull[i0] = false
        end

        kk = clamp(k, 3 , npoints-npick)
        kind, kdist = knn(tree, p_cur, kk, true, i -> ishull[i])
        angles = collect(get_angle(tree.data[i], p_cur, p_pre) for i in kind)
        w = sortperm(angles,rev=true)
        inter = true
        for i in kind[w]
            p_pro = tree.data[i]
            if ~intersect_hull((p_pro,p_cur),hull)
                p_pre = p_cur
                p_cur = tree.data[i]
                ishull[i] = true
                inter = false
                break
            end
        end

        if inter
            if k+1 >= npoints
                @info("Unable to construct concave hull")
                return hull
            end
            return concave_hull(tree, k+1)
        end

        if p_cur != p0
            push!(hull.vertices, copy(p_cur))
            npick = npick + 1
        else
            break
        end
        nstep = nstep + 1
    end

    if any(~in_hull(p,hull) for p in tree.data[.~(ishull)])
        if k+1 >= npoints
            @info("Unable to construct concave hull")
            return hull
        end
        return concave_hull(tree, k+1)
    end

    return hull
end

function concave_hull(points::Vector, k::Int = 3)
    p = unique(points)
    npoints = length(p)
    npoints < 3 && throw(ArgumentError("Number of unique points should be greater then 2"))
    npoints == 3 && return Hull(points,k)
    tree = KDTree(hcat(points...),reorder=false)
    return concave_hull(tree, k)
end
