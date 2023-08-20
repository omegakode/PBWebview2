XIncludeFile "windows\windows.pbi"

XIncludeFile "stream.pb"
XIncludeFile "resource.pb"
XIncludeFile "json.pb"
XIncludeFile "keyboard.pb"
XIncludeFile "enum.pb"

CompilerIf #PB_Compiler_Backend = #PB_Backend_Asm
	XIncludeFile "VCall.pb"
	
CompilerElseIf #PB_Compiler_Backend = #PB_Backend_C
	XIncludeFile "ffi.pbi"
	XIncludeFile "ffitarget.pbi"
CompilerEndIf

IncludeFile "WebView2Loader.pbi"
IncludeFile "WebView2.pbi"
IncludeFile "WebView2EnvironmentOptions.pb"
IncludeFile "WebView2_Helper.pb"
IncludeFile "PB_Host_Object.pb"

; IDE Options = PureBasic 6.03 beta 5 LTS (Windows - x86)
; CursorPosition = 16
; Folding = -
; EnableXP
; DPIAware