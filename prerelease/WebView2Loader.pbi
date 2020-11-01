CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
	Import "x64\WebView2Loader.lib"
	
CompilerElse
	Import "x86\WebView2Loader.lib"
CompilerEndIf

	CreateCoreWebView2Environment(environment_created_handler.i)
	CreateCoreWebView2EnvironmentWithOptions(browserExecutableFolder.s, userDataFolder.s, environmentOptions.i, environment_created_handler.i)
	GetAvailableCoreWebView2BrowserVersionString(browserExecutableFolder.s, versionInfo.i)
	CompareBrowserVersions(version1.s, version2.s, result.i)
EndImport