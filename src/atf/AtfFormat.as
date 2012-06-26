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
	 * away3d.tools.atf.ATFFormat
	 */
	public class AtfFormat {
		
		/**
		 * 24bit RGB format
		 */
		public static const RGB888 : uint = 0;
		/**
		 * 32bit RGBA format
		 */
		public static const RGBA88888 : uint = 1;
		/**
		 * block based compression format (DXT1 + PVRTC + ETC1)
		 */
		public static const Compressed : uint = 2;
		
		
		/**
		 * return the human readable format information
		 */
		public static function getFormat( fmt : int ) : String {
			switch( fmt ) {
				case RGB888 : 		return "RGB888";
				case RGBA88888 :	return "RGBA88888";
				case Compressed :	return "Compressed";
				default:			return "UNKNOWN ATF FORMAT";
			}
		}
	}
}
