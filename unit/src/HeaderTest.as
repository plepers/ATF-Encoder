package {

	import atf.AtfFormat;
	import atf.AtfType;
	import atf.Header;

	import flash.utils.ByteArray;
	/**
	 * @author Pierre Lepers
	 * HeaderTEst
	 */
	public class HeaderTest {

		public function HeaderTest() {
			
			var h1 : Header = new Header();
			h1.format = AtfFormat.RGB888;
			h1.type = AtfType.NORMAL;
			h1.count = 6;
			h1.width = 1024;
			h1.height = 128;
			h1.length = 123456789;
			
			var ba : ByteArray = new ByteArray();
			h1.writeExternal( ba );
			
			ba.position = 0;
			
			var h2 : Header = new Header();
			h2.readExternal( ba );
			
			if( !_isHeaderEquals( h1, h2 ) ) throw new Error( "UnitTests - _isHeaderEquals 1 : " );
			
			trace( "UnitTests - _testHeader --  OK " );
		}
		
		
		private function _isHeaderEquals(h1 : Header, h2 : Header) : Boolean {
			return ( 
			
					h1.format != h2.format || 
					h1.type != h2.type || 
					h1.count != h2.count || 
					h1.width != h2.width || 
					h1.height != h2.height || 
					h1.length != h2.length
					
					);
		}

	}
}
