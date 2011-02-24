package lse.math.games.web;

import java.io.IOException;
import java.io.StringReader;
import java.util.Map;
import java.util.Map.Entry;
import java.util.logging.Logger;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import lse.math.games.Rational;
import lse.math.games.io.ColumnTextWriter;
import lse.math.games.io.ExtensiveFormXMLReader;
import lse.math.games.lcp.LCP;
import lse.math.games.lcp.LemkeAlgorithm;
import lse.math.games.lcp.LemkeAlgorithm.LemkeException;
//import lse.math.games.lcp.LemkeAlgorithm.LemkeInitException;
import lse.math.games.lcp.LemkeAlgorithm.RayTerminationException;
import lse.math.games.tree.ExtensiveForm;
import lse.math.games.tree.Move;
import lse.math.games.tree.Player;
import lse.math.games.tree.SequenceForm;
import lse.math.games.tree.SequenceForm.ImperfectRecallException;
import lse.math.games.tree.SequenceForm.InvalidPlayerException;

import org.w3c.dom.Document;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

/**
 * @author Mark Egesdal
 */
@SuppressWarnings("serial")
public class TreeServlet extends AbstractRESTServlet 
{
	private static final Logger log = Logger.getLogger(TreeServlet.class.getName());

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) 
	throws ServletException, IOException 
	{
		doPost(request, response);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) 
	throws ServletException, IOException 
	{		
		response.setContentType("text/plain");
		log.info("Processing new request");
		SequenceForm seqForm = null;
		String solutionStr = null;
		try {
			// 0. See if we have a seed for random priors		
			Long seed = this.parseRandomSeed(request.getParameter("s"));

			// 1. pull XML out of request returning any errors
			String xmlStr = request.getParameter("g");
			if (xmlStr == null) {
				this.addError(request, "g parameter is missing");			
				return;
			} else {

				// 2. load XML into ExtensiveForm returning any errors
				ExtensiveForm tree = null;
				try {
					DocumentBuilder builder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
					Document doc = builder.parse(new InputSource(new StringReader(xmlStr)));
					ExtensiveFormXMLReader reader = new ExtensiveFormXMLReader();
					tree = reader.load(doc);			
				} catch (ParserConfigurationException ex) {
					this.addError(request, "unable to configure xml parser");			
				} catch (SAXException ex) {
					this.addError(request, "unable to parse xml");			
				}

				if (tree != null) 
				{
					// 3. Convert to SequenceForm returning any errors			
					try {
						seqForm = new SequenceForm(tree, seed);	
					} catch (ImperfectRecallException ex) {
						this.addError(request, ex.getMessage());
					}

					if (seqForm != null) 
					{
						// 4. Retrieve LCP and run through Lemke
						Rational[] z = null;
						try {			
							LCP lcp = seqForm.getLemkeLCP();
							log.info(lcp.toString());

							LemkeAlgorithm lemke = new LemkeAlgorithm();
							//lemke.init(lcp);
							z = lemke.run(lcp);
						} catch (InvalidPlayerException ex) {
							this.addError(request, ex.getMessage());
						} catch (RayTerminationException ex) {
							//TODO: give special treatment
							this.addError(request, ex.getMessage());			
						} catch (LemkeException ex) {
							this.addError(request, ex.getMessage());
						}

						if (z != null) 
						{	
							// 5. Parse Lemke solution into behavior strategy equilibrium
							Map<Player,Map<Move,Rational>> plProbs = seqForm.parseLemkeSolution(z);
							Map<Player,Rational> epayoffs = SequenceForm.expectedPayoffs(plProbs, tree);

							ColumnTextWriter colpp = new ColumnTextWriter();
							colpp.writeCol("Equilibrium");
							colpp.endRow();
							boolean firsttime = true;
							for (Player pl = tree.firstPlayer(); pl != null; pl = pl.next) {
								if (firsttime) {
									firsttime = false;
								} else {
									colpp.endRow();
								}
								for (Entry<Move,Rational> entry : plProbs.get(pl).entrySet()) {
									colpp.writeCol(entry.getKey().toString());							
									colpp.writeCol(entry.getValue().toString());
									colpp.endRow();
								}					
							}
							colpp.endRow();
							for (Player pl = tree.firstPlayer(); pl != null; pl = pl.next) {
								colpp.writeCol("\u00A3" + pl.toString());						
								colpp.writeCol(epayoffs.get(pl).toString());
								colpp.endRow();						
							}
							colpp.alignLeft(0);
							solutionStr = colpp.toString();
						}
					}
				}
			}
		} catch (Exception ex) {
			this.addError(request, ex.toString());
			ex.printStackTrace();			
		}

		this.writeResponseHeader(request, response);
		if (seqForm != null) {
			response.getWriter().println("SequenceForm");
			response.getWriter().println(seqForm.toString());
		}
		if (solutionStr != null) {			
			response.getWriter().println(solutionStr);
		}
	}
}
