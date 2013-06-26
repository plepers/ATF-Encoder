package {

	import atf.Utils;
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display3D.Context3DRenderMode;
	import flash.events.Event;
	/**
	 * @author Pierre Lepers
	 * UtilsSuitableFmtTest
	 */
	public class UtilsSuitableFmtTest {

		private var stage : Stage;

		public function UtilsSuitableFmtTest(stage : Stage) {
			this.stage = stage;
			stage.stage3Ds[0].addEventListener( Event.CONTEXT3D_CREATE, onCtx );
			stage.stage3Ds[0].requestContext3D();
			stage.stage3Ds[1].addEventListener( Event.CONTEXT3D_CREATE, onCtx );
			stage.stage3Ds[1].requestContext3D( Context3DRenderMode.SOFTWARE );
		}

		private function onCtx(event : Event) : void {
			var s3d : Stage3D = event.currentTarget as Stage3D;
			
			trace( "UtilsSuitableFmtTest - onCtx -- ", s3d.context3D.driverInfo );
			trace( "UtilsSuitableFmtTest - onCtx -- ", Utils.getSuitableBlockbasedFormat( s3d.context3D ) );
		}

	}
}
