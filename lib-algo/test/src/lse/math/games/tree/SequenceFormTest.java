package lse.math.games.tree;

import static org.junit.Assert.*;

import java.io.IOException;
import java.io.StringReader;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import lse.math.games.Rational;
import lse.math.games.io.ExtensiveFormXMLReader;
import lse.math.games.lcp.LCP;
import lse.math.games.tree.SequenceForm.ImperfectRecallException;
import lse.math.games.tree.SequenceForm.InvalidPlayerException;

import org.junit.Test;
import org.w3c.dom.Document;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

public class SequenceFormTest {

	@Test
	public void testSimpleSequenceFormConstruction()
	throws ImperfectRecallException, InvalidPlayerException
	{
		ExtensiveForm tree = new ExtensiveForm();		
		Player p1 = tree.createPlayer("I");
		Player p2 = tree.createPlayer("II");
		
		Iset h0 = tree.createIset(Player.CHANCE);
		Iset h11 = tree.createIset(p1);
		Iset h12 = tree.createIset(p1);
		Iset h21 = tree.createIset(p2);
		Iset h22 = tree.createIset(p2);
		
		tree.addToIset(tree.root(), h11);
		
		Node L = tree.createNode();		
		tree.addToIset(L, h21);
		L.reachedby = tree.createMove();
		L.reachedby.setIset(h11);
		tree.root().addChild(L);
		
		Node R = tree.createNode();		
		tree.addToIset(R, h12);
		R.reachedby = tree.createMove();
		R.reachedby.setIset(h11);
		tree.root().addChild(R);
		
		Node S = tree.createNode();		
		tree.addToIset(S, h0);
		S.reachedby = tree.createMove();
		S.reachedby.setIset(h12);
		R.addChild(S);
		
		Node T = tree.createNode();		
		tree.addToIset(T, h22);
		T.reachedby = tree.createMove();
		T.reachedby.setIset(h12);
		R.addChild(T);
		
		
		Node x1 = tree.createNode();		
		tree.addToIset(x1, h21);
		x1.reachedby = tree.createMove();
		x1.reachedby.prob = Rational.valueOf("1/2");
		x1.reachedby.setIset(h0);
		S.addChild(x1);
		
		Node x2 = tree.createNode();		
		tree.addToIset(x2, h22);
		x2.reachedby = tree.createMove();
		x2.reachedby.prob = Rational.valueOf("1/2");
		x2.reachedby.setIset(h0);
		S.addChild(x2);
		
		// Outcomes		
		Node o1 = tree.createNode();		
		o1.reachedby = tree.createMove();
		o1.reachedby.setIset(h21);
		Outcome pay1 = tree.createOutcome(o1);
		pay1.setPay(tree.firstPlayer(), Rational.valueOf(11));
		pay1.setPay(tree.firstPlayer().next, Rational.valueOf(3));
		L.addChild(o1);
		
		Node o2 = tree.createNode();		
		o2.reachedby = tree.createMove();
		o2.reachedby.setIset(h21);
		Outcome pay2 = tree.createOutcome(o2);
		pay2.setPay(tree.firstPlayer(), Rational.valueOf(3));
		pay2.setPay(tree.firstPlayer().next, Rational.valueOf(0));
		L.addChild(o2);
		
		Node o3 = tree.createNode();		
		o3.reachedby = o1.reachedby;		
		Outcome pay3 = tree.createOutcome(o3);
		pay3.setPay(tree.firstPlayer(), Rational.valueOf(0));
		pay3.setPay(tree.firstPlayer().next, Rational.valueOf(0));
		x1.addChild(o3);
		
		Node o4 = tree.createNode();		
		o4.reachedby = o2.reachedby;
		Outcome pay4 = tree.createOutcome(o4);
		pay4.setPay(tree.firstPlayer(), Rational.valueOf(0));
		pay4.setPay(tree.firstPlayer().next, Rational.valueOf(10));
		x1.addChild(o4);
		
		
		Node o5 = tree.createNode();		
		o5.reachedby = tree.createMove();
		o5.reachedby.setIset(h22);
		Outcome pay5 = tree.createOutcome(o5);
		pay5.setPay(tree.firstPlayer(), Rational.valueOf(0));
		pay5.setPay(tree.firstPlayer().next, Rational.valueOf(4));
		x2.addChild(o5);
		
		Node o6 = tree.createNode();		
		o6.reachedby = tree.createMove();
		o6.reachedby.setIset(h22);
		Outcome pay6 = tree.createOutcome(o6);
		pay6.setPay(tree.firstPlayer(), Rational.valueOf(24));
		pay6.setPay(tree.firstPlayer().next, Rational.valueOf(0));
		x2.addChild(o6);
		
		Node o7 = tree.createNode();		
		o7.reachedby = o5.reachedby;		
		Outcome pay7 = tree.createOutcome(o7);
		pay7.setPay(tree.firstPlayer(), Rational.valueOf(6));
		pay7.setPay(tree.firstPlayer().next, Rational.valueOf(0));
		T.addChild(o7);
		
		Node o8 = tree.createNode();		
		o8.reachedby = o6.reachedby;
		Outcome pay8 = tree.createOutcome(o8);
		pay8.setPay(tree.firstPlayer(), Rational.valueOf(0));
		pay8.setPay(tree.firstPlayer().next, Rational.valueOf(1));
		T.addChild(o8);
				
		tree.autoname();
		
		SequenceForm seq = new SequenceForm(tree);
		//System.out.println(seq.toString());
		
		//assertEquals("dksl", seq.toString());
		
		LCP lcp = seq.getLemkeLCP();
		assertEquals(16, lcp.size());
		
		String[] rows = {                
				" M                                                          d  q",
				" .  .  .    .  .  .  .  .  .    .    .    .   . -1  1  .    0  0",
				" .  .  .    .  .  .  .  .  .   14   22    .   .  . -1  .   18  0",
				" .  .  .    .  .  .  .  .  .    .    .    .   .  . -1  1    0  0",
				" .  .  .    .  .  .  .  .  . 25/2 25/2 25/2 1/2  .  . -1   19  0",
				" .  .  .    .  .  .  .  .  .    .    .   19  25  .  . -1   22  0",
				" .  .  .    .  .  .  .  .  1    .    .    .   .  .  .  .    1 -1",
				" .  .  .    .  .  .  .  . -1    1    1    .   .  .  .  .    0  0",
				" .  .  .    .  .  .  .  . -1    .    .    1   1  .  .  .    0  0",
				" .  .  .    .  . -1  1  1  .    .    .    .   .  .  .  .    0  0",
				" .  8  . 11/2  .  . -1  .  .    .    .    .   .  .  .  . 43/8  0",
				" . 11  .  1/2  .  . -1  .  .    .    .    .   .  .  .  . 45/8  0",
				" .  .  .  7/2 11  .  . -1  .    .    .    .   .  .  .  . 29/8  0",
				" .  .  . 11/2 10  .  . -1  .    .    .    .   .  .  .  . 31/8  0",
				" 1  .  .    .  .  .  .  .  .    .    .    .   .  .  .  .    1 -1",
				"-1  1  1    .  .  .  .  .  .    .    .    .   .  .  .  .    0  0",
				" .  . -1    1  1  .  .  .  .    .    .    .   .  .  .  .    0  0"
		};
		//System.out.println(lcp.toString());
		assertArrayEquals(rows, lcp.toString().split("[\\r\\n]+"));
	}
	
	@Test
	public void testOneChoiceTree() throws SAXException, IOException, ParserConfigurationException, ImperfectRecallException, InvalidPlayerException
	{
		String xmlStr = "<extensiveForm>"+
		 "<node player=\"1\">"+
		   "<outcome move=\"L\">"+
		     "<payoff player=\"1\" value=\"13\"/>"+
		     "<payoff player=\"2\" value=\"14\"/>"+
		   "</outcome>"+
		   "<outcome move=\"R\">"+
		     "<payoff player=\"1\" value=\"21\"/>"+
		     "<payoff player=\"2\" value=\"0\"/>"+
		   "</outcome>"+
		 "</node>"+
		"</extensiveForm>";

		DocumentBuilder builder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
		Document doc = builder.parse(new InputSource(new StringReader(xmlStr)));
		ExtensiveFormXMLReader reader = new ExtensiveFormXMLReader();
		ExtensiveForm tree = reader.load(doc);
		//assertFalse(tree.root().terminal);
		
		SequenceForm seqForm = new SequenceForm(tree);
		LCP lcp = seqForm.getLemkeLCP();
		assertEquals(7,lcp.size());
	}
	
	@Test
	public void testNoChoiceTree() throws SAXException, IOException, ParserConfigurationException, ImperfectRecallException, InvalidPlayerException
	{
		String xmlStr = "<extensiveForm>"+		 
		   "<outcome>"+
		     "<payoff player=\"1\" value=\"13\"/>"+
		     "<payoff player=\"2\" value=\"14\"/>"+
		   "</outcome>"+		   
		"</extensiveForm>";

		DocumentBuilder builder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
		Document doc = builder.parse(new InputSource(new StringReader(xmlStr)));
		ExtensiveFormXMLReader reader = new ExtensiveFormXMLReader();
		ExtensiveForm tree = reader.load(doc);
		//assertFalse(tree.root().terminal);
		
		SequenceForm seqForm = new SequenceForm(tree);
		LCP lcp = seqForm.getLemkeLCP();
		assertEquals(4,lcp.size());
	}
}
