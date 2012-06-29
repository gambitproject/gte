package lse.math.games.web;

import java.util.logging.Logger;

public class AlgoInterface {

	private native String callnative(String s); 
	 
	
	private static final Logger log = Logger.getLogger(AlgoInterface.class.getName());
	public AlgoInterface(){
		  System.loadLibrary("setupnash3");
	}
	
	public void startExtern(){
		log.info(this.callnative("Blabla123 "));
		log.info("sdf");
	}
}
