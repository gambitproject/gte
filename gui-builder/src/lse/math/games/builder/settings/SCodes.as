package lse.math.games.builder.settings
{
	/**
	 * Enum containing each Setting code, with a brief description of what the associated content should be and mean.
	 * 
	 * <p/>When adding a new setting, its key inside UserSettings.as / FileSetting.as and Settings.mxml 
	 * must be the same and taken from here, for reference purposes
	 * 
	 * <p/>You can call defaultSettings() to load a default value for each setting (except from File Settings)
	 */
	public final class SCodes
	{
		/* <--- GENERAL SETTINGS ---> */
		/** 
		 * <li><b>true:</b> Settings are stored as 'flash-cookies' (shared object) locally, and will remain if the browser window is closed</li>
		 * <li><b>false:</b> Settings are discarded once the user closes the browser window</li>
		 * <p><b>Default:</b> false
		 */
		public static const STORE_SETTINGS_LOCALLY:String = "STORE_SETTINGS_LOCALLY";
		
		/** 
		 * <li><b>true:</b> The output after running an algo, instead of in an external pop-up, will be shown in an internal flash one</li>
		 * <li><b>false:</b> The output will be shown in a browser pop-up</li>
		 * <p><b>Default:</b> false
		 */
		public static const DISPLAY_OUTPUT_INTERNALLY:String = "DISPLAY_OUTPUT_INTERNALLY";
		
		/**
		 * int containing the number of undoable actions, at least, that the user would like to keep
		 * <p><b>Default:</b> 10
		 */
		public static const MINIMUM_BUFFER_SIZE:String = "MINIMUM_BUFFER_SIZE";
		
		/**
		 * <li><b>true:</b> The game will autosave, for recovery in case the browser was 
		 * closed unexpectedly, in the interval determined by AUTOSAVE_INTERVAL</li>
		 * <li><b>false:</b> The game will not be autosaved</li>
		 * <p><b>Default:</b> true
		 */
		public static const AUTOSAVE_ENABLED:String = "AUTOSAVE_ENABLED";
		
		/**
		 * int containing the number of seconds between two consecutive autosavings of the game
		 * <p><b>Default:</b> 60
		 */
		public static const AUTOSAVE_INTERVAL:String = "AUTOSAVE_INTERVAL";
		
		
		
		/* <--- DEFAULT GRAPHIC SETTINGS (applied to trees with no graphic information) ---> */
		/** 
		 * uint with player 1's color 
		 * <p><b>Default:</b> Red
		 */
		public static const DEFAULT_PLAYER_1_COLOR:String = "DEFAULT_PLAYER_1_COLOR";
		
		/** 
		 * uint with player 2's color 
		 * <p><b>Default:</b> Blue
		 */
		public static const DEFAULT_PLAYER_2_COLOR:String = "DEFAULT_PLAYER_2_COLOR";
		
		/** 
		 * String with the default font family to be used 
		 * <p><b>Default:</b> Times
		 */
		public static const DEFAULT_FONT:String = "DEFAULT_FONT"; 
		
		/**
		 * Number representing the width of the strokes of lines for drawing isets and moves
		 * <p><b>Default:</b> 1.0
		 */
		public static const DEFAULT_STROKE_WIDTH:String = "DEFAULT_STROKE_WIDTH";
		
		/** 
		 * int representing the diameter of nodes
		 * <p><b>Default:</b> 7
		 */
		public static const DEFAULT_NODE_DIAMETER:String = "DEFAULT_NODE_DIAMETER";
		
		/**
		 * Number representing the diameter of isets
		 * <p><b>Default:</b> 25
		 */
		public static const DEFAULT_ISET_DIAMETER:String = "DEFAULT_ISET_DIAMETER";
		
		/** 
		 * int representing the distance between two consecutive node levels
		 * <p><b>Default:</b> 75
		 */
		public static const DEFAULT_LEVEL_DISTANCE:String = "DEFAULT_LEVEL_DISTANCE";
		
		/**
		 * number representing the vertical padding in cells
		 * <p><b>Default:</b> 5
		 */
		public static const DEFAULT_CELL_PADDING_VERT:String = "DEFAULT_CELL_PADDING_VERT";
		
		/**
		 * number representing the horizontal padding in cells
		 * <p><b>Default:</b> 5
		 */
		public static const DEFAULT_CELL_PADDING_HOR:String = "DEFAULT_CELL_PADDING_HOR";
		
		
		
		/* <--- FILE GRAPHIC SETTINGS (settings not stored in the users PC but on XML files. Loaded with FileSettings) ---> */
		//NOTE: All of these must have their "DEFAULT_" counterpart, else FileSettings.setAsDefault() will need to be modified
		/** uint with player 1's color */
		public static const FILE_PLAYER_1_COLOR:String = "FILE_PLAYER_1_COLOR";
		
		/** uint with player 2's color */
		public static const FILE_PLAYER_2_COLOR:String = "FILE_PLAYER_2_COLOR";
		
		/** String with the FILE font family to be used */
		public static const FILE_FONT:String = "FILE_FONT"; 
		
		/** int representing the width of the strokes of lines for drawing isets and moves */
		public static const FILE_STROKE_WIDTH:String = "FILE_STROKE_WIDTH";
		
		/** Number representing the diameter of nodes */
		public static const FILE_NODE_DIAMETER:String = "FILE_NODE_DIAMETER";
		
		/** Number representing the diameter of isets */
		public static const FILE_ISET_DIAMETER:String = "FILE_ISET_DIAMETER";
		
		/** int representing the distance between two consecutive node levels */
		public static const FILE_LEVEL_DISTANCE:String = "FILE_LEVEL_DISTANCE";
		
		/** Number representing the vertical padding in cells */
		public static const FILE_CELL_PADDING_VERT:String = "FILE_CELL_PADDING_VERT";
		
		/** Number representing the horizontal padding in cells */
		public static const FILE_CELL_PADDING_HOR:String = "FILE_CELL_PADDING_HOR";
		
		/** String represents the delimeter of cells in the matrix editor */
		public static const EDITOR_MATRIX_DELIMETER:String = "EDITOR_MATRIX_DELIMETER";	
		
		/** Boolean represents true/false if autoadjust is enabled */
		public static const TREE_AUTO_ADJUST:String = "TREE_AUTO_ADJUST";
		
		/** Boolean represents true/false if autoadjust is enabled */
		public static const SYSTEM_ENABLE_GUIDANCE:String = "SYSTEM_ENABLE_GUIDANCE";	
		public static const SYSTEM_MODE_GUIDANCE:String = "SYSTEM_MODE_GUIDANCE";
				
		/** Represents the tree orientation in extensive mode
		 * <ul>
		 * <li> 0: top-down </li>
		 * <li> 1: bottom-up </li>
		 * <li> 2: left-right </li>
		 * <li> 3: right-left </li>
		 * </ul>
		 * @default 0
		 * */
		public static const TREE_ORIENTATION:String = "TREE_ORIENTATION";
		
		/** Max payoff for randomly setting payoffs in extensive and strategic form
		 * @default 25
		 * */
		public static const SYSTEM_MAX_PAYOFF:String = "SYSTEM_MAX_PAYOFF";
		
		public static const SYSTEM_DECIMAL_LAYOUT:String = "SYSTEM_DECIMAL_LAYOUT";
		public static const SYSTEM_DECIMAL_PLACES:String = "SYSTEM_DECIMAL_PLACES";
		
		
		/* <--- OTHER SETTINGS (Not shown under the Settings panel) ---> */
		
		/**
		 * Boolean with the current expand status of the webcontainer of the GUI
		 * <p><b>Default:</b> False
		 */
		public static const EXPANDED:String = "EXPANDED";
		
		
		
		/* <--- DEFAULT SETTINGS ---> */
		
		/** Creates a default entry for each setting that a UserSetting object should have*/
		public static function defaultSettings():void
		{
			var settings:UserSettings = UserSettings.instance;
			
			//GENERAL SETTINGS
			settings.setValue(STORE_SETTINGS_LOCALLY, false);
			settings.setValue(DISPLAY_OUTPUT_INTERNALLY, false);
			settings.setValue(MINIMUM_BUFFER_SIZE, 10);
			settings.setValue(AUTOSAVE_ENABLED, true);
			settings.setValue(AUTOSAVE_INTERVAL, 60);
			//GRAPHIC SETTINGS
			settings.setValue(DEFAULT_PLAYER_1_COLOR, 0xFF0000);
			settings.setValue(DEFAULT_PLAYER_2_COLOR, 0x0000FF);
			settings.setValue(DEFAULT_FONT, "Times");
			settings.setValue(DEFAULT_STROKE_WIDTH, 1);
			settings.setValue(DEFAULT_NODE_DIAMETER, new Number(5));
			settings.setValue(DEFAULT_ISET_DIAMETER, new Number(25));
			settings.setValue(DEFAULT_LEVEL_DISTANCE, 75);
			settings.setValue(DEFAULT_CELL_PADDING_VERT, new Number(5));
			settings.setValue(DEFAULT_CELL_PADDING_HOR, new Number(5));
			settings.setValue(EDITOR_MATRIX_DELIMETER, " ");
			settings.setValue(TREE_AUTO_ADJUST, true);
			settings.setValue(SYSTEM_ENABLE_GUIDANCE, true);
			settings.setValue(SYSTEM_MODE_GUIDANCE, new Number(0));
			settings.setValue(TREE_ORIENTATION, new Number(0));
			settings.setValue(SYSTEM_MAX_PAYOFF, new Number(25));
			settings.setValue(SYSTEM_DECIMAL_LAYOUT, false);
			settings.setValue(SYSTEM_DECIMAL_PLACES, 2);
			
			
			
			//OTHER SETTINGS
			settings.setValue(EXPANDED, false);
		}
	}
}