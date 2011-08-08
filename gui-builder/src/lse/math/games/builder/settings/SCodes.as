package lse.math.games.builder.settings
{
	/**
	 * Enum containing each Setting code, with a brief description of what the associated content should be and mean.
	 * 
	 * <p/>When adding a new setting, its key inside UserSettings.as and Settings.mxml 
	 * must be the same and taken from here, for reference purposes
	 * 
	 * <p/>You can call defaultSettings() to load a default value for each setting
	 */
	public final class SCodes
	{
		/* <--- GENERAL SETTINGS ---> */
		/** 
		 * <li><b>true:</b> Settings are stored as 'flash-cookies' (shared object) locally, and will remain if the browser window is closed</li>
		 * <li><b>false:</b> Settings are discarded once the user closes the browser window</li>
		 * <p><b>Default:</b> false
		 */
		public static var STORE_SETTINGS_LOCALLY:String = "STORE_SETTINGS_LOCALLY";
		
		/** 
		 * <li><b>true:</b> The output after running an algo, instead of in an external pop-up, will be shown in an internal flash one</li>
		 * <li><b>false:</b> The output will be shown in a browser pop-up</li>
		 * <p><b>Default:</b> false
		 */
		public static var DISPLAY_OUTPUT_INTERNALLY:String = "DISPLAY_OUTPUT_INTERNALLY";
		
		/* <--- GRAPHIC SETTINGS ---> */
		/** 
		 * uint with player 1's color 
		 * <p><b>Default:</b> Red
		 */
		public static var PLAYER_1_COLOR:String = "PLAYER_1_COLOR";
		
		/** 
		 * uint with player 2's color 
		 * <p><b>Default:</b> Blue
		 */
		public static var PLAYER_2_COLOR:String = "PLAYER_2_COLOR";
		
		/** 
		 * String with the default font family to be used 
		 * <p><b>Default:</b> Times
		 */
		public static var DEFAULT_FONT:String = "DEFAULT_FONT"; 
		//It is called DEFAULT because in the future there might be also more specific ones, such as payoff_font or player_font
		//and then this one will be the used in whatever's not got a specific one
		
		
		/** Creates a default entry for each setting that a UserSetting object should have*/
		public static function defaultSettings():void
		{
			var settings:UserSettings = UserSettings.instance;
			
			//GENERAL SETTINGS
			settings.setValue(STORE_SETTINGS_LOCALLY, false);
			settings.setValue(DISPLAY_OUTPUT_INTERNALLY, false);
			//GRAPHIC SETTINGS
			settings.setValue(PLAYER_1_COLOR, 0xFF0000);
			settings.setValue(PLAYER_2_COLOR, 0x0000FF);
			settings.setValue(DEFAULT_FONT, "Times");

			
		}
	}
}