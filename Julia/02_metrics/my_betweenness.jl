using ParserCombinator
using PrettyPrint
using Graphs
using GraphIO
using IterTools
include("all_paths.jl")

g = loadgraph("Julia/01_loading_graphs/starwars-episode-1-interactions-allCharacters.gml", "graph", GMLFormat())


function betweenness_centrality_dumb(g::SimpleGraph)
  n = nv(g)
  bc = zeros(n)

  vs = vertices(g)
  for v in vs
    for v1 in vs
      if v == v1
        continue
      end

      for v2 in vs
        if v == v2 || v1 == v2
          continue
        end

        paths = all_paths(g, v1, v2)
        shortest_length = minimum(length, paths)
        shortest_paths = filter(p -> length(p) == shortest_length, paths)
        n_shortest = length(shortest_paths)
        n_v_shortest = length(filter(p -> v in p, shortest_paths))
        bc[v] += n_v_shortest / n_shortest
      end
    end

    bc[v] /= ((n-1) * (n-2))
  end

  # @show bc
  return bc
end

print(betweenness_centrality(g))
print(betweenness_centrality_dumb(g))
