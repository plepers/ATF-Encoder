package {

	import atf.Encoder;
	import atf.EncodingOptions;
	import atf.Header;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapEncodingColorSpace;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.CompressionAlgorithm;



	/**
	 * @author Pierre Lepers
	 * SimpleTest
	 */
	public class SimpleTest extends Sprite {

	
		private var _viewer : SimpleViewer;
		
		private var _atf : ByteArray;
		
		[Embed(source="../assets/modified_atf.atf", mimeType="application/octet-stream")]
		private var ModAtf : Class;
		

		public function SimpleTest() {
			
			
			
			_viewer = new SimpleViewer();
			
			var tex : BitmapData = new BitmapData(512, 512, true, 0x0 );
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

//			addChild( new Bitmap(tex) );
			
			var opt : EncodingOptions = new EncodingOptions();
			opt.quantization = 60;
			opt.mipmap = false;
			opt.flexbits = 5;
			opt.mipQuality = StageQuality.HIGH;
			opt.colorSpace = BitmapEncodingColorSpace.COLORSPACE_4_2_0;
			
			_atf = new ByteArray();
			Encoder.encode( tex, opt, _atf );
			
			// cube
			//Encoder.encodeCubeMap( new <BitmapData>[tex, tex, tex, tex, tex, tex ], opt, _atf );
			
			trace( "SimpleTest - SimpleTest -- ", _atf.length );
			
			_viewer.setTexture( _atf );
			
			addChild( _viewer );
			
			addEventListener( Event.ADDED_TO_STAGE, onAdded );
			addEventListener( Event.REMOVED_FROM_STAGE, onRemoved );
			
		}

		private function onClick(event : MouseEvent) : void {
			var fr : FileReference = new FileReference();
			fr.save( _atf, "testatf.atf" );
		}

		private function onAdded( e : Event ) : void {
			stage.addEventListener( MouseEvent.CLICK, onClick );
		}
		
		private function onRemoved( e : Event ) : void {
		}
	}
}
