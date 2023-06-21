using ParserCombinator
using Graphs
using GraphIO

g = loadgraph("Julia/01_loading_graphs/starwars-episode-1-interactions-allCharacters.gml", "graph", GMLFormat())

# calculate betweenness centrality
bc = betweenness_centrality(g)

# enumerate it so we could retain the ids after it's sorted
ebc = collect(enumerate(bc))

# sort the reusults and print the sorted ids
print(map(x -> x[1], sort!(ebc, by = x -> x[2], rev = true)))

# sortperm actually returns the ids since they match the index
print(sortperm(bc, rev = true))
