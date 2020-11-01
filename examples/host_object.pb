;host_object.pb

;Shows how to call PB runtime procedures from the javascript html content.

IncludeFile "..\PBWebView2.pb"

EnableExplicit

;- APP_TAG
Structure APP_TAG
	window.i
	wvEnvironment.ICoreWebView2Environment
	wvController.ICoreWebView2Controller
	wvCore.ICoreWebView2
	pbHostObject.IDispatch
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
Declare.d addNum(a.d, b.d)
Declare.i addStr(a.i, b.i)

Procedure window_Proc(hwnd.i, msg.l, wparam.i, lparam.i)
	Select msg
		Case #WM_MOVE, #WM_MOVING
			wv2_Controller_On_WM_MOVE_MOVING(app\wvController)
	EndSelect
	
	ProcedureReturn #PB_ProcessPureBasicEvents
EndProcedure


Runtime Procedure.d addNum(a.d, b.d)
	ProcedureReturn a + b
EndProcedure

Runtime Procedure.i addStr(a.i, b.i)
	Protected.i ret
	
	ret = SysAllocString_(PeekS(a) + PeekS(b))
	SysFreeString_(a)
	SysFreeString_(b)
	
	ProcedureReturn ret 
EndProcedure

Procedure.s page1_Create()
	Protected.s page1
	
	page1 = "<!DOCTYPE html>" +
	"<html>" +
	"<body>" +
	
	"addNum() Procedure:</br>" + 
	"Param1 (number):" + ~"<input type=\"text\" spellcheck=\"false\" id=\"addNumP1\" value=\"10\"></br>" + 
	"Param2 (number):" + ~"<input type=\"text\" spellcheck=\"false\" id=\"addNumP2\" value=\"20\"></br>" + 
	~"<button type=\"button\" onclick=\"alert('addNum() Result: ' + purebasic.callRTProcNum('addNum', Number(document.getElementById('addNumP1').value), Number(document.getElementById('addNumP2').value)))\">Call PB addNum()</button>" +
	"</br>" + "</br>" +
	"addStr() Procedure:</br>" + 
	"Param1 (string):" + ~"<input type=\"text\" spellcheck=\"false\" id=\"addStrP1\" value=\"pure\"></br>" + 
	"Param2 (string):" + ~"<input type=\"text\" spellcheck=\"false\" id=\"addStrP2\" value=\"basic\"></br>" + 
	~"<button type=\"button\" onclick=\"alert('addStr() Result: ' + purebasic.callRTProcStr('addStr', document.getElementById('addStrP1').value, document.getElementById('addStrP2').value))\">Call PB addStr()</button>" +
	
	"</body>" +
	"</html>"
	
	ProcedureReturn page1
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
	Protected.VARIANT vPBObj
		
	If result = #S_OK
		controller\QueryInterface(?IID_ICoreWebView2Controller, @app\wvController)
		app\wvController\get_CoreWebView2(@app\wvCore)
		
		;Add purebasic object.
		vPBObj\vt = #VT_DISPATCH
		vPBObj\pdispVal = app\pbHostObject
		app\wvCore\AddHostObjectToScript("purebasic", @vPBObj)
		
		;Add JS Proxy to access directly from 'purebasic' global var instead of
		;window.chrome.webview.hostObjects.sync.purebasic
		app\wvCore\AddScriptToExecuteOnDocumentCreated(wv2_CreateJSHostObjectProxy("purebasic"), #Null)
		
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
	app\pbHostObject\Release()
	
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
	app\pbHostObject = wv2_PBObj_New()
	
	app\window = OpenWindow(#PB_Any, 10, 10, 600, 400, "PBWebView2 - Host Object", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_SizeGadget | #PB_Window_MaximizeGadget)
	SetWindowCallback(@window_Proc(), app\window)

	BindEvent(#PB_Event_CloseWindow, @window_Close())
	BindEvent(#PB_Event_SizeWindow, @window_Resize())
	
	CreateCoreWebView2EnvironmentWithOptions("", "", #Null, wv2_EventHandler_New(?IID_ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler, @wvEnvironment_Created()))
	
	Repeat
		ev = WaitWindowEvent()
		
	Until app\quit
EndProcedure

main()