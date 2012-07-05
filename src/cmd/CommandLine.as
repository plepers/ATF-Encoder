package cmd {
	import flash.utils.Dictionary;	

	/**
	 * @author pierre
	 */
	public class CommandLine {

		public function isEmpty() : Boolean {
			return _empty;
		}

		
		public function CommandLine( arguments : Array ) {
			_init();
			_build(arguments);
		}

		private var _output : String;

		private var _input : String;

		private var _help : Boolean;

		private var _verbose : Boolean;
		
		private var _formats : uint = 0;
		
		private function _build(arguments : Array) : void {
			
			
			_empty = arguments.length == 0;
			var arg : String;
			while( arguments.length > 0 ) {
				arg = arguments.shift();
				//				if( !isAnArgument( arg ) )
				//					throw new Error(arg+" is not a valid argument" );
				var handler : Function = _argHandlers[ arg ];
				if( handler == undefined )
					throw new Error(arg + " is not a valid argument." + HELP);
					
				handler(arguments);
			}
		}
		

		
		private function handleIn( args : Array ) : void {
			_input = formatPath( args.shift() );
		}

		private function handleOutput( args : Array ) : void {
			if( _output != null )
				throw new Error("-o / -output argument cannot be define twice." + HELP);
			_output = args.shift();
		}

		private function handleHelp( args : Array ) : void {
			_help = true;
		}

		
		private function handle_fmt_dxt( args : Array ) : void {
			_formats |= 1;
		}
		
		private function handle_fmt_pvrtc( args : Array ) : void {
			_formats |= 2;
		}

		private function handle_fmt_etc( args : Array ) : void {
			_formats |= 4;
		}

		private function handleVerbose( args : Array ) : void {
			var val : String = args.shift();
			_verbose = ( val == "1" || val == "true" );
		}

		private function _init() : void {
			_argHandlers = new Dictionary();
			
			_argHandlers[ "-i" ] = handleIn;
			_argHandlers[ "-o" ] = handleOutput;
			_argHandlers[ "-E" ] = handle_fmt_etc;
			_argHandlers[ "-D" ] = handle_fmt_dxt;
			_argHandlers[ "-P" ] = handle_fmt_pvrtc;
			_argHandlers[ "-verbose" ] = handleVerbose;
			_argHandlers[ "-help" ] = handleHelp;
		}
		
		private function formatPath( str : String ) : String {
			/*FDT_IGNORE*/
			return str.AS3::replace( /\\/g, "/" );
			/*FDT_IGNORE*/;
			return str;
		}
		
		private var _empty : Boolean = true;

		private var _argHandlers : Dictionary;

//		private static function isAnArgument( arg : String ) : Boolean {
//			return ( arg.AS3::charAt(0) == "-" && (arg.length > 1) && ( isNaN(parseInt(arg.AS3::charAt(1)))));
//		}


		private static const HELP : String = " -help for more infos."
		

		public function get output() : String {
			return _output || _input;
		}

		public function get input() : String {
			return _input;
		}
		
		public function get help() : Boolean {
			return _help;
		}
		
		public function get verbose() : Boolean {
			return _verbose;
		}

		public function get formats() : uint {
			return ( _formats == 0 ) ? 7 : _formats;
		}
		
	}
}
