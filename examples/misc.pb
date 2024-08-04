;misc.pb

;Placeholder for various examples:
;Custom scheme registration / Environment Options

IncludeFile "..\PBWebView2.pb"

EnableExplicit

;- PAGE1
#PAGE1 = "<!DOCTYPE html><html><body>" +
"Custom scheme:" + "</br>" +
~"<a href=\"wv2rocks://www.test.com/\">Visit wv2rocks://www.test.com/</a>" + 
"</body></html>"

;- APP_TAG
Structure APP_TAG
	window.i
	wvEnvironment.ICoreWebView2Environment
	wvController.ICoreWebView2Controller
	wvCore.ICoreWebView2
	eventNavigationCompleted.IWV2EventHandler
	eventNavigationSarting.IWV2EventHandler
	eventWebResourceRequested.IWV2EventHandler
	
EndStructure
Global.APP_TAG app

;- DECLARES
Declare main()

Declare window_Close()
Declare window_Resize()

Declare wvEnvironment_Created(this.IWV2EventHandler, result.l, environment.ICoreWebView2Environment)	
Declare wvController_Created(this.IWV2EventHandler, result.l, controller.ICoreWebView2Controller)
Declare wv_NavigationCompleted(this.IWV2EventHandler, sender.ICoreWebView2, args.ICoreWebView2NavigationCompletedEventArgs)
Declare wv_NavigationStarting(this.IWV2EventHandler, sender.ICoreWebView2, args.ICoreWebView2NavigationStartingEventArgs)
Declare wv_WebResourceRequested(this.IWV2EventHandler, sender.ICoreWebView2, args.ICoreWebView2WebResourceRequestedEventArgs)

Procedure window_Proc(hwnd.i, msg.i, wparam.i, lparam.i)
	Select msg
		Case #WM_MOVE, #WM_MOVING
			wv2_Controller_On_WM_MOVE_MOVING(app\wvController)
	EndSelect
	
	ProcedureReturn #PB_ProcessPureBasicEvents
EndProcedure

Procedure wvEnvironment_Created(this.IWV2EventHandler, result.l, environment.ICoreWebView2Environment)	
	If result = #S_OK
		environment\QueryInterface(?IID_ICoreWebView2Environment, @app\wvEnvironment)
		app\wvEnvironment\CreateCoreWebView2Controller(WindowID(app\window), wv2_EventHandler_New(@wvController_Created(), 0))

		this\Release()
		app\wvEnvironment\Release()

	Else
		MessageRequester("Error", "Failed to create WebView2Environment.")
		End 
	EndIf 
EndProcedure

Procedure wvController_Created(this.IWV2EventHandler, result.l, controller.ICoreWebView2Controller)		
	If result = #S_OK
		controller\QueryInterface(?IID_ICoreWebView2Controller, @app\wvController)
		app\wvController\get_CoreWebView2(@app\wvCore)
		
		;Setup events
		app\eventNavigationCompleted = wv2_EventHandler_New(@wv_NavigationCompleted(), 0)
		app\wvCore\add_NavigationCompleted(app\eventNavigationCompleted, #Null)
		
		app\eventNavigationSarting = wv2_EventHandler_New(@wv_NavigationStarting(), 0)
		app\wvCore\add_NavigationStarting(app\eventNavigationSarting, #Null)
		
		app\wvCore\AddWebResourceRequestedFilter("*", #COREWEBVIEW2_WEB_RESOURCE_CONTEXT_ALL)
		app\eventWebResourceRequested = wv2_EventHandler_New(@wv_WebResourceRequested(), 0)
		app\wvCore\add_WebResourceRequested(app\eventWebResourceRequested, #Null)
		
		window_Resize()
		
		app\wvCore\NavigateToString(#PAGE1)
		
		this\Release()

	Else
		MessageRequester("Error", "Failed to create WebView2Controller.")
		End
	EndIf 
EndProcedure

Procedure wv_WebResourceRequested(this.IWV2EventHandler, sender.ICoreWebView2, args.ICoreWebView2WebResourceRequestedEventArgs)	
	Protected.ICoreWebView2WebResourceRequest req
	Protected.ICoreWebView2HttpRequestHeaders reqHeaders
	Protected.i uri
	Protected.s suri
	
	Debug #PB_Compiler_Procedure
	
	If args\get_Request(@req) = #S_OK
		req\get_uri(@uri)
		If uri
			suri = PeekS(uri)
			str_FreeCoMemString(uri)
			If GetURLPart(suri, #PB_URL_Protocol) = "wv2rocks"
				MessageRequester("WebView2", "wv2rocks scheme requested")
			EndIf 
		EndIf 
		
		req\Release()
	EndIf 
EndProcedure

Procedure wv_NavigationCompleted(this.IWV2EventHandler, sender.ICoreWebView2, args.ICoreWebView2NavigationCompletedEventArgs)
	Debug "Event NavigationCompleted"
	
EndProcedure

Procedure wv_NavigationStarting(this.IWV2EventHandler, sender.ICoreWebView2, args.ICoreWebView2NavigationStartingEventArgs)
	Protected.i uri
	Protected.s suri
	
	Debug "Event NavigationStarting"
	
	If args\get_uri(@uri) = #S_OK
		suri = PeekS(uri)
		CoTaskMemFree_(uri)

		;CANCEL NAVIGATION
		If LCase(StringField(GetURLPart(suri, #PB_URL_Site), 2, ".")) = "google"
			MessageRequester("Purebasic", "Sorry google is banned.")
			args\put_Cancel(#True)
		EndIf 
	EndIf 
EndProcedure

Procedure window_Close()
	If app\wvController
		app\wvController\Close()
		app\wvController\Release()	
	EndIf 
	
	If app\wvCore : app\wvCore\Release() : EndIf 
	
	If app\eventNavigationCompleted : app\eventNavigationCompleted\Release() : EndIf 
	
	If app\eventNavigationSarting : app\eventNavigationSarting\Release() : EndIf 
	
	If app\eventWebResourceRequested : app\eventWebResourceRequested\Release() : EndIf 
	
	ProcedureReturn #True ;Exit message loop.
EndProcedure

Procedure window_Resize()
	Protected.RECT wvBounds
		
	If app\wvController
		GetClientRect_(WindowID(app\window), @wvBounds)
		wv2_Controller_put_Bounds(app\wvController, @wvBounds)
	EndIf 
EndProcedure

Procedure main()
	Protected.l ev
	Protected.b quit
	Protected.ICoreWebView2EnvironmentOptions opt
	Protected.ICoreWebView2EnvironmentOptions4 opt4
	Protected.i allowedOrigins
	Protected.ICoreWebView2CustomSchemeRegistration customSchemeRegistration, customSchemeRegistration2, customSchemeRegistration3
	Protected.WV2_VECTOR_ICUSTOM_SCHEME_REGISTRATION *registrations
	
	If wv2_GetBrowserVersion("") = ""
		MessageRequester("Error", "MS Edge not found, install MS Edge runtime.")
		End 
	EndIf

	app\window = OpenWindow(#PB_Any, 10, 10, 600, 400, "PBWebView2 - Misc Examples", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_SizeGadget | #PB_Window_MaximizeGadget)
	SetWindowCallback(@window_Proc(), app\window)

	BindEvent(#PB_Event_SizeWindow, @window_Resize())
	
	;- CUSTOM SCHEME REGISTRATION / ENV OPTIONS
	;To set Environment Options create an EnvironmentOptions base class,
	;QueryInterface for the desired options, set it, and release when needed.
	;Custom scheme registration from msdn example:
	;https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions4?view=webview2-1.0.2210.55#setcustomschemeregistrations
	
	opt = wv2_EnvironmentOptions_New()
	opt\QueryInterface(?IID_ICoreWebView2EnvironmentOptions4, @opt4)
	allowedOrigins = str_MakeStringArray(1)
	str_PutStringArrayElement(allowedOrigins, 0, "https://*.example.com")
	
	customSchemeRegistration = wv2_CustomSchemeRegistration_New("custom-scheme")
	customSchemeRegistration\SetAllowedOrigins(1, allowedOrigins)
	
	customSchemeRegistration2 = wv2_CustomSchemeRegistration_New("wv2rocks")
	customSchemeRegistration2\put_TreatAsSecure(#True)
	customSchemeRegistration2\SetAllowedOrigins(1, allowedOrigins)
	customSchemeRegistration2\put_HasAuthorityComponent(#True)

	customSchemeRegistration3 = wv2_CustomSchemeRegistration_New("custom-scheme-not-in-allowed-origins")
	
	*registrations = wv2_CustomSchemeRegistration_MakeArray(3)
	*registrations\item[0] = customSchemeRegistration
	*registrations\item[1] = customSchemeRegistration2
	*registrations\item[2] = customSchemeRegistration3
	
	opt4\SetCustomSchemeRegistrations(3, *registrations)
	wv2_CustomSchemeRegistration_ReleaseArray(*registrations, 3)
	str_FreeStringArray(allowedOrigins, 1)

	CreateCoreWebView2EnvironmentWithOptions("", "", opt, wv2_EventHandler_New(@wvEnvironment_Created(), 0))
	
	opt4\Release()
	opt\Release()

	quit = #False 
	Repeat
		ev = WaitWindowEvent()
		Select ev
			Case #PB_Event_CloseWindow
				quit = window_Close()
		EndSelect
	Until quit
EndProcedure

main()

