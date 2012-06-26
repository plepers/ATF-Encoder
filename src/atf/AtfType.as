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

	/**
	 * @author Pierre Lepers
	 * away3d.tools.atf.ATFType
	 */
	public class AtfType {

		/**
		 * 2D texture
		 */
		public static const NORMAL : uint = 0;

		/**
		 * cubic texture
		 */
		public static const CUBE_MAP : uint = 1;

		/**
		 * return the human readable type information
		 */
		public static function getType( type : int ) : String {
			switch( type ) {
				case NORMAL : 	return "NORMAL";
				case CUBE_MAP :	return "CUBE_MAP";
				default:		return "UNKNOWN ATF TYPE";
			}
		}
	}
}
