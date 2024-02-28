XIncludeFile "WebView2_Config.pbi"

XIncludeFile "debug.pb"
DebugLevel #_DEBUG_LEVEL_ALL

XIncludeFile "windows\windows.pbi"

XIncludeFile "math.pb"
XIncludeFile "Unsigned.pb"
XIncludeFile "stream.pb"
XIncludeFile "resource.pb"
XIncludeFile "json.pb"
XIncludeFile "keyboard.pb"
XIncludeFile "enum.pb"

XIncludeFile "ffi.pbi"
XIncludeFile "ffitarget.pbi"

XIncludeFile "WebView2Loader.pbi"
XIncludeFile "WebView2_IID.pbi"
CompilerIf Not(Defined(ICoreWebView2, #PB_Interface))
	XIncludeFile "WebView2.pbi"
CompilerEndIf
XIncludeFile "WebView2EnvironmentOptions.pb"
XIncludeFile "WebView2_Helper.pb"
XIncludeFile "PB_Host_Object.pb"

