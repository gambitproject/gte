package lse.math.games.io;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

public class SettingLoader {

		private static final Logger log = Logger.getLogger(SettingLoader.class.getName());
		private static SettingLoader currentLoader;
		private static final String configFile="config.properties";
		Properties properties;
		
		private SettingLoader() {
			currentLoader = this;
			properties = new Properties();
			InputStream iS=null;
			
		
			
			
			try {
				
				iS = this.getClass().getClassLoader().getResourceAsStream(configFile);  
				properties.load(iS);
			} catch (IOException ex) {
				log.log(Level.SEVERE,ex.toString());
				properties=null;
			} finally {
				try {
					iS.close();
				} catch (Exception e) {}
			}
		}

		public static synchronized SettingLoader getInstance() {
			if (currentLoader == null) 
				currentLoader = new SettingLoader();
			return currentLoader;
		}
	 
		public String getProperty(String element){
			if (properties==null){
				log.log(Level.INFO,"Properties not loaded");
				return null;
			} else {
				if ((element==null) || (element.trim().equals(""))){
					log.log(Level.INFO,"Element is null or empty");
					return null;
				} else {
					return properties.getProperty(element);
				}
			}
		}
}
