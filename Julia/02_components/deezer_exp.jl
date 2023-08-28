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

ENV["GKSwstype"] = "nul"

println("$(now()): Loading graph...")
deezer_graph = SimpleGraph(28281)

for line in eachline("/deezer_data/deezer_europe_edges.csv")
  i, j = split(line, ",")
  add_edge!(deezer_graph, parse(Int64, i) + 1, parse(Int64, j) + 1)
end

@show nv(deezer_graph)
@show ne(deezer_graph)

println("$(now()): Calculating core number...")
core_num = core_number(deezer_graph)
save_object("/out/deezer_core_num.jld2", core_num)
println("$(now()): Calculating degree...")
deg = degree(deezer_graph)
save_object("/out/deezer_degree.jld2", deg)
println("$(now()): Calculating betweenness...")
betw = betweenness_centrality(deezer_graph)
save_object("/out/deezer_betweenness.jld2", betw)
println("$(now()): Calculating closeness...")
clos = closeness_centrality(deezer_graph)
save_object("/out/deezer_closeness.jld2", clos)

println("$(now()): Calculating Pearson correlations...")
correlations = cor([core_num deg betw clos], dims=1)
save_object("/out/deezer_pearson_correlation.jld2", correlations)

# pearson_heatmap = heatmap(["core number", "degree", "betweenness", "closeness"], ["core number", "degree", "betweenness", "closeness"], correlations, c=:blues)
# Plots.svg(pearson_heatmap, "/out/deezer_pearson_correlation.svg")

# plot_shell_deg = scatter(core_num, deg, xlabel="core number", ylabel="degree", legend=false)
# plot_shell_betw = scatter(core_num, betw, xlabel="core number", ylabel="betweenness", legend=false)
# plot_shell_clos = scatter(core_num, clos, xlabel="core number", ylabel="closeness", legend=false)

# correlation_scatter = plot(plot_shell_deg, plot_shell_betw, plot_shell_clos, layout=(1, 3), size=(1200, 400))

# Plots.svg(correlation_scatter, "/out/deezer_correlation_scatter")

println("$(now()): Calculating Spearman correlations...")
spearman_correlation = Iterators.product([core_num, deg, betw, clos], [core_num, deg, betw, clos]) |> collect |> m -> map(x -> corspearman(x[1], x[2]), m)
save_object("/out/deezer_spearman_correlation.jld2", spearman_correlation)

# spearman_heatmap = heatmap(["core number", "degree", "betweenness", "closeness"], ["core number", "degree", "betweenness", "closeness"], spearman_correlation, c=:blues)

# Plots.svg(spearman_heatmap, "/out/deezer_spearman_correlation.svg")

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
characteristics = macroscopic_characteristics_analysis(deezer_graph)
save_object("/out/deezer_characteristics.jld2", characteristics)

# ks = map(i -> convert(Int64, i), characteristics[1, :])

# nums_nodes = map(i -> convert(Int64, i), characteristics[2, :])
# nums_edges = map(i -> convert(Int64, i), characteristics[3, :])
# graph_densities = characteristics[4, :]
# nums_connected_components = map(i -> convert(Int64, i), characteristics[5, :])
# percentages_of_nodes_in_gcc = characteristics[6, :]
# percentages_of_edges_in_gcc = characteristics[7, :]
# smallworldnesses = characteristics[8, :]
# diameters = map(i -> convert(Int64, i), characteristics[9, :])
# clustering_coefficients = characteristics[10, :]

# plot_shell_num_nodes = scatter(ks, nums_nodes, xlabel="k", ylabel="number of nodes", legend=false)
# plot_shell_num_edges = scatter(ks, nums_edges, xlabel="k", ylabel="number of edges", legend=false)
# plot_shell_graph_density = scatter(ks, graph_densities, xlabel="k", ylabel="graph density", legend=false)
# plot_shell_num_connected_components = scatter(ks, nums_connected_components, xlabel="k", ylabel="number of connected components", legend=false)
# plot_shell_percentage_of_nodes_in_gcc = scatter(ks, percentages_of_nodes_in_gcc, xlabel="k", ylabel="percentage of nodes in gcc", legend=false)
# plot_shell_percentage_of_edges_in_gcc = scatter(ks, percentages_of_edges_in_gcc, xlabel="k", ylabel="percentage of edges in gcc", legend=false)
# plot_shell_smallworldness = scatter(ks, smallworldnesses, xlabel="k", ylabel="smallworldness", legend=false)
# plot_shell_diameter = scatter(ks, diameters, xlabel="k", ylabel="diameter", legend=false)
# plot_shell_clustering_coefficient = scatter(ks, clustering_coefficients, xlabel="k", ylabel="clustering coefficient", legend=false)

# characteristics_plots = plot(plot_shell_num_nodes, plot_shell_num_edges, plot_shell_graph_density, plot_shell_num_connected_components, plot_shell_percentage_of_nodes_in_gcc, plot_shell_percentage_of_edges_in_gcc, plot_shell_smallworldness, plot_shell_diameter, plot_shell_clustering_coefficient, layout=(3, 3), size=(1200, 800))

# Plots.svg(characteristics_plots, "/out/deezer_characteristics.svg")
