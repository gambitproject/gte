package lse.math.games.web;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * @author Mark Egesdal
 */
@SuppressWarnings("serial")
public abstract class AbstractRESTServlet extends HttpServlet 
{
	private static final Logger log = Logger.getLogger(AbstractRESTServlet.class.getName());
	private static final String ERROR = "error";
	private static final String WARNING = "warning";
	
	protected Long parseRandomSeed(String s)
	{
		Long seed = null;		
		if (s != null) {
			if ("auto".equals(s)) {
				seed = (long) (Math.random() * Long.MAX_VALUE);
			} else if (!"none".equals(s)){
				try {
					seed = Long.valueOf(s);
				} catch (NumberFormatException ex) {
					// ignore
					log.warning("Seed not formatted correctly... Ignored: " + s);
				}
			}
		}
		return seed;
	}
	
	protected boolean hasWarnings(HttpServletRequest request)
	{
		return hasMessages(request, WARNING);
	}
	
	protected void addWarning(HttpServletRequest request, String msg)
	{
		addMessage(request, WARNING, msg);
	}
	
	protected void writeWarnings(HttpServletRequest request, PrintWriter out)
	{			
		writeMessages(request, WARNING, out);
	}
	
	protected boolean hasErrors(HttpServletRequest request)
	{
		return hasMessages(request, ERROR);
	}
	
	protected void addError(HttpServletRequest request, String msg)
	{
		addMessage(request, ERROR, msg);
	}
	
	protected void writeErrors(HttpServletRequest request, PrintWriter out)
	{			
		writeMessages(request, ERROR, out);
	}
	
	private boolean hasMessages(HttpServletRequest request, String attr)
	{
		return request.getAttribute(attr) != null;
	}
	
	private void addMessage(HttpServletRequest request, String attr, String msg)
	{
		@SuppressWarnings("unchecked")
		List<String> messages = (List<String>) request.getAttribute(attr);
		if (messages == null) {
			messages = new ArrayList<String>();
			request.setAttribute(attr, messages);
		}
		log.info(msg);
		messages.add(msg);
	}
	
	private void writeMessages(HttpServletRequest request, String attr, PrintWriter out)
	{			
		@SuppressWarnings("unchecked")
		List<String> messages = (List<String>) request.getAttribute(attr);
		if (messages != null) {
			for (String msg : messages) {
				out.println(msg);
			}
		}
	}
	
	protected void writeResponseHeader(HttpServletRequest request, HttpServletResponse response) 
		throws IOException
	{
		if (this.hasErrors(request)) {
			response.getWriter().println("ERROR");
			response.getWriter().println();
			log.info("ERROR");
			this.writeErrors(request, response.getWriter());
			
		} else {
			response.getWriter().println("SUCCESS");			
			log.info("SUCCESS");
		}
		response.getWriter().println();
	}
}
