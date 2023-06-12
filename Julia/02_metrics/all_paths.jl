using ParserCombinator
using Graphs
using GraphIO
using DataStructures
using Karnak
using NetworkLayout
using Colors

# g = loadgraph("Julia/01_loading_graphs/starwars-episode-1-interactions-allCharacters.gml", "graph", GMLFormat())

# @drawsvg begin
#   background("black")
#   sethue("grey40")
#   fontsize(8)
#   drawgraph(g,
#     layout=stress,
#     vertexlabels = 1:nv(g),
#     vertexfillcolors = 
#       [RGB(rand(3)/2...)
#         for i in 1:nv(g)]
#   )
# end

function all_paths(g::SimpleGraph, s::Int64, d::Int64)
  ps = Vector{Vector{Int64}}()

  q = Queue{Vector{Int64}}()
  vis = Dict{Int64, Bool}(v => false for v in vertices(g))
  enqueue!(q, [s])
  while !isempty(q)
    p = dequeue!(q)
    if last(p) == d
      append!(ps, [p[2:end-1]])
    else
      neigh = neighbors(g, last(p))
      for v in neigh
        if !vis[v]
          new_p = Vector{Int64}()
          copy!(new_p, p)
          append!(new_p, v)
          enqueue!(q, new_p)
        end
      end
      vis[last(p)] = true
    end
  end

  return ps
end

# print(all_paths(g, 20, 23))