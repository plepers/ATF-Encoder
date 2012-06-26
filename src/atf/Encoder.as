package atf {

	import flash.display.BitmapData;
	import flash.display.JPEGXREncoderOptions;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;

	/**
	 * @author Pierre Lepers
	 * encoder.AtfEncoder
	 */
	public class Encoder {
		
		/**
		 * encode a single bitmapdata in a normal atf file (AtfType.NORMAL / 2D texture)
		 * @param bmp BitmapData to encode
		 * @param opts encoding options @see AtfEncoderOptions
		 * @param output The output ByteArray to hold the atf, if null the atf bytes are returned. The position of the bytearray is not modified by encoder, so you can encode multiple atf in single bytearray.
		 * @return the atf encoded file
		 */
		public static function encode( bmp : BitmapData, opts : EncodingOptions, output : ByteArray ) : ByteArray {
			
			output = output || new ByteArray(); 
			
			var position : uint;
			var headpos : uint = output.position; 
			var clipRect : Rectangle = bmp.rect;
			var buffer : BitmapData = bmp.transparent ? _canvasBufferRGBA : _canvasBufferRGB;
			var jxropt : JPEGXREncoderOptions = new JPEGXREncoderOptions( opts.quantization, opts.colorSpace, opts.flexbits );
			
			output.position += Header.LENGTH;
			
			_prepareHeader( bmp, opts, false );
			_appendTexture( bmp, clipRect, jxropt, output );
			
			for (var mip : int = 1; mip < _header.count; mip++) {
				buffer.drawWithQuality( (mip == 1) ? bmp:buffer, _subscaleMtx, null, null, clipRect, true, opts.mipQuality );
				clipRect.width *= .5;
				clipRect.height *= .5;
				_appendTexture( buffer, clipRect, jxropt, output );
			}
			
			position = output.position;
			output.position = headpos;
			_header.length = position - headpos - 6;
			_header.writeExternal( output );
			output.position = position;
			
			return output;
		}
		
		/**
		 * create a cube map texture with the given 6 bitmapdatas.
		 * @param bmps Vector containing 6 bitmapdatas
		 * 			0: Left
		 *			(negative x)
		 *			1: Right
		 *			(positive x)
		 *			2: Bottom
		 *			(negative y)
		 *			3: Top
		 *			(positive y)
		 *			4: Back
		 *			(negative z)
		 *			5: Front
		 *			(positive z)
		 *			note that the first face (left) is used to determine transparency and size. the encoder assume that each bitmapdatas have the same size and transparency
		 * @param opts encoding options @see AtfEncoderOptions
		 * @param output The output ByteArray to hold the encoded image, if null the atf bytes are returned. The position of the bytearray is not modified by encoder, so you can encode multiple atf in single bytearray.
		 * @return the atf encoded file
		 */
		public static function encodeCubeMap( bmps : Vector.<BitmapData>, opts : EncodingOptions, output : ByteArray ) : ByteArray {
			output = output || new ByteArray(); 
			
			var position : uint;
			var headpos : uint = output.position; 
			
			output.position += Header.LENGTH;
			
			_prepareHeader( bmps[0], opts, false );
			
			var count : uint = _header.count;
			var bmp : BitmapData;
			var buffer : BitmapData = bmps[0].transparent ? _canvasBufferRGBA : _canvasBufferRGB;
			var clipRect : Rectangle;
			var jxropt : JPEGXREncoderOptions = new JPEGXREncoderOptions( opts.quantization, opts.colorSpace, opts.flexbits );
			
			
			for (var j : int = 0; j < 6; j++) {
				
				bmp = bmps[j];
				
				clipRect = bmp.rect;
	
				_appendTexture( bmp, clipRect, jxropt, output );
				
				for (var mip : int = 1; mip < count; mip++) {
					buffer.drawWithQuality( (mip == 1) ? bmp:buffer, _subscaleMtx, null, null, clipRect, true, opts.mipQuality );
					clipRect.width *= .5;
					clipRect.height *= .5;
					_appendTexture( buffer, clipRect, jxropt, output );
				}
			}
			
			position = output.position;
			output.position = headpos;
			_header.length = position - headpos - 6;
			_header.writeExternal( output );
			output.position = position;
			
			return output;
		}

		private static function _prepareHeader( bmp : BitmapData, opts : EncodingOptions, cubic : Boolean = false ) : void {
			
			var h : uint = bmp.height;
			var w : uint = bmp.width;
			
			if( (w & (w - 1)) != 0 ||  (h & (h - 1)) != 0 ) 
				throw new ArgumentError( "input bitmapdata's dimensions must be power of two : "+w+"x"+h );
				
			_header.count = opts.mipmap ? ( Math.log( Math.min( w, h ) ) / Math.LN2)+1 : 1;
			_header.format = bmp.transparent ? AtfFormat.RGBA88888 : AtfFormat.RGB888;
			_header.type = cubic ? AtfType.CUBE_MAP : AtfType.NORMAL;
			_header.width = w;
			_header.height = h;
		}



		private static function _appendTexture(bmp : BitmapData, rect : Rectangle, opts : JPEGXREncoderOptions, bytes : ByteArray ) : void {
			var pos : uint = bytes.position;
			bytes.position += 3;
			bmp.encode( rect, opts, bytes );
			var len : uint = bytes.position - pos - 3;
			bytes.position = pos;
			bytes.writeByte( len >> 16 );
			bytes.writeByte( len >> 8 );
			bytes.writeByte( len );
			bytes.position += len;
		}
		
		private static const _subscaleMtx : Matrix= new Matrix( .5, 0, 0, .5 );
		private static const _header : Header = new Header();
		private static const _canvasBufferRGB : BitmapData = new BitmapData( 1024, 1024, false, 0 );
		private static const _canvasBufferRGBA : BitmapData = new BitmapData( 1024, 1024, true, 0 );
		
	}
}
