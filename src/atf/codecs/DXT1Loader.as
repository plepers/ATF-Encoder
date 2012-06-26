/* ***** BEGIN LICENSE BLOCK *****
 * Copyright (C) 2007-2009 Digitas France
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 * The Initial Developer of the Original Code is
 * Digitas France Flash Team
 *
 * Contributor(s):
 *   Digitas France Flash Team
 *
 * ***** END LICENSE BLOCK ***** */
package atf.codecs {

	import apparat.lzma.LZMADecoder;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;

	/**
	 * @author Pierre Lepers
	 * @author Joa Ebert for LZMA decoder ( http://code.google.com/p/apparat/ )
	 * 
	 * atf.codec.DXT1Loader
	 */
	public class DXT1Loader extends TextureLoader {

		private var _imageData : ByteArray;
		private var _data : ByteArray;

		public function DXT1Loader(imageData : ByteArray, data : ByteArray) {
			_data = data;
			_imageData = imageData;
		}

		override public function load( ) : void {
			_loadImage( );
		}

		private function _loadImage() : void {
			var l : Loader = new Loader( );
			l.contentLoaderInfo.addEventListener( Event.COMPLETE, imageLoaded );
			l.loadBytes( _imageData, new LoaderContext( false, new ApplicationDomain() ) );
		}

		private function imageLoaded(event : Event) : void {
			
			var li : LoaderInfo = event.currentTarget as LoaderInfo;
			li.removeEventListener( Event.COMPLETE, imageLoaded );
			var bmpd : BitmapData = ( li.loader.content as Bitmap ).bitmapData;
			
//			var t : int = getTimer();
			
			_w = bmpd.width << 2;
			_h = bmpd.height << 1;
			
			var colors0 : ByteArray = bmpd.getPixels( new Rectangle( 0, 0, bmpd.width, bmpd.height >> 1 ) ); 
			var colors1 : ByteArray = bmpd.getPixels( new Rectangle( 0, bmpd.height >> 1, bmpd.width, bmpd.height >> 1 ) );
				
			
//			trace( "getPixels	", getTimer() - t , "ms");
			bmpd.dispose( );

			var datas : ByteArray = new ByteArray( );
			_data.position = 0;
			
			// LZMA Decoding
			LZMA.setDecoderProperties( new <int>[
				_data.readUnsignedByte(),
				_data.readUnsignedByte(),
				_data.readUnsignedByte(),
				_data.readUnsignedByte(),
				_data.readUnsignedByte()
			] );
			LZMA.code( _data, datas, uint( _h *_w ) >> 2 );
			
//			trace( "lzma decoded", getTimer() - t , "ms");
			
			colors0.position =
			colors1.position =
			datas.position = 0;
			
			var pixels : ByteArray = _decode( colors0, colors1, datas );

//			trace( "dxt1 decoded", getTimer() - t , "ms");
			
			bitmapData = new BitmapData( _w, _h, false, 0 );
			bitmapData.setPixels( bitmapData.rect, pixels );
			
//			trace( "bitmap ok	", getTimer() - t , "ms\n---");
			dispatchEvent( event );
		}
		private static const LZMA : LZMADecoder = new LZMADecoder( ); 

		
		private function _decode( colors0 : ByteArray, colors1 : ByteArray, data : ByteArray) : ByteArray {
			
			var pixels : ByteArray = new ByteArray( );
			pixels.length = _w * _h * 4;
			
			var bcindex : uint;
			
			// number of 4px lines / rows
			var rlen : uint = _h >> 2;
			var clen : uint = _w >> 2;
			
			// row lenght in pixels bytes
			var rweight : uint = clen << 6;
			var lweight : uint = clen << 4;
			
			var roff : uint;
			var coff : uint;
			
			var m1 : Number = 2 / 3;
			var m2 : Number = 1 / 3;
			
			var RB0 : uint, RB1 : uint, RB2 : uint, RB3 : uint;
			var GB0 : uint, GB1 : uint, GB2 : uint, GB3 : uint;
			var BB0 : uint, BB1 : uint, BB2 : uint, BB3 : uint;
			
			for (var l : int = 0; l < rlen ; l ++) {
				// 4px line
				roff = rweight * l;
				
				for (var b : int = 0; b < clen ; b ++) {
					// DXT 4x4 macro block
					coff = (b << 4) + roff;
					
					// fill colors buffer
					colors0.position++;
					colors1.position++;

					RB0 = colors0.readUnsignedByte( );
					GB0 = colors0.readUnsignedByte( );
					BB0 = colors0.readUnsignedByte( );

					RB1 = colors1.readUnsignedByte( );
					GB1 = colors1.readUnsignedByte( );
					BB1 = colors1.readUnsignedByte( );

					RB2 = RB0 * m1 + RB1 * m2;
					GB2 = GB0 * m1 + GB1 * m2;
					BB2 = BB0 * m1 + BB1 * m2;

					RB3 = RB1 * m1 + RB0 * m2;
					GB3 = GB1 * m1 + GB0 * m2;
					BB3 = BB1 * m1 + BB0 * m2;
					
					palette[0] = 0xFF000000 + (RB0<<16) + (GB0<<8 ) + BB0;
					palette[1] = 0xFF000000 + (RB1<<16) + (GB1<<8 ) + BB1;
					palette[2] = 0xFF000000 + (RB2<<16) + (GB2<<8 ) + BB2;
					palette[3] = 0xFF000000 + (RB3<<16) + (GB3<<8 ) + BB3;
						
					bcindex = data.readUnsignedByte( );
					pixels.position = coff;
					pixels.writeUnsignedInt( palette[ bcindex & 0x3 ] );
					pixels.writeUnsignedInt( palette[ ( bcindex & 0xC  )>>2 ] );
					pixels.writeUnsignedInt( palette[ ( bcindex & 0x30 )>>4 ] );
					pixels.writeUnsignedInt( palette[ ( bcindex & 0xC0 )>>6 ] );
						
					bcindex = data.readUnsignedByte( );
					pixels.position = coff + lweight;
					pixels.writeUnsignedInt( palette[ bcindex & 0x3 ] );
					pixels.writeUnsignedInt( palette[ ( bcindex & 0xC  )>>2 ] );
					pixels.writeUnsignedInt( palette[ ( bcindex & 0x30 )>>4 ] );
					pixels.writeUnsignedInt( palette[ ( bcindex & 0xC0 )>>6 ] );
						
					bcindex = data.readUnsignedByte( );
					pixels.position = coff + 2 * lweight;
					pixels.writeUnsignedInt( palette[ bcindex & 0x3 ] );
					pixels.writeUnsignedInt( palette[ ( bcindex & 0xC  )>>2 ] );
					pixels.writeUnsignedInt( palette[ ( bcindex & 0x30 )>>4 ] );
					pixels.writeUnsignedInt( palette[ ( bcindex & 0xC0 )>>6 ] );
						
					bcindex = data.readUnsignedByte( );
					pixels.position = coff + 3 * lweight;
					pixels.writeUnsignedInt( palette[ bcindex & 0x3 ] );
					pixels.writeUnsignedInt( palette[ ( bcindex & 0xC  )>>2 ] );
					pixels.writeUnsignedInt( palette[ ( bcindex & 0x30 )>>4 ] );
					pixels.writeUnsignedInt( palette[ ( bcindex & 0xC0 )>>6 ] );
						
				}
			}
			pixels.position = 0;
			return pixels;
		}

		private var _w : uint;
		private var _h : uint;

		private static const palette : Vector.<uint> = new Vector.<uint>( 4, true );
	}
}
