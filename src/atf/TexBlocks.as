/* ***** BEGIN LICENSE BLOCK *****
 * Copyright (C) 2007-2009 Digitas France
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 * The Initial Developer of the Original Code is
 * Digitas France Flash Team
 *
 * Contributor(s):
 *   Digitas France Flash Team
 *
 * ***** END LICENSE BLOCK ***** */
package atf {

	import flash.utils.ByteArray;
	
	/**
	 * @author Pierre Lepers
	 * atf.TexBlocks
	 */
	public class TexBlocks {

		
		
		
		public function read( bytes : ByteArray, header : Header ) : void {
			var count : int = header.count* (( header.format==AtfFormat.Compressed ) ? 8 : 1) * ( (header.type==AtfType.NORMAL ) ? 1 : 6 );
			
			blocks = new Vector.<uint>( count*2 , true );
			var len : int, i : int = 0;
			while( i < count ) {
				len = blocks[i*2+1] = (bytes.readUnsignedByte()<<16) + (bytes.readUnsignedByte()<<8) + bytes.readUnsignedByte();
				blocks[i*2] = bytes.position;
				bytes.position += len;
				i++;
			}
		}
		
		



		public var blocks : Vector.<uint>;

	}
}
