package lse.math.games.io;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.logging.Formatter;
import java.util.logging.LogRecord;

public class BriefLogFormatter extends Formatter {
	
	private static final DateFormat format = new SimpleDateFormat("h:mm:ss");
	private static final String lineSep = System.getProperty("line.separator");

	public String format(LogRecord record) {
		String loggerName = record.getLoggerName();
		if(loggerName == null) {
			loggerName = "root";
		}
		StringBuilder output = new StringBuilder()
			.append(loggerName)
			.append("[")
			.append(record.getLevel()).append('|')
			//.append(Thread.currentThread().getName()).append('|')
			.append(format.format(new Date(record.getMillis())))
			.append("]:")
			.append(record.getMessage().indexOf(lineSep) >= 0 ? lineSep : " ")
			.append(record.getMessage())
			.append(lineSep);
		return output.toString();		
	}
 
}