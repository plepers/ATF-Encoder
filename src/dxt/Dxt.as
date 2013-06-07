package dxt {
	import flash.geom.Rectangle;
	import flash.utils.IDataOutput;
	import flash.utils.ByteArray;
	import flash.display.BitmapData;
	/**
	 * @author Pierre Lepers
	 * dxt.Dxt
	 */
	public class Dxt {

		public static function encode( input : BitmapData, output : IDataOutput ) : void {
			
			var bw : int = input.width >> 2;
			var bh : int = input.height >> 2;
			
			var cset : ColourSet = new ColourSet();
			
			for (var y : int = 0; y < bh; y++) {
				_blockRect.y = y<<2;
				
				for (var x : int = 0; x < bw; x++) {
					_blockRect.x = x<<2;
					
					cset.construct( input.getVector( _blockRect ) );
					
					
				}
			}
		}
		
		internal static function writeBlock4( r1 : Number, g1 : Number, b1 : Number, r2 : Number, g2 : Number, b2 : Number, indices : Vector.<uint>, output : IDataOutput ) : void {
			
		}
		
		private static const _blockRect : Rectangle = new Rectangle( 0, 0, 4, 4 );
		
	}
}
