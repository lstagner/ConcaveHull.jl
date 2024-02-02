using ConcaveHull
using Test

# Triangle
p = [[-1.0,0.0],[1.0,0.0],[0.0,1.0]]
h = concave_hull(p)
@test Set(h.vertices) == Set(p)
@test h.converged
@test area(h) == 0.5*2
@test in_hull([0.0,0.5], h)
@test !in_hull([3.0, 3.0], h)

# Triangle enclosing point
p = [[-1.0,0.0],[1.0,0.0],[0.0,1.0],[0.0,0.5]]
h = concave_hull(p)
@test h.converged
@test Set(p[1:3]) == Set(h.vertices)

# Square
p = [[-1.0,0.0],[1.0,0.0],[1.0,2.0],[-1.0,2.0]]
h = concave_hull(p)
@test Set(h.vertices) == Set(p)
@test area(h) == 4.0
@test h.converged

# Square with multiple points on one side
p = [[-1.0,0.0], [1.0,0.0], [1.0,0.25], [1.0,0.5], [1.0,0.75],
     [1.0,1.0], [1.0,1.25], [1.0,1.5], [1.0,1.75], [1.0,2.0], [-1.0,2.0]]
h = concave_hull(p)
@test area(h) == 4.0
@test h.converged

# Square enclosing point
p = [[-1.0,0.0],[1.0,0.0],[1.0,2.0],[-1.0,2.0],[0.0,1.0]]
h = concave_hull(p)
@test Set(p[1:4]) == Set(h.vertices)
@test h.converged

# Square enclosing many points
p = [[-1.0,0.0],[1.0,0.0],[1.0,2.0],[-1.0,2.0]]
pr = [[-0.99,0.01] + 1.98*rand(2) for i=1:100]
h = concave_hull(vcat(p,pr))
@test issubset(Set(p), Set(h.vertices))
@test h.converged

# Test non-convergence case
p = [[-1.0, -1.0], [0.0, 0.0], [1.0, 1.0], [2.0, 2.0]]
h = concave_hull(p)
@test h.converged == false
