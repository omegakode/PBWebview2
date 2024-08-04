XIncludeFile "..\WebView2_Config.pbi"

XIncludeFile "..\debug.pb"
DebugLevel #_DEBUG_LEVEL_ALL

XIncludeFile "..\windows\windows.pbi"

XIncludeFile "..\stream.pb"
XIncludeFile "..\resource.pb"
XIncludeFile "..\json.pb"
XIncludeFile "..\keyboard.pb"
XIncludeFile "..\enum.pb"
XIncludeFile "..\VCall.pb"

CompilerIf Not Defined(ICoreWebView2, #PB_Interface)
	IncludeFile "WebView2.pbi"
CompilerEndIf
XIncludeFile "WebView2Experimental.pbi"
XIncludeFile "WebView2Loader.pbi"
XIncludeFile "WebView2EnvironmentOptions.pb"

XIncludeFile "..\WebView2_Helper.pb"
XIncludeFile "..\PB_Host_Object.pb"
