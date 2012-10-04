package atf {

	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.display3D.Context3D;
	import flash.utils.ByteArray;

	/**
	 * @author Pierre Lepers
	 * atf.Util
	 */
	public class Utils {

		public static const DXT_MOD : uint = 0;
		public static const DXT_IMAGE : uint = 1;
		public static const PVRTC_TOP_MOD : uint = 2;
		public static const PVRTC_BOTTOM_MOD : uint = 3;
		public static const PVRTC_IMAGE : uint = 4;
		public static const ETC_TOP_MOD : uint = 5;
		public static const ETC_BOTTOM_MOD : uint = 6;
		public static const ETC_IMAGE : uint = 7;

		/**
		 * replace specific jpegxr data in existing atf file.
		 * @param input atf file to modify
		 * @param data bytes to inject
		 * @param miplevel miplevel to replace, default 0 is the higher size.
		 * @param face face to replace in a cube texture, ignored if input is 2D texture
		 * @param atfOffset start position of the atf file in input bytes
		 * @param blockbasedFormat block to replace in blockbased formats
		 */
		public static function replaceImageData(input : ByteArray, data : ByteArray, miplevel : uint = 0, face : uint = 0, atfOffset : uint = 0, blockbasedFormat : uint = 1) : void {
			input.position = atfOffset;

			_header.readExternal(input);
			_blocks.read(input, _header);

			var blockBased : Boolean = _header.format == AtfFormat.Compressed;
			var cubic : Boolean = _header.type == AtfType.CUBE_MAP;
			var blocksPerMip : uint = blockBased ? 8 : 1;
			var bbfmtOffset : uint = blockBased ? blockbasedFormat << 1 : 0;
			var blocksPerFace : uint = (cubic ? 6 : 1) * blocksPerMip;
			if ( !cubic ) face = 0;

			miplevel = (miplevel >= _header.count ) ? _header.count - 1 : miplevel;

			var i : int = ( ( face * blocksPerFace + miplevel * blocksPerMip ) << 1 ) + bbfmtOffset;

			input.position = atfOffset;
			_header.length += (data.length - _blocks.blocks[ i + 1 ]);
			_header.writeExternal(input);

			_replaceDataBlock(input, data, _blocks.blocks[ i ], _blocks.blocks[ i + 1 ]);
		}
		
		

		/**
		 * For blockbased compressed atf files only.
		 * Keep just one blockbased format in a compressed ATF (DXT1, ETC1 or PVRTC). remove the other one.
		 * Use it to create platform specific lightweight texture by removing unused one.
		 * @param input input atf file to modify
		 * @param format format to keep.
		 * @param atfOffset start position of the atf file in input bytes
		 * @see TexFormat
		 */
		public static function removeAllBut(input : ByteArray, format : uint, atfOffset : uint = 0) : void {
			input.position = atfOffset;

			_header.readExternal(input);
			if ( _header.format != AtfFormat.Compressed )
				throw new ArgumentError("atf.Util - removeAllButDXT : input must be blockbased compressed");

			_blocks.read(input, _header);

			var blocks : Vector.<uint> = _blocks.blocks;
			var numBlocks : uint = _blocks.blocks.length >> 1;
			var rmblocks : Vector.<uint> = new Vector.<uint>();

			var mask : uint;
			switch( format ) {
				case TexFormat.DXT:
					mask = ~0x03;
					break;
				case TexFormat.PVRTC:
					mask = ~0x1C;
					break;
				case TexFormat.ETC:
					mask = ~0xE0;
					break;
			}

			for (var i : int = 0; i < numBlocks; i++) {
				if ( (0x1 << (i % 8) ) & mask ) {
					rmblocks.AS3::push(blocks[i * 2], blocks[i * 2 + 1]);
				}
			}

			var dlen : uint = _removeBlocks(input, rmblocks);
			input.position = atfOffset;
			_header.length -= dlen;
			_header.writeExternal(input);
		}
		
		public static function removeMips(input : ByteArray, atfOffset : uint = 0) : void {
			input.position = atfOffset;

			_header.readExternal(input);

			_blocks.read(input, _header);

			var blocks : Vector.<uint> = _blocks.blocks;
			var numBlocks : uint = _blocks.blocks.length >> 1;
			var rmblocks : Vector.<uint> = new Vector.<uint>();

			if ( _header.format != AtfFormat.Compressed ) {
				
			} else {
				
			}
			

			for (var i : int = 0; i < numBlocks; i++) {
				if ( (0x1 << (i % 8) ) & mask ) {
					rmblocks.AS3::push(blocks[i * 2], blocks[i * 2 + 1]);
				}
			}

			var dlen : uint = _removeBlocks(input, rmblocks);
			input.position = atfOffset;
			_header.length -= dlen;
			_header.writeExternal(input);
		}
		
		/**
		 * return one of the blockbased texture formats internaly used by flash for the giver Context3D
		 * @return one of the Blockbased format (TexFormat.ETC, TexFormat.DXT or TexFormat.PVRTC)
		 */
		public static function getSuitableBlockbasedFormat(ctx : Context3D) : uint {
			_createBBSamples();

			var tex : Texture = ctx.createTexture(8, 8, Context3DTextureFormat.COMPRESSED, false);

			try {
				tex.uploadCompressedTextureFromByteArray(BB8x8_dxt, 0);
			} catch( e : ArgumentError ) {
				tex.dispose();
				return TexFormat.DXT;
			}
			try {
				tex.uploadCompressedTextureFromByteArray(BB8x8_etc, 0);
			} catch( e : ArgumentError ) {
				tex.dispose();
				return TexFormat.ETC;
			}
			try {
				tex.uploadCompressedTextureFromByteArray(BB8x8_pvr, 0);
			} catch( e : ArgumentError ) {
				tex.dispose();
				return TexFormat.PVRTC;
			}
			
			// should never append
			tex.dispose();
			return 0;
		}

		private static function _removeBlocks(input : ByteArray, blocks : Vector.<uint>) : uint {
			var tlen : uint = 0;
			var pos : uint, len : uint, npos : uint, gap : uint;
			var blen : uint = blocks.length;

			for (var i : int = 0; i < blen; i += 2 ) {
				pos = blocks[ i ];
				npos = ( i == blen - 2 ) ? input.length + 3 : blocks[ i + 2 ];
				len = blocks[ i + 1 ];
				gap = npos - pos - len - 3;

				input.position = pos - tlen - 3;
				input.writeBytes(_U24_ZERO, 0, 3);
				if ( gap > 0 )
					input.writeBytes(input, pos + len, gap);

				tlen += len;
			}
			input.length -= tlen;

			return tlen;
		}

		/**
		 * assume input position at the begining of atf file
		 */
		private static function _replaceDataBlock(input : ByteArray, data : ByteArray, pos : uint, len : uint) : void {
			var nlen : uint = ( data != null ) ? data.length : 0;
			var dlen : int = nlen - len;

			if ( dlen != 0 ) {
				input.position = pos + nlen;
				input.writeBytes(input, pos + len, input.length - pos - len);
				input.length += dlen;
			}

			input.position = pos - 3;
			input.writeByte(nlen >> 16);
			input.writeByte(nlen >> 8);
			input.writeByte(nlen);

			if ( data != null ) input.writeBytes(data, 0, data.length);
		}

		private static const _U24_ZERO : ByteArray = new ByteArray();
		{
		_U24_ZERO.writeByte(0);
		_U24_ZERO.writeByte(0);
		_U24_ZERO.writeByte(0);
		}
		
		private static var BB8x8_dxt : ByteArray;
		private static var BB8x8_etc : ByteArray;
		private static var BB8x8_pvr : ByteArray;
		
		
		private static function _createBBSamples() : void {
			if ( BB8x8_dxt != null ) return;

			var i : int;

			_header.count = 1;
			_header.height = _header.width = 8;
			_header.format = AtfFormat.Compressed;
			_header.type = AtfType.NORMAL;

			// create invalid tex block
			var invalidBlock : ByteArray = new ByteArray();
			invalidBlock.writeShort(0);
			invalidBlock.writeByte(4);
			invalidBlock.writeUnsignedInt(0x11111111);

			// BB8x8_dxt
			BB8x8_dxt = new ByteArray();
			BB8x8_dxt.position = Header.LENGTH;

			for (i = 0; i < 2; i++)
				BB8x8_dxt.writeBytes(invalidBlock, 0, 7);
			for (i = 0; i < 6; i++) 
				BB8x8_dxt.writeBytes(_U24_ZERO, 0, 3);

			_header.length = BB8x8_dxt.length - 6;
			BB8x8_dxt.position = 0;
			_header.writeExternal(BB8x8_dxt);

			// BB8x8_pvr
			BB8x8_pvr = new ByteArray();
			BB8x8_pvr.position = Header.LENGTH;

			for (i = 0; i < 2; i++)
				BB8x8_pvr.writeBytes(_U24_ZERO, 0, 3);
			for (i = 0; i < 3; i++)
				BB8x8_pvr.writeBytes(invalidBlock, 0, 7);
			for (i = 0; i < 3; i++)
				BB8x8_pvr.writeBytes(_U24_ZERO, 0, 3);

			_header.length = BB8x8_pvr.length - 6;
			BB8x8_pvr.position = 0;
			_header.writeExternal(BB8x8_pvr);

			// BB8x8_etc
			BB8x8_etc = new ByteArray();
			BB8x8_etc.position = Header.LENGTH;

			for (i = 0; i < 5; i++)
				BB8x8_etc.writeBytes(_U24_ZERO, 0, 3);

			for (i = 0; i < 3; i++) 
				BB8x8_etc.writeBytes(invalidBlock, 0, 7);

			_header.length = BB8x8_etc.length - 6;
			BB8x8_etc.position = 0;
			_header.writeExternal(BB8x8_etc);
		}
	}
}

import atf.Header;
import atf.TexBlocks;
const _header : Header = new Header();
const _blocks : TexBlocks = new TexBlocks();

