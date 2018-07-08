using ConcaveHull
using Test

# Triangle
p = [[-1.0,0.0],[1.0,0.0],[0.0,1.0]]
h = concave_hull(p)
@test Set(h.vertices) == Set(p)
@test area(h) == 0.5*2

# Triangle enclosing point
p = [[-1.0,0.0],[1.0,0.0],[0.0,1.0],[0.0,0.5]]
h = concave_hull(p)
@test Set(p[1:3]) == Set(h.vertices)

# Square
p = [[-1.0,0.0],[1.0,0.0],[1.0,2.0],[-1.0,2.0]]
h = concave_hull(p)
@test Set(h.vertices) == Set(p)
@test area(h) == 4.0

# Square enclosing point
p = [[-1.0,0.0],[1.0,0.0],[1.0,2.0],[-1.0,2.0],[0.0,1.0]]
h = concave_hull(p)
@test Set(p[1:4]) == Set(h.vertices)

# Square enclosing many points
p = [[-1.0,0.0],[1.0,0.0],[1.0,2.0],[-1.0,2.0]]
pr = [[-0.99,0.01] + 1.98*rand(2) for i=1:100]
h = concave_hull(vcat(p,pr))
@test issubset(Set(p), Set(h.vertices))
