package {

	import atf.TexBlocks;
	import atf.Header;
	import flash.net.FileReference;
	import atf.Decoder;
	import atf.TexFormat;
	import atf.Utils;
	import atf.codecs.TextureLoader;

	import flash.display.BitmapData;
	import flash.display.JPEGXREncoderOptions;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.ByteArray;

	/**
	 * @author Pierre Lepers
	 * UtilReplaceTest
	 */
	public class UtilReplaceTest extends Sprite {

		
		private var _viewer : SimpleViewer;
		private var _atf : ByteArray;
		
		[Embed(source="../assets/jxr_nomip.atf", mimeType="application/octet-stream")]
		private var jxr_nomip : Class;
		[Embed(source="../assets/jxr_mip.atf", mimeType="application/octet-stream")]
		private var jxr_mip : Class;
		
		[Embed(source="../assets/bb_mip.atf", mimeType="application/octet-stream")]
		private var bb_mip : Class;

		[Embed(source="../assets/8x8.atf", mimeType="application/octet-stream")]
		private var bb8x8 : Class;
		
		[Embed(source="../assets/bb_nomip.atf", mimeType="application/octet-stream")]
		private var bb_nomip : Class;
		
		[Embed(source="../assets/out.jxr", mimeType="application/octet-stream")]
		private var jxr_565 : Class;
		
		private var jxr : ByteArray;

		public function UtilReplaceTest() {
			
			
			
			_viewer = new SimpleViewer();
			
//			var tex : BitmapData = new BitmapData(64, 124, false, 0x00FF00 );
			var tex : BitmapData = new BitmapData(128, 128, false, 0x00FF00 );
			var shape : Shape = new Shape();
			
			shape.graphics.beginFill( 0xFF0000 );
			shape.graphics.drawCircle( 40, 40, 30 );
			shape.graphics.beginFill( 0x0000ff );
			shape.graphics.drawCircle( 256-40, 40, 30 );
			for (var i : int = 0; i < 100; i++) {
				shape.graphics.beginFill( Math.random() * 0xFFFFFF );
				shape.graphics.drawCircle( Math.random() * tex.width,  Math.random() * tex.height, Math.random() * 30 );
			}

			shape.graphics.endFill();
			for (i = 0; i < 50; i++) {
				shape.graphics.lineStyle( 1, 0 );
				shape.graphics.moveTo(Math.random() * tex.width,  Math.random() * tex.height );
				shape.graphics.lineTo(Math.random() * tex.width,  Math.random() * tex.height );
			}
			
			tex.draw( shape );

			jxr = tex.encode(tex.rect, new JPEGXREncoderOptions( 20 ) );
//			jxr = new jxr_565();
//			return;
			_atf = new jxr_mip();
			Utils.replaceImageData( _atf, jxr, 2 );
//			_atf = new bb_mip();
//			jxr = new ByteArray();
//			jxr.writeBytes( _atf, 60311, 39729 );
			
//			var l : Loader = new Loader();
//			l.loadBytes( jxr );
//			addChild( l );
			
//			Util.replaceImageData(_atf, jxr, 0, 0, 0, TexFormat.DXT );
			
			
//			var loader : TextureLoader = Decoder.decode(_atf, 0, 0, 0 );
//////			loader.scaleX = loader.scaleY = 0.5;
//			loader.x = 256;
//			loader.load();
//			addChild( loader );
			
			
			
			
			addEventListener( Event.ADDED_TO_STAGE, onAdded );
			addEventListener( Event.REMOVED_FROM_STAGE, onRemoved );
			

			_atf = new bb8x8();
			Utils.removeAllBut( _atf, TexFormat.DXT );
			_viewer.setTexture( _atf );
			
			addChild( _viewer );
			
			var h : Header = new Header();
			var b : TexBlocks = new TexBlocks();
			_atf.position = 0;
			h.readExternal( _atf );
			b.read( _atf, h );
			
			trace( "UtilReplaceTest - UtilReplaceTest -- ", b.blocks );
			
		}

//		private function onClick(event : MouseEvent) : void {
//			var fr : FileReference = new FileReference();
//			fr.save( _atf, "testatf.atf" );
//		}

		private function onAdded( e : Event ) : void {
			stage.addEventListener( MouseEvent.CLICK, onClick );
		}

		private function onClick(event : MouseEvent) : void {
			var fr : FileReference = new FileReference();
			fr.save( _atf );
		}
		
		private function onRemoved( e : Event ) : void {
		}
	}
}
