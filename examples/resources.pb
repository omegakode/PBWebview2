;resources.pb

;Windows resources example.
;You must add the file resources.rc as a resource in Compilers Options -> Resources

XIncludeFile "..\PBWebView2.pb"

EnableExplicit

;- APP_TAG
Structure APP_TAG
	window.i
	wvEnvironment.ICoreWebView2Environment
	wvController.ICoreWebView2Controller
	wvCore.ICoreWebView2
	*evWebResourceRequested.WV2_EVENT_HANDLER
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
Declare wv_WebResourceRequested(*this.WV2_EVENT_HANDLER, sender.ICoreWebView2, args.ICoreWebView2WebResourceRequestedEventArgs)
Declare.s page1_Create()

Procedure window_Proc(hwnd.i, msg.l, wparam.i, lparam.i)
	Select msg
		Case #WM_MOVE, #WM_MOVING
			wv2_Controller_On_WM_MOVE_MOVING(app\wvController)
	EndSelect
	
	ProcedureReturn #PB_ProcessPureBasicEvents
EndProcedure

Procedure.s page1_Create()
	Protected.s page
	
	page = "<!DOCTYPE html><html><body>" +
	"<h3>All content is loaded directly from the executable, without copying to disk." +
	~"<span style=\"color:red\">You must add the file 'resources.rc' as a resource in PB IDE Compilers Options -> Resources " +
	"to see the image loaded.</span></h3>" +
	~"<img src=\"myapp://resources/img1.png\" width=\"\" height=\"\">" +
	"</body></html>"

	ProcedureReturn page
EndProcedure

Procedure wv_WebResourceRequested(*this.WV2_EVENT_HANDLER, sender.ICoreWebView2, args.ICoreWebView2WebResourceRequestedEventArgs)	
	Protected.ICoreWebView2WebResourceRequest req
	Protected.ICoreWebView2WebResourceResponse resp
	Protected.IStream img1Stream
	Protected.s uri, respHeaders
	Protected.i uriBuf
	
	args\get_Request(@req)
	req\get_uri(@uriBuf)
	
	If uriBuf
		uri = PeekS(uriBuf)
	
		Select GetFilePart(GetURLPart(uri, #PB_URL_Path))
			Case "img1.png"
				img1Stream = res_CreateResourceStream(1, #RT_RCDATA)
				If img1Stream
					respHeaders =	"Content-Type: image/jpeg" + #CRLF$ +
												"Content-Length: " + Str(stm_GetSize(img1Stream)) + #CRLF$ + #CRLF$
					
					app\wvEnvironment\CreateWebResourceResponse(img1Stream, 200, "OK", respHeaders, @resp)
					
					If resp
						args\put_Response(resp)
						resp\Release()
					EndIf 
				EndIf 
		EndSelect
		
		str_FreeCoMemString(uriBuf)
	EndIf 
EndProcedure

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

Procedure wvController_Created(*this.WV2_EVENT_HANDLER, result.l, controller.ICoreWebView2Controller)
	Protected.q evToken
	
	If result = #S_OK
		controller\QueryInterface(?IID_ICoreWebView2Controller, @app\wvController)
		app\wvController\get_CoreWebView2(@app\wvCore)
		
		;Setup WebResourceRequested event, where reaources are handled.
		app\wvCore\AddWebResourceRequestedFilter("*", #COREWEBVIEW2_WEB_RESOURCE_CONTEXT_ALL)
		app\wvCore\add_WebResourceRequested(app\evWebResourceRequested, @evToken)
		
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
	wv2_EventHandler_Release(app\evWebResourceRequested)
	
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
	app\evWebResourceRequested = wv2_EventHandler_New(?IID_ICoreWebView2WebResourceRequestedEventHandler, @wv_WebResourceRequested())
	
	app\window = OpenWindow(#PB_Any, 10, 10, 600, 400, "PBWebView2 - Resources", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_SizeGadget | #PB_Window_MaximizeGadget)
	SetWindowCallback(@window_Proc(), app\window)

	BindEvent(#PB_Event_CloseWindow, @window_Close())
	BindEvent(#PB_Event_SizeWindow, @window_Resize())
	
	CreateCoreWebView2EnvironmentWithOptions("", "", #Null, wv2_EventHandler_New(?IID_ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler, @wvEnvironment_Created()))
	
	Repeat
		ev = WaitWindowEvent()
		
	Until app\quit
	
	If app\wvEnvironment
		app\wvEnvironment\Release()
	EndIf 
EndProcedure

main()

