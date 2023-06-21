using ParserCombinator
using Graphs
using GraphIO

g = loadgraph("Julia/01_loading_graphs/starwars-episode-1-interactions-allCharacters.gml", "graph", GMLFormat())

function my_degree_centrality(g::SimpleGraph{Int64})
  n = nv(g)
  dc = zeros(n)

  for (v, d) in enumerate(degree(g))
    dc[v] = d
  end

  return map(d -> d / (n - 1), dc)
end
  
print(degree_centrality(g))
print(my_degree_centrality(g))
