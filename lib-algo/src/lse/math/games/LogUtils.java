package lse.math.games;

import java.io.StringWriter;

import lse.math.games.io.ColumnTextWriter;

public class LogUtils {
	
	public static enum LogLevel {
		
		MINIMAL(0), SHORT(1), DETAILED(2), DEBUG(3);
		
		private final int log;
		LogLevel(int log) { this.log = log; }
	    public int getValue() { return log; }
	    
	    public static LogLevel getFromInteger(int index) {
	        switch (index) {
	        case 0: return LogLevel.MINIMAL;
	        case 1: return LogLevel.SHORT;
	        case 2: return LogLevel.DETAILED;
	        case 3: return LogLevel.DEBUG;

	        default:
	        	return LogLevel.DEBUG;
	        }
	    }
	};
	
	public static LogLevel currentLogLevel = LogLevel.MINIMAL;
	
	public static void logi(LogLevel level, String format, Object... args) {
		if (level.getValue() <= currentLogLevel.getValue()) {
			System.out.println(String.format(format, args));
		}
	}
	
	public static void logi(LogLevel level, ColumnTextWriter colpp) {
		if (level.getValue() <= currentLogLevel.getValue()) {
			StringWriter output = new StringWriter();
			output.write(colpp.toString());
			
			System.out.println(String.format(output.toString()));
		}
	}
}
