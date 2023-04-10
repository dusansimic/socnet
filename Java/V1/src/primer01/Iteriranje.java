package primer01;

import java.util.Collection;
import java.util.Iterator;

import edu.uci.ics.jung.graph.UndirectedSparseGraph;
import edu.uci.ics.jung.graph.util.Pair;

public class Iteriranje {

	public static void main(String[] args) {
		
		//kreiramo prazan graf
		UndirectedSparseGraph<Node, Link> mreza = new UndirectedSparseGraph<>();
		
		//kreiramo cvorove i dodamo ih u mrezu
		Node mika = new Node("mika");
		mreza.addVertex(mika);
		Node pera = new Node("pera");
		mreza.addVertex(pera);
		Node zika = new Node("zika");
		mreza.addVertex(zika);
		Node tika = new Node("tika");
		mreza.addVertex(tika);
		
		
		//dodamo linkove u mrezu
		mreza.addEdge(new Link("l1"), mika, pera);
		mreza.addEdge(new Link("l2"), mika, zika);
		mreza.addEdge(new Link("l3"), zika, pera);
		mreza.addEdge(new Link("l4"), pera, tika);
		
		//iteriranje po cvorovima i njihovim susedima
		for (Node n : mreza.getVertices()) {
			Collection<Node> susedi = mreza.getNeighbors(n);
			System.out.println(n.getLabel() + " ima " + susedi.size() + " suseda: ");
			
			for (Node s : susedi) {
				System.out.println(s.getLabel());
			}
		}
		
		
		//iteriranje po linkovima
		for (Link l : mreza.getEdges()) {
			Pair<Node> nodepair = mreza.getEndpoints(l);
			Node first = nodepair.getFirst();
			Node second = nodepair.getSecond();
			
			System.out.println("Link " + l.getLabel() + " povezuje " + first.getLabel() + " i " + second.getLabel());
		}
	}
	
}
