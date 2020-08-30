;basic_async.pb

;Basic browser asyncrhonous creation.

IncludeFile "..\PBWebView2.pb"

EnableExplicit

;- APP_TAG
Structure APP_TAG
	window.i
	wvEnvironment.ICoreWebView2Environment
	wvController.ICoreWebView2Controller
	wvCore.ICoreWebView2
	*eventNavigationCompleted.WV2_EVENT_HANDLER
EndStructure
Global.APP_TAG app

;- DECLARES
Declare main()

Declare window_Close()
Declare window_Resize()
Declare window_ProcessEvents(ev.l)

Declare wvEnvironment_Created(*this.WV2_EVENT_HANDLER, result.l, environment.ICoreWebView2Environment)	
Declare wvController_Created(*this.WV2_EVENT_HANDLER, result.l, controller.ICoreWebView2Controller)
Declare wv_NavigationCompleted(*this.WV2_EVENT_HANDLER, sender.ICoreWebView2, args.ICoreWebView2NavigationCompletedEventArgs)

Procedure window_Proc(hwnd.i, msg.l, wparam.i, lparam.i)
	Select msg
		Case #WM_MOVE, #WM_MOVING
			wv2_Controller_On_WM_MOVE_MOVING(app\wvController)
	EndSelect
	
	ProcedureReturn #PB_ProcessPureBasicEvents
EndProcedure

Procedure wvEnvironment_Created(*this.WV2_EVENT_HANDLER, result.l, environment.ICoreWebView2Environment)	
	If result = #S_OK
		environment\QueryInterface(?IID_ICoreWebView2Environment, @app\wvEnvironment)
		app\wvEnvironment\CreateCoreWebView2Controller(WindowID(app\window), wv2_EventHandler_New(?IID_ICoreWebView2CreateCoreWebView2ControllerCompletedHandler, @wvController_Created()))
		wv2_EventHandler_Release(*this)
		app\wvEnvironment\Release()
		
	Else
		MessageRequester("Error", "Failed to create WebView2Environment.")
		End 
	EndIf 
EndProcedure

Procedure wvController_Created(*this.WV2_EVENT_HANDLER, result.l, controller.ICoreWebView2Controller)	
	If result = #S_OK
		controller\QueryInterface(?IID_ICoreWebView2Controller, @app\wvController)
		app\wvController\get_CoreWebView2(@app\wvCore)
		
		;Setup events
		app\eventNavigationCompleted = wv2_EventHandler_New(?IID_ICoreWebView2NavigationCompletedEventHandler, @wv_NavigationCompleted())
		app\wvCore\add_NavigationCompleted(app\eventNavigationCompleted, #Null)
		
		window_Resize()
		
		app\wvCore\Navigate("https://duckduckgo.com")
		
		wv2_EventHandler_Release(*this)
		
	Else
		MessageRequester("Error", "Failed to create WebView2Controller.")
		End
	EndIf 
EndProcedure

Procedure wv_NavigationCompleted(*this.WV2_EVENT_HANDLER, sender.ICoreWebView2, args.ICoreWebView2NavigationCompletedEventArgs)
	Debug "Event NavigationCompleted"

EndProcedure

Procedure window_Close()
	If app\wvController
		app\wvController\Close()
		app\wvController\Release()	
	EndIf 
	
	If app\wvCore : app\wvCore\Release() : EndIf 
	
	If app\eventNavigationCompleted
		wv2_EventHandler_Release(app\eventNavigationCompleted)
	EndIf 
	
	ProcedureReturn #True ;Exit message loop.
EndProcedure

Procedure window_Resize()
	Protected.RECT wvBounds
		
	If app\wvController
		GetClientRect_(WindowID(app\window), @wvBounds)
		wv2_Controller_put_Bounds(app\wvController, @wvBounds)
	EndIf 
EndProcedure

Procedure window_ProcessEvents(ev.l)
	Select ev
		Case #PB_Event_CloseWindow : ProcedureReturn window_Close()
	EndSelect
	
	ProcedureReturn #False 
EndProcedure

Procedure main()	
	If wv2_GetBrowserVersion("") = ""
		MessageRequester("Error", "MS Edge not found, install MS Edge runtime.")
		End 
	EndIf
	
	app\window = OpenWindow(#PB_Any, 10, 10, 600, 400, "PBWebView2 - Basic Browser Asynchronous Creation", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_SizeGadget | #PB_Window_MaximizeGadget)
	SetWindowCallback(@window_Proc(), app\window)

	BindEvent(#PB_Event_SizeWindow, @window_Resize())
	
	CreateCoreWebView2EnvironmentWithOptions("", "", #Null, wv2_EventHandler_New(?IID_ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler, @wvEnvironment_Created()))
	
	Repeat
	Until window_ProcessEvents(WaitWindowEvent()) = #True 
EndProcedure

main()