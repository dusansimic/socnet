using ParserCombinator
using Graphs
using GraphIO

g = loadgraph("Julia/01_loading_graphs/starwars-episode-1-interactions-allCharacters.gml", "graph", GMLFormat())

nv(g)
