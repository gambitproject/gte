package lse.math.games.builder.fig
{
	import flash.text.Font;
	import flash.text.FontStyle;
	import flash.text.engine.FontPosture;
	import flash.text.engine.FontWeight;
	
	import util.Log;
	
	/**	
	 * Class that manages the collection of fonts embedded in the fig 
	 * 
	 * @author Mark Egesdal
	 */
	public class FigFontManager
	{		
		private static var _fontEnums:Object = {
			"Times Roman" : 0,
			"Times Italic" : 1,
			"Times Bold" : 2,
			"Times Bold Italic" : 3,
			"AvantGarde Book" : 4,
			"AvantGarde Book Oblique" : 5,
			"AvantGarde Demi" : 6,
			"AvantGarde Demi Oblique" : 7,
			"Bookman Light" : 8,
			"Bookman Light Italic" : 9,
			"Bookman Demi" : 10,
			"Bookman Demi Italic" : 11,
			"Courier" : 12,
			"Courier Oblique" : 13,
			"Courier Bold" : 14,
			"Courier Bold Oblique" : 15,
			"Helvetica" : 16,
			"Helvetica Oblique" : 17,
			"Helvetica Bold" : 18,
			"Helvetica Bold Oblique" : 19,
			"Helvetica Narrow" : 20,
			"Helvetica Narrow Oblique" : 21,
			"Helvetica Narrow Bold" : 22,
			"Helvetica Narrow Bold Oblique" : 23,			
			"New Century Schoolbook Roman" : 24,
			"New Century Schoolbook Italic" : 25,
			"New Century Schoolbook Bold" : 26,
			"New Century Schoolbook Bold Italic" : 27,
			"Palatino Roman" : 28,
			"Palatino Italic" : 29,
			"Palatino Bold" : 30,
			"Palatino Bold Italic" : 31,
			"Symbol" : 32,
			"Zapf Chancery Medium Italic" : 33,
			"Zapf Dingbats" : 34
		};
		
		private static var _fontFamilyEnums:Object = {
			"Times" : 0,
			"AvantGarde" : 4,
			"Bookman" : 8,
			"Courier" : 12,
			"Helvetica" : 16,
			"Helvetica Narrow" : 20,			
			"New Century Schoolbook" : 24,
			"Palatino" : 28,
			"Symbol" : 32,
			"Zapf Chancery Medium Italic" : 33,
			"Zapf Dingbats" : 34
		};
		
		// Despite intuition, we want to give all fonts in the same family the same fontName and ignore the fontFamily attribute
		[Embed(source="../../../../../../assets/fonts/NimbusRomNo9L-Regu.otf", fontName="Times", fontWeight=FontWeight.NORMAL, fontStyle=FontPosture.NORMAL, embedAsCFF='true')]
		private static var FontTimes:Class;
		[Embed(source="../../../../../../assets/fonts/NimbusRomNo9L-Medi.otf", fontName="Times", fontWeight=FontWeight.BOLD, fontStyle=FontPosture.NORMAL, embedAsCFF='true')]
		private static var FontTimesBold:Class;
		[Embed(source="../../../../../../assets/fonts/NimbusRomNo9L-ReguItal.otf", fontName="Times", fontWeight=FontWeight.NORMAL, fontStyle=FontPosture.ITALIC, embedAsCFF='true')]
		private static var FontTimesItalic:Class;
		[Embed(source="../../../../../../assets/fonts/NimbusRomNo9L-MediItal.otf", fontName="Times", fontWeight=FontWeight.BOLD, fontStyle=FontPosture.ITALIC, embedAsCFF='true')]
		private static var FontTimesBoldItalic:Class;	
		
		[Embed(source="../../../../../../assets/fonts/URWGothicL-Book.otf", fontName="AvantGarde", fontWeight=FontWeight.NORMAL, fontStyle=FontPosture.NORMAL, embedAsCFF='true')]
		private static var FontGothic:Class;
		[Embed(source="../../../../../../assets/fonts/URWGothicL-Demi.otf", fontName="AvantGarde", fontWeight=FontWeight.BOLD, fontStyle=FontPosture.NORMAL, embedAsCFF='true')]
		private static var FontGothicBold:Class;
		[Embed(source="../../../../../../assets/fonts/URWGothicL-BookObli.otf", fontName="AvantGarde", fontWeight=FontWeight.NORMAL, fontStyle=FontPosture.ITALIC, embedAsCFF='true')]
		private static var FontGothicItalic:Class;
		[Embed(source="../../../../../../assets/fonts/URWGothicL-DemiObli.otf", fontName="AvantGarde", fontWeight=FontWeight.BOLD, fontStyle=FontPosture.ITALIC, embedAsCFF='true')]
		private static var FontGothicBoldItalic:Class;
		
		[Embed(source="../../../../../../assets/fonts/URWBookmanL-Ligh.otf", fontName="Bookman", fontWeight=FontWeight.NORMAL, fontStyle=FontPosture.NORMAL, embedAsCFF='true')]
		private static var FontBookman:Class;
		[Embed(source="../../../../../../assets/fonts/URWBookmanL-DemiBold.otf", fontName="Bookman", fontWeight=FontWeight.BOLD, fontStyle=FontPosture.NORMAL, embedAsCFF='true')]
		private static var FontBookmanBold:Class;
		[Embed(source="../../../../../../assets/fonts/URWBookmanL-LighItal.otf", fontName="Bookman",  fontWeight=FontWeight.NORMAL, fontStyle=FontPosture.ITALIC, embedAsCFF='true')]
		private static var FontBookmanItalic:Class;
		[Embed(source="../../../../../../assets/fonts/URWBookmanL-DemiBoldItal.otf", fontName="Bookman", fontWeight=FontWeight.BOLD, fontStyle=FontPosture.ITALIC, embedAsCFF='true')]
		private static var FontBookmanBoldItalic:Class;
		
		[Embed(source="../../../../../../assets/fonts/NimbusMonL-Regu.otf", fontName="Courier", fontWeight=FontWeight.NORMAL, fontStyle=FontPosture.NORMAL, embedAsCFF='true')]
		private static var FontCourier:Class;
		[Embed(source="../../../../../../assets/fonts/NimbusMonL-Bold.otf", fontName="Courier", fontWeight=FontWeight.BOLD, fontStyle=FontPosture.NORMAL, embedAsCFF='true')]
		private static var FontCourierBold:Class;
		[Embed(source="../../../../../../assets/fonts/NimbusMonL-ReguObli.otf", fontName="Courier", fontWeight=FontWeight.NORMAL, fontStyle=FontPosture.ITALIC, embedAsCFF='true')]
		private static var FontCourierItalic:Class;
		[Embed(source="../../../../../../assets/fonts/NimbusMonL-BoldObli.otf", fontName="Courier", fontWeight=FontWeight.BOLD, fontStyle=FontPosture.ITALIC, embedAsCFF='true')]
		private static var FontCourierBoldItalic:Class;		

		[Embed(source="../../../../../../assets/fonts/NimbusSanL-Regu.otf", fontName="Helvetica", fontWeight=FontWeight.NORMAL, fontStyle=FontPosture.NORMAL, embedAsCFF='true')]
		private static var FontHelvetica:Class;
		[Embed(source="../../../../../../assets/fonts/NimbusSanL-Bold.otf", fontName="Helvetica", fontWeight=FontWeight.BOLD, fontStyle=FontPosture.NORMAL, embedAsCFF='true')]
		private static var FontHelveticaBold:Class;
		[Embed(source="../../../../../../assets/fonts/NimbusSanL-ReguItal.otf", fontName="Helvetica", fontWeight=FontWeight.NORMAL, fontStyle=FontPosture.ITALIC, embedAsCFF='true')]
		private static var FontHelveticaItalic:Class;
		[Embed(source="../../../../../../assets/fonts/NimbusSanL-BoldItal.otf", fontName="Helvetica", fontWeight=FontWeight.BOLD, fontStyle=FontPosture.ITALIC, embedAsCFF='true')]
		private static var FontHelveticaBoldItalic:Class;
		
		[Embed(source="../../../../../../assets/fonts/NimbusSanL-ReguCond.otf", fontName="Helvetica Narrow", fontWeight=FontWeight.NORMAL, fontStyle=FontPosture.NORMAL, embedAsCFF='true')]
		private static var FontHelveticaNarrow:Class;
		[Embed(source="../../../../../../assets/fonts/NimbusSanL-BoldCond.otf", fontName="Helvetica Narrow", fontWeight=FontWeight.BOLD, fontStyle=FontPosture.NORMAL, embedAsCFF='true')]
		private static var FontHelveticaNarrowBold:Class;
		[Embed(source="../../../../../../assets/fonts/NimbusSanL-ReguCondItal.otf", fontName="Helvetica Narrow", fontWeight=FontWeight.NORMAL, fontStyle=FontPosture.ITALIC, embedAsCFF='true')]
		private static var FontHelveticaNarrowItalic:Class;
		[Embed(source="../../../../../../assets/fonts/NimbusSanL-BoldCondItal.otf", fontName="Helvetica Narrow", fontWeight=FontWeight.BOLD, fontStyle=FontPosture.ITALIC, embedAsCFF='true')]
		private static var FontHelveticaNarrowBoldItalic:Class;		
		
		[Embed(source="../../../../../../assets/fonts/CenturySchL-Roma.otf", fontName="New Century Schoolbook", fontWeight=FontWeight.NORMAL, fontStyle=FontPosture.NORMAL, embedAsCFF='true')]
		private static var FontCentury:Class;
		[Embed(source="../../../../../../assets/fonts/CenturySchL-Bold.otf", fontName="New Century Schoolbook", fontWeight=FontWeight.BOLD, fontStyle=FontPosture.NORMAL, embedAsCFF='true')]
		private static var FontCenturyBold:Class;
		[Embed(source="../../../../../../assets/fonts/CenturySchL-Ital.otf", fontName="New Century Schoolbook", fontWeight=FontWeight.NORMAL, fontStyle=FontPosture.ITALIC, embedAsCFF='true')]
		private static var FontCenturyItalic:Class;
		[Embed(source="../../../../../../assets/fonts/CenturySchL-BoldItal.otf", fontName="New Century Schoolbook", fontWeight=FontWeight.BOLD, fontStyle=FontPosture.ITALIC, embedAsCFF='true')]
		private static var FontCenturyBoldItalic:Class;
		
		[Embed(source="../../../../../../assets/fonts/URWPalladioL-Roma.otf", fontName="Palatino", fontWeight=FontWeight.NORMAL, fontStyle=FontPosture.NORMAL, embedAsCFF='true')]
		private static var FontPalladio:Class;
		[Embed(source="../../../../../../assets/fonts/URWPalladioL-Bold.otf", fontName="Palatino", fontWeight=FontWeight.BOLD, fontStyle=FontPosture.NORMAL, embedAsCFF='true')]
		private static var FontPalladioBold:Class;
		[Embed(source="../../../../../../assets/fonts/URWPalladioL-Ital.otf", fontName="Palatino", fontWeight=FontWeight.NORMAL, fontStyle=FontPosture.ITALIC, embedAsCFF='true')]
		private static var FontPalladioItalic:Class;
		[Embed(source="../../../../../../assets/fonts/URWPalladioL-BoldItal.otf", fontName="Palatino", fontWeight=FontWeight.BOLD, fontStyle=FontPosture.ITALIC, embedAsCFF='true')]
		private static var FontPalladioBoldItalic:Class;		

		
		
		public function FigFontManager() {}
		
		
		
		private static var fontFamilies:Array = null;
		
		/** Returns an array with all the available font families */
		public static function getAvailableFontFamilies():Array 
		{			
			if (fontFamilies == null) {
				fontFamilies = initFontFamilies();
			}
			return fontFamilies;
		}
		
		//Returns an array with all the font families (and not each font name!) available and embedded in the fig
		private static function initFontFamilies():Array
		{
			var baseFonts:Array = new Array();
			for each (var font:Font in Font.enumerateFonts()) {
				if (_fontFamilyEnums.hasOwnProperty(font.fontName) && font.fontStyle == FontStyle.REGULAR) {
					baseFonts.push(font.fontName);
				}
			}
			return baseFonts;
		}
		
		/** Returns true if the font is available */
		public static function isFontAvailable(fontName:String):Boolean
		{
			return (_fontFamilyEnums.hasOwnProperty(fontName));
		}
		
		/** Returns a font's code in the enum of fonts of the fig*/
		public static function figEnumValue(fontFamily:String, weight:String, posture:String):int
		{
			var enum:int = -1;
			if (_fontFamilyEnums.hasOwnProperty(fontFamily)) {
				enum = _fontFamilyEnums[fontFamily];
				if (weight == FontWeight.BOLD) {
					enum += 2;
				}
				if (posture == FontPosture.ITALIC) {
					enum += 1;
				}
			} else {
				Log.instance.add(Log.ERROR_HIDDEN, "font " + fontFamily + " is not found.  Using default " + enum);
			}
			
			return enum;
		}
	}
}