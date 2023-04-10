package primer02;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;

import org.apache.commons.collections15.Transformer;

import edu.uci.ics.jung.graph.UndirectedSparseGraph;
import edu.uci.ics.jung.io.GraphIOException;
import edu.uci.ics.jung.io.graphml.EdgeMetadata;
import edu.uci.ics.jung.io.graphml.GraphMLReader2;
import edu.uci.ics.jung.io.graphml.GraphMetadata;
import edu.uci.ics.jung.io.graphml.HyperEdgeMetadata;
import edu.uci.ics.jung.io.graphml.NodeMetadata;

public class Import {

	public static void main(String[] args) throws FileNotFoundException, GraphIOException {

		BufferedReader br = new BufferedReader(new FileReader("res/simple.graphml"));
		
		//transformer za graf
		Transformer<GraphMetadata, UndirectedSparseGraph<SimpleNode, SimpleLink>> graphT = new Transformer<GraphMetadata, UndirectedSparseGraph<SimpleNode,SimpleLink>>() {

			@Override
			public UndirectedSparseGraph<SimpleNode, SimpleLink> transform(GraphMetadata metadata) {
				return new UndirectedSparseGraph<>();
			}
		};
		
		//transformer za cvorove
		Transformer<NodeMetadata, SimpleNode> nodeT = new Transformer<NodeMetadata, SimpleNode>() {

			@Override
			public SimpleNode transform(NodeMetadata metadata) {
				String id = metadata.getId();
				return new SimpleNode(id);
			}
		};
		
		//transformer za grane
		Transformer<EdgeMetadata, SimpleLink> linkT = new Transformer<EdgeMetadata, SimpleLink>() {

			@Override
			public SimpleLink transform(EdgeMetadata metadata) {
				return new SimpleLink();
			}
		};
		
		//transformer za hiperlinkove
		Transformer<HyperEdgeMetadata, SimpleLink> hyperT = new Transformer<HyperEdgeMetadata, SimpleLink>() {

			@Override
			public SimpleLink transform(HyperEdgeMetadata arg0) {
				return new SimpleLink();
			}
		};
		
		//citamo
		GraphMLReader2<UndirectedSparseGraph<SimpleNode, SimpleLink>, SimpleNode, SimpleLink> reader = new GraphMLReader2<>(br, graphT, nodeT, linkT, hyperT);
		
		UndirectedSparseGraph<SimpleNode, SimpleLink> graph = reader.readGraph();
		System.out.println(graph);
	}

}
