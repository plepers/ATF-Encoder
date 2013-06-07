package cmd {

	import flash.trace.Trace;
	import atf.AtfType;
	import atf.Header;
	import atf.TexBlocks;
	import atf.Utils;
	import avmplus.FileSystem;
	import avmplus.System;
	import flash.utils.ByteArray;
	
	
	
	use namespace AS3;
	/**
	 * @author Pierre Lepers
	 * cmd.Splitter
	 */
	public class MipAssembler {

		private var cl : CommandLine;

		function MipAssembler(args : Array) {
			
			cl = new CommandLine( args );
			
			if( cl.isEmpty() ) {
				printHelp();
				System.exit( 0 );
			}
			
			_run();
			
			System.exit( 0 );
			
		}

		private function _run() : void {
			

			var atf : ByteArray = FileSystem.readByteArray( cl.input );
			
			var baselevel : int = parseInt( ( /(\d*)\./gi ).exec( cl.input )[1] );
			var basename : String = cl.input.replace( /_mip\d*/gi, "" );
			
			var mipheader : Header = new Header();
			var mipBlocks : TexBlocks = new TexBlocks();
			var blockBuff : ByteArray = new ByteArray();
			
			var header : Header = new Header();
			header.readExternal( atf );
			
			var maxsize : int = ( header.width < header.height ) ? header.height : header.width;
			var nummips : int = Math.log( maxsize ) /  Math.LN2;
			
			var bi : int;
			
			// cubemap
			if( header.type == AtfType.CUBE_MAP ) {
				var mipfile : ByteArray;
				for (var i : int = 0; i < nummips; i++) {
					mipfile = FileSystem.readByteArray( getMipFile( basename, i+1+baselevel ) );
					mipheader.readExternal( mipfile );
					mipBlocks.read(mipfile, mipheader );
					
					for (var face : int = 0; face < 6; face++) {
						bi = ( ( face * mipheader.count ) << 1 );
						blockBuff.position =
						blockBuff.length = 0;
						blockBuff.writeBytes( mipfile, mipBlocks.blocks[bi], mipBlocks.blocks[bi+1] );
						Utils.replaceImageData( atf, blockBuff, i+1, face );
					}
					
				}
				
			}
			
			FileSystem.writeByteArray( cl.output, atf );
			
			
			
		}
		private function getMipFile(input : String, level : int) : String {
			return input.substring( 0, input.lastIndexOf( "." ) ) + "_mip"+level+".atf";
		}
		
		private function printHelp() : void {
			
			var nl : String = "\n";
			
			var help : String = "todo";
			
			
			
			trace( help );
		}
	}
}

import avmplus.System;
import flash.utils.Dictionary;

class CommandLine {

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
		
		trace( "cmd.MipAssembler - _build -- ", arguments.join("#") );
		_empty = arguments.length == 0;
		var arg : String;
		while( arguments.length > 0 ) {
			arg = arguments.shift();
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

	private function handleVerbose( args : Array ) : void {
		var val : String = args.shift();
		_verbose = ( val == "1" || val == "true" );
	}

	private function _init() : void {
		_argHandlers = new Dictionary();
		
		_argHandlers[ "-i" ] = handleIn;
		_argHandlers[ "-o" ] = handleOutput;
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


	private static const HELP : String = " -help for more infos.";
	

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


include "builtin"
include "../atf/Utils.as"
include "../atf/TexFormat.as"
include "../atf/Header.as"
include "../atf/AtfFormat.as"
include "../atf/AtfType.as"
include "../atf/TexBlocks.as"

import cmd.MipAssembler;

var assembler : MipAssembler = new MipAssembler( System.argv );
