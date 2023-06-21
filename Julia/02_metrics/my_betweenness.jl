using ParserCombinator
using PrettyPrint
using Graphs
using GraphIO
using IterTools
using DataStructures
include("all_paths.jl")

g = loadgraph("Julia/01_loading_graphs/starwars-episode-1-interactions-allCharacters.gml", "graph", GMLFormat())


function _betweenness_centrality_paths_func(g::SimpleGraph, paths_func::Function)
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

        paths = paths_func(g, v1, v2)
        shortest_length = minimum(length, paths)
        shortest_paths = filter(p -> length(p) == shortest_length, paths)
        n_shortest = length(shortest_paths)
        n_v_shortest = length(filter(p -> v in p, shortest_paths))
        bc[v] += n_v_shortest / n_shortest
      end
    end

    bc[v] /= ((n - 1) * (n - 2))
  end

  # @show bc
  return bc
end

function betweenness_centrality_bfs(g::SimpleGraph)
  _betweenness_centrality_paths_func(g, bfs_paths)
end

function _bfs_dp_matrix(g::SimpleGraph, start_v::Int64, D::Matrix{Int64}, P::Matrix{Int64})
  visited = Dict{Int64,Bool}(v => false for v in vertices(g))
  q = Queue{Int64}()

  visited[start_v] = true
  enqueue!(q, start_v)

  while !isempty(q)
    curr = dequeue!(q)
    for v in neighbors(g, curr)
      if visited[v]
        if D[start_v, v] == D[start_v, curr] + 1
          P[start_v, v] += P[start_v, curr]
        end
      else
        visited[v] = true
        enqueue!(q, v)
        D[start_v, v] = D[start_v, curr] + 1
        if curr == start_v
          P[start_v, v] = 1
        else
          P[start_v, v] = P[start_v, curr]
        end
      end
    end
  end
  D, P
end

function betw_cent_dp_mat(g::SimpleGraph)
  n_v = nv(g)
  D = zeros(Int64, n_v, n_v)
  P = zeros(Int64, n_v, n_v)

  for v in vertices(g)
    D, P = _bfs_dp_matrix(g, v, D, P)
  end

  D, P
end

function betw_cent_vertex_val(g::SimpleGraph, z::Int64, D::Matrix{Int64}, P::Matrix{Int64})
  bc = 0
  vs = vertices(g)

  for x in vs
    if z == x
      continue
    end
    for y in vs
      if z == y || x == y
        continue
      end

      σ = D[x, y]
      σ_z = 0
      if D[x, y] == D[x, z] + D[y, z]
        σ_z = P[x, z] * P[z, y]
      end
      # @show σ_z σ
      bc += σ_z / σ
    end
  end

  n_v = nv(g)
  bc / ((n_v - 1) * (n_v - 2))
end

function betw_cent_vertices_val_dp_mat(g::SimpleGraph)
  D, P = betw_cent_dp_mat(g)
  bc = zeros(nv(g))

  for v in vertices(g)
    bc[v] = betw_cent_vertex_val(g, v, D, P)
  end

  bc
end

println(betweenness_centrality(g))
println(betweenness_centrality_bfs(g))
println(betw_cent_vertices_val_dp_mat(g))
