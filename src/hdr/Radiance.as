package hdr {
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	
	use namespace AS3;
	/**
	 * @author Pierre Lepers
	 * hdr.Radiance
	 */
	public class Radiance {

		private var _header : Header;
		private var _rle : ByteArray;
		
		
		public function get width() : int {
			return _header.width;
		}

		public function get height() : int {
			return _header.height;
		}
		
		public function readExternal(input : IDataInput) : void {
			_header = new Header();
			_header.readExternal(input);

			_rle = new ByteArray();
			readPixelsRawRLE(input, _rle, _header.width, _header.height);
			//saturate( _rle );

		}

		public function saturate(rle : ByteArray) : void {
			
			var min : uint = 0xFF;
			var max : uint = 0x0;
			var f : uint;
			
			var len : int = rle.length>>2;
			for (var i : int = 0; i < len; i++) {
				rle.position = i*4+3;
				f = rle.readUnsignedByte();
				if( f == 0 ) continue;
				if( f < min ) min = f;
				if( f > max ) max = f;
			}
			
			var range_m : Number = 0xFE / (max-min);
			
			for ( i  = 0; i < len; i++) {
				rle.position = i*4+3;
				f = uint( ( rle.readUnsignedByte() - min + 1) * range_m ) & 0xFF;
				rle.position = i*4+3;
				rle.writeByte( f );
				
			}

		}
		
		public function getHistogram() : Vector.<uint> {
			var i: uint;
			var len : int = _rle.length>>2;
			var hist : Vector.<uint> = new Vector.<uint>( 0xff, true );

			for (i = 0; i <= 0xff; i++) {
				hist[i] = 0;
			}
			
			for ( i = 0; i < len; i++) {
				_rle.position = i*4+3;
				hist[_rle.readUnsignedByte()]++;
			}
			return hist;
		}

		public function getRGBE() : ByteArray {
			return _rle;
		}

		public function convertToFloatRGB(result : ByteArray) : void {
			_rle.position = result.position = 0;

			var npix : uint = _header.width * _header.height;
			var f : Number;
			var r : Number,g : Number,b : Number;

			for (var i : int = 0; i < npix; i++) {
				
				r = _rle.readUnsignedByte();
				g = _rle.readUnsignedByte();
				b = _rle.readUnsignedByte();
				f = _rle.readUnsignedByte();
				
				if( f == 0 ) {
					result.writeFloat( .0 );
					result.writeFloat( .0 );
					result.writeFloat( .0 );
				} else {
					f = Math.pow(2.0,( f & 0xFF ) - (128+8) );
					result.writeFloat( r * f );
					result.writeFloat( g * f );
	                result.writeFloat( b * f );
				}
			}
		}


		private static function readPixelsRawRLE(input : IDataInput, data : ByteArray, scanline_width : int, num_scanlines : int) : void {
			var offset : uint = 0;
			var ptr : uint, ptr_end : uint;
			var count : uint;

			var scanline_buffer : ByteArray;
			var rgbe : ByteArray = new ByteArray();
			rgbe.length = 4;
			var buf : ByteArray = new ByteArray();
			rgbe.length = 2;

			if ((scanline_width < 8) || (scanline_width > 0x7fff)) {
				throw "run length encoding is not allowed so read flat";
			}

			while (num_scanlines > 0) {
				input.readBytes(rgbe, 0, 4);

				if ((rgbe[0] != 2) || (rgbe[1] != 2) || ((rgbe[2] & 0x80) != 0)) {
					/* this file is not run length encoded */
					data[offset++] = rgbe[0];
					data[offset++] = rgbe[1];
					data[offset++] = rgbe[2];
					data[offset++] = rgbe[3];
					readPixelsRaw(input, data, offset, scanline_width * num_scanlines - 1);
				}

				if ((((rgbe[2] & 0xFF) << 8) | (rgbe[3] & 0xFF)) != scanline_width) {
					throw new Error("Wrong scanline width " + (((rgbe[2] & 0xFF) << 8) | (rgbe[3] & 0xFF)) + ", expected " + scanline_width);
				}

				if (scanline_buffer == null) {
					scanline_buffer = new ByteArray();
					scanline_buffer.length = 4 * scanline_width;
				}
				ptr = 0;
				/* read each of the four channels for the scanline into the buffer */
				
				
				for (var i : int = 0; i < 4; i++) {
					ptr_end = (i + 1) * scanline_width;
					while (ptr < ptr_end) {
						input.readBytes(buf, 0, 2);

						if ((buf[0] & 0xFF) > 128) {
							/* a run of the same value */
							count = (buf[0] & 0xFF) - 128;
							if ((count == 0) || (count > ptr_end - ptr)) {
								throw new Error("Bad scanline data");
							}
							while (count-- > 0)
								scanline_buffer[ptr++] = buf[1];
						} else {
							/* a non-run */
							count = buf[0] & 0xFF;
							if ((count == 0) || (count > ptr_end - ptr)) {
								throw new Error("Bad scanline data");
							}
							scanline_buffer[ptr++] = buf[1];
							if (--count > 0) {
								input.readBytes(scanline_buffer, ptr, count);
								ptr += count;
							}
						}
					}
				}
				

				/* copy byte data to output */
				for ( i = 0; i < scanline_width; i++) {
					data[offset++] = scanline_buffer[i];
					data[offset++] = scanline_buffer[i + scanline_width];
					data[offset++] = scanline_buffer[i + 2 * scanline_width];
					data[offset++] = scanline_buffer[i + 3 * scanline_width];
				}

				num_scanlines--;
			}
		}

		private static function readPixelsRaw(input : IDataInput, data : ByteArray, offset : int, numpixels : int) : void {
			var numExpected : int = 4 * numpixels;
			input.readBytes(data, offset, numExpected);
		}
	}
}

import hdr.readLn;

import flash.utils.IDataInput;
import flash.utils.IDataOutput;
import flash.utils.IExternalizable;

use namespace AS3;
class Header implements IExternalizable {

	var programType : String = null;
	var gamma : Number = 1.0;
	var exposure : Number = 1.0;
	var valid : int = 0;
	var width : int = 0;
	var height : int = 0;

	public function Header() {
	}

	public function readExternal(input : IDataInput) : void {
		var buf : String;

		buf = readLn(input);
		if (buf.charAt(0) == '#' && buf.charAt(1) == '?') {
			valid |= VALID_PROGRAMTYPE;
			programType = buf.substring(2);
			buf = readLn(input);
		}

		var foundFormat : Boolean = false;
		var done : Boolean = false;
		var c : int = 0;
		while (!done && c < 80) {
			c++;
			trace(buf);
			if (buf == "FORMAT=32-bit_rle_rgbe" ) {
				foundFormat = true;
			} else if ( buf.indexOf(GAMMA_STRING) == 0 ) {
				valid |= VALID_GAMMA;
				gamma = parseFloat(buf.substring(GAMMA_STRING.length));
			} else if (buf.indexOf(EXPOSURE_STRING) == 0 ) {
				valid |= VALID_EXPOSURE;
				exposure = parseFloat(buf.substring(EXPOSURE_STRING.length));
			} else {
				var res : * = WidthHeightPattern.exec(buf)
				if ( res ) {
					width = parseInt(res[2]);
					height = parseInt(res[1]);
					done = true;
				}
			}

			if (!done) buf = readLn(input);
		}
	}

	public function writeExternal(output : IDataOutput) : void {
	}

	private static const VALID_PROGRAMTYPE : int = 0x01;
	private static const VALID_GAMMA : int = 0x02;
	private static const VALID_EXPOSURE : int = 0x04;
	private static const GAMMA_STRING : String = "GAMMA=";
	private static const EXPOSURE_STRING : String = "EXPOSURE=";
	private static const WidthHeightPattern : RegExp = /-Y (\d+) \+X (\d+)/gi;
}
