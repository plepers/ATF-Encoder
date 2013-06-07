package fx {
	import C.unistd.sleep;
	
	
	use namespace AS3;

	/**
	 * @author Pierre Lepers
	 * fx.DiffuseEnv
	 */
	public class DiffuseEnv {

		private var _falloffs : Vector.<Vector.<Number>>;
		private var _numsamples : int = 256;
		private var _samples : Vector.<Vector.<Number>>;
		private var _tsamples : Vector.<Number>;
		private var _power : Number = 1.7;
		private var _outputSize : uint = 32;
		private var _curve : Number = .8;
		private var _passes : int = 10;
		private var _curreentPass : int;
		private var _currentSample : int = 0;
		 
		// POT !
		private static const MRAW : Vector.<Number> = new <Number>[ 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 ];
		
		private var _currentRes : Array;
		private var _tmoeout : uint;
		private var _complete : Function;
		
		public function DiffuseEnv() {
			
		}

		public function configure( outputSize : int, numSamples : int, power : Number, curve : Number, passes : int ) : void {
			_numsamples = numSamples;
			_power = power;
			_curve = curve;
			_passes = passes;
			_outputSize = outputSize;
		}


		public function processFaces(left : Vector.<Number>, right : Vector.<Number>, top : Vector.<Number>, bottom : Vector.<Number>, front : Vector.<Number>, back : Vector.<Number>, complete : Function) : void {
			_complete = complete;
			_curreentPass = 0;
			
			
			stepPass(left, right, top, bottom, front, back);
			
		}

		private function stepPass( left : Vector.<Number>, right : Vector.<Number>, top : Vector.<Number>, bottom : Vector.<Number>, front : Vector.<Number>, back : Vector.<Number>) : void {
			//clearTimeout( _tmoeout );
			
			sleep( 50 );
			trace( "pass "+_curreentPass );
			sleep( 100 );
			
			var a : Array = _processFaces(left, right, top, bottom, front, back);
			if( _currentRes == null ) {
				_currentRes = a;
			} else {
				for (var i : int = 0; i < a.length; i++) {
					var v : Vector.<Number> = a[i];
					var v2: Vector.<Number> = _currentRes[i];
					for (var j : int = 0; j < v.length; j++) {
						v2[j] += v[j];
					}
				}
			}
			
			_curreentPass++;
			
			if( _curreentPass >= _passes ) {
				if( _passes>1 ) {
					for ( i = 0; i < _currentRes.length; i++) {
						v = _currentRes[i];
						for (j = 0; j < v.length; j++) {
							v[j] /= _passes; 
						}
					}
				}
				_complete( _currentRes );
			} else {
				sleep( 250 );
				stepPass(left, right, top, bottom, front, back);
			}
			
			
		}

		
		private function _processFaces( left : Vector.<Number>, right : Vector.<Number>, top : Vector.<Number>, bottom : Vector.<Number>, front : Vector.<Number>, back : Vector.<Number>) : Array {
			
			generateDistribs();
				
			var res : Array = [];
			
			_tsamples = new Vector.<Number>(_samples[0].length, true);

			var oface : Vector.<Number>;

			var opCoords : Vector.<Vector3D> = new Vector.<Vector3D>(_outputSize * _outputSize, true);
			var op : Vector3D;

			var invSize : Number = 1 / _outputSize;
			var invSize2 : Number = invSize * 2;
			for (var i : int = 0; i < _outputSize * _outputSize; i++) {
				opCoords[i] = new Vector3D();
			}

			// left
			oface = new Vector.<Number>(_outputSize * _outputSize * 3, true);
			res.push( oface );
			for (var y : int = 0; y < _outputSize; y++) {
				for (var x : int = 0; x < _outputSize; x++) {
					op = opCoords[ y * _outputSize + x ];
					op.x = -1.0;
					op.y = -(y+.5) * invSize2 + 1.0;
					op.z = (x+.5) * invSize2 - 1.0;
					op.normalize();
				}
			}
			operateFace(oface, opCoords, left, right, top, bottom, front, back);

			// right
			oface = new Vector.<Number>(_outputSize * _outputSize * 3, true);
			res.push( oface );
			for ( y = 0; y < _outputSize; y++) {
				for ( x = 0; x < _outputSize; x++) {
					op = opCoords[ y * _outputSize + x ];
					op.x = 1.0;
					op.y = -(y+.5) * invSize2 + 1.0;
					op.z = -(x+.5) * invSize2 + 1.0;
					op.normalize();
				}
			}
			operateFace(oface, opCoords, left, right, top, bottom, front, back);

			// top
			oface = new Vector.<Number>(_outputSize * _outputSize * 3, true);
			res.push( oface );
			for ( y = 0; y < _outputSize; y++) {
				for ( x = 0; x < _outputSize; x++) {
					op = opCoords[ y * _outputSize + x ];
					op.x = (x+.5) * invSize2 - 1.0;
					op.y = 1.0;
					op.z = (y+.5) * invSize2 - 1.0;
					op.normalize();
				}
			}
			operateFace(oface, opCoords, left, right, top, bottom, front, back);

			// bottom
			oface = new Vector.<Number>(_outputSize * _outputSize * 3, true);
			res.push( oface );
			for ( y = 0; y < _outputSize; y++) {
				for ( x = 0; x < _outputSize; x++) {
					op = opCoords[ y * _outputSize + x ];
					op.x = (x+.5) * invSize2 - 1.0;
					op.y = -1.0;
					op.z = -(y+.5) * invSize2 + 1.0;
					op.normalize();
				}
			}
			operateFace(oface, opCoords, left, right, top, bottom, front, back);

			// front
			oface = new Vector.<Number>(_outputSize * _outputSize * 3, true);
			res.push( oface );
			for ( y = 0; y < _outputSize; y++) {
				for ( x = 0; x < _outputSize; x++) {
					op = opCoords[ y * _outputSize + x ];
					op.x = (x+.5) * invSize2 - 1.0;
					op.y = -(y+.5) * invSize2 + 1.0;
					op.z = 1.0;
					op.normalize();
				}
			}
			operateFace(oface, opCoords, left, right, top, bottom, front, back);

			// back
			oface = new Vector.<Number>(_outputSize * _outputSize * 3, true);
			res.push( oface );
			for ( y = 0; y < _outputSize; y++) {
				for ( x = 0; x < _outputSize; x++) {
					op = opCoords[ y * _outputSize + x ];
					op.x = -(x+.5) * invSize2 + 1.0;
					op.y = -(y+.5) * invSize2 + 1.0;
					op.z = -1.0;
					op.normalize();
				}
			}
			operateFace(oface, opCoords, left, right, top, bottom, front, back);
			
			return res;
		}

		private function operateFace( oface : Vector.<Number>, opCoords : Vector.<Vector3D>, left : Vector.<Number>, right : Vector.<Number>, top : Vector.<Number>, bottom : Vector.<Number>, front : Vector.<Number>, back : Vector.<Number>) : void {
			var plen : int = opCoords.length;
			var m : Matrix3D = new Matrix3D();

			var vx : Vector3D;
			var vy : Vector3D;
			var vz : Vector3D;
			var up : Vector3D = new Vector3D(0, 1, 0);
			var up2 : Vector3D = new Vector3D(0, 0, 1);

			var sx : Number;
			var sy : Number;
			var sz : Number;

			var asx : Number;
			var asy : Number;
			var asz : Number;
			var pond: Number;
			
			var inputSize : uint = Math.sqrt(left.length/3);
			

			for (var i : int = 0; i < plen; i++) {
				vx = opCoords[i];

				vy = vx.crossProduct(up);
				if ( vy.length < 0.0001 ) vy = vx.crossProduct(up2);

				vy.normalize();
				vz = vx.crossProduct(vy);
				//vz.normalize();
				
				vy.scaleBy(_curve);
				vz.scaleBy(_curve);

				MRAW[0] = vx.x;
				MRAW[1] = vx.y;
				MRAW[2] = vx.z;
				MRAW[4] = vy.x;
				MRAW[5] = vy.y;
				MRAW[6] = vy.z;
				MRAW[8] = vz.x;
				MRAW[9] = vz.y;
				MRAW[10] = vz.z;

				m.rawData = MRAW;
				

				m.transformVectors(_samples[_currentSample], _tsamples);
				
				var ocr : Number = 0;
				var ocg : Number = 0;
				var ocb : Number = 0;
				
				var tpond : Number = 0;
				var tex : Vector.<Number>;
				var uf : Number;
				var vf : Number;
				var u : int;
				var v : int;
				var ind : int;
				
				for (var s : int = 0; s < _numsamples; s++) {
					sx = _tsamples[s * 3];
					sy = _tsamples[s * 3 + 1];
					sz = _tsamples[s * 3 + 2];
					asx = Math.abs( sx );
					asy = Math.abs( sy );
					asz = Math.abs( sz );
					
//					sx = vx.x;
//					sy = vx.y;
//					sz = vx.z;
					pond = _falloffs[_currentSample][s];
					
					
					if ((asx >= asy) && (asx >= asz)) {
						if (sx > 0.0) {
							tex = right;
							uf = 1.0 - (sz / sx + 1.0) * 0.5 ;
							vf = 1.0 - (sy / sx + 1.0) * 0.5;
						} else if (sx <	 0.0) {
							tex = left;
							uf = 1.0 - (sz / sx + 1.0) * 0.5;
							vf = ( sy / sx + 1.0) * 0.5;
						}
					} else if ((asy >= asx) && (asy >= asz)) {
						if (sy > 0.0) {
							tex = top;
							uf = (sx / sy + 1.0) * 0.5;
							vf = (sz / sy + 1.0) * 0.5;
						} else if (sy < 0.0) {
							tex = bottom;
							uf = 1.0 - (sx / sy + 1.0) * 0.5;
							vf = (sz / sy + 1.0) * 0.5;
						}
					} else if ((asz >= asx) && (asz >= asy)) {
						if (sz > 0.0) {
							tex = front;
							uf = (sx / sz + 1.0) * 0.5;
							vf = 1.0 - (sy / sz + 1.0) * 0.5;
						} else if (sz < 0.0) {
							tex = back;
							uf = (sx / sz + 1.0) * 0.5;
							vf = (sy / sz + 1) * 0.5;
						}
					}
					
					//if( uf > 1.0 || vf > 1.0 || uf < .0 || vf < .0 ) throw ("error x "+uf );
					
					u = Math.floor ( uf*(inputSize-0.001) );
					v = Math.floor ( vf*(inputSize-0.001) );
					
					ind = (u + v*inputSize)*3;
//					oc[0] += tex[ind*3] ;
//					oc[1] += tex[ind*3+1] ;
//					oc[2] += tex[ind*3+2] ;
					ocr += tex[ind] * pond;
					ocg += tex[ind+1] * pond;
					ocb += tex[ind+2] * pond;
					
					tpond += pond;
				}
				
				
				oface[ i*3 ] = ocr/tpond;
				oface[ i*3+1 ] = ocg/tpond;
				oface[ i*3+2 ] = ocb/tpond;
				
				_currentSample ++;
				if( _currentSample >= 16 )_currentSample = 0;
			}
		}

		private function generateDistribs() : void {
			_samples = new Vector.<Vector.<Number>>(16, true);
			_falloffs = new Vector.<Vector.<Number>>(16, true);

			var theta : Number;
			var phi : Number;
			var i3 : int;
			
			var sample : Vector.<Number>;
			var folloff : Vector.<Number>;

			for (var j : int = 0; j < 16; j++) {
				
			
				sample = new Vector.<Number>(_numsamples * 3, true);
				folloff = new Vector.<Number>(_numsamples, true);
				
				_samples[j] = sample;
				_falloffs[j] = folloff;
				
				for (var i : int = 0; i < _numsamples; i++) {
					i3 = i * 3;
					theta = Math.random() * Math.PI;
					phi = 2.0 * Math.asin(Math.sqrt(Math.random()));
	
					sample[ i3     ] = Math.sin(phi) * Math.sin(theta);
					sample[ i3 + 1 ] = Math.sin(phi) * Math.cos(theta);
					sample[ i3 + 2 ] = Math.cos(phi);
					
					folloff[i] = Math.pow( sample[ i3 ], _power );
					//res[ i3 + 3 ] = Math.pow( res[ i3     ], _power );
				}

			}
			
		}

	}
}

class Vector3D {
	
	public var x : Number = 0;
	public var y : Number = 0;
	public var z : Number = 0;

	public function Vector3D(x : Number = 0, y : Number = 0, z : Number = 0) {
		this.x = x;
		this.y = y;
		this.z = z;
	}

	public function scaleBy(l : Number) : void {
		x*=l;
		y*=l;
		z*=l;
	}

	public function normalize() : void {
		var l : Number = Math.sqrt( x*x+y*y+z*z );
		x/=l;
		y/=l;
		z/=l;
	}

	public function get length() : Number {
		return Math.sqrt( x*x+y*y+z*z );
	}

	public function crossProduct(b : Vector3D) : Vector3D {
		return new Vector3D(y * b.z - z * b.y, z * b.x - x * b.z, x * b.y - y * b.x);
	}
}

class Matrix3D {

	public var rawData : Vector.<Number>;

	public function Matrix3D() {
		rawData = new <Number>[ 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 ];
	}

	public function transformVectors(inp : Vector.<Number>, out : Vector.<Number>) : void {
		var l : int = inp.length/3;
		var i3 : int;
		
		var vx : Number, vy : Number, vz : Number, d : Number;
		for (var i : int = 0; i < l; i++) {
			i3 = i*3;
			
			vx = inp[i3];
			vy = inp[i3+1];
			vz = inp[i3+2];
			
			d = 1 / ( rawData[3] * vx + rawData[7] * vy + rawData[11] * vz + rawData[15] );
			
			out[i3]    = ( rawData[0] * vx + rawData[4] * vy + rawData[8] * vz + rawData[12] ) * d;
			out[i3+1]  = ( rawData[1] * vx + rawData[5] * vy + rawData[9] * vz + rawData[13] ) * d;
			out[i3+2]  = ( rawData[2] * vx + rawData[6] * vy + rawData[10] * vz + rawData[14] ) * d;
		}
		

		
	}
	
}
