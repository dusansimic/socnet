using ParserCombinator
using Graphs
using GraphIO
using Statistics

g = loadgraph("Julia/01_loading_graphs/starwars-episode-1-interactions-allCharacters.gml", "graph", GMLFormat())

function my_closeness_centrality(g::SimpleGraph)
  n = nv(g)
  cc = zeros(n)

  for v in vertices(g)
    dists = dijkstra_shortest_paths(g, v).dists
    dists_without_v = filter(d -> d != 0, dists)
    fracs = map(d -> 1 / d, dists_without_v)
    cc[v] = sum(fracs) / (n - 1)
  end

  return cc
end


print(closeness_centrality(g, normalize = false))
print(my_closeness_centrality(g))
