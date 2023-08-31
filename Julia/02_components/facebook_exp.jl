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
all_files = readdir("/facebook_data", join=true)

facebook_graph = SimpleGraph(4039)

for f in filter(f -> endswith(f, ".edges"), all_files)
  ego_v = parse(Int64, match(r".*/(\d+).edges", f).captures[1]) + 1
  for line in eachline(f)
    i, j = split(line, " ")
    i, j = parse(Int64, i) + 1, parse(Int64, j) + 1
    add_edge!(facebook_graph, i, j)
    add_edge!(facebook_graph, ego_v, i)
    add_edge!(facebook_graph, ego_v, j)
  end
end

for line in eachline("/facebook_data/facebook_combined.txt")
  i, j = split(line, " ")
  add_edge!(facebook_graph, parse(Int64, i) + 1, parse(Int64, j) + 1)
end

@show nv(facebook_graph)
@show ne(facebook_graph)

println("$(now()): Calculating core number...")
core_num = core_number(facebook_graph)
save_object("/out/facebook_core_num.jld2", core_num)
println("$(now()): Calculating degree...")
deg = degree(facebook_graph)
save_object("/out/facebook_degree.jld2", deg)
println("$(now()): Calculating betweenness...")
betw = betweenness_centrality(facebook_graph)
save_object("/out/facebook_betweenness.jld2", betw)
println("$(now()): Calculating closeness...")
clos = closeness_centrality(facebook_graph)
save_object("/out/facebook_closeness.jld2", clos)

println("$(now()): Calculating Pearson correlations...")
correlations = cor([core_num deg betw clos], dims=1)
save_object("/out/facebook_pearson_correlation.jld2", correlations)

println("$(now()): Calculating Spearman correlations...")
spearman_correlation = Iterators.product([core_num, deg, betw, clos], [core_num, deg, betw, clos]) |> collect |> m -> map(x -> corspearman(x[1], x[2]), m)
save_object("/out/facebook_spearman_correlation.jld2", spearman_correlation)

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

    distances = Matrix{Int64}(undef, num_nodes, num_nodes)
    for v in vertices(graph_of_connected_component)
      dists = Parallel.dijkstra_shortest_paths(graph_of_connected_component, v).dists
      for (i, d) in enumerate(dists)
        distances[v, i] = d
      end
    end
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
characteristics = macroscopic_characteristics_analysis(facebook_graph)
save_object("/out/facebook_characteristics.jld2", characteristics)
