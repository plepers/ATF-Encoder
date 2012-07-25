package cmd {

	import avmplus.FileSystem;
	import avmplus.System;

	import hdr.Radiance;

	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.getTimer;

	use namespace AS3;
	/**
	 * @author Pierre Lepers
	 * cmd.Hdr2Float
	 */
	public class HdrConverter {

		private var cl : CommandLine;

		public function HdrConverter(args : Array) {
			trace("cmd.Hdr2Float - Hdr2Float -- ");

			cl = new CommandLine(args);

			if ( cl.isEmpty() ) {
				printHelp();
				System.exit(0);
			}

			_run();

			System.exit(0);
		}

		private function _run() : void {
			trace("cmd.Hdr2Float - _run -- ", cl.input);
			var input : ByteArray = FileSystem.readByteArray(cl.input);
			trace("cmd.Hdr2Float - _run -- input len  ", input.length);

			var t : int = getTimer();

			var hdrData : Radiance = new Radiance();
			hdrData.readExternal(input);

			var fdata : ByteArray

			trace("convert in ", getTimer() - t, "ms");

			if ( cl.crossmap && cl.floatExport ) {
				if( fdata == null ) {
					fdata = new ByteArray();
					hdrData.convertToFloatRGB(fdata);
				}
				_exportCrossMapToFloat(fdata, hdrData.width, hdrData.height);
			}
			if ( cl.crossmap && cl.pngExport ) {
				_exportCrossMapToPng(hdrData.getRGBE(), hdrData.width, hdrData.height);
			}
		}

		private function _exportCrossMapToPng( data : ByteArray, width : int, height : int) : void {
			var baseName : String = cl.pngExport;
			// Figure out whether we're dealing with an image with mipmaps
			// (square image, with mipmap chain embedded down and to the right
			// of the cross) or not (simple cross).
			var faceSize : int = guessFaceSize( width, height );
			var faceData : ByteArray = new ByteArray();

			// Positive X
			var i : int, j : int;
			var x : int, y : int;
			var ht : int;
			for (j = 0; j < faceSize; ++j) {
				y = height - (faceSize + j + 1);
				ht = width * (height - 1 - y);
				faceData.writeBytes(data, ht*4, faceSize*4 );
			}
			writeBinaryFile(baseName, "1", PNGEncoder.encode( faceData, faceSize, faceSize ) );

			// Negative X
			faceData.position = 
			faceData.length = 0;
			for ( j = 0; j < faceSize; ++j) {
				y = height - (faceSize + j + 1);
				ht = width * (height - 1 - y);
				ht = (ht + 2 * faceSize)*4;
				faceData.writeBytes(data, ht, faceSize*4 );
			}
			writeBinaryFile(baseName, "0", PNGEncoder.encode( faceData, faceSize, faceSize ) );

			// Positive Y
			faceData.position = 
			faceData.length = 0;
			for ( j = 0; j < faceSize; ++j) {
				y = 3 * faceSize + j;
				ht = width * (height - 1 - y);
				
				for ( i = 0; i < faceSize; ++i) {
					x = 2 * faceSize - (i + 1);
					data.position = (ht + x) * 4;
					faceData.writeUnsignedInt(data.readUnsignedInt());
				}
				
			}
			writeBinaryFile(baseName, "3", PNGEncoder.encode( faceData, faceSize, faceSize ) );

			// Negative Y
			faceData.position = 
			faceData.length = 0;
			for ( j = 0; j < faceSize; ++j) {
				y = faceSize + j;
				ht = width * (height - 1 - y);
				for ( i = 0; i < faceSize; ++i) {
					x = 2 * faceSize - (i + 1);
					data.position = (ht + x) * 4;
					faceData.writeUnsignedInt(data.readUnsignedInt());
				}
			}
			writeBinaryFile(baseName, "2", PNGEncoder.encode( faceData, faceSize, faceSize ) );

			// Positive Z
			faceData.position = 
			faceData.length = 0;
			for ( j = 0; j < faceSize; ++j) {
				y = j;
				ht = width * (height - 1 - y);
				for ( i = 0; i < faceSize; ++i) {
					x = 2 * faceSize - (i + 1);
					data.position = (ht + x) * 4;
					faceData.writeUnsignedInt(data.readUnsignedInt());
				}
			}
			writeBinaryFile(baseName, "5", PNGEncoder.encode( faceData, faceSize, faceSize ) );

			// Negative Z
			faceData.position = 
			faceData.length = 0;
			for ( j = 0; j < faceSize; ++j) {
				y = height - (faceSize + j + 1);
				ht = width * (height - 1 - y);
				ht = ( ht+faceSize )*4;
				faceData.writeBytes(data, ht, faceSize*4 );
			}
			writeBinaryFile(baseName, "4", PNGEncoder.encode( faceData, faceSize, faceSize ) );
		}

		private function _exportCrossMapToFloat(data : ByteArray, width : int, height : int) : void {
			var baseName : String = cl.floatExport;
			// Figure out whether we're dealing with an image with mipmaps
			// (square image, with mipmap chain embedded down and to the right
			// of the cross) or not (simple cross).
			var faceSize : int = guessFaceSize( width, height );
			var faceData : ByteArray = new ByteArray();
			faceData.endian = Endian.LITTLE_ENDIAN;

			// Positive X
			var i : int, j : int;
			var x : int, y : int;
			var ht : int;
			for (j = 0; j < faceSize; ++j) {
				y = height - (faceSize + j + 1);
				ht = width * (height - 1 - y);
				for (i = 0; i < faceSize; ++i) {
					x = i;
					data.position = (ht + x) * 12;
					faceData.writeFloat(data.readFloat());
					faceData.writeFloat(data.readFloat());
					faceData.writeFloat(data.readFloat());
				}
			}
			writeBinaryFile(baseName, "0", faceData);

			// Negative X
			faceData.position = 0;
			for ( j = 0; j < faceSize; ++j) {
				y = height - (faceSize + j + 1);
				ht = width * (height - 1 - y);
				for ( i = 0; i < faceSize; ++i) {
					x = 2 * faceSize + i;
					data.position = (ht + x) * 12;

					faceData.writeFloat(data.readFloat());
					faceData.writeFloat(data.readFloat());
					faceData.writeFloat(data.readFloat());
				}
			}
			writeBinaryFile(baseName, "1", faceData);

			// Positive Y
			faceData.position = 0;
			for ( j = 0; j < faceSize; ++j) {
				y = 3 * faceSize + j;
				ht = width * (height - 1 - y);
				for ( i = 0; i < faceSize; ++i) {
					x = 2 * faceSize - (i + 1);
					data.position = (ht + x) * 12;
					faceData.writeFloat(data.readFloat());
					faceData.writeFloat(data.readFloat());
					faceData.writeFloat(data.readFloat());
				}
			}
			writeBinaryFile(baseName, "4", faceData);

			// Negative Y
			faceData.position = 0;
			for ( j = 0; j < faceSize; ++j) {
				y = faceSize + j;
				ht = width * (height - 1 - y);
				for ( i = 0; i < faceSize; ++i) {
					x = 2 * faceSize - (i + 1);
					data.position = (ht + x) * 12;
					faceData.writeFloat(data.readFloat());
					faceData.writeFloat(data.readFloat());
					faceData.writeFloat(data.readFloat());
				}
			}
			writeBinaryFile(baseName, "5", faceData);

			// Positive Z
			faceData.position = 0;
			for ( j = 0; j < faceSize; ++j) {
				y = j;
				ht = width * (height - 1 - y);
				for ( i = 0; i < faceSize; ++i) {
					x = 2 * faceSize - (i + 1);
					data.position = (ht + x) * 12;
					faceData.writeFloat(data.readFloat());
					faceData.writeFloat(data.readFloat());
					faceData.writeFloat(data.readFloat());
				}
			}
			writeBinaryFile(baseName, "2", faceData);

			// Negative Z
			faceData.position = 0;
			for ( j = 0; j < faceSize; ++j) {
				y = height - (faceSize + j + 1);
				ht = width * (height - 1 - y);
				for ( i = 0; i < faceSize; ++i) {
					x = faceSize + i;
					data.position = (ht + x) * 12;
					faceData.writeFloat(data.readFloat());
					faceData.writeFloat(data.readFloat());
					faceData.writeFloat(data.readFloat());
				}
			}
			writeBinaryFile(baseName, "3", faceData);
		}

		private function guessFaceSize(width : int, height : int) : int {
			var faceSize : int = 0;
			if (width == height) {
				if ((width % 4) != 0) {
					throw new Error("Image width wasn't divisible by 4");
				}
				faceSize = width / 4;
			} else {
				if ((height % 4) != 0) {
					throw new Error("Image height wasn't divisible by 4");
				}
				if ((width % 3) != 0) {
					throw new Error("Image width wasn't divisible by 3");
				}
				faceSize = height / 4;
				if (faceSize != width / 3) {
					throw new Error("Couldn't determine the size of each cube map face");
				}
			}
			return faceSize;
		}

		private function writeBinaryFile(baseName : String, baseName1 : String, faceData : ByteArray) : void {
			var lio : int = baseName.lastIndexOf(".");
			if ( lio == -1 ) lio = baseName.length;

			var n : String = baseName.substr(0, lio) + baseName1 + baseName.substr(lio);
			if ( FileSystem.exists(n) && !FileSystem.canWrite(n) ) {
				throw new Error("hdr2Float - cannot write file " + n);
			}

			FileSystem.writeByteArray(n, faceData);
		}

		private function printHelp() : void {
			var nl : String = "\n";

			var help : String = "";

			help += "hdr2float" + nl;
			help += "convert .hdr (radiance format) to rgb float map" + nl;
			help += "author Pierre Lepers (pierre[dot]lepers[at]gmail[dot]com)" + nl;
			help += "powered by RedTamarin" + nl;
			help += "version 1.0" + nl;
			help += "usage : hdr2float " + nl;

			help += " -i <atffile> input hdr file" + nl;
			help += " -o <filename> : output binary" + nl;
			help += " -c 		convert crossmap to 6 textures" + nl;
			help += " -float 	export to float map" + nl;
			help += " -png 		export to rgbe png" + nl;

			trace(help);
		}
	}
}

import avmplus.System;

import cmd.HdrConverter;

import flash.utils.ByteArray;
import flash.utils.Dictionary;

class CommandLine {

	public var crossmap : Boolean;
	public var floatExport : String;
	public var pngExport : String;

	public function isEmpty() : Boolean {
		return _empty;
	}

	public function CommandLine(arguments : Array) {
		_init();
		_build(arguments);
	}

	private var _input : String;
	private var _help : Boolean;
	private var _verbose : Boolean;

	private function _build(arguments : Array) : void {
		_empty = arguments.length == 0;
		var arg : String;
		while ( arguments.length > 0 ) {
			arg = arguments.shift();
			var handler : Function = _argHandlers[ arg ];
			if ( handler == undefined )
				throw new Error(arg + " is not a valid argument." + HELP);

			handler(arguments);
		}
	}

	private function handleIn(args : Array) : void {
		_input = formatPath(args.shift());
	}


	private function handleHelp(args : Array) : void {
		_help = true;
	}

	private function handleCross(args : Array) : void {
		crossmap = true;
	}

	private function handleFloatExport(args : Array) : void {
		floatExport = args.shift();
	}

	private function handlePngExport(args : Array) : void {
		pngExport = args.shift();
	}

	private function handleVerbose(args : Array) : void {
		var val : String = args.shift();
		_verbose = ( val == "1" || val == "true" );
	}

	private function _init() : void {
		_argHandlers = new Dictionary();

		_argHandlers[ "-i" ] = handleIn;
		_argHandlers[ "-c" ] = handleCross;
		_argHandlers[ "-float" ] = handleFloatExport;
		_argHandlers[ "-png" ] = handlePngExport;
		_argHandlers[ "-verbose" ] = handleVerbose;
		_argHandlers[ "-help" ] = handleHelp;
	}

	private function formatPath(str : String) : String {
		/*FDT_IGNORE*/
		return str.AS3::replace( /\\/g, "/" );
		/*FDT_IGNORE*/
		;
		return str;
	}

	private var _empty : Boolean = true;
	private var _argHandlers : Dictionary;
	private static const HELP : String = " -help for more infos.";


	public function get input() : String {
		return _input;
	}

	public function get help() : Boolean {
		return _help;
	}

	public function get verbose() : Boolean {
		return _verbose;
	}
}

/**
 * from adobe corelib
 */
class PNGEncoder {

	/**
	 * Created a PNG image from the specified BitmapData
	 *
	 * @param image The BitmapData that will be converted into the PNG format.
	 * @return a ByteArray representing the PNG encoded image data.
	 * @langversion ActionScript 3.0
	 * @playerversion Flash 9.0
	 * @tiptext
	 */
	public static function encode( pixels : ByteArray, w : int, h : int ) : ByteArray {
		// Create output byte array
		pixels.position = 0;
		
		var png : ByteArray = new ByteArray();
		// Write PNG signature
		png.writeUnsignedInt(0x89504e47);
		png.writeUnsignedInt(0x0D0A1A0A);
		// Build IHDR chunk
		var IHDR : ByteArray = new ByteArray();
		IHDR.writeInt(w);
		IHDR.writeInt(h);
		IHDR.writeUnsignedInt(0x08060000);
		// 32bit RGBA
		IHDR.writeByte(0);
		writeChunk(png, 0x49484452, IHDR);
		// Build IDAT chunk
		var IDAT : ByteArray = new ByteArray();
		for (var i : int = 0;i < h;i++) {
			// no filter
			IDAT.writeByte(0);
			var p : uint;
			var j : int;
			
			for (j = 0;j < w;j++) {
				p = pixels.readUnsignedInt();
				IDAT.writeUnsignedInt(p);
			}
			
		}
		IDAT.compress();
		writeChunk(png, 0x49444154, IDAT);
		// Build IEND chunk
		writeChunk(png, 0x49454E44, null);
		// return PNG
		return png;
	}

	private static var crcTable : Array;
	private static var crcTableComputed : Boolean = false;

	private static function writeChunk(png : ByteArray, type : uint, data : ByteArray) : void {
		if (!crcTableComputed) {
			crcTableComputed = true;
			crcTable = [];
			var c : uint;
			for (var n : uint = 0; n < 256; n++) {
				c = n;
				for (var k : uint = 0; k < 8; k++) {
					if (c & 1) {
						c = uint(uint(0xedb88320) ^ uint(c >>> 1));
					} else {
						c = uint(c >>> 1);
					}
				}
				crcTable[n] = c;
			}
		}
		var len : uint = 0;
		if (data != null) {
			len = data.length;
		}
		png.writeUnsignedInt(len);
		var p : uint = png.position;
		png.writeUnsignedInt(type);
		if ( data != null ) {
			png.writeBytes(data);
		}
		var e : uint = png.position;
		png.position = p;
		c = 0xffffffff;
		for (var i : int = 0; i < (e - p); i++) {
			c = uint(crcTable[
			(c ^ png.readUnsignedByte()) & uint(0xff)] ^ uint(c >>> 8));
		}
		c = uint(c ^ uint(0xffffffff));
		png.position = e;
		png.writeUnsignedInt(c);
	}
}

include "../hdr/Radiance.as"
include "../hdr/readLn.as"

var hdr2float : HdrConverter = new HdrConverter(System.argv);