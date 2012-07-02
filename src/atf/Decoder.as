package atf {

	import atf.codecs.JXRLoader;
	import atf.codecs.DXT1Loader;
	import atf.codecs.TextureLoader;

	import flash.utils.ByteArray;
	/**
	 * @author Pierre Lepers
	 * atf.AtfDecoder
	 */
	public class Decoder {
		
		public static function decode( atfbytes : ByteArray, miplevel : uint = 0, face : uint = 0, atfOffset : uint = 0 ) : TextureLoader {
			
			atfbytes.position = atfOffset;
			
			_header.readExternal( atfbytes );
			_blocks.read( atfbytes, _header );
			
			var b : Vector.<uint> = _blocks.blocks;
			
			var blockBased : Boolean = _header.format == AtfFormat.Compressed;
			var blocksPerMip : uint = blockBased ? 8 : 1;
			var cubic : Boolean = _header.type == AtfType.CUBE_MAP;
			if( !cubic ) face = 0;

			miplevel = (miplevel >= _header.count ) ? _header.count-1 : miplevel;
			
			var i : int = ( ( face * (cubic?6:1) + miplevel )* blocksPerMip ) << 1;
			
			if( _header.format == AtfFormat.Compressed )
				return _extractDXT1( atfbytes, b[ i ], b[ i + 1 ], b[ i+2 ], b[ i + 3 ] );
			else 
				return _extractJXR( atfbytes, b[ i ], b[ i + 1 ] );
			
		}
		
		
		private static function _extractDXT1( atfbytes : ByteArray, dpos : uint, dlen : uint, jpos : uint, jlen : uint) : TextureLoader {
			var dxtData : ByteArray = new ByteArray( );
			dxtData.writeBytes( atfbytes, dpos, dlen );
			var jpegxr : ByteArray = new ByteArray( );
			jpegxr.writeBytes( atfbytes,jpos, jlen );
			return new DXT1Loader( jpegxr, dxtData);
		}

		private static function _extractJXR( atfbytes : ByteArray, jpos : uint, jlen : uint) : TextureLoader {
			var jpegxr : ByteArray = new ByteArray( );
			jpegxr.writeBytes( atfbytes, jpos, jlen );
			return new JXRLoader( jpegxr );
		}
		
		private static const _header : Header = new Header();
		private static const _blocks : TexBlocks = new TexBlocks();
		
	}
}
