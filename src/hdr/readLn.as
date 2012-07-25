package hdr {
	import flash.utils.IDataInput;
	/**
	 * @author Pierre Lepers
	 * hdr.readLine
	 */
	public function readLn( input : IDataInput ) : String {
		buff.length = 
		buff.position = 0;
		var b: uint;
		while( input.bytesAvailable > 0 && ( b = input.readUnsignedByte() ) != 0x0A ) {
			buff.writeByte( b );
		}
		buff.position = 0;
		return buff.readUTFBytes( buff.length );
		
	}
	
}
import flash.utils.ByteArray;
const buff : ByteArray = new ByteArray();
