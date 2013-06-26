package {

	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import atf.AtfFormat;
	import atf.Header;

	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.events.Event;
	import flash.utils.ByteArray;

	/**
	 * @author Pierre Lepers
	 * SimpleViewer
	 */
	public class SimpleViewer extends Sprite {
		
		
		private var _stage : Stage;
		private var _context : Context3D;
		
		private var _atf : ByteArray;
		private var _atfOffset : uint = 0;
		private var _vdata : Vector.<Number>;
		private var _scaleX : Number = 1;
		private var _scaleY : Number = 1;
		private var _texDirty : Boolean = true;
		
		private var _indices : Vector.<uint>;
		
		private var _width : uint = 500;
		private var _height : uint = 500;
		private var _programDirty : Boolean;
		private var _mipmap : Boolean;

		public function SimpleViewer() {
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);

			_build();
		}

		public function setTexture( atfbytes : ByteArray, offset : uint = 0 ) : void {
			_atf = atfbytes;
			_atfOffset = offset;
			_texDirty = true;
			if( _context ) _update();
		}

		public function dispose() : void {
			_stage.removeEventListener( MouseEvent.MOUSE_WHEEL, onWheel );
			_stage = null;
			_context.dispose();
			_context = null;
		}



		protected function getVertexCode() : String {
			return 	"mov vt0, va0\n"+
					"mul vt0.xy, vt0.xy, vc0.xy\n" + 
					"mov op, vt0\n" + 
					"mov v0, va1";
		}

		protected function getFragmentCode() : String {
			var filtering : String = ( _mipmap ) ? "linear,miplinear" : "linear";
			return "tex oc, v0, fs0 <2d,"+filtering+",clamp>\n";
		}

		protected function getVertices() : Vector.<Number> {
			return new <Number>[	
				-1, -1, 	0, 0, 0, 
				1, 	-1, 	1, 0, 1, 
				1, 	1, 		1, 1, 2, 
				-1, 1, 		0, 1, 3];
		}

		protected function getIndices() : Vector.<uint> {
			return new <uint>[
				2, 1, 0, 
				3, 2, 0
				];
		}

		private function _build() : void {
			_vdata = new Vector.<Number>( 4, true );
			_vdata[0] = _scaleX;
			_vdata[1] = _scaleY;
			_vdata[2] = 0;
			_vdata[3] = 0;
			
			_vertices = getVertices();
			_indices = getIndices();
		}

		private function onAdded(e : Event) : void {
			_initialize();
		}

		private function onRemoved(e : Event) : void {
		}

		private function _initialize() : void {
			_stage = stage;
			_stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, onContext3dCreate);
			_stage.stage3Ds[0].requestContext3D();
			
			_stage.addEventListener( MouseEvent.MOUSE_WHEEL, onWheel );
		}

		private function onWheel(event : MouseEvent) : void {
			vscaleX = vscaleY = (vscaleY - event.delta*0.01);
		}

		private function onContext3dCreate(event : Event) : void {
			_context = _stage.stage3Ds[0].context3D;
			_vbuffer = _context.createVertexBuffer(4, 5);

			_vbuffer.uploadFromVector(_vertices, 0, 4);

			_ibuffer = _context.createIndexBuffer(6);
			_ibuffer.uploadFromVector( _indices, 0, 6);

			_program = _context.createProgram();
			updateProgram(),
			
			_context.configureBackBuffer(_width, _height, 4 );
			
			if( _atf ) _update();
		}

		private function updateProgram() : void {
			_program.upload(new AGALMiniAssembler().assemble(Context3DProgramType.VERTEX, getVertexCode()), new AGALMiniAssembler().assemble(Context3DProgramType.FRAGMENT, getFragmentCode()));
			_programDirty = false;
		}


		public function getBitmapData() : BitmapData {
			return _update( true );
		}


		private function _update( drawToBmp : Boolean = false ) : BitmapData {
			
			_vdata[0] = _scaleX;
			_vdata[1] = _scaleY;
			_vdata[2] = 0;
			_vdata[3] = 0;
			
			
			_atf.position = _atfOffset;
			var h : Header = new Header();
			h.readExternal( _atf );
			
			trace( "SimpleViewer - _update -- ", h.count );
			trace( "SimpleViewer - _update -- ", h.format );
			trace( "SimpleViewer - _update -- ", h.type );
			trace( "SimpleViewer - _update -- ", h.width );
			trace( "SimpleViewer - _update -- ", h.height );
			
			_mipmap = (h.count>1);
			
			_atf.position = _atfOffset;
			if( _texDirty ) {
				if( _texture ) _texture.dispose();
				_texture = _context.createTexture( h.width, h.height, (h.format == AtfFormat.Compressed) ? Context3DTextureFormat.COMPRESSED : Context3DTextureFormat.BGRA, false );
				_texture.uploadCompressedTextureFromByteArray( _atf, _atfOffset );
				_texDirty = false;
			}
			if( _programDirty )
				updateProgram();

			
			_context.setVertexBufferAt(0, _vbuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			_context.setVertexBufferAt(1, _vbuffer, 2, Context3DVertexBufferFormat.FLOAT_2);
			
			_context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, _vdata);

			_context.setTextureAt(0, _texture );
			_context.setProgram(_program);
			_context.clear(0.0, 0.0, 0.0, 1.0);
			_context.drawTriangles( _ibuffer, 0, 2);
			
			if( drawToBmp ) {
				var res : BitmapData = new BitmapData(_width, _height, false );
				_context.drawToBitmapData( res );
			}
			
			_context.present();
			return res;
		}

		private var _vertices : Vector.<Number>;
		private var _vbuffer : VertexBuffer3D;
		private var _ibuffer : IndexBuffer3D;
		private var _texture : Texture;
		private var _program : Program3D;

		public function get vscaleX() : Number {
			return _scaleX;
		}

		public function get vscaleY() : Number {
			return _scaleY;
		}

		public function set vscaleY(scaleY : Number) : void {
			_scaleY = scaleY;
			if( _context ) _update();
		}

		public function set vscaleX(scaleX : Number) : void {
			_scaleX = scaleX;
			if ( _context ) _update();
		}

		public function get mipmap() : Boolean {
			return _mipmap;
		}

		public function set mipmap(mipmap : Boolean) : void {
			if( _mipmap == mipmap ) return;
			_mipmap = mipmap;
			_programDirty = true;
		}
	}
}
