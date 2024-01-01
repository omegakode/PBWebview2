CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
	Import "x64\WebView2Loader.lib"

	CreateCoreWebView2Environment(environment_created_handler.i)
	CreateCoreWebView2EnvironmentWithOptions(browserExecutableFolder.s, userDataFolder.s, environmentOptions.i, environment_created_handler.i)
	GetAvailableCoreWebView2BrowserVersionString(browserExecutableFolder.s, versionInfo.i)
	CompareBrowserVersions(version1.s, version2.s, result.i)
	CreateWebViewEnvironmentWithOptionsInternal(checkRunningInstance.l, runtimeType.l, userDataFolder.s, environmentOptions.i, webViewEnvironmentCreatedHandler.i)
	
	EndImport

CompilerElseIf #PB_Compiler_Processor = #PB_Processor_x86
	Prototype p_CreateCoreWebView2Environment(environment_created_handler.i)
	Prototype p_CreateCoreWebView2EnvironmentWithOptions(browserExecutableFolder.s, userDataFolder.s, environmentOptions.i, environment_created_handler.i)
	Prototype p_GetAvailableCoreWebView2BrowserVersionString(browserExecutableFolder.s, versionInfo.i)
	Prototype p_CompareBrowserVersions(version1.s, version2.s, result.i)
	Prototype p_CreateWebViewEnvironmentWithOptionsInternal(checkRunningInstance.l, runtimeType.l, userDataFolder.s, environmentOptions.i, webViewEnvironmentCreatedHandler.i)

	Global.p_CreateCoreWebView2Environment CreateCoreWebView2Environment
	Global.p_CreateCoreWebView2EnvironmentWithOptions CreateCoreWebView2EnvironmentWithOptions
	Global.p_GetAvailableCoreWebView2BrowserVersionString GetAvailableCoreWebView2BrowserVersionString
	Global.p_CompareBrowserVersions CompareBrowserVersions
	Global.p_CreateWebViewEnvironmentWithOptionsInternal CreateWebViewEnvironmentWithOptionsInternal
	
	Procedure wv2_LoadWebView2DLL()
		Protected.i hlib
		
		hlib = OpenLibrary(#PB_Any, "WebView2Loader.dll")
	
		If hlib
			CreateCoreWebView2Environment = GetFunction(hlib, "CreateCoreWebView2Environment")
			CreateCoreWebView2EnvironmentWithOptions = GetFunction(hlib, "CreateCoreWebView2EnvironmentWithOptions")
			GetAvailableCoreWebView2BrowserVersionString = GetFunction(hlib, "GetAvailableCoreWebView2BrowserVersionString")
			CompareBrowserVersions = GetFunction(hlib, "CompareBrowserVersions")
			CreateWebViewEnvironmentWithOptionsInternal = GetFunction(hlib, "CreateWebViewEnvironmentWithOptionsInternal")
		EndIf 
	EndProcedure
	
	wv2_LoadWebView2DLL()
CompilerEndIf
