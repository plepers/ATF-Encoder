package cmd {

	import avmplus.System;
	import atf.TexFormat;
	import atf.Utils;
	import avmplus.FileSystem;

	import flash.utils.ByteArray;
	
	
	
	use namespace AS3;
	/**
	 * @author Pierre Lepers
	 * cmd.Splitter
	 */
	public class Splitter {

		private var cl : CommandLine;
		
		function Splitter(args : Array) {
			
			cl = new CommandLine( args );
			
			if( cl.isEmpty() ) {
				printHelp();
				System.exit( 0 );
			}
			
			_run();
			
			System.exit( 0 );
			
		}

		private function _run() : void {
			
			
			var fmts : uint = cl.formats;

			var atf : ByteArray = FileSystem.readByteArray( cl.input );
			
			if( fmts & TexFormat.DXT ) 
				_export( multipleOutput() ? getName( cl.output, TexFormat.DXT ) : cl.output, atf, TexFormat.DXT );
			if( fmts & TexFormat.ETC ) 
				_export( multipleOutput() ? getName( cl.output, TexFormat.ETC ) : cl.output, atf, TexFormat.ETC );
			if( fmts & TexFormat.PVRTC ) 
				_export( multipleOutput() ? getName( cl.output, TexFormat.PVRTC ) : cl.output, atf, TexFormat.PVRTC );
			
			
		}
		
		private function _export( fname : String, input : ByteArray, fmt : uint ) : void {
			var cpy : ByteArray = new ByteArray();
			input.position = 0;
			input.readBytes(cpy, 0, input.length );
			Utils.removeAllBut( cpy, fmt );
			
			FileSystem.writeByteArray( fname, cpy );
		}
		
		private function getName( base : String, fmt : uint ) : String {
			switch(fmt){
				case TexFormat.DXT:			return base.substring( 0, base.lastIndexOf( "." ) ) + "_dxt.atf";
				case TexFormat.ETC:			return base.substring( 0, base.lastIndexOf( "." ) ) + "_etc.atf";
				case TexFormat.PVRTC:		return base.substring( 0, base.lastIndexOf( "." ) ) + "_pvrtc.atf";
			}
			return null;
		}

			
		private function multipleOutput() : Boolean {
			return !( cl.formats == 1 || cl.formats == 2 || cl.formats == 4 );
		}
		
		private function printHelp() : void {
			
			var nl : String = "\n";
			
			var help : String = "";
			
			help += "splitter"+nl;
			help += "split blockbased compressed atf file into platform-specific lightweight atf file, "+nl;
			help += "keeping only one format ( DXT1, ETC1 or PVRTC ), removing the others"+nl;
			help += "author Pierre Lepers (pierre[dot]lepers[at]gmail[dot]com)"+nl;
			help += "powered by RedTamarin"+nl;
			help += "version 1.0"+nl;
			help += "usage : splitter "+nl;
			
			help += " -i <atffile> input atf file"+nl;
			help += " -o <filename> : output"+nl;
			help += " -E : generate ETC1"+nl;
			help += " -D : generate DXT1"+nl;
			help += " -P : generate PVRTC"+nl;
			
			trace( help );
		}
	}
}

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

import avmplus.System;
import cmd.Splitter;

var splitter : Splitter = new Splitter( System.argv );
