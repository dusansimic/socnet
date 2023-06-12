using ParserCombinator
using Graphs
using GraphIO

g = loadgraph("Julia/01_loading_graphs/starwars-episode-1-interactions-allCharacters.gml", "graph", GMLFormat())

dc = degree_centrality(g)

print(sortperm(dc, rev = true))
