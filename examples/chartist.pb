;chartist.pb

;Chartist.js example.

IncludeFile "..\PBWebView2.pb"
; IncludeFile "..\prerelease\PBWebView2.pb"

EnableExplicit

;- Enum MENU_ID
Enumeration
	#MENU_ID_CHANGE_DATA
EndEnumeration

;- APP_TAG
Structure APP_TAG
	window.i
	menu.i
	wvEnvironment.ICoreWebView2Environment
	wvController.ICoreWebView2Controller
	wvCore.ICoreWebView2
	eventNavigationCompleted.IWV2EventHandler
EndStructure
Global.APP_TAG app

;- DECLARES
Declare main()

Declare window_Close()
Declare window_Resize()
Declare window_ProcessEvents(ev.l)

Declare menu_ChangeData_Click()

Declare wvEnvironment_Created(this.IWV2EventHandler, result.l, environment.ICoreWebView2Environment)	
Declare wvController_Created(this.IWV2EventHandler, result.l, controller.ICoreWebView2Controller)
Declare wv_NavigationCompleted(this.IWV2EventHandler, sender.ICoreWebView2, args.ICoreWebView2NavigationCompletedEventArgs)

Runtime Procedure visitChartist_Click()
	ShellExecute_(#Null, "open", "http://gionkunz.github.io/chartist-js/index.html", #Null, #Null, #SW_SHOW)
EndProcedure

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
		
		window_Resize()
		
		app\wvCore\Navigate("file:///" + GetCurrentDirectory() + "chartist.html")
		
		this\Release()
		
	Else
		MessageRequester("Error", "Failed to create WebView2Controller.")
		End
	EndIf 
EndProcedure

Procedure wv_NavigationCompleted(this.IWV2EventHandler, sender.ICoreWebView2, args.ICoreWebView2NavigationCompletedEventArgs)
	Debug "Event NavigationCompleted"

	HideWindow(app\window, #False)
	app\wvController\put_IsVisible(#True)
EndProcedure

Procedure window_Close()
	If app\wvController
		app\wvController\Close()
		app\wvController\Release()	
	EndIf 
	
	If app\wvCore : app\wvCore\Release() : EndIf 
		
	If app\eventNavigationCompleted : wv2_EventHandler_Release(app\eventNavigationCompleted) : EndIf 
	
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
		Case #PB_Event_Menu
			Select EventMenu()
				Case #MENU_ID_CHANGE_DATA : menu_ChangeData_Click()
			EndSelect
			
		Case #PB_Event_CloseWindow : ProcedureReturn window_Close()
	EndSelect
	
	ProcedureReturn #False 
EndProcedure

Procedure menu_ChangeData_Click()
	Protected.s script
	
	script = "chart1Data.series[0] = [" + Str(Random(9)) + ", " + Str(Random(9)) + ", " + Str(Random(9)) + ", " + Str(Random(9)) + ", " + Str(Random(9)) + "];"
	script + "chart1Data.series[1] = [" + Str(Random(9)) + ", " + Str(Random(9)) + ", " + Str(Random(9)) + ", " + Str(Random(9)) + ", " + Str(Random(9)) + "];"
	script + "chart1.update(chart1Data);"
	
	app\wvCore\ExecuteScript(script, #Null)
EndProcedure

Procedure menu_Create(winid.l)
	Protected.i menu
	
	menu = CreateMenu(#PB_Any, winid)
	MenuTitle("Interact")
	MenuItem(#MENU_ID_CHANGE_DATA, "Change data")

	ProcedureReturn menu
EndProcedure

Procedure main()	
	If wv2_GetBrowserVersion("") = ""
		MessageRequester("Error", "MS Edge not found, install MS Edge runtime.")
		End 
	EndIf
	
	app\window = OpenWindow(#PB_Any, 10, 10, 700, 500, "PBWebView2 - Chartist", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_SizeGadget | #PB_Window_MaximizeGadget | #PB_Window_Invisible)
	SetWindowCallback(@window_Proc(), app\window)

	app\menu = menu_Create(WindowID(app\window))

	BindEvent(#PB_Event_SizeWindow, @window_Resize())
	
	CreateCoreWebView2EnvironmentWithOptions("", "", #Null, wv2_EventHandler_New(@wvEnvironment_Created(), 0))
	
	Repeat
	Until window_ProcessEvents(WaitWindowEvent()) = #True 
EndProcedure

main()