module ConcaveHull

using NearestNeighbors
using RecipesBase
using LinearAlgebra

include("hull.jl")
include("concave_hull.jl")

export concave_hull, in_hull, area

@recipe function f(h::Hull)
    linewidth --> 2
    label --> ""
    v = copy(h.vertices)
    push!(v,v[1])
    x = [vv[1] for vv in v]
    y = [vv[2] for vv in v]
    x, y
end

end # module
