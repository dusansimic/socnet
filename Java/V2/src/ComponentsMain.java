import java.util.Iterator;
import java.util.List;
import java.util.Set;

import edu.uci.ics.jung.algorithms.cluster.WeakComponentClusterer;
import edu.uci.ics.jung.graph.UndirectedSparseGraph;

public class ComponentsMain {

	public static void main(String[] args) {
		
		UndirectedSparseGraph<String, String> graph = new UndirectedSparseGraph<>();
		graph.addVertex("n1");
		graph.addVertex("n2");
		graph.addVertex("n3");
		graph.addVertex("n4");
		graph.addVertex("n5");
		graph.addEdge("e1", "n1", "n2");
		graph.addEdge("e2", "n3", "n4");
		graph.addEdge("e3", "n4", "n5");
		graph.addEdge("e4", "n5", "n3");

		System.out.println("JUNG");
		WeakComponentClusterer<String, String> wcc = new WeakComponentClusterer<>();
		Set<Set<String>> comps = wcc.transform(graph);
		
		Iterator<Set<String>> it = comps.iterator();
		while(it.hasNext()) {
			Set<String> comp = it.next();
			System.out.println(comp);
		}
		System.out.println("--------------------------------------");
		
		ComponentClustererU<String, String> cc = new ComponentsClustererBFS<>(graph);
		List<UndirectedSparseGraph<String, String>> comps1 = cc.getComponents();
		Iterator<UndirectedSparseGraph<String, String>> it1 = comps1.iterator();
		while(it1.hasNext()) {
			UndirectedSparseGraph<String, String> comp = it1.next();
			System.out.println(comp.getVertices());
		}
		System.out.println("giant: " + cc.getGiantComponent().getVertices());
		
	}

}
