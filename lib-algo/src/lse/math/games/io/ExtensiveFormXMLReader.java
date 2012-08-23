package lse.math.games.io;

import java.io.StringWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import lse.math.games.LogUtils;
import lse.math.games.LogUtils.LogLevel;
import lse.math.games.Rational;
import lse.math.games.tree.ExtensiveForm;
import lse.math.games.tree.Iset;
import lse.math.games.tree.Move;
import lse.math.games.tree.Node;
import lse.math.games.tree.Outcome;
import lse.math.games.tree.Player;

import org.w3c.dom.Document;
//import org.w3c.dom.Node;

public class ExtensiveFormXMLReader 
{	
	private static final Logger log = Logger.getLogger(ExtensiveFormXMLReader.class.getName());
	
	private Map<String,Node> nodes;
	private Map<String,Iset> isets;
	private List<Iset> singletons;
	private Map<String,Move> moves;
	private Map<String,Player> players;
	
	//private Document xml = null;
	private ExtensiveForm tree = null;
	
	public ExtensiveFormXMLReader() {}
	
	public ExtensiveForm load(Document xml)
	{
		LogUtils.logi(LogLevel.SHORT, "~~~~~ Reading the XML >>> ~~~~~");
		
		tree = new ExtensiveForm();
		
		nodes = new HashMap<String,Node>();
		isets = new HashMap<String,Iset>();
		singletons = new ArrayList<Iset>();
		moves = new HashMap<String,Move>();
		players = new HashMap<String,Player>();			
		
//		Just for testing purpose	
//		writeXmlFile(xml, "test.xml");
		
		org.w3c.dom.Node root = xml.getFirstChild();
		if ("extensiveForm".equals(xml.getFirstChild().getNodeName())) {			
			for (org.w3c.dom.Node child = root.getFirstChild(); child != null; child = child.getNextSibling()) {
				if ("iset".equals(child.getNodeName())) {
					processIset(child);
				} else if ("node".equals(child.getNodeName())) {
					processNode(child, null);
				} else if ("outcome".equals(child.getNodeName())) {
					processOutcome(child, null);
				} else {
//					log.warning("Ignoring unknown element:\r\n" + child);
				}
			}
			hookupAndVerifyMoves();
		} else {
			log.warning("Unregonized root elem" + xml.getFirstChild());
		}
		LogUtils.logi(LogLevel.SHORT, "~~~~~ <<< Reading the XML ~~~~~\n");
		
		/* Just for testing purpose */
		LogUtils.logi(LogLevel.SHORT, "~~~~~ Extensive form >>> ~~~~~\n%s~~~~~ <<< Extensive form ~~~~~\n", tree.toString());
		
		return tree;
	}	
	

	// This method writes a DOM document to a file
	public static void writeXmlFile(Document doc, String filename) {
	    try {
	        // Prepare the DOM document for writing
	        Source source = new DOMSource(doc);

	        // Prepare the output file
	        StreamResult result = new StreamResult(new StringWriter());

	        // Write the DOM document to the file
	        Transformer xformer = TransformerFactory.newInstance().newTransformer();
	        xformer.transform(source, result);
	        
	        String xmlString = result.getWriter().toString();
	        LogUtils.logi(LogLevel.DETAILED, xmlString);
	        
	    } catch (TransformerConfigurationException e) {
	    } catch (TransformerException e) {
	    }
	}
	
	//TODO: there has got to be a more efficient algorithm
	private void hookupAndVerifyMoves()
	{
		for (Iset iset = tree.root().iset(); iset != null; iset = iset.next()) 
		{					
			//iset.sort();
			
			//for each child of the first node, hook up move
			log.fine("hooking up moves for iset " + iset.uid());
			Node baseline = iset.firstNode();
			int childIdx = 0;
			for (Node baselineChild = baseline.firstChild(); baselineChild != null; baselineChild = baselineChild.sibling())
			{					
				baselineChild.reachedby.setIset(iset);
				
				log.fine("assigning move " + baselineChild.reachedby + " to iset " + iset.uid() + " at " + childIdx);
				
				// make sure all the rest of the nodes have the child with the same move
				// TODO: it does not necessarily need to be at the same index
				for (Node baselineMate = baseline.nextInIset; baselineMate != null; baselineMate = baselineMate.nextInIset)
				{
					Node mateChild = baselineMate.firstChild();
					for (int i = 0; i < childIdx; ++i) {
						mateChild = mateChild.sibling();
						if (mateChild == null) {
							String msg = "not enough children";
							log.severe(msg);
							throw new RuntimeException(msg);
						}
					}
					
					if (baselineChild.sibling() == null && mateChild.sibling() != null) {
						String msg = "too many children";
						log.severe(msg);
						throw new RuntimeException(msg);
					}
					
					if (mateChild.reachedby != baselineChild.reachedby) {
						if (mateChild.reachedby == null) {
							String msg = "node does not contain an incoming move";
							log.severe(msg);
							//throw new RuntimeException(msg);
						} else {
							String msg = "Iset " + iset.uid() + " is inconsistent for node " + baselineMate.uid() /*+ " at " + baselineMate.setIdx*/ + " for child " + mateChild.uid() + " at " + childIdx + " with move " + mateChild.reachedby;
							log.severe(msg);
							//throw new RuntimeException(msg);
						}
						mateChild.reachedby = baselineChild.reachedby;
					}						
				}
				
				++childIdx;
			}
		}
	}
	
	private Player getPlayer(String playerId)
	{
		if (Player.CHANCE_NAME.equals(playerId)) {
			return Player.CHANCE;
		}
		
		Player player = players.get(playerId);
		if (player == null) {
			player = tree.createPlayer(playerId);
			players.put(playerId, player);
		}
		return player;
	}
	
	private void processIset(org.w3c.dom.Node elem)
	{
		String id = getAttribute(elem, "id");
		Iset iset = isets.get(id);
		
		if (iset == null) {
			String playerId = getAttribute(elem, "player");
			Player player = (playerId != null) ? getPlayer(playerId) : Player.CHANCE;
			iset = tree.createIset(id, player);
			isets.put(id, iset);
		}
		
		for (org.w3c.dom.Node child = elem.getFirstChild(); child != null; child = child.getNextSibling())
		{
			if ("node".equals(child.getNodeName())) {
				processNode(child, null);
			} else {
				log.warning("Ignoring unknown element:\r\n" + child);
			}
		}
	}
	
	private void processNode(org.w3c.dom.Node elem, Node parentNode)
	{
		//init
		Node node = null;
		
		//lookup parent if not passed in
		String parentId = getAttribute(elem, "parent");
		if (parentNode == null && parentId != null) 
		{			
			parentNode = nodes.get(parentId);
			
			if (parentNode == null) {
				log.fine("XMLReader: creating parent node " + parentId);
				parentNode = tree.createNode();						
				nodes.put(parentId, parentNode);
			}			 
		}
		
		String id = getAttribute(elem, "id");
		if (id != null) 
		{
			node = nodes.get(id);
			
			if (node == null) {				
				if (parentNode != null) {
					log.fine("XMLReader: creating new node " + id);	
					node = tree.createNode();
				} else {
					log.fine("XMLReader: No parent... assuming root is node " + id);
					node = tree.root();
				}
				nodes.put(id, node);
			} else {
				log.fine("XMLReader: processing previously created node " + id);				
			}
		} else {
			if (parentNode != null) {
				log.fine("XMLReader: creating new node");	
				node = tree.createNode();
			} else {
				log.fine("XMLReader: No parent... assuming this is the root");
				node = tree.root();
			}
		}
		
		if (parentNode != null) {
			log.fine("XMLReader: processing child of " + parentNode.uid());
			parentNode.addChild(node);
		}
		
		// process iset
		// if parent is an iset use that
		// if iset ref exists use that (make sure player is not also set)
		// if player exists create a new iset for that (don't add to dictionary)
		// else throw an error
		String isetId = getAttribute(elem, "iset");			
		if (elem.getParentNode() != null && "iset".equals(elem.getParentNode().getNodeName())) {
			if (isetId != null) {
				log.warning("Warning: @iset attribute is set for a node nested in an iset tag.  Ignored.");				
			}
			isetId = getAttribute(elem.getParentNode(), "id");
		}
				
		String playerId = getAttribute(elem, "player");
		Player player = (playerId != null) ? getPlayer(playerId) : Player.CHANCE;
		
		Iset iset = null;
		if (isetId == null) {								
			iset = tree.createIset(player);
			singletons.add(iset); // root is already taken care of				
		} else {
			//if (elem.@player != undefined) trace("Warning: @player attribute is set for a node that references an iset.  Ignored.");				
			
			//look it up in the map, if it doesn't exist create it and add it
			iset = isets.get(isetId);
			if (iset == null) {				
				iset = tree.createIset(isetId, player);
				isets.put(isetId, iset);
			} else {
				if (player != Player.CHANCE) {
					if (iset.player() != Player.CHANCE && player != iset.player()) {
						log.warning("Warning: @player attribute conflicts with earlier iset player assignment.  Ignored.");	
					}
					iset.setPlayer(player);
				}
			}				
		}
		tree.addToIset(node, iset);
		
		// set up the moves
		processMove(elem, node, parentNode);
/*		
		String moveId = getAttribute(elem, "move");
		if (moveId != null) {			
			String moveIsetId = parentNode.iset() != null ? parentNode.iset().name() : ""; 
			Move move = moves.get(moveIsetId + "::" + moveId);
			if (move == null) {
				move = tree.createMove(moveId); 				
				moves.put(moveIsetId + "::" + moveId, move);
			}
			node.reachedby = move;
		} else if (parentNode != null) {
			// assume this comes from a chance node
			node.reachedby = tree.createMove();
			log.fine("Node " + id + " has a parent, but no incoming probability or move is specified");
		}
		
		String probStr = getAttribute(elem, "prob");
		if (probStr != null && node.reachedby != null) {
			node.reachedby.prob = Rational.valueOf(probStr);
		} else if (node.reachedby != null) {
			log.fine("Warning: @move is missing probability.  Prior belief OR chance will be random.");			
		}
*/		
		log.fine("node: " + id + ", iset: " + isetId + ", pl: " + 
			(getAttribute(elem, "player") == null ? getAttribute(elem.getParentNode(), "player") : getAttribute(elem, "player")) + 
			(node.reachedby != null ? ", mv: " + node.uid() : ""));
		
		for (org.w3c.dom.Node child = elem.getFirstChild(); child != null; child = child.getNextSibling()) {
			if ("node".equals(child.getNodeName())) {
				processNode(child, node);
			} else if ("outcome".equals(child.getNodeName())) {
				processOutcome(child, node);
			} else {
//				log.warning("Ignoring unknown element:\r\n" + child);
			}
		}
	}
	
	private void processOutcome(org.w3c.dom.Node elem, Node parent)
	{		
		// Create wrapping node
		// get parent from dictionary... if it doesn't exist then the outcome must be the root
		Node wrapNode = parent != null ? tree.createNode() : tree.root();
		if (parent != null) parent.addChild(wrapNode);		
					
		processMove(elem, wrapNode, parent);
		/*
		String moveId = getAttribute(elem, "move");
		if (moveId != null) {
			String moveIsetId = (parent != null && parent.iset() != null) ? parent.iset().name() : ""; 
			Move move = moveId != null ? moves.get(moveIsetId + "::" + moveId) : null;
			if (move == null && moveId != null) {
				move = tree.createMove(moveId);			
				moves.put(moveIsetId + "::" + moveId, move);
			}
			wrapNode.reachedby = move;
		} else if (parent != null) {
			wrapNode.reachedby = tree.createMove();
			log.fine("Node " + wrapNode.uid() + " has a parent, but no incoming probability or move is specified");
		}

		String probStr = getAttribute(elem, "prob");
		if (probStr != null && wrapNode.reachedby != null) {
			wrapNode.reachedby.prob = Rational.valueOf(probStr);
		} else if (wrapNode.reachedby != null) {
			log.fine("Warning: @move is missing probability.  Prior belief OR chance will be random.");
		}
*/
		Outcome outcome = tree.createOutcome(wrapNode);
		for (org.w3c.dom.Node child = elem.getFirstChild(); child != null; child = child.getNextSibling()) {
			if ("payoff".equals(child.getNodeName())) {
				String playerId = getAttribute(child, "player");
				Rational payoff = Rational.valueOf(getAttribute(child, "value"));
				
				Player player = players.get(playerId);
				if (player == null) {
					player = tree.createPlayer(playerId);
					players.put(playerId, player);
				}
				outcome.setPay(player, payoff);
			} else {
//				log.warning("Ignoring unknown element:\r\n" + child);
			}
		}
		log.fine("outcome: " + wrapNode + ", by move: " + (wrapNode.reachedby != null ? wrapNode.reachedby.uid() : "null"));
	}
	
	private void processMove(org.w3c.dom.Node elem, Node node, Node parentNode)
	{
		String moveId = getAttribute(elem, "move");
		if (moveId != null) {			
			String moveIsetId = parentNode.iset() != null ? parentNode.iset().name() : ""; 
			Move move = moves.get(moveIsetId + "::" + moveId);
			if (move == null) {
				move = tree.createMove(moveId);
				moves.put(moveIsetId + "::" + moveId, move);
			}
			node.reachedby = move;
		} else if (parentNode != null) {
			// assume this comes from a chance node
			node.reachedby = tree.createMove();
			log.fine("Node has a parent, but no incoming probability or move is specified");
		}
		
		String probStr = getAttribute(elem, "prob");
		if (probStr != null && node.reachedby != null) {
			node.reachedby.prob = Rational.valueOf(probStr);
		} else if (node.reachedby != null) {
			log.fine("Warning: @move is missing probability.  Prior belief OR chance will be random.");
		}
	}

	private String getAttribute(org.w3c.dom.Node elem, String key)
	{
		String value = null;
		if (elem != null && elem.getAttributes().getNamedItem(key) != null) {
			value = elem.getAttributes().getNamedItem(key).getNodeValue();
		}
		return value;
	}
	
}
