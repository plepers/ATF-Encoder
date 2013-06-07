package hdp {
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	/**
	 * @author Pierre Lepers
	 * hdp.HDPDecode
	 */
	public class IfdContainer {

		public function IfdContainer() {
		}

		public function read( input : ByteArray ) : void {
			
			_directories = new Vector.<Ifd>();
			
			_readHeader( input );
			
		}

		private function _readHeader(input : IDataInput) : void {
			
			if( input.readUnsignedShort() != TIFF_MAGIC )
				throw new Error( "hdp.IfdContainer - bad magic : unknown format");

			if( input.readUnsignedByte() != HDP_MAGIC )
				throw new Error( "hdp.IfdContainer - bad magic : unknown format");
			
			_version = input.readUnsignedByte();
			
			_directories.push( new Ifd( input.readUnsignedInt() ) );
		}
		
		private var _directories : Vector.<Ifd>;
		
		private var _version : uint;
		
	}
}

import flash.utils.ByteArray;

class Ifd {

	private var _off : uint;

	public function Ifd(off : uint) {
		_off = off;
	}

	public function read( input : ByteArray ) : void {
		input.position = _off;
		
		var len : uint = input.readUnsignedShort();
		
	}
	
}

const TIFF_MAGIC : uint = 0x4949;
const HDP_MAGIC : uint = 0xBC;
