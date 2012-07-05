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
				HelpPrinter.print();
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
				case TexFormat.DXT:		return base.substring( 0, base.lastIndexOf( "." ) ) + "_dxt.atf";
				case TexFormat.ETC:		return base.substring( 0, base.lastIndexOf( "." ) ) + "_etc.atf";
				case TexFormat.PVRTC:		return base.substring( 0, base.lastIndexOf( "." ) ) + "_pvrtc.atf";
			}
			return null;
		}

			
		private function multipleOutput() : Boolean {
			return !( cl.formats == 1 || cl.formats == 2 || cl.formats == 4 );
		}
		
	}
}


include "builtin.as"
include "CommandLine.as"
include "HelpPrinter.as"
include "../atf/Utils.as"
include "../atf/TexFormat.as"
include "../atf/Header.as"
include "../atf/AtfFormat.as"
include "../atf/AtfType.as"
include "../atf/TexBlocks.as"

import avmplus.System;
import cmd.Splitter;

var splitter : Splitter = new Splitter( System.argv );
