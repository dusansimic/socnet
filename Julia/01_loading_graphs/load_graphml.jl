using EzXML
using Graphs
using GraphIO

g = loadgraph("Java/V1/res/simple.graphml", "G", GraphMLFormat())

nv(g)
