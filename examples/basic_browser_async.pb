;basic_browser_async.pb

;Basic browser asyncrhonous creation.

IncludeFile "..\PBWebView2.pb"

EnableExplicit

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

Procedure window_Proc(hwnd.i, msg.l, wparam.i, lparam.i)
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
		
		app\wvCore\Navigate("https://duckduckgo.com")
		
		this\Release()

	Else
		MessageRequester("Error", "Failed to create WebView2Controller.")
		End
	EndIf 
EndProcedure

Procedure wv_WebResourceRequested(this.IWV2EventHandler, sender.ICoreWebView2, args.ICoreWebView2WebResourceRequestedEventArgs)	
	Protected.ICoreWebView2WebResourceRequest req
	Protected.ICoreWebView2HttpRequestHeaders reqHeaders
	
	;SET CUSTOM HEADER
	If args\get_Request(@req) = #S_OK
		If req\get_Headers(@reqHeaders) = #S_OK
			reqHeaders\SetHeader("myheader", "myvalue")
			
			reqHeaders\Release()
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
	
	If wv2_GetBrowserVersion("") = ""
		MessageRequester("Error", "MS Edge not found, install MS Edge runtime.")
		End 
	EndIf

	app\window = OpenWindow(#PB_Any, 10, 10, 600, 400, "PBWebView2 - Basic Browser Asynchronous Creation", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_SizeGadget | #PB_Window_MaximizeGadget)
	SetWindowCallback(@window_Proc(), app\window)

	BindEvent(#PB_Event_SizeWindow, @window_Resize())
	
	CreateCoreWebView2EnvironmentWithOptions("", "", #Null, wv2_EventHandler_New(@wvEnvironment_Created(), 0))

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

