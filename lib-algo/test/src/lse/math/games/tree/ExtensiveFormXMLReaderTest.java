package lse.math.games.tree;

import static org.junit.Assert.*;

import java.io.IOException;
import java.io.StringReader;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import lse.math.games.io.ExtensiveFormXMLReader;

import org.junit.Test;
import org.w3c.dom.Document;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

public class ExtensiveFormXMLReaderTest {
	@Test
	public void testLoad() throws ParserConfigurationException, SAXException, IOException
	{
		String xmlStr = 
		"<extensiveForm>" +
		  "<node player=\"A\">" +
		   "<node iset=\"B:1\" player=\"B\" move=\"L\">" +
		      "<outcome move=\"a\">" +
		        "<payoff player=\"A\" value=\"11\"/>" +
		        "<payoff player=\"B\" value=\"3\"/>" +
		      "</outcome>" +
		      "<outcome move=\"b\">" +
		        "<payoff player=\"A\" value=\"3\"/>" +
		        "<payoff player=\"B\" value=\"0\"/>" +
		      "</outcome>" +
		    "</node>" +
		    "<node player=\"A\" move=\"R\">" +
		      "<node move=\"S\">" +
		        "<node iset=\"B:1\" prob=\"0.5\">" +
		          "<outcome move=\"a\">" +
		            "<payoff player=\"A\" value=\"0\"/>" +
		            "<payoff player=\"B\" value=\"0\"/>" +
		          "</outcome>" +
		          "<outcome move=\"b\">" +
		            "<payoff player=\"A\" value=\"0\"/>" +
		            "<payoff player=\"B\" value=\"10\"/>" +
		          "</outcome>" +
		        "</node>" +
		        "<node iset=\"B:2\" player=\"B\" prob=\"0.5\">" +
		          "<outcome move=\"c\">" +
		            "<payoff player=\"A\" value=\"0\"/>" +
		            "<payoff player=\"B\" value=\"4\"/>" +
		          "</outcome>" +
		          "<outcome move=\"d\">" +
		            "<payoff player=\"A\" value=\"24\"/>" +
		            "<payoff player=\"B\" value=\"0\"/>" +
		          "</outcome>" +
		        "</node>" +
		      "</node>" +
		      "<node iset=\"B:2\" move=\"T\">" +
		        "<outcome move=\"c\">" +
		          "<payoff player=\"A\" value=\"6\"/>" +
		          "<payoff player=\"B\" value=\"0\"/>" +
		        "</outcome>" +
		        "<outcome move=\"d\">" +
		          "<payoff player=\"A\" value=\"0\"/>" +
		          "<payoff player=\"B\" value=\"1\"/>" +
		        "</outcome>" +
		      "</node>" +
		    "</node>" +
		  "</node>" +
		"</extensiveForm>";
		
		
		DocumentBuilder builder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
		Document doc = builder.parse(new InputSource(new StringReader(xmlStr)));
		ExtensiveFormXMLReader reader = new ExtensiveFormXMLReader();
		ExtensiveForm tree = reader.load(doc);
		
		String[] treeGrid = {				
				"node leaf iset player parent reachedby outcome pay1 pay2",
				"   0    0    0      A                                   ",
				"   1    0  B:1      B      0         L                  ",
				"   2    1                  1         a       0   11    3",
				"   3    1                  1         b       1    3    0",
				"   4    0    2      A      0         R                  ",
				"   5    0    3      !      4         S                  ",
				"   6    0  B:1      B      5    !(1/2)                  ",
				"   7    1                  6         a       2    0    0",
				"   8    1                  6         b       3    0   10",
				"   9    0  B:2      B      5    !(1/2)                  ",
				"  10    1                  9         c       4    0    4",
				"  11    1                  9         d       5   24    0",
				"  12    0  B:2      B      4         T                  ",
				"  13    1                 12         c       6    6    0",
				"  14    1                 12         d       7    0    1"
		};
			
		assertArrayEquals(treeGrid, tree.toString().split("[\\r\\n]+"));
	}
}
