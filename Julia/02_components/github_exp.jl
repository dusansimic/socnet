using Pkg
Pkg.add("Graphs")
Pkg.add("JLD2")
Pkg.add("Plots")
Pkg.add("StatsBase")

using Graphs
using Graphs.Parallel
using JLD2
using Plots
using StatsBase
using Statistics
using Distributed
using Dates

ENV["GKSwstype"] = "nul"

println("$(now()): Loading graph...")
github_graph = SimpleGraph(37700)

for line in eachline("/github_data/musae_git_edges.csv")
  i, j = split(line, ",")
  add_edge!(github_graph, parse(Int64, i) + 1, parse(Int64, j) + 1)
end

@show nv(github_graph)
@show ne(github_graph)

println("$(now()): Calculating core number...")
core_num = core_number(github_graph)
save_object("/out/github_core_num.jld2", core_num)
println("$(now()): Calculating degree...")
deg = degree(github_graph)
save_object("/out/github_degree.jld2", deg)
println("$(now()): Calculating betweenness...")
betw = betweenness_centrality(github_graph)
save_object("/out/github_betweenness.jld2", betw)
println("$(now()): Calculating closeness...")
clos = closeness_centrality(github_graph)
save_object("/out/github_closeness.jld2", clos)

println("$(now()): Calculating Pearson correlations...")
correlations = cor([core_num deg betw clos], dims=1)
save_object("/out/github_pearson_correlation.jld2", correlations)

println("$(now()): Calculating Spearman correlations...")
spearman_correlation = Iterators.product([core_num, deg, betw, clos], [core_num, deg, betw, clos]) |> collect |> m -> map(x -> corspearman(x[1], x[2]), m)
save_object("/out/github_spearman_correlation.jld2", spearman_correlation)

function macroscopic_characteristics_analysis(g::SimpleGraph)
  G = SimpleGraph(nv(g))
  for e in edges(g)
    add_edge!(G, e.src, e.dst)
  end

  k = 0
  characteristics = Vector{Vector{Float64}}()

  while true
    while true
      δ = [i for i in 1:nv(G) if degree(G, i) < k]
      if length(δ) == 0
        break
      end
      rem_vertices!(G, δ)
    end

    if nv(G) == 0
      break
    end

    num_nodes = nv(G)
    num_edges = ne(G)

    graph_density = (2 * num_edges) / (num_nodes * (num_nodes - 1))

    all_connected_components = connected_components(G)
    number_of_connected_components = length(all_connected_components)
    largest_connected_component = argmax(length, all_connected_components)
    graph_of_connected_component, _vmap = induced_subgraph(G, largest_connected_component)

    percentage_of_nodes_in_gcc = length(vertices(graph_of_connected_component)) / num_nodes
    percentage_of_edges_in_gcc = length(edges(graph_of_connected_component)) / num_edges

    distances = Parallel.floyd_warshall_shortest_paths(graph_of_connected_component).dists
    sum_of_distances = sum(distances)
    smallworldness = sum_of_distances / (num_nodes * (num_nodes - 1))

    diam = diameter(graph_of_connected_component)
    clustering_coefficient = global_clustering_coefficient(graph_of_connected_component)

    push!(characteristics, [
      convert(Float64, k),
      convert(Float64, num_nodes),
      convert(Float64, num_edges),
      graph_density,
      convert(Float64, number_of_connected_components),
      percentage_of_nodes_in_gcc,
      percentage_of_edges_in_gcc,
      smallworldness,
      convert(Float64, diam),
      clustering_coefficient
    ])
    println("$(now()): Done k = $k")
    k += 1
  end

  hcat(characteristics...)
end

println("$(now()): Calculating characteristics...")
characteristics = macroscopic_characteristics_analysis(github_graph)
save_object("/out/github_characteristics.jld2", characteristics)
