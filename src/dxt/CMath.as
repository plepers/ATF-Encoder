package dxt {
	/**
	 * @author Pierre Lepers
	 * dxt.CMath
	 */
	public class CMath {
		
//		public static function Dot( Arg left, Arg right ) : Number
//		{
//			return left.m_x*right.m_x + left.m_y*right.m_y + left.m_z*right.m_z;
//		}
		
		public static function computeWeightedCovariance( n : int, points : Vector.<Number>, weights : Vector.<Number> ) : Vector.<Number>
		{
			// compute the centroid
			var total : Number = 0.0;
			
			var centroidR : Number = 0.0;
			var centroidG : Number = 0.0;
			var centroidB : Number = 0.0;

			var ax : Number, ay : Number, az : Number;
			var bx : Number, by : Number, bz : Number;
			var w : Number;

			var covariance : Vector.<Number> = new <Number>[0,0,0,0,0,0];
			covariance.fixed=true;
			
			var i3 : int;
			for( var i : int = 0; i < n; ++i )
			{
				i3 = i*3;
				total += weights[i];
				centroidR += weights[i]*points[i3];
				centroidG += weights[i]*points[i3+1];
				centroidB += weights[i]*points[i3+2];
			}
			
			centroidR /= total;
			centroidG /= total;
			centroidB /= total;
		
			// accumulate the covariance matrix
			
			for( i = 0; i < n; ++i )
			{
				i3 = i*3;
				w = weights[i];
				ax = points[i3] - centroidR;
				ay = points[i3+1] - centroidG;
				az = points[i3+2] - centroidB;
				bx = w*ax;
				by = w*ay;
				bz = w*az;
				
				covariance[0] += ax*bx;
				covariance[1] += ax*by;
				covariance[2] += ax*bz;
				covariance[3] += ay*by;
				covariance[4] += ay*bz;
				covariance[5] += az*bz;
			}
			
			// return it
			return covariance;
		}
		
		public static function ComputePrincipleComponent( matrix : Vector.<Number> ) : Vector.<Number>
		{
			// compute the cubic coefficients
			var c0 : Number = matrix[0]*matrix[3]*matrix[5] 
				+ 2.0f*matrix[1]*matrix[2]*matrix[4] 
				- matrix[0]*matrix[4]*matrix[4] 
				- matrix[3]*matrix[2]*matrix[2] 
				- matrix[5]*matrix[1]*matrix[1];
			var c1 : Number = matrix[0]*matrix[3] + matrix[0]*matrix[5] + matrix[3]*matrix[5]
				- matrix[1]*matrix[1] - matrix[2]*matrix[2] - matrix[4]*matrix[4];
			var c2 : Number = matrix[0] + matrix[3] + matrix[5];
			var c2t : Number;
		
			// compute the quadratic coefficients
			var a : Number = c1 - ( 1.0/3.0 )*c2*c2;
			var b : Number = ( -2.0/27.0 )*c2*c2*c2 + ( 1.0/3.0 )*c1*c2 - c0;
		
			// compute the root count check
			var Q : Number = 0.25f*b*b + ( 1.0f/27.0f )*a*a*a;
			
			var rt : Number;
			var l1 : Number,l2 : Number,l3 : Number;
		
			// test the multiplicity
			if( FLT_EPSILON < Q )
			{
				// only one root, which implies we have a multiple of the identity
		        return new <Number>[0.0, 0.0, 0.0];
			}
			else if( Q < -FLT_EPSILON )
			{
				c2t = TIER*c2;
				// three distinct roots
				var theta : Number = Math.atan2( Math.sqrt( -Q ), -0.5f*b )/3.0;
				var rho   : Number = Math.sqrt( 0.25f*b*b - Q );
				
				rt = Math.pow( rho, TIER );
				var ct 	  : Number = Math.cos( theta );
				var st	  : Number = Math.sin( theta );
				
				l1 = c2t + 2.0*rt*ct;
				l2 = c2t - rt*( ct + SQRT3*st );
				l3 = c2t - rt*( ct - SQRT3*st );
		
				// pick the larger
				if( Math.abs( l2 ) > Math.abs( l1 ) )
					l1 = l2;
				if( Math.abs( l3 ) > Math.abs( l1 ) )
					l1 = l3;
		
				// get the eigenvector
				return GetMultiplicity1Evector( matrix, l1 );
			}
			else // if( -FLT_EPSILON <= Q && Q <= FLT_EPSILON )
			{
				// two roots
				c2t = TIER*c2;
				
				if( b < 0.0 )
					rt = -Math.pow( -0.5f*b, TIER );
				else
					rt = Math.pow( 0.5f*b, TIER );
				
				l1 = c2t + rt;		// repeated
				l2 = c2t - 2.0f*rt;
				
				// get the eigenvector
				if( Math.abs( l1 ) > Math.abs( l2 ) )
					return GetMultiplicity2Evector( matrix, l1 );
				else
					return GetMultiplicity1Evector( matrix, l2 );
			}
		}
		
		private static function GetMultiplicity1Evector( matrix : Vector.<Number>, evalue : Number ) : Vector.<Number>
		{
			// compute M
			MM[0] = matrix[0] - evalue;
			MM[1] = matrix[1];
			MM[2] = matrix[2];
			MM[3] = matrix[3] - evalue;
			MM[4] = matrix[4];
			MM[5] = matrix[5] - evalue;
		
			// compute U
			UM[0] = MM[3]*MM[5] - MM[4]*MM[4];
			UM[1] = MM[2]*MM[4] - MM[1]*MM[5];
			UM[2] = MM[1]*MM[4] - MM[2]*MM[3];
			UM[3] = MM[0]*MM[5] - MM[2]*MM[2];
			UM[4] = MM[1]*MM[2] - MM[4]*MM[0];
			UM[5] = MM[0]*MM[3] - MM[1]*MM[1];
		
			// find the largest component
			var mc :  Number = Math.abs( UM[0] );
			var mi : int = 0;
			for( var i : int = 1; i < 6; ++i )
			{
				var c : Number = Math.abs( UM[i] );
				if( c > mc )
				{
					mc = c;
					mi = i;
				}
			}
		
			// pick the column with this component
			switch( mi )
			{
			case 0:
				return new <Number> [ UM[0], UM[1], UM[2] ];
		
			case 1:
			case 3:
				return new <Number> [  UM[1], UM[3], UM[4] ];
		
			default:
				return new <Number> [  UM[2], UM[4], UM[5] ];
			}
		}
		
		private static function GetMultiplicity2Evector( matrix : Vector.<Number>, evalue : Number ) : Vector.<Number>
		{
			// compute M
			MM[0] = matrix[0] - evalue;
			MM[1] = matrix[1];
			MM[2] = matrix[2];
			MM[3] = matrix[3] - evalue;
			MM[4] = matrix[4];
			MM[5] = matrix[5] - evalue;
		
			// find the largest component
			var mc : Number = Math.abs( MM[0] );
			var mi : int = 0;
			for( var i :int = 1; i < 6; ++i )
			{
				var c : Number = Math.abs( MM[i] );
				if( c > mc )
				{
					mc = c;
					mi = i;
				}
			}
		
			// pick the first eigenvector based on this index
			switch( mi )
			{
			case 0:
			case 1:
				return new <Number> [ -MM[1], MM[0], 0.0 ];
		
			case 2:
				return new <Number> [  MM[2], 0.0, -MM[0] ];
		
			case 3:
			case 4:
				return new <Number> [  0.0, -MM[4], MM[3] ];
		
			default:
				return new <Number> [  0.0, -MM[5], MM[4] ];
			}
		}
		
		private static const MM : Vector.<Number> = new Vector.<Number>(6, true);
		private static const UM : Vector.<Number> = new Vector.<Number>(6, true);
	}
}

const TIER : Number = 1.0/3.0;
const SQRT3 : Number = Math.sqrt(3.0);

const FLT_EPSILON : Number = 1.192092896e-07;
