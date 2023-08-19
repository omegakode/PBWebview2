;Get HTML

IncludeFile "..\PBWebView2.pb"

EnableExplicit

;- APP_TAG
Structure APP_TAG
	window.i
	wvEnvironment.ICoreWebView2Environment
	wvController.ICoreWebView2Controller
	wvCore.ICoreWebView2
	evNavigationCompleted.IWV2EventHandler
EndStructure
Global.APP_TAG app

;- DECLARES
Declare main()
Declare window_Resize()

Enumeration #PB_Event_FirstCustomValue
	#WINDOW_EVENT_NAVIGATION_COMPLETED
EndEnumeration

Procedure wv_NavigationCompleted(this.IWV2EventHandler, sender.ICoreWebView2, args.ICoreWebView2NavigationCompletedEventArgs)
	Debug "Webview2 Event NavigationCompleted"
	
	;Webview2 releases args when exiting the event, add a reference to keep them alive for using it in window_on_navigation_completed()
	args\AddRef()
	
	;Post window event, set args as event data
	PostEvent(#WINDOW_EVENT_NAVIGATION_COMPLETED, app\window, 0, 0, args)
EndProcedure

Procedure window_on_navigation_completed()
	Protected.i json
	Protected.ICoreWebView2NavigationCompletedEventArgs args
	Protected.q navId
	
	Debug "window_on_navigation_completed"
	
	args = EventData()
	
	If args
		args\get_NavigationId(@navId)
		Debug "Navigation ID " + Str(navId)
	EndIf 
	
	json = ParseJSON(#PB_Any, wv2_Core_ExecuteScriptSync(app\wvCore, "document.documentElement.outerHTML;", #Null))
	
	Debug "HTML:"
	Debug GetJSONString(JSONValue(json))
	
	FreeJSON(json)
	If args : args\Release() : EndIf 
EndProcedure

Procedure window_Proc(hwnd.i, msg.l, wparam.i, lparam.i)
	Select msg
		Case #WM_MOVE, #WM_MOVING
			wv2_Controller_On_WM_MOVE_MOVING(app\wvController)
	EndSelect
	
	ProcedureReturn #PB_ProcessPureBasicEvents
EndProcedure

Procedure window_Resize()
	Protected.RECT wvBounds
		
	If app\wvController
		GetClientRect_(WindowID(app\window), @wvBounds)
		wv2_Controller_put_Bounds(app\wvController, @wvBounds)
	EndIf 
EndProcedure

Procedure main()
	Protected.i ev
	
	If wv2_GetBrowserVersion("") = ""
		MessageRequester("Error", "MS Edge not found, install MS Edge Runtime.")
		End 
	EndIf
	
	app\window = OpenWindow(#PB_Any, 10, 10, 600, 400, "PBWebView2 - Get HTML", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_SizeGadget | #PB_Window_MaximizeGadget)
	SetWindowCallback(@window_Proc(), app\window)

	BindEvent(#PB_Event_SizeWindow, @window_Resize())
	BindEvent(#WINDOW_EVENT_NAVIGATION_COMPLETED, @window_on_navigation_completed(), app\window)
	
	app\wvEnvironment = wv2_CreateCoreWebView2EnvironmentWithOptionsSync("", "", #Null)
	If app\wvEnvironment = 0
		MessageRequester("Error", "Failed to create WebView2Environment.")
		End
	EndIf
	Debug "Environment created"
	
	app\wvController = wv2_Environment_CreateCoreWebView2ControllerSync(app\wvEnvironment, WindowID(app\window))
	If app\wvController = 0
		MessageRequester("Error", "Failed to create WebView2Controller.")
		End 
	EndIf 
	Debug "Controller created"
	
	app\evNavigationCompleted = wv2_EventHandler_New(@wv_NavigationCompleted(), 0)

	app\wvController\get_CoreWebView2(@app\wvCore)
	window_Resize()
	
	app\wvCore\add_NavigationCompleted(app\evNavigationCompleted, #Null)
	app\wvCore\Navigate("https://duckduckgo.com/") 
		
	Repeat
	Until WaitWindowEvent() = #PB_Event_CloseWindow
	
	If app\wvEnvironment : app\wvEnvironment\Release() : EndIf 
	If app\wvController : app\wvController\Release() : EndIf 
	If app\wvCore : app\wvCore\Release() : EndIf 
	If app\evNavigationCompleted :  app\evNavigationCompleted\Release() : EndIf 
EndProcedure

main()