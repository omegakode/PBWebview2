;bootstrap_app.pb

IncludeFile "..\PBWebView2.pb"

EnableExplicit

;- Enum MENU_ID
Enumeration
	#MENU_ID_GET_CHECK1_STATE
	#MENU_ID_TOGGLE_CHECK1_STATE
	#MENU_ID_GET_PASSWORD
	#MENU_ID_SET_EMAIL
	#MENU_ID_ZOOM_IN
	#MENU_ID_ZOOM_OUT
	#MENU_ID_ZOOM_RESET
EndEnumeration

;- APP_TAG
Structure APP_TAG
	window.i
	menu.i
	envOptions.ICoreWebView2EnvironmentOptions
	
	wvEnvironment.ICoreWebView2Environment
	wvController.ICoreWebView2Controller
	wvCore.ICoreWebView2
	pbHostObject.IDispatch
	
	;Events
	*evWebResourceRequested.WV2_EVENT_HANDLER
	*eventNavigationCompleted.WV2_EVENT_HANDLER
	*evAccelKeyPressed.WV2_EVENT_HANDLER
	*evDevProtocol.WV2_EVENT_HANDLER

	;Resources
	page1.s
	stmBootstrap.IStream
	stmBootstrapCss.IStream
	stmJQuery.IStream
	stmPopper.IStream
EndStructure
Global.APP_TAG app

;- DECLARES
Declare main()

Declare app_Init()
Declare app_Free()

Declare window_Close()
Declare window_Resize()
Declare window_ProcessEvents(ev.l)
Declare window_Proc(hwnd.i, msg.l, wparam.i, lparam.i)

Declare menu_Create(winid.i)
Declare menu_GetCheck1State_Click()
Declare menu_ToggleCheck1State_Click()
Declare menu_GetPassword_Click()
Declare menu_SetEmail_Click()
Declare menu_ZoomIn_Click()
Declare menu_ZoomOut_Click()
Declare menu_ZoomReset_Click()

Declare wvEnvironment_Created(*this.WV2_EVENT_HANDLER, result.l, environment.ICoreWebView2Environment)	

Declare wvController_Created(*this.WV2_EVENT_HANDLER, result.l, controller.ICoreWebView2Controller)
Declare wvController_AccelKeyPressed(*this.WV2_EVENT_HANDLER, sender.ICoreWebView2Controller, args.ICoreWebView2AcceleratorKeyPressedEventArgs)

Declare wvCore_WebResourceRequested(*this.WV2_EVENT_HANDLER, sender.ICoreWebView2, args.ICoreWebView2WebResourceRequestedEventArgs)	
Declare wvCore_NavigationCompleted(*this.WV2_EVENT_HANDLER, sender.ICoreWebView2, args.ICoreWebView2NavigationCompletedEventArgs)

Declare.s page1_Create()

;-
;- HTML Events
Runtime Procedure signIn_Click()
	Debug "Sign in clicked"
EndProcedure

Runtime Procedure check_Change(id.i, state.i)
	Debug "Check change " + PeekS(id) + " state: " + state
	
	str_FreeBstr(id)
EndProcedure

Runtime Procedure switch_Change(id.i, state.i)
	Debug "Switch change " + PeekS(id) + " state: " + state
	
	str_FreeBstr(id)
EndProcedure

;- 
Procedure wvEnvironment_Created(*this.WV2_EVENT_HANDLER, result.l, environment.ICoreWebView2Environment)		
	If result = #S_OK
		environment\QueryInterface(?IID_ICoreWebView2Environment, @app\wvEnvironment)
		app\wvEnvironment\CreateCoreWebView2Controller(WindowID(app\window), wv2_EventHandler_New(?IID_ICoreWebView2CreateCoreWebView2ControllerCompletedHandler, @wvController_Created()))
		
		wv2_EventHandler_Release(*this)
			
	Else
		MessageRequester("Error", "Failed to create WebView2Environment.")
		End 
	EndIf 
EndProcedure

;-
Procedure wvController_Created(*this.WV2_EVENT_HANDLER, result.l, controller.ICoreWebView2Controller)
	Protected.VARIANT vPBObj
	Protected.ICoreWebView2Settings sett
	Protected.s file, currDir
		
	If result = #S_OK
		controller\QueryInterface(?IID_ICoreWebView2Controller, @app\wvController)
		app\wvController\get_CoreWebView2(@app\wvCore)
		
		;Controller Events
		app\wvController\add_AcceleratorKeyPressed(app\evAccelKeyPressed, #Null)
		
		;Settings
		app\wvCore\get_Settings(@sett)
		sett\put_AreDefaultContextMenusEnabled(#False)
		sett\put_IsStatusBarEnabled(#False)
		sett\put_AreDevToolsEnabled(#False)
		sett\Release()
		
		;Add purebasic object.
		vPBObj\vt = #VT_DISPATCH
		vPBObj\pdispVal = app\pbHostObject
		app\wvCore\AddHostObjectToScript("purebasic", @vPBObj)
		
		;Add JS Proxy to access directly from 'purebasic' global var.
		app\wvCore\AddScriptToExecuteOnDocumentCreated(wv2_CreateJSHostObjectProxy("purebasic"), #Null)
		
		;Core Events
		;Setup WebResourceRequested event, where reaources are handled.
		app\wvCore\AddWebResourceRequestedFilter("*", #COREWEBVIEW2_WEB_RESOURCE_CONTEXT_ALL)
		app\wvCore\add_WebResourceRequested(app\evWebResourceRequested, #Null)
		
		app\wvCore\add_NavigationCompleted(app\eventNavigationCompleted, #Null)

		window_Resize()
		
		app\wvCore\NavigateToString(app\page1)

		wv2_EventHandler_Release(*this)
		
	Else
		MessageRequester("Error", "Failed to create WebView2Controller.")
		End
	EndIf 
EndProcedure

Procedure wvController_AccelKeyPressed(*this.WV2_EVENT_HANDLER, sender.ICoreWebView2Controller, args.ICoreWebView2AcceleratorKeyPressedEventArgs)
	Protected.l keyEventKind, key
		
	;Disable webview2 accelerator keys.
	
	args\get_KeyEventKind(@keyEventKind)
	If keyEventKind = #COREWEBVIEW2_KEY_EVENT_KIND_KEY_DOWN Or keyEventKind = #COREWEBVIEW2_KEY_EVENT_KIND_SYSTEM_KEY_DOWN
		args\get_VirtualKey(@key)
		
		Select key
			;refresh, search box, nav
			Case #VK_F5, #VK_F3, #VK_F7 ;#VK_F12
				args\put_Handled(#True)
			
			;Print.
			Case #VK_P
				If key_IsDown(#VK_CONTROL)
					args\put_Handled(#True)
					
				Else
					args\put_Handled(#False)
				EndIf 

			Default
				args\put_Handled(#False)
		EndSelect
	EndIf 
EndProcedure 

;-
Procedure wvCore_NavigationCompleted(*this.WV2_EVENT_HANDLER, sender.ICoreWebView2, args.ICoreWebView2NavigationCompletedEventArgs)
	HideWindow(app\window, #False)
	app\wvController\put_IsVisible(#True)
	
EndProcedure

Procedure wvCore_WebResourceRequested(*this.WV2_EVENT_HANDLER, sender.ICoreWebView2, args.ICoreWebView2WebResourceRequestedEventArgs)	
	Protected.ICoreWebView2WebResourceRequest req
	Protected.ICoreWebView2WebResourceResponse resp
	Protected.s uri, contentType
	Protected.i uriBuf
	Protected.IStream respStream
	
	args\get_Request(@req)
	req\get_uri(@uriBuf)
	req\Release()
	
	If uriBuf
		uri = PeekS(uriBuf)
		
		Select GetFilePart(uri)
			Case "bootstrap.min.js"
				respStream = app\stmBootstrap
				contentType = "text/javascript"
				
			Case "bootstrap.min.css"
				respStream = app\stmBootstrapCss
				contentType = "text/css"
					
			Case "jquery-3.5.1.slim.min.js"
				respStream = app\stmJQuery
				contentType = "text/javascript"

			Case "popper.min.js"
				respStream = app\stmPopper
				contentType = "text/javascript"
		EndSelect
				
		If respStream
			app\wvEnvironment\CreateWebResourceResponse(respStream, 200, "OK", 
				"Content-Type: " + contentType + #CRLF$ + 
				"Content-Length: " + Str(stm_GetSize(respStream)) + #CRLF$ + #CRLF$, @resp)

			If resp
				args\put_Response(resp)
				resp\Release()
			EndIf 
		EndIf 
		
		str_FreeCoMemString(uriBuf)
	EndIf 
EndProcedure

;-
Procedure window_Resize()
	Protected.RECT wvBounds
		
	If app\wvController
		GetClientRect_(WindowID(app\window), @wvBounds)
		wv2_Controller_put_Bounds(app\wvController, @wvBounds)
	EndIf 
EndProcedure

Procedure window_Close()
	Protected.l processId
	Protected.s wvdir
	
	If app\wvCore
		app\wvCore\get_BrowserProcessId(@processId)
		app\wvCore\Release()
	EndIf 
	
	If app\wvController
		app\wvController\Close()
		app\wvController\Release()	
	EndIf 
	
	If app\pbHostObject : app\pbHostObject\Release() : EndIf 
	
	If app\stmBootstrap : app\stmBootstrap\Release() : EndIf
	If app\stmBootstrapCss : app\stmBootstrapCss\Release() : EndIf
	If app\stmJQuery : app\stmJQuery\Release() : EndIf 
	If app\stmPopper : app\stmPopper\Release() : EndIf 
	
;	Delete webview userdata folder
; 	wvdir = ProgramFilename() + ".WebView2"
; 	If wv2_DeleteUserDataFolder(wvdir, processId, 2000) = #False
; 		MessageRequester("Webview2", "Userdata folder " + wvdir + " could not be deleted.")
; 	EndIf 

	ProcedureReturn #True ;Exit message loop.
EndProcedure

Procedure window_Proc(hwnd.i, msg.l, wparam.i, lparam.i)
	Select msg
		;Required by webview2
		Case #WM_MOVE, #WM_MOVING
			wv2_Controller_On_WM_MOVE_MOVING(app\wvController)
	EndSelect
	
	ProcedureReturn #PB_ProcessPureBasicEvents
EndProcedure

Procedure window_ProcessEvents(ev.l)
	Select ev
		Case #PB_Event_Menu
			Select EventMenu()
				Case #MENU_ID_GET_CHECK1_STATE : menu_GetCheck1State_Click()
				
				Case #MENU_ID_TOGGLE_CHECK1_STATE : menu_ToggleCheck1State_Click()
				
				Case #MENU_ID_GET_PASSWORD : menu_GetPassword_Click()
				
				Case #MENU_ID_SET_EMAIL : menu_SetEmail_Click()
				
				Case #MENU_ID_ZOOM_IN : menu_ZoomIn_Click()
				
				Case #MENU_ID_ZOOM_OUT : menu_ZoomOut_Click()

				Case #MENU_ID_ZOOM_RESET : menu_ZoomReset_Click()
			EndSelect
			
		Case #PB_Event_CloseWindow : ProcedureReturn window_Close()
	EndSelect
	
	ProcedureReturn #False ;Kepp message loop running.
EndProcedure

;- 
Procedure menu_GetCheck1State_Click()
	Protected.s res, script
	
	;jquery
	script = "$('#gridCheck1').is(':checked')"

	res = wv2_Core_ExecuteScriptSync(app\wvCore, script, @window_ProcessEvents())
	
	Debug "Checkbox state: " + res
EndProcedure

Procedure menu_ToggleCheck1State_Click()
	Protected.s script
	
	;jquery
	script = "$('#gridCheck1').prop('checked', !$('#gridCheck1').prop('checked'))"

	app\wvCore\ExecuteScript(script, #Null)
EndProcedure

Procedure menu_GetPassword_Click()
	Protected.s script, pwd
	
	script = "document.getElementById('inputPassword3').value"
	
	;Result is returned as json object, strings are quoted.
	pwd = wv2_Core_ExecuteScriptSync(app\wvCore, script, @window_ProcessEvents())
	
	Debug json_GetString(pwd)
	
EndProcedure

Procedure menu_SetEmail_Click()
	Protected.s script
	
	script = ~"document.getElementById('inputEmail3').value = \"" +  Str(Random(10000)) + ~"@gmail.com\""
	
	app\wvCore\ExecuteScript(script, #Null)
EndProcedure

Procedure menu_ZoomIn_Click()
	Protected.d zf
	Protected.s ret
		
	app\wvController\get_ZoomFactor(@zf)
	app\wvController\put_ZoomFactor(zf + 0.1)
EndProcedure

Procedure menu_ZoomOut_Click()
	Protected.d zf
	
	app\wvController\get_ZoomFactor(@zf)
	app\wvController\put_ZoomFactor(zf - 0.1)
EndProcedure

Procedure menu_ZoomReset_Click()
	app\wvController\put_ZoomFactor(1)
EndProcedure

Procedure menu_Create(winid.i)
	Protected.i menu
	
	menu = CreateMenu(#PB_Any, winid)
	MenuTitle("Interact")
	MenuItem(#MENU_ID_GET_CHECK1_STATE, "Get Checkbox state")
	MenuItem(#MENU_ID_TOGGLE_CHECK1_STATE, "Toggle Checkbox state")
	MenuItem(#MENU_ID_GET_PASSWORD, "Get password")
	MenuItem(#MENU_ID_SET_EMAIL, "Set random email")

	MenuTitle("Zoom")
	MenuItem(#MENU_ID_ZOOM_IN, "Zoom in")
	MenuItem(#MENU_ID_ZOOM_OUT, "Zoom out")
	MenuItem(#MENU_ID_ZOOM_RESET, "Reset zoom")
		
	ProcedureReturn menu
EndProcedure

;-
Procedure app_Init()
	app\page1 = page1_Create()
	app\pbHostObject = wv2_PBObj_New()
	
	;Create resource streams
	app\stmBootstrap = stm_CreateStream(?bootStrapStart, ?bootStrapEnd - ?bootStrapStart)
	app\stmBootstrapCss = stm_CreateStream(?bootStrapCssStart, ?bootStrapCssEnd - ?bootStrapCssStart)
	app\stmJQuery = stm_CreateStream(?jQueryStart, ?jQueryEnd - ?jQueryStart)
	app\stmPopper = stm_CreateStream(?popperStart, ?popperEnd - ?popperStart)
	
	;Events
	app\evWebResourceRequested = wv2_EventHandler_New(?IID_ICoreWebView2WebResourceRequestedEventHandler, @wvCore_WebResourceRequested())
	app\eventNavigationCompleted = wv2_EventHandler_New(?IID_ICoreWebView2NavigationCompletedEventHandler, @wvCore_NavigationCompleted())
	app\evAccelKeyPressed = wv2_EventHandler_New(?IID_ICoreWebView2AcceleratorKeyPressedEventHandler, @wvController_AccelKeyPressed())
EndProcedure

Procedure app_Free()
	If app\wvEnvironment : app\wvEnvironment\Release() : EndIf 
	If app\envOptions : app\envOptions\Release() : EndIf 
EndProcedure

;-
Procedure.s page1_Create()	
	ProcedureReturn PeekS(?page1Start, -1, #PB_UTF8)
EndProcedure

Procedure main()		
	If wv2_GetBrowserVersion("") = ""
		MessageRequester("Error", "MS Edge not found, install MS Edge Runtime.")
		End 
	EndIf
	
	app_Init()
	
	app\window = OpenWindow(#PB_Any, 10, 10, 700, 500, "PBWebView2 - Bootstrap App", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_SizeGadget | #PB_Window_MaximizeGadget | #PB_Window_Invisible)
	SetWindowCallback(@window_Proc(), app\window)
	
	app\menu = menu_Create(WindowID(app\window))
	
	BindEvent(#PB_Event_SizeWindow, @window_Resize())
	
	app\envOptions = wv2_EnvironmentOptions_New()
	;This disables CORS errors
	app\envOptions\put_AdditionalBrowserArguments("--disable-web-security")
	CreateCoreWebView2EnvironmentWithOptions("", "", 0, wv2_EventHandler_New(?IID_ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler, @wvEnvironment_Created()))
	
	Repeat		
	Until window_ProcessEvents(WaitWindowEvent()) = #True
	
	app_Free()
EndProcedure

main()

;- DATA
DataSection
	page1Start:
	IncludeBinary "bootstrap.html"
	Data.b 0, 0
	
	bootStrapStart:
	IncludeBinary "bootstrap-4.5.1\js\bootstrap.min.js"
	bootStrapEnd:
	
	bootStrapCssStart:
	IncludeBinary "bootstrap-4.5.1\css\bootstrap.min.css"
	bootStrapCssEnd:
	
	jQueryStart:
	IncludeBinary "jquery-3.5.1\jquery-3.5.1.slim.min.js"
	jQueryEnd:
	
	popperStart:
	IncludeBinary "popper\popper.min.js"
	popperEnd:
EndDataSection 