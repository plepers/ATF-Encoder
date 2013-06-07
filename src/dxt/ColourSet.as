package dxt {
	/**
	 * @author Pierre Lepers
	 * dxt.ColourSet
	 */
	public class ColourSet {

		public function ColourSet() {
			
		}

		public function construct( bloc : Vector.<uint> ) : void {
			
			var m_count3  : uint;

			m_count = 0;
			
			for( var i : int = 0; i < 16; ++i )
			{
				for( var j : int = 0;; ++j ) {
					
					if( j == i )
					{
						m_count3 = m_count * 3;
						m_points[ m_count3] = (bloc[i] & 0xFF0000)>>16;
						m_points[ m_count3+1] = (bloc[i] & 0xFF00)>>8;
						m_points[ m_count3+2] = bloc[i] & 0xFF;
						
						m_weights[m_count] = 1.0;
						m_remap[i] = m_count;
				
						++m_count;
						break;
					}
					
					if( bloc[i] == bloc[j] ) { // TODO mask alpha ?
						var index : uint = m_remap[j];
						m_weights[index] += 1.0;
						m_remap[i] = index;
						break;
					}
				}
			}
			
			for( i = 0; i < m_count; ++i )
				m_weights[i] = Math.sqrt( m_weights[i] );
			
		}

		public function remapIndices( source : Vector.<uint>, target : Vector.<uint> ) : void {
			for( var i : int = 0; i < 16; ++i )
				target[i] = source[ m_remap[i] ];
		}
		

		
		
		internal var m_count : uint = 0;
		
		internal const m_points : Vector.<Number> = new Vector.<Number>( 48, true ); // 16*3
		internal const m_weights :Vector.<Number> = new Vector.<Number>( 16, true ); // 16
		internal const m_remap :Vector.<int> = new Vector.<int>( 16, true ); // 16
		
	}
}
