;basic_sync.pb

;Basic browser synchronous creation.

IncludeFile "..\PBWebView2.pb"

EnableExplicit

;- APP_TAG
Structure APP_TAG
	window.i
	wvEnvironment.ICoreWebView2Environment
	wvController.ICoreWebView2Controller
	wvCore.ICoreWebView2
EndStructure
Global.APP_TAG app

;- DECLARES
Declare main()
Declare window_Close()
Declare window_Resize()
Declare window_ProcessEvent(ev.l)

Procedure window_Proc(hwnd.i, msg.l, wparam.i, lparam.i)
	Select msg
		Case #WM_MOVE, #WM_MOVING
			wv2_Controller_On_WM_MOVE_MOVING(app\wvController)
	EndSelect
	
	ProcedureReturn #PB_ProcessPureBasicEvents
EndProcedure

Procedure window_Close()
	If app\wvController : app\wvController\Close() : EndIf 
	If app\wvCore : app\wvCore\Release() : EndIf 
	
	ProcedureReturn #True ;Exit message loop.
EndProcedure

Procedure window_Resize()
	Protected.RECT wvBounds
		
	If app\wvController
		GetClientRect_(WindowID(app\window), @wvBounds)
		wv2_Controller_put_Bounds(app\wvController, @wvBounds)
	EndIf 
EndProcedure

Procedure window_ProcessEvent(ev.l)
	Select ev
		Case #PB_Event_CloseWindow : ProcedureReturn window_Close()
	EndSelect
	
	ProcedureReturn #False
EndProcedure

Procedure main()
	Protected.i ev
	
	If wv2_GetBrowserVersion("") = ""
		MessageRequester("Error", "MS Edge not found, install MS Edge Runtime.")
		End 
	EndIf
	
	app\window = OpenWindow(#PB_Any, 10, 10, 600, 400, "PBWebView2 - Basic Browser Synchronous Creation", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_SizeGadget | #PB_Window_MaximizeGadget)
	SetWindowCallback(@window_Proc(), app\window)

	BindEvent(#PB_Event_SizeWindow, @window_Resize())
	
	app\wvEnvironment = wv2_CreateCoreWebView2EnvironmentWithOptionsSync("", "", #Null, @window_ProcessEvent())
	If app\wvEnvironment = 0
		MessageRequester("Error", "Failed to create WebView2Environment.")
		End
	EndIf
	Debug "Environment created"
	
	app\wvController = wv2_Environment_CreateCoreWebView2ControllerSync(app\wvEnvironment, WindowID(app\window), @window_ProcessEvent())
	If app\wvController = 0
		MessageRequester("Error", "Failed to create WebView2Controller.")
		End 
	EndIf 
	Debug "Controller created"
	
	app\wvController\get_CoreWebView2(@app\wvCore)
	window_Resize()
	app\wvCore\Navigate("https://duckduckgo.com/") 
		
	app\wvEnvironment\Release()
	
	Repeat
	Until window_ProcessEvent(WaitWindowEvent()) = #True
EndProcedure

main()