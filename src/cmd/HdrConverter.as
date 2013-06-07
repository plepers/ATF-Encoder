package cmd {

	import fx.DiffuseEnv;
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
		private var _base : Number;

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
			trace("cmd.Hdr2Float - convert ", cl.input);
			var input : ByteArray = FileSystem.readByteArray(cl.input);

			var t : int = getTimer();

			var hdrData : Radiance = new Radiance();
			hdrData.readExternal(input);
			
			// TODO add option
			hdrData.saturate();

			var fdata : ByteArray;

			trace("convert in ", getTimer() - t, "ms");
			
			if( cl.mipmap ) {
				hdrData.generateMipmaps(  );
			}

			if ( cl.pngExport ) {
				
				if( cl.diffusion && !cl.mipmap ) {
					
					if( !cl.mipmap ) hdrData.generateMipmaps(  );
					var floatRgb : ByteArray = hdrData.getMipmapFloat( 4 );
//					var floatRgb : ByteArray = new ByteArray();
//					hdrData.convertToFloatRGB( floatRgb );
					_base = hdrData.getBase();
					trace("_splitCrossMapToFloat with base ", _base );
					var faces : Array = _splitCrossMapToFloat( floatRgb , hdrData.width >> 5, hdrData.height >> 5);
					
					var diffuseEnv : DiffuseEnv = new DiffuseEnv();
					diffuseEnv.configure( cl.outputSize, cl.numSample, cl.power, cl.curve, cl.passes );
					diffuseEnv.processFaces( faces[0],faces[1],faces[2],faces[3],faces[4],faces[5], onDiffuseComplete);
					return;
				}
				
				writeBinaryFile(cl.pngExport, cl.mipmap ? "_mip0":"", PNGEncoder.encode( hdrData.getRGBE(), hdrData.width, hdrData.height) );
				
				if( cl.mipmap ) {
					var mipbytes : ByteArray = new ByteArray();
					for (var i : int = 0; i < hdrData.numLevels; i++) {
						hdrData.getMipmapRGBE(i, mipbytes);
						writeBinaryFile(cl.pngExport, "_mip"+(i+1), PNGEncoder.encode( mipbytes, hdrData.width >> (i+1), hdrData.height >> (i+1) ) );
						mipbytes.length = 0;
						
					}
				}
			}
		}

		public function onDiffuseComplete( result : Array ) : void {
			
			
			var faceSize : int = Math.sqrt( ( result[0] as Vector.<Number> ).length/3);
			
			trace( "faceSize", faceSize );
			
			var floatRgb : ByteArray = _composeCrossMapFromFloat( result );
			
			var hdrData : Radiance = new Radiance();
			
			hdrData.setFloatRGB( floatRgb, faceSize*3, faceSize*4, _base );
			
			trace( "hdrData.width, hdrData.height, base",  hdrData.width, hdrData.height, _base);
			
			writeBinaryFile(cl.pngExport, cl.mipmap ? "_mip0":"", PNGEncoder.encode( hdrData.getRGBE(), hdrData.width, hdrData.height) );
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

		private function _splitCrossMapToFloat(data : ByteArray, width : int, height : int) : Array {
			
			var res : Array = [];
			
			// Figure out whether we're dealing with an image with mipmaps
			// (square image, with mipmap chain embedded down and to the right
			// of the cross) or not (simple cross).
			var faceSize : int = guessFaceSize( width, height );
			
			var faceData : Vector.<Number>;
			
			
			faceData = new Vector.<Number>();
			res.push( faceData );
			
			// left
			var i : int, j : int;
			var x : int, y : int;
			var ht : int;
			for (j = 0; j < faceSize; ++j) {
				ht = width * (faceSize + j);
				for (i = 0; i < faceSize; ++i) {
					x = i;
					data.position = (ht + x) * 12;
					faceData.push( data.readFloat() );
					faceData.push( data.readFloat() );
					faceData.push( data.readFloat() );
				}
			}

			// right
			faceData = new Vector.<Number>();
			res.push( faceData );
			for ( j = 0; j < faceSize; ++j) {
				ht = width * (faceSize + j);
				for ( i = 0; i < faceSize; ++i) {
					x = 2 * faceSize + i;
					data.position = (ht + x) * 12;

					faceData.push(data.readFloat());
					faceData.push(data.readFloat());
					faceData.push(data.readFloat());
				}
			}

			// top
			faceData = new Vector.<Number>();
			res.push( faceData );
			for ( j = 0; j < faceSize; ++j) {
				ht = width * j;
				for ( i = 0; i < faceSize; ++i) {
					x = faceSize + i;
					data.position = (ht + x) * 12;
					faceData.push(data.readFloat());
					faceData.push(data.readFloat());
					faceData.push(data.readFloat());
				}
			}

			// bottom
			faceData = new Vector.<Number>();
			res.push( faceData );
			for ( j = 0; j < faceSize; ++j) {
				ht = width * (faceSize*2 + j);
				for ( i = 0; i < faceSize; ++i) {
					x = faceSize + i;
					data.position = (ht + x) * 12;
					faceData.push(data.readFloat());
					faceData.push(data.readFloat());
					faceData.push(data.readFloat());
				}
			}

			// front
			faceData = new Vector.<Number>();
			res.push( faceData );
			for ( j = 0; j < faceSize; ++j) {
				ht = width * (faceSize + j);
				for ( i = 0; i < faceSize; ++i) {
					x = faceSize + i;
					data.position = (ht + x) * 12;
					faceData.push(data.readFloat());
					faceData.push(data.readFloat());
					faceData.push(data.readFloat());
				}
			}

			// back
			faceData = new Vector.<Number>();
			res.push( faceData );
			for ( j = 0; j < faceSize; ++j) {
				ht = width * (height - 1 - j);
				for ( i = 0; i < faceSize; ++i) {
					x = 2 * faceSize - (i + 1);
					data.position = (ht + x) * 12;
					faceData.push(data.readFloat());
					faceData.push(data.readFloat());
					faceData.push(data.readFloat());
				}
			}
			
			return res;
		}


		private function _composeCrossMapFromFloat( faces : Array) : ByteArray {
			
			var data : ByteArray = new ByteArray();
			// Figure out whether we're dealing with an image with mipmaps
			// (square image, with mipmap chain embedded down and to the right
			// of the cross) or not (simple cross).
			var faceSize : int = Math.sqrt( ( faces[0] as Vector.<Number> ).length/3);
			var width : int = faceSize*3;
			var height : int = faceSize*4;
			
			data.length = width * height * 12;
			
			var faceData : Vector.<Number>;
			
			
			faceData = faces[0];
			
			
			// left
			var i : int, j : int;
			var x : int, y : int;
			var ht : int;
			var c : int;
			
			c = 0;
			for (j = 0; j < faceSize; ++j) {
				ht = width * (faceSize + j);
				for (i = 0; i < faceSize; ++i) {
					x = i;
					data.position = (ht + x) * 12;
					data.writeFloat(faceData[c++] );
					data.writeFloat(faceData[c++] );
					data.writeFloat(faceData[c++] );
				}
			}

			// right
			faceData = faces[1];
			c=0;
			for ( j = 0; j < faceSize; ++j) {
				ht = width * (faceSize + j);
				for ( i = 0; i < faceSize; ++i) {
					x = 2 * faceSize + i;
					data.position = (ht + x) * 12;

					data.writeFloat(faceData[c++] );
					data.writeFloat(faceData[c++] );
					data.writeFloat(faceData[c++] );
				}
			}

			// top
			faceData = faces[2];
			c=0;
			for ( j = 0; j < faceSize; ++j) {
				y = 3 * faceSize + j;
				ht = width * j;
				for ( i = 0; i < faceSize; ++i) {
					x = faceSize + i;
					data.position = (ht + x) * 12;
					data.writeFloat(faceData[c++] );
					data.writeFloat(faceData[c++] );
					data.writeFloat(faceData[c++] );
				}
			}

			// bottom
			faceData = faces[3];
			c=0;
			for ( j = 0; j < faceSize; ++j) {
				ht = width * (faceSize*2 + j);
				for ( i = 0; i < faceSize; ++i) {
					x = faceSize + i;
					data.position = (ht + x) * 12;
					data.writeFloat(faceData[c++] );
					data.writeFloat(faceData[c++] );
					data.writeFloat(faceData[c++] );
				}
			}

			// front
			faceData = faces[4];
			c=0;
			for ( j = 0; j < faceSize; ++j) {
				y = j;
				ht = width * (faceSize + j);
				for ( i = 0; i < faceSize; ++i) {
					x = faceSize + i;
					data.position = (ht + x) * 12;
					data.writeFloat(faceData[c++] );
					data.writeFloat(faceData[c++] );
					data.writeFloat(faceData[c++] );
				}
			}

			// back
			faceData = faces[5];
			c=0;
			for ( j = 0; j < faceSize; ++j) {
				y = height - (faceSize + j + 1);
				ht = width * (height - 1 - j);
				for ( i = 0; i < faceSize; ++i) {
					x = 2 * faceSize - (i + 1);
					data.position = (ht + x) * 12;
					data.writeFloat(faceData[c++] );
					data.writeFloat(faceData[c++] );
					data.writeFloat(faceData[c++] );
				}
			}
			
			return data;
		}

		private function rotatePict( pict : Vector.<Number> ) : void {
			var l : int = pict.length/3;
			var l3 : int = l-3;
			var tmp :  Vector.<Number>  = pict.concat();
			var i3 : int;
			var ri3 : int;
			for (var i : int = 0; i <l; i++) {
				
				i3 = i*3;
				ri3 = (l3-i)*3
				pict[i3] = tmp[i3];
				pict[i3+1] = tmp[i3+1];
				pict[i3+2] = tmp[i3+2];
			}
			
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
			help += " -float 	export to float map" + nl;
			help += " -png 		export to rgbe png" + nl;
			help += " -tm <expo> <gamma>	tone map export in std RGB24 " + nl;
			help += " -diffusion <size> <numSamples> <power> <curve> <passes>" + nl;

			trace(help);
		}
	}
}

import avmplus.System;

import cmd.HdrConverter;

import flash.utils.ByteArray;
import flash.utils.Dictionary;

class CommandLine {

	public var floatExport : String;
	public var pngExport : String;
	public var mipmap : Boolean;
	private var _numSample : int;
	private var _power : Number;
	private var _curve : Number;
	private var _passes : int;
	public var diffusion : Boolean;
	private var _outputSize : int;

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

	private function handleDiffusion(args : Array) : void {
		_outputSize = parseInt( args.shift() );
		_numSample = parseInt( args.shift() );
		_power = parseFloat( args.shift() );
		_curve = parseFloat( args.shift() );
		_passes = parseInt( args.shift() );
		diffusion = true;
	}

	private function handleMipmap(args : Array) : void {
		var val : String = args.shift();
		mipmap = ( val == "1" || val == "true" );
	}

	private function _init() : void {
		_argHandlers = new Dictionary();

		_argHandlers[ "-i" ] = handleIn;
		_argHandlers[ "-mipmap" ] = handleMipmap;
		_argHandlers[ "-float" ] = handleFloatExport;
		_argHandlers[ "-png" ] = handlePngExport;
		_argHandlers[ "-diffusion" ] = handleDiffusion;
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

	public function get numSample() : int {
		return _numSample;
	}

	public function get power() : Number {
		return _power;
	}

	public function get curve() : Number {
		return _curve;
	}

	public function get passes() : int {
		return _passes;
	}

	public function get outputSize() : int {
		return _outputSize;
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
include "../fx/DiffuseEnv.as"

var hdr2float : HdrConverter = new HdrConverter(System.argv);