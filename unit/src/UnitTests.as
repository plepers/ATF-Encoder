package {

	import dxt.Dxt;
	import flash.display.BitmapData;
	import flash.display.JPEGXREncoderOptions;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;

	/**
	 * @author Pierre Lepers
	 * UnitTests
	 */
	 [SWF(backgroundColor="#FF00FF", frameRate="31", width="640", height="480")]
	public class UnitTests extends Sprite {

		[Embed(source="../assets/test.png")]
		private var Joconde : Class;

		public function UnitTests() {
			// _testDxt();
			// _testUtils();
			//_testAlphaEncode();
			_testHeader();
		}

		private function _testUtils() : void {
			addChild(new UtilReplaceTest());
			new UtilsSuitableFmtTest(stage);
		}

		private function _testDxt() : void {
			var bmp : BitmapData = new Joconde().bitmapData;
			var dxtbytes : ByteArray = new ByteArray();
			Dxt.encode(bmp, dxtbytes);
		}

		private function _testHeader() : void {
			//addChild(new SimpleTest());
			addChild(new DecodeTest());
		}

		private function _testAlphaEncode() : void {
			
			var bmp : BitmapData = new BitmapData(256, 256, true, 0 );
			bmp.fillRect( new Rectangle( 10, 10, 50, 50 ), 0xFFFF0000 );
			bmp.fillRect( new Rectangle( 70, 70, 50, 50 ), 0xFFFFFF00 );
			
			var jxr : ByteArray = new ByteArray();
			bmp.encode( bmp.rect, new JPEGXREncoderOptions( 90 ), jxr );
			
			var l : Loader = new Loader();
			l.loadBytes( jxr );
			addChild( l );
		}
	}
}
