/*
 * builtin dummies
 */

/*FDT_IGNORE*/
package flash.display3D {
	
	import flash.display3D.textures.Texture;
	
	public class Context3D {
		
		public function createTexture(width : int, height : int, format : String, optimizeForRenderToTexture : Boolean, streamingLevels : int = 0) : Texture {
			return null;
		}
		
	}

	public class Context3DTextureFormat {
		public static const COMPRESSED : String;
	}
	
	
}

package flash.display3D.textures {
	
	import flash.utils.ByteArray;
	
	public class Texture {
		
		public function uploadCompressedTextureFromByteArray(data : ByteArray, byteArrayOffset : uint, async : Boolean = false) : void {}
		
		public function dispose() : void{}
		
	}
	
}

/*FDT_IGNORE*/
