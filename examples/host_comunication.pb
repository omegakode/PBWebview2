;host_comunication.pb

IncludeFile "..\PBWebView2.pb"

EnableExplicit

Enumeration
	#MENU_ID_SEND_MESSAGE_TO_WEB_CONTENT
EndEnumeration

;- APP_TAG
Structure APP_TAG
	window.i
	wvEnvironment.ICoreWebView2Environment
	wvController.ICoreWebView2Controller
	wvCore.ICoreWebView2
	*eventWebMessageReceived.WV2_EVENT_HANDLER
	page1.s
	quit.b
EndStructure
Global.APP_TAG app

;- DECLARES
Declare main()
Declare window_Close()
Declare window_Resize()
Declare wvEnvironment_Created(*this.WV2_EVENT_HANDLER, result.l, environment.ICoreWebView2Environment)	
Declare wvController_Created(*this.WV2_EVENT_HANDLER, result.l, controller.ICoreWebView2Controller)
Declare.s page1_Create()
Declare wv_WebMessageReceived(*this.WV2_EVENT_HANDLER, webview.ICoreWebView2, args.ICoreWebView2WebMessageReceivedEventArgs)
Declare menu_Create(winId.i)
Declare menu_SendMessage_Click()

Procedure window_Proc(hwnd.i, msg.l, wparam.i, lparam.i)
	Select msg
		Case #WM_MOVE, #WM_MOVING
			wv2_Controller_On_WM_MOVE_MOVING(app\wvController)
	EndSelect
	
	ProcedureReturn #PB_ProcessPureBasicEvents
EndProcedure


Procedure menu_Create(winId)
	Protected.i menu
	
	menu = CreateMenu(#PB_Any, winId)
	MenuTitle("Communicate")
	MenuItem(#MENU_ID_SEND_MESSAGE_TO_WEB_CONTENT, "Send Message To Web Content")
	
	BindMenuEvent(menu, #MENU_ID_SEND_MESSAGE_TO_WEB_CONTENT, @menu_SendMessage_Click())
	
	ProcedureReturn menu
EndProcedure

Procedure menu_SendMessage_Click()
	Protected.s msg
	
	app\wvCore\PostWebMessageAsString("hello from Purebasic")
EndProcedure

Procedure.s page1_Create()
	Protected.s page1
	
	page1 = "<!DOCTYPE html>" +
	"<html>" +
	"<body>" +
	"Message:" + ~"<input type=\"text\" id=\"msg\" value=\"hello from web content\">" + 
	~"<button type=\"button\" onclick=\"window.chrome.webview.postMessage(document.getElementById('msg').value)\">Send To PB</button>" +
	"</body>" +
	"</html>"
	
	ProcedureReturn page1
EndProcedure

Procedure wv_WebMessageReceived(*this.WV2_EVENT_HANDLER, webview.ICoreWebView2, args.ICoreWebView2WebMessageReceivedEventArgs)
	Protected.i msg
	
	args\TryGetWebMessageAsString(@msg)
	If msg
		MessageRequester("Purebasic", "Message received: " + PeekS(msg))
		CoTaskMemFree_(msg)
	EndIf 
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
	Protected.q evToken
	
	If result = #S_OK
		controller\QueryInterface(?IID_ICoreWebView2Controller, @app\wvController)
		app\wvController\get_CoreWebView2(@app\wvCore)
		
		app\wvCore\add_WebMessageReceived(app\eventWebMessageReceived, @evToken)
		
		;Add javascript message handler.
		app\wvCore\AddScriptToExecuteOnDocumentCreated(~"window.chrome.webview.addEventListener('message', event => alert(event.data));", #Null)
		
		window_Resize()
		app\wvCore\NavigateToString(app\page1)
		wv2_EventHandler_Release(*this)
		
	Else
		MessageRequester("Error", "Failed to create WebView2Controller.")
		End
	EndIf 
EndProcedure

Procedure window_Close()
	app\wvController\Close()
	app\wvCore\Release()
	wv2_EventHandler_Release(app\eventWebMessageReceived)
	
	app\quit = #True
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
	
	app\page1 = page1_Create()
	app\eventWebMessageReceived = wv2_EventHandler_New(?IID_ICoreWebView2WebMessageReceivedEventHandler, @wv_WebMessageReceived())
	
	app\window = OpenWindow(#PB_Any, 10, 10, 600, 400, "PBWebView2 - Host Communication", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_SizeGadget | #PB_Window_MaximizeGadget)
	SetWindowCallback(@window_Proc(), app\window)	
	
	menu_Create(WindowID(app\window))
	
	BindEvent(#PB_Event_CloseWindow, @window_Close())
	BindEvent(#PB_Event_SizeWindow, @window_Resize())
	
	CreateCoreWebView2EnvironmentWithOptions("", "", #Null, wv2_EventHandler_New(?IID_ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler, @wvEnvironment_Created()))
	
	Repeat
		ev = WaitWindowEvent()
		
	Until app\quit
EndProcedure

main()