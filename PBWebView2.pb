XIncludeFile "WebView2_Config.pbi"

XIncludeFile "debug.pb"
DebugLevel #_DEBUG_LEVEL_ALL

XIncludeFile "windows\windows.pbi"

XIncludeFile "stream.pb"
XIncludeFile "resource.pb"
XIncludeFile "json.pb"
XIncludeFile "keyboard.pb"
XIncludeFile "enum.pb"

XIncludeFile "ffi.pbi"
XIncludeFile "ffitarget.pbi"

IncludeFile "WebView2Loader.pbi"
IncludeFile "WebView2_IID.pbi"
CompilerIf #WV2_CONFIG_USE_RESIDENT = #False
	IncludeFile "WebView2.pbi"
CompilerEndIf
IncludeFile "WebView2EnvironmentOptions.pb"
IncludeFile "WebView2_Helper.pb"
IncludeFile "PB_Host_Object.pb"
IncludeFile "WebGadget2.pb"

