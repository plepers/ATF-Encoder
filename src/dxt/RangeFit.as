package dxt {
	import flash.utils.IDataOutput;
	/**
	 * @author Pierre Lepers
	 * dxt.RangeFit
	 */
	public class RangeFit {

		public function prepare( cset : ColourSet ) : void {
			
			m_metricR = 0.2126f;
			m_metricG = 0.7152f;
			m_metricB = 0.0722f;
			
			m_besterror =  Number.MAX_VALUE;
			
			var count : uint = cset.m_count;
			var values : Vector.<Number> = cset.m_points;
			var weights : Vector.<Number> = cset.m_weights;
			
			var covariance : Vector.<Number> = CMath.computeWeightedCovariance( count, values, weights );
		
			var principle : Vector.<Number> = CMath.ComputePrincipleComponent( covariance );
			
			var sx : Number, sy : Number, sz : Number;
			var ex : Number, ey : Number, ez : Number;
			var min : Number, max : Number, val : Number;
			var i3 : int;
			
			if( count > 0 )
			{
				
				// compute the range
				sx = ex = values[0];
				sy = ey = values[1];
				sz = ez = values[2];
				min = max = sx*principle[0] + sy*principle[1] + sz*principle[2];
				for( var i : int = 1; i < count; ++i )
				{
					i3 = i*3;
					val = values[i3]*principle[0] + values[i3+1]*principle[1] + values[i3+2]*principle[2];
					if( val < min )
					{
						sx = values[i3];
						sy = values[i3+1];
						sz = values[i3+2];
						min = val;
					}
					else if( val > max )
					{
						ex = values[i3];
						ey = values[i3+1];
						ez = values[i3+2];
						max = val;
					}
				}
			}
			
			// clamp the output to [0, 1]
			
			sx = 31.0 * Math.min( Math.max( 0.0, sx ), 1.0 ) + .5;
			sy = 63.0 * Math.min( Math.max( 0.0, sy ), 1.0 ) + .5;
			sz = 31.0 * Math.min( Math.max( 0.0, sz ), 1.0 ) + .5;

			ex = 31.0 * Math.min( Math.max( 0.0, ex ), 1.0 ) + .5;
			ey = 63.0 * Math.min( Math.max( 0.0, ey ), 1.0 ) + .5;
			ez = 31.0 * Math.min( Math.max( 0.0, ez ), 1.0 ) + .5;
		
			// clamp to the grid and save
			m_startX = ( (sx>0.0)? Math.floor( sx ) : Math.ceil( sx ) ) / 31.0;
			m_startY = ( (sy>0.0)? Math.floor( sy ) : Math.ceil( sy ) ) / 63.0;
			m_startZ = ( (sz>0.0)? Math.floor( sy ) : Math.ceil( sz ) ) / 31.0;

			m_endX = ( (ex>0.0)? Math.floor( ex ) : Math.ceil( ex ) ) / 31.0;
			m_endY = ( (ey>0.0)? Math.floor( ey ) : Math.ceil( ey ) ) / 63.0;
			m_endZ = ( (ez>0.0)? Math.floor( ey ) : Math.ceil( ez ) ) / 31.0;
			
//			m_start = Truncate( grid*start + half )*gridrcp;
//			m_end = Truncate( grid*end + half )*gridrcp;
			
		}

		
		public function compress( cset : ColourSet, output : IDataOutput ) : void {
			
			const count : uint = cset.m_count;
			const values : Vector.<Number> = cset.m_points;
			
			var i3 : int;
			
//			codes[0] = m_start;
//			codes[1] = m_end;
			//codes[2] = ( 2.0f/3.0f )*m_start + ( 1.0f/3.0f )*m_end;
			var l23X : Number = TIER2 * m_startX + TIER * m_endX;
			var l23Y : Number = TIER2 * m_startY + TIER * m_endY;
			var l23Z : Number = TIER2 * m_startZ + TIER * m_endZ;
			
			//codes[3] = ( 1.0f/3.0f )*m_start + ( 2.0f/3.0f )*m_end;
			var l13X : Number = TIER * m_startX + TIER2 * m_endX;
			var l13Y : Number = TIER * m_startY + TIER2 * m_endY;
			var l13Z : Number = TIER * m_startZ + TIER2 * m_endZ;
			
			var vix : Number, viy : Number, viz : Number;
			var tx : Number, ty : Number, tz : Number;
		
			// match each point to the closest code
			var closest : Vector.<uint> = new Vector.<uint>( 16, true );
			var error : Number = 0.0;
			for( var i : int = 0; i < count; ++i )
			{
				
				vix = values[i3];
				viy = values[i3+1];
				viz = values[i3+2];
				
				// find the closest code
				var d : Number;
				var dist : Number = Number.MAX_VALUE;
				var idx : uint = 0;
				
				tx = (vix-m_startX) * m_metricR;
				ty = (viy-m_startY) * m_metricG;
				tz = (viz-m_startZ) * m_metricB;
				d = tx*tx+ty*ty+tz*tz;
				if( d < dist ){
						dist = d;
						idx = 0;
				}

				tx = (vix-m_endX) * m_metricR;
				ty = (viy-m_endY) * m_metricG;
				tz = (viz-m_endZ) * m_metricB;
				d = tx*tx+ty*ty+tz*tz;
				if( d < dist ){
						dist = d;
						idx = 1;
				}

				tx = (vix-l23X) * m_metricR;
				ty = (viy-l23Y) * m_metricG;
				tz = (viz-l23Z) * m_metricB;
				d = tx*tx+ty*ty+tz*tz;
				if( d < dist ){
						dist = d;
						idx = 2;
				}

				tx = (vix-l13X) * m_metricR;
				ty = (viy-l13Y) * m_metricG;
				tz = (viz-l13Z) * m_metricB;
				d = tx*tx+ty*ty+tz*tz;
				if( d < dist ){
						dist = d;
						idx = 3;
				}
				
				// save the index
				closest[i] = idx;
				
				// accumulate the error
				error += dist;
			}
			
			// save this scheme if it wins
			if( error < m_besterror )
			{
				// remap the indices
				var indices : Vector.<uint> = new Vector.<uint>( 16, true ); // TODO keep static const??
				cset.remapIndices( closest, indices );
				
				// save the block
				Dxt.writeBlock4( m_startX, m_startY, m_startZ, m_endX, m_endY, m_endZ, indices, output );
		
				// save the error
				m_besterror = error;
			}
		}
		
		
		
		private var m_metricR : Number;
		private var m_metricG : Number;
		private var m_metricB : Number;
		private var m_startX  : Number;
		private var m_startY  : Number;
		private var m_startZ  : Number;
		private var m_endX    : Number;
		private var m_endY    : Number;
		private var m_endZ    : Number;
		private var m_besterror : Number;
	}
}

const TIER 		: Number = 1.0/3.0;
const TIER2 	: Number = 2.0/3.0;

const ONE 		: Vector.<Number> 	= new <Number>[1.0, 1.0, 1.0];
const ZERO 		: Vector.<Number> 	= new <Number>[0.0, 0.0, 0.0];
const GRID 		: Vector.<Number> 	= new <Number>[31.0, 63.0, 31.0];
const GRIDRCP 	: Vector.<Number> 	= new <Number>[1.0/31.0, 1.0/63.0, 1.0/31.0];
const HALF	 	: Vector.<Number> 	= new <Number>[.5,.5,.5];
