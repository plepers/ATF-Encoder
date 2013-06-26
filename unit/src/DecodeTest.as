package {

	import atf.Decoder;
	import atf.codecs.TextureLoader;

	import flash.display.Sprite;
	import flash.utils.ByteArray;

	/**
	 * @author Pierre Lepers
	 * DecodeTest
	 */
	public class DecodeTest extends Sprite {

		[Embed(source="../assets/jxr_nomip.atf", mimeType="application/octet-stream")]
		private var jxr_nomip : Class;
		[Embed(source="../assets/jxr_mip.atf", mimeType="application/octet-stream")]
		private var jxr_mip : Class;
		[Embed(source="../assets/Tire_COLOR.atf", mimeType="application/octet-stream")]
		private var bb_mip : Class;

		public function DecodeTest() {
			
			var refatf : ByteArray;
			var loader : TextureLoader;
			var y : uint=  0;
			
//			refatf = new jxr_nomip();
//			loader = Decoder.decode(refatf, 0, 0, 0 );
//			loader.scaleX = loader.scaleY = 0.5;
//			loader.y = y;
//			loader.load();
//			addChild( loader );
//			y += 256;
//
//			refatf = new jxr_mip();
//			loader = Decoder.decode(refatf, 1, 0, 0 );
//			loader.y = y;
//			loader.scaleX = loader.scaleY = 0.5;
//			loader.load();
//			addChild( loader );
//			y += 128;

			refatf = new bb_mip();
			loader = Decoder.decode(refatf, 0, 0, 0 );
			loader.scaleX = loader.scaleY = 1;
			loader.load();
			loader.y = y;
			addChild( loader );
			y += 128;
			
			
			
		}
	}
}
