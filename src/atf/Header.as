package atf {

	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	/**
	 * @author Pierre Lepers
	 * atf.AtfHeader
	 */
	public class Header implements IExternalizable {
		
		/**
		 * static header length in byte
		 */
		public static const LENGTH : uint = 10;


		public function readExternal(input : IDataInput) : void {
			
			var sign : String = input.readUTFBytes( 3 );
			if( sign != MAGIC )
				throw new Error( "ATF parsing error, unknown format " + sign );
			
			length = (input.readUnsignedByte( ) << 16) + (input.readUnsignedByte( ) << 8) + input.readUnsignedByte( );
			
			var tdata : uint = input.readUnsignedByte( );
			type = tdata >> 7; 		// UB[1]
			format = tdata & 0x7f;	// UB[7]

			width = Math.pow( 2, input.readUnsignedByte( ) );
			height = Math.pow( 2, input.readUnsignedByte( ) );
			
			count = input.readUnsignedByte( );
		}

		public function writeExternal(output : IDataOutput) : void {
			output.writeUTFBytes( MAGIC );
			
			output.writeByte( length >> 16 );
			output.writeByte( length >> 8 );
			output.writeByte( length );
			
			output.writeByte( uint( (type << 7) | (format&0x7f) ) );
			
			output.writeByte( Math.log( width ) /  Math.LN2 );
			output.writeByte( Math.log( height ) /  Math.LN2 );

			output.writeByte( count );
		}

		public var type : uint;
		
		public var format : uint;
		
		public var count : uint;
		
		public var length : uint;
		
		public var width : uint;
		
		public var height : uint;
		
		
	}
}

const MAGIC : String = "ATF";
