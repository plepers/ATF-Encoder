ATF-Encoder
===========

Pure AS3 librairies for encode/decode ATF (Adobe Texture Format) files.

require FP 11.3

Features
========

Decoding :
* support all types, 2D and Cube
* decoding sepecific face in cube texture
* support all RGB888, RGBA8888 and Blockbased compression (decoding DXT1 version)
	
Encoding
* support all types, 2D and Cube
* support only RGB888 and RGBA8888 formats.

Utils
* replaceImageData : modify mip/face in existing atf file	
* removeAllBut : keep only one blockbased format of existing atf file. Use it to create platform specific lightweight texture by removing unused one.
* getSuitableBlockbasedFormat :  return one of the blockbased texture formats internaly used by flash for the giver Context3D

Limitations
===========	

Encoder don't support BlockBased compression formats (DXT1, ETC1, PVRTC) due to lack of available source code :/