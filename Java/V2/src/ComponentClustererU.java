import java.util.List;

import edu.uci.ics.jung.graph.UndirectedSparseGraph;

public interface ComponentClustererU<V, E> {
	List<UndirectedSparseGraph<V, E>> getComponents();
	UndirectedSparseGraph<V, E> getGiantComponent();
}
