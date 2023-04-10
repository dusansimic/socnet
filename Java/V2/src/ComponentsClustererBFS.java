import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;

import edu.uci.ics.jung.graph.UndirectedSparseGraph;

public class ComponentsClustererBFS<V, E> implements ComponentClustererU<V, E>{
	
	//input
	private UndirectedSparseGraph<V, E> g;
	
	//output
	private List<UndirectedSparseGraph<V, E>> components;
	
	private Set<V> visited = new HashSet<>();
	
	
	public ComponentsClustererBFS(UndirectedSparseGraph<V, E> g) {
		if(g == null || g.getVertexCount() == 0) {
			throw new IllegalArgumentException("Empty network");
		}
		this.g = g;
		components = new ArrayList<>();
		identifyComponents();
	}
	
	private void identifyComponents() {
		for (V node : g.getVertices()) {
			if (!visited.contains(node)) {
				identifyComponent(node);
			}
		}
		
		Collections.sort(components, (c1, c2) -> c2.getVertexCount() - c1.getVertexCount());
	}

	private void identifyComponent(V startNode) {
		//LinkedList ima sama po sebi osobine reda opsluzivanja
		LinkedList<V> queue = new LinkedList<>();
		queue.add(startNode);
		visited.add(startNode);
		UndirectedSparseGraph<V, E> component = new UndirectedSparseGraph<>();
		component.addVertex(startNode);
		
		while(!queue.isEmpty()) {
			V current = queue.removeFirst();
			for (V neighbor : g.getNeighbors(current)) {
				if (!visited.contains(neighbor)) {
					visited.add(neighbor);
					queue.addLast(neighbor);
					component.addVertex(neighbor);
				}
				
				E link;
				if ((link = component.findEdge(current, neighbor)) == null) {
					component.addEdge(link, current, neighbor);
				}
			}
		}
		components.add(component);
	}

	@Override
	public List<UndirectedSparseGraph<V, E>> getComponents() {
		return components;
	}

	@Override
	public UndirectedSparseGraph<V, E> getGiantComponent() {
		return components.get(0);
	}

}
