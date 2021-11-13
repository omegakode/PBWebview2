;container.pb

IncludeFile "..\PBWebView2.pb"

EnableExplicit

;- APP_TAG
Structure APP_TAG
	window.i
	splitter.i
	cont1.i
	cont2.i
	listGd.i
	canvas.i
	wvEnvironment.ICoreWebView2Environment
	wvController.ICoreWebView2Controller
	wvCore.ICoreWebView2
	*eventNavigationCompleted.WV2_EVENT_HANDLER
	*eventNavigationSarting.WV2_EVENT_HANDLER
EndStructure
Global.APP_TAG app

;- DECLARES
Declare main()

Declare window_Close()
Declare window_Resize()
Declare wv_Resize()
Declare window_ProcessEvents(ev.l)

Declare wvEnvironment_Created(*this.WV2_EVENT_HANDLER, result.l, environment.ICoreWebView2Environment)	
Declare wvController_Created(*this.WV2_EVENT_HANDLER, result.l, controller.ICoreWebView2Controller)
Declare wv_NavigationCompleted(*this.WV2_EVENT_HANDLER, sender.ICoreWebView2, args.ICoreWebView2NavigationCompletedEventArgs)
Declare wv_NavigationStarting(*this.WV2_EVENT_HANDLER, sender.ICoreWebView2, args.ICoreWebView2NavigationStartingEventArgs)

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
		app\wvEnvironment\CreateCoreWebView2Controller(GadgetID(app\cont2), wv2_EventHandler_New(?IID_ICoreWebView2CreateCoreWebView2ControllerCompletedHandler, @wvController_Created()))

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
		
		app\eventNavigationSarting = wv2_EventHandler_New(?IID_ICoreWebView2NavigationStartingEventHandler, @wv_NavigationStarting())
		app\wvCore\add_NavigationStarting(app\eventNavigationSarting, #Null)
		
		window_Resize()
		wv_Resize()
		
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

Procedure wv_NavigationStarting(*this.WV2_EVENT_HANDLER, sender.ICoreWebView2, args.ICoreWebView2NavigationStartingEventArgs)
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
	
	If app\eventNavigationCompleted
		wv2_EventHandler_Release(app\eventNavigationCompleted)
	EndIf 
	
	If app\eventNavigationSarting
		wv2_EventHandler_Release(app\eventNavigationSarting)
	EndIf 
	
	ProcedureReturn #True ;Exit message loop.
EndProcedure

Procedure canvas_Draw()
	If StartDrawing(CanvasOutput(app\canvas))
    Circle(10, 10, 10, RGB(255, 0, 0))

  	StopDrawing()
  EndIf 
EndProcedure

Procedure window_Resize()		
	ResizeGadget(app\cont1, 0, 0, WindowWidth(app\window), WindowHeight(app\window))
EndProcedure

Procedure cont1_Resize()
	ResizeGadget(app\splitter, 0, 0, GadgetWidth(app\cont1), GadgetHeight(app\cont1))
EndProcedure

Procedure wv_Resize()
	Protected.RECT wvBounds

	wvBounds\left = DesktopScaledX(GadgetWidth(app\canvas))
	wvBounds\top = 0
	wvBounds\bottom = DesktopScaledY(GadgetHeight(app\cont2))
	wvBounds\right = DesktopScaledX(GadgetWidth(app\cont2))
	If app\wvController
		wv2_Controller_put_Bounds(app\wvController, @wvBounds)
	EndIf 
EndProcedure

Procedure cont2_Resize()

	ResizeGadget(app\canvas, 0, 0, #PB_Ignore, GadgetHeight(app\cont2))
	canvas_Draw()
	
	wv_Resize()
EndProcedure

Procedure window_ProcessEvents(ev.l)
	Select ev
		Case #PB_Event_CloseWindow : ProcedureReturn window_Close()
	EndSelect
	
	ProcedureReturn #False 
EndProcedure

Procedure main()
	Protected.l winWidth, winHeight, x
	
	If wv2_GetBrowserVersion("") = ""
		MessageRequester("Error", "MS Edge not found, install MS Edge runtime.")
		End 
	EndIf
	
	winWidth = 600
	winHeight = 400
	
	app\window = OpenWindow(#PB_Any, 10, 10, winWidth, winHeight, "PBWebView2 - Basic Browser Asynchronous Creation", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_SizeGadget | #PB_Window_MaximizeGadget)
	SetWindowCallback(@window_Proc(), app\window)
	
	app\cont1 = ContainerGadget(#PB_Any, 0, 0, WindowWidth(app\window), WindowHeight(app\window))
	BindGadgetEvent(app\cont1, @cont1_Resize(), #PB_EventType_Resize)
	app\listGd = ListViewGadget(#PB_Any, 0, 0, 0, 0)
	For x = 1 To 10
  	AddGadgetItem (app\listGd, -1, "Item" + Str(x))
  Next

	app\cont2 = ContainerGadget(#PB_Any, 0, 0, 0, 0)
	BindGadgetEvent(app\cont2, @cont2_Resize(), #PB_EventType_Resize)
	app\canvas = CanvasGadget(#PB_Any, 0, 0, 0, 0)
	CloseGadgetList()
	app\splitter = SplitterGadget(#PB_Any, 0, 0, 600, 400, app\listGd, app\cont2, #PB_Splitter_Separator   )
	CloseGadgetList()
	
	ResizeGadget(app\canvas, 0, 0, GadgetWidth(app\cont2) / 2, GadgetHeight(app\cont2))
	
	canvas_Draw()

	BindEvent(#PB_Event_SizeWindow, @window_Resize())
	CreateCoreWebView2EnvironmentWithOptions("", "", #Null, wv2_EventHandler_New(?IID_ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler, @wvEnvironment_Created()))

	Repeat
	Until window_ProcessEvents(WaitWindowEvent()) = #True 
EndProcedure

main()

