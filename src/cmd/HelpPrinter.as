package cmd {
	
	
	/**
	 * @author pierre
	 */
	public class HelpPrinter {

		public static function print() : void {
			
			var nl : String = "\n";
			
			var help : String = "";
			
			help += "splitter"+nl;
			help += "split blockbased compressed atf file into platform-specific lightweight atf file, "+nl;
			help += "keeping only one format ( DXT1, ETC1 or PVRTC ), removing the others"+nl;
			help += "author Pierre Lepers (pierre[dot]lepers[at]gmail[dot]com)"+nl;
			help += "powered by RedTamarin"+nl;
			help += "version 1.0"+nl;
			help += "usage : splitter "+nl;
			
			help += " -i <atffile> input atf file"+nl;
			help += " -o <filename> : output"+nl;
			help += " -E : generate ETC1"+nl;
			help += " -D : generate DXT1"+nl;
			help += " -P : generate PVRTC"+nl;
			
			trace( help );
		}

		
	}
}
