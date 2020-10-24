;GdiPlusInit.pbi

;- IMPORTS
CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
	Import "lib\x64\gdiplus.lib"
	
CompilerElse
	Import "lib\x86\gdiplus.lib"
CompilerEndIf

	GdiplusStartup(token.i, input.i, output.i)
	GdiplusShutdown(token.i)
EndImport

;- GdiplusStartupInput
Structure GdiplusStartupInput Align #PB_Structure_AlignC
	GdiplusVersion.l          
	DebugEventCallback.i
	SuppressBackgroundThread.l
	SuppressExternalCodecs.l
EndStructure

