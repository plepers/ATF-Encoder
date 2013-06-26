package {

	import flash.utils.Endian;
	import flash.display.BitmapEncodingColorSpace;
	import flash.display.JPEGXREncoderOptions;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.net.FileReference;
	import atf.Decoder;
	import atf.Header;
	import atf.TexBlocks;
	import atf.codecs.TextureLoader;

	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.utils.ByteArray;
	/**
	 * @author Pierre Lepers
	 * Temp
	 */
	public class Temp extends Sprite {
		
		[Embed(source="../assets/8x8.atf", mimeType="application/octet-stream")]
		private var Atf8x8 : Class;
		private var _jxr : ByteArray;
		private var loader : Loader;
		private var _rjxr : ByteArray;
		
		public function Temp() {
			
//			var bmp : BitmapData = new BitmapData(100, 100, false, 0 );
//			var cmp : Object = new Object();
//			cmp.colorSpace = "auto";
//			cmp.quantization = uint( 20 );
//			cmp.trimFlexBits = uint( 0 );
//			bmp.encode( bmp.rect, cmp );
			
			var _atf : ByteArray = new Atf8x8();
			
			var h : Header = new Header();
			h.readExternal( _atf );
			var b : TexBlocks = new TexBlocks();
			
			b.read( _atf, h );
			
			for (var i : int = 0; i < b.blocks.length; i+=2) {
				trace( " ", b.blocks[i], b.blocks[i+1] );
			}
			
			
			_jxr = new ByteArray();
			
			_jxr.writeBytes( _atf, b.blocks[50], b.blocks[51] );
			
			trace( "Temp - Temp -- ", _jxr.length );
			
			loader = new Loader();
			loader.loadBytes( _jxr );
			addChild( loader );
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, jxrloaded );
			loader.scaleX  = loader.scaleY = 8;
			
			var l : TextureLoader = Decoder.decode( _atf, 3 );
			
//			l.load();
//			addChild( l );
//			l.scaleX = l.scaleY = 4;
//			
		}

		private function jxrloaded(event : Event) : void {
			stage.addEventListener( MouseEvent.CLICK, onClick );
			var bmp : BitmapData = (loader.content as Bitmap).bitmapData;
			_rjxr = bmp.encode( bmp.rect, new JPEGXREncoderOptions(0, BitmapEncodingColorSpace.COLORSPACE_4_2_0, 0 ) );
			_rjxr.endian = Endian.LITTLE_ENDIAN;
		}

		private function onClick(event : MouseEvent) : void {
			var fr : FileReference = new FileReference();
//			fr.save( _jxr, "temp_jxr.jxr" );
			fr.save( _rjxr, "temp_rjxr.jxr" );
		}

	}
}
