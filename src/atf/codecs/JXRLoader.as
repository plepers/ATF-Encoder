package atf.codecs {

	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;

	/**
	 * @author Pierre Lepers
	 * atf.codecs.JXRLoader
	 */
	public class JXRLoader extends TextureLoader {

		private var _jxr : ByteArray;

		public function JXRLoader(jxr : ByteArray) {
			_jxr = jxr;
			super();
		}

		override public function load() : void {
			var l : Loader = new Loader( );
			l.contentLoaderInfo.addEventListener( Event.COMPLETE, imageLoaded );
			l.loadBytes( _jxr, new LoaderContext( false, new ApplicationDomain() ) );
		}

		private function imageLoaded(event : Event) : void {
			var li : LoaderInfo = event.currentTarget as LoaderInfo;
			li.removeEventListener( Event.COMPLETE, imageLoaded );
			bitmapData = ( li.loader.content as Bitmap ).bitmapData;
			dispatchEvent(event);
		}
	}
}
