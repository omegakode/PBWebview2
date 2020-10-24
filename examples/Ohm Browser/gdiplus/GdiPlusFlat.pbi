;GdiPlusFlat.pbi

CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
	Import "lib\x64\gdiplus.lib"
	
CompilerElse
	Import "lib\x86\gdiplus.lib"
CompilerEndIf

	GdipCreateFromHDC(hdc.i, graphics.i)
	GdipDeleteGraphics(graphics.i)

	GdipLoadImageFromStream(stream.i, image.i)
	GdipDisposeImage(image.i)
	GdipLoadImageFromFile(filename.s, image.i)

	GdipDrawImageI(graphics.i, image.i, x.l, y.l)
	GdipDrawImageRectI(graphics.i, image.i, x.l, y.l, width.l, height.l)
EndImport
