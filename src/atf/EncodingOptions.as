package atf {

	import flash.display.BitmapEncodingColorSpace;
	import flash.display.StageQuality;
	/**
	 * @author Pierre Lepers
	 * encoder.AtfEncoderOptions
	 */
	public final class EncodingOptions {
		
		
		/**
		 * 	By default encoder will auto generate all applicable mip map levels. In some cases it is 
			not desirable to enable mip maps like for instance for sky maps; you can use this op-
			tion to turn off the auto generation of mip maps.
		 */
		public var mipmap : Boolean = true;
		
		/**
		 * JPEG-XR color space to use.
		 * @default 4:2:0 (BitmapEncodingColorSpace.COLORSPACE_4_2_0)
		 * @see BitmapEncodingColorSpace
		 */
		public var colorSpace : String = BitmapEncodingColorSpace.COLORSPACE_4_2_0;
		
		
		/**
		 * 	Specifies the amount of lossy in the compression. 
		 * 	The range of values is 0 to 100, where a value of 0 means lossless compression. 
		 * 	Larger values increase the lossy value and the resultant image becomes more grainy. 
		 * 	A common value is 10. For values of 20 or larger, the image can become very grainy.
		 * 	default 20
		 *  @see JPEGXREncoderOptions#quantization
		 *  @value [0-100]
		 */
		public var quantization : uint = 20;

		
		/**
		 * 	Selects how many flex bits should be trimmed during JPEG-XR compression. This op-
			tion in not related to the quantization level but selects how much noise should be re-
			tained across the image. Like the quantization level higher values create more artifact. 
			The default value is always 0.
		 * 
		 *  @value [0-15]
		 */
		public var flexbits : uint = 0;
		
		/**
		 * quality used for mipmaps generation.
		 * @see StageQuality
		 * @see Stage#quality
		 * @see BitmapData#drawWithQuality
		 * @default high
		 */
		public var mipQuality : String = StageQuality.HIGH;
		
		
		
		
	}
}
