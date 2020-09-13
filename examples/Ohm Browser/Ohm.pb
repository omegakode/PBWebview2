;browser_multitab.pb

XIncludeFile "..\..\PBWebView2.pb"

XIncludeFile "..\..\windows\commctrl.pbi"
XIncludeFile "..\..\windows\windef.pbi"

XIncludeFile "button.pb"

EnableExplicit

#APP_NAME = "Ohm"
#APP_VERSION = "0.1"

;- Enum MENU_ID
Enumeration 1
	#MENU_ID_NEW_TAB
	#MENU_ID_CLOSE_TAB
	#MENU_ID_NEXT_TAB
	#MENU_ID_PREVIOUS_TAB
	#MENU_ID_QUIT
	
	#MENU_ID_GO_BACK
	#MENU_ID_GO_FORWARD
	#MENU_ID_GO_HOME
	#MENU_ID_RELOAD
	#MENU_ID_STOP
	
	#MENU_ID_ZOOM_IN
	#MENU_ID_ZOOM_OUT
	#MENU_ID_RESET_ZOOM
	#MENU_ID_TOGGLE_FULLSCREEN
	
	#MENU_ID_GET_VERSION
	
	#MENU_ID_URL_SELECT
	#MENU_ID_URL_SET_HTTP
	#MENU_ID_SHOW_MENU
EndEnumeration

;- Enum TIMER_ID
Enumeration 1
	#TIMER_ID_FULLSCREEN
EndEnumeration

;- BROWSER
Structure BROWSER
	controller.ICoreWebView2Controller
	core.ICoreWebView2
	
	;Events
	;Core
	*evNavigationCompleted.WV2_EVENT_HANDLER
	*evNewWindowRequested.WV2_EVENT_HANDLER
	*evContainsFullScreenElementChanged.WV2_EVENT_HANDLER
	*evHistoryChanged.WV2_EVENT_HANDLER
	;Controller
	*evAccelKeyPressed.WV2_EVENT_HANDLER

	createParam.i
EndStructure

;- APP_TAG
Structure APP_TAG
	window.i
	windowIsFullscreen.b
	windowOldStyle.i
	windowOldPlacement.WINDOWPLACEMENT
	
	menu.i
	
	toolBar.i
	toolBarHeight.i
	
	btnSize.l
	btnNewTab.i
	btnMenu.i
	btnGoBack.i
	btnGoForward.i
	btnGoHome.i
	btnReload.i
	
	tab.i
	tabOldProc.i
	tabTip.i
	tabTipBuffer.i
	tabHeight.l
	tabCurrent.l
	tabMenu.i

	url.i
	urlOldProc.i
	urlHeight.l
	
	List browsers.BROWSER()
	
	env.ICoreWebView2Environment
EndStructure
Global.APP_TAG app

;- DECLARES
Declare browser_New(env.ICoreWebView2Environment, tanIndex.l)
Declare browser_GetCurrent()
Declare browser_GoBack(*browser.BROWSER)
Declare browser_GoForward(*browser.BROWSER)
Declare browser_ZoomIn(*browser.BROWSER)
Declare browser_ZoomOut(*browser.BROWSER)
Declare browser_GoHome(*browser.BROWSER)
Declare browser_Free(*browser.BROWSER)
Declare browser_GetTab(*browser.BROWSER)
Declare browser_Reload(*browser.BROWSER)

Declare window_Resize()
Declare window_SetFullScreen(fs.b)
Declare window_ToggleFullscreen()

Declare toolBar_HideIfFullscreen()
Declare toolBar_UpdateNavButtons(*browser.BROWSER)

Declare menu_Show()

Declare url_SelectAll()

Declare core_NavigationCompleted(*this.WV2_EVENT_HANDLER, sender.ICoreWebView2, args.ICoreWebView2NavigationCompletedEventArgs)
Declare core_NewWindowRequested(*this.WV2_EVENT_HANDLER, sender.ICoreWebView2, args.ICoreWebView2NewWindowRequestedEventArgs)
Declare core_ContainsFullScreenElementChanged(*this.WV2_EVENT_HANDLER, sender.ICoreWebView2, args.IUnknown)
Declare core_HistoryChanged(*this.WV2_EVENT_HANDLER, sender.ICoreWebView2, args.IUnknown)

Macro browser_Get(tabIndex)
	GetGadgetItemData(app\tab, tabIndex)
EndMacro

;-
Macro gadget_Enable(gd, enable)
	DisableGadget(gd, Bool(Not(enable)))
EndMacro

;-
Macro tab_DeleteItem(item)
 SendMessage_(GadgetID(app\tab), #TCM_DELETEITEM, item, 0)
EndMacro

Macro tab_GetSelected()
	GetGadgetState(app\tab)
EndMacro

Procedure tab_New()
	Protected.l tabIndex
	
	OpenGadgetList(app\tab)
	AddGadgetItem(app\tab, -1, "New Tab")
	CloseGadgetList()
	tabIndex = CountGadgetItems(app\tab) - 1
	app\tabCurrent = tabIndex
	browser_New(app\env, tabIndex)
EndProcedure

Procedure tab_Select(index.l)
	Protected.BROWSER *currBrowser, *newBrowser

	*currBrowser = browser_GetCurrent()
	*newBrowser = browser_Get(index)
	
	If *currBrowser
		If *currBrowser\controller
			*currBrowser\controller\put_IsVisible(#False)
		EndIf 
	EndIf
	
	If *newBrowser
		If *newBrowser\controller
			*newBrowser\controller\put_IsVisible(#True)
		EndIf 
	EndIf
	
	SetGadgetState(app\tab, index)
	app\tabCurrent = index
	
	toolBar_UpdateNavButtons(browser_GetCurrent())
	
	window_Resize()
EndProcedure

Procedure tab_Changed()
	Protected.BROWSER *currBrowser, *newBrowser
		
	*currBrowser = browser_Get(app\tabCurrent)
	*newBrowser = browser_Get(GetGadgetState(app\tab))
	
	If *currBrowser
		If *currBrowser\controller : *currBrowser\controller\put_IsVisible(#False) : EndIf 
	EndIf
	
	If *newBrowser
		If *newBrowser\controller : *newBrowser\controller\put_IsVisible(#True) : EndIf 
	EndIf
	
	app\tabCurrent = GetGadgetState(app\tab)
	
	toolBar_UpdateNavButtons(browser_GetCurrent())
	
	window_Resize()
	
	toolBar_HideIfFullscreen()
EndProcedure

Procedure tab_SelectNext(currentTab.l)
	Protected.l tabCount, nextTab
	
	tabCount = CountGadgetItems(app\tab)
	If tabCount <= 1 : ProcedureReturn : EndIf
	
	nextTab = currentTab + 1
	If nextTab = tabCount
		nextTab = 0
	EndIf
	
	tab_Select(nextTab)
EndProcedure

Procedure tab_SelectPrevious(currentTab.l)
	Protected.l tabCount, prevTab
	
	tabCount = CountGadgetItems(app\tab)
	If tabCount <= 1 : ProcedureReturn : EndIf
	
	prevTab = currentTab - 1
	If prevTab < 0
		prevTab = tabCount - 1
	EndIf	
	
	tab_Select(prevTab)
EndProcedure

Procedure tab_Close(item.l)
	Protected.l tabCount
	Protected.BROWSER *browser
	
	If item = -1 : ProcedureReturn : EndIf
	
	tabCount = CountGadgetItems(app\tab)
	If tabCount = 1 ;Close app
		PostEvent(#PB_Event_CloseWindow, app\window, 0)
	EndIf 
	
	*browser = browser_Get(item)
	
	;Update selected tab
	If item = tab_GetSelected()
		If item = tabCount - 1 ;is last
			tab_SelectPrevious(item)
			
		Else
			tab_SelectNext(item)
		EndIf 
	EndIf 
	
	tab_DeleteItem(item)
	browser_Free(*browser)
EndProcedure

Procedure tab_On_RBUTTONDOWN(hwnd.i, msg.l, wparam.i, lparam.i)
	Protected.l cmd, tabIndex
	Protected.POINT pt
	Protected.TCHITTESTINFO tcht

	pt\x = LOWORD(lparam)
	pt\y = HIWORD(lparam)
	
	tcht\pt\x = pt\x
	tcht\pt\y = pt\y
	tabIndex = SendMessage_(hwnd, #TCM_HITTEST, 0, @tcht)
	If tabIndex <> -1
		ClientToScreen_(hwnd, @pt)
		
		cmd = TrackPopupMenu_(MenuID(app\tabMenu), #TPM_LEFTALIGN | #TPM_TOPALIGN | #TPM_RETURNCMD | #TPM_LEFTBUTTON | #TPM_NONOTIFY, pt\x, pt\y, 0, WindowID(app\window), #Null)
		Select cmd
			Case #MENU_ID_CLOSE_TAB : tab_Close(tabIndex)
		EndSelect
	EndIf 
EndProcedure

Procedure tab_Proc(hwnd.i, msg.l, wparam.i, lparam.i)
	Select msg
		Case #WM_RBUTTONDOWN : ProcedureReturn tab_On_RBUTTONDOWN(hwnd.i, msg.l, wparam.i, lparam.i)
		
		Default : ProcedureReturn CallWindowProc_(app\tabOldProc, hwnd, msg, wparam, lparam)
	EndSelect
EndProcedure

;-
Procedure tabMenu_Create()
	Protected.i men
	
	men = CreatePopupMenu(#PB_Any)
	MenuItem(#MENU_ID_CLOSE_TAB, "Close tab")
	
	ProcedureReturn men
EndProcedure

;-
Procedure tabTip_New(hwParent.i, hwPanel.i)
	Protected.i hwTip
	Protected.TOOLINFO ti
	
	hwTip = CreateWindowEx_(#Null, #TOOLTIPS_CLASS, #Null, 
												#WS_POPUP | #TTS_NOPREFIX | #TTS_ALWAYSTIP, 
												#CW_USEDEFAULT, #CW_USEDEFAULT, #CW_USEDEFAULT, #CW_USEDEFAULT, 
												hwParent, #Null, GetModuleHandle_(0), #Null)

	SetWindowPos_(hwTip, #HWND_TOPMOST, 0, 0, 0, 0, #SWP_NOMOVE | #SWP_NOSIZE | #SWP_NOACTIVATE)
	
	ti\cbSize = SizeOf(TOOLINFO)
	ti\hWnd = hwParent
	ti\uFlags = #TTF_IDISHWND | #TTF_SUBCLASS
	ti\uId = hwPanel
	ti\lpszText = #LPSTR_TEXTCALLBACK
	
	SendMessage_(hwTip, #TTM_ADDTOOL, 0, @ti)

	SendMessage_(hwPanel, #TCM_SETTOOLTIPS, hwTip, 0)

	ProcedureReturn hwTip
EndProcedure

Procedure tabTip_On_TTN_GETDISPINFO(hwnd.i, msg.l, wparam.i, *ttdi.NMTTDISPINFO)
	Protected.l tabIndex
	Protected.TCHITTESTINFO tcht
	Protected.BROWSER *browser
	Protected.i title, tipByteLen
	
	GetCursorPos_(@tcht\pt)
	ScreenToClient_(GadgetID(app\tab), @tcht\pt)
	tabIndex = SendMessage_(GadgetID(app\tab), #TCM_HITTEST, 0, @tcht)
	If tabIndex <> -1
		*browser = browser_Get(tabIndex)
		If *browser And *browser\core
			*browser\core\get_DocumentTitle(@title)
			If title
				tipByteLen = (MemoryStringLength(title) + 1) * SizeOf(Character)
				If MemorySize(app\tabTipBuffer) <> tipByteLen
					app\tabTipBuffer = ReAllocateMemory(app\tabTipBuffer, tipByteLen)
					CopyMemory(title, app\tabTipBuffer, tipByteLen)
				EndIf 
				
				*ttdi\lpszText = app\tabTipBuffer

			EndIf 
		EndIf 
	EndIf 
	
	ProcedureReturn #PB_ProcessPureBasicEvents
EndProcedure

;-
Procedure toolBar_Show(show.b)
	If show
		HideGadget(app\toolBar, #False)

	Else
		HideGadget(app\toolBar, #True)
	EndIf 
EndProcedure

Procedure toolBar_HideIfFullscreen()
	If app\windowIsFullscreen
		toolBar_Show(#False)
	EndIf 
EndProcedure

Procedure toolBar_UpdateNavButtons(*browser.BROWSER)
	Protected.l canGoBack, canGoForward
	
	If *browser And *browser\core
		*browser\core\get_CanGoBack(@canGoBack)
		gadget_Enable(app\btnGoBack, canGoBack)
		btn_Draw(app\btnGoBack)
		
		*browser\core\get_CanGoForward(@canGoForward)
		gadget_Enable(app\btnGoForward, canGoForward)
		btn_Draw(app\btnGoForward)
	EndIf 
EndProcedure

;-
Procedure btn_OnLeftClickOrSpace(btn.i)
	Select btn
		Case app\btnNewTab : tab_New()
		Case app\btnGoBack : browser_GoBack(browser_GetCurrent())
		Case app\btnGoForward : browser_GoForward(browser_GetCurrent())
		Case app\btnReload : browser_Reload(browser_GetCurrent())
		Case app\btnGoHome : browser_GoHome(browser_GetCurrent())
		Case app\btnMenu : menu_Show()
	EndSelect
EndProcedure

Procedure btn_DrawBackground(*bd.BUTTON_DATA)
	Protected.l bColor
	
	If enum_HasFlag(*bd\state, #BUTTON_STATE_PUSHED)
		bColor = GetSysColor_(#COLOR_3DSHADOW)

	ElseIf enum_HasFlag(*bd\state, #BUTTON_STATE_HIGHLIGHTED)
		bColor = GetSysColor_(#COLOR_3DLIGHT)
		
	Else
		bColor = GetSysColor_(#COLOR_3DFACE)
	EndIf
	
	VectorSourceColor(RGBA(Red(bColor), Green(bColor), Blue(bColor), 255))
	FillVectorOutput()
EndProcedure

Procedure btn_DrawFocus(btn.i, size.l, color.l)
	Protected.i w
	
	If GetActiveGadget() = btn
		w = Int(size / 6.0) - (size % 3)
		VectorSourceColor(color)
		AddPathBox(0, 0, VectorOutputWidth(), VectorOutputHeight())
		StrokePath(w)
	EndIf 
EndProcedure

Procedure btn_GetForeColor(btn.i)
	Protected.l foreColor, sysGrayedColor
	
	If IsWindowEnabled_(GadgetID(btn))
		foreColor = RGBA(0, 0, 0, 255)
		
	Else
		sysGrayedColor = GetSysColor_(#COLOR_GRAYTEXT)
		foreColor = RGBA(Red(sysGrayedColor), Green(sysGrayedColor), Blue(sysGrayedColor), 255)
	EndIf 
	
	ProcedureReturn foreColor
EndProcedure

Procedure btnNewTab_Callback(btn.i, msg.l)
	Protected.BUTTON_DATA *bd
	Protected.i w, size
	Protected.d voWidth, voHeight, half
	Protected.l foreColor
	
	*bd = btn_GetData(btn)
	If *bd = 0 : ProcedureReturn : EndIf
	
	Select msg
		Case #BUTTON_MSG_DRAW
			StartVectorDrawing(CanvasVectorOutput(btn))
			voWidth = VectorOutputWidth()
			voHeight = VectorOutputHeight()
			
			size = DesktopScaledX(GadgetWidth(btn))
			half = size / 2.0
	    w = Int(size / 6.0) - (size % 3)
	    
	    foreColor = btn_GetForeColor(btn)
	
			;Background
			btn_DrawBackground(*bd)
			
			;Focus
			If GetActiveGadget() = btn
				btn_DrawFocus(btn, size, foreColor)
			EndIf 
	
			;Plus
			drw_DrawPlus(half, half, half / 2, w, foreColor)
			
			StopVectorDrawing()
	EndSelect
EndProcedure

Procedure btnMenu_CallBack(btn.i, msg.l)
	Protected.BUTTON_DATA *bd
	Protected.l foreColor
	Protected.d voWidth, voHeight, half, h, p
	Protected.i w, size

	*bd = btn_GetData(btn)
	If *bd = 0 : ProcedureReturn : EndIf
	
	Select msg
		Case #BUTTON_MSG_DRAW
			StartVectorDrawing(CanvasVectorOutput(btn))
			voWidth = VectorOutputWidth()
			voHeight = VectorOutputHeight()
			
			size = DesktopScaledX(GadgetWidth(btn))
			half = size / 2.0
	    w = Int(size / 6.0) - (size % 3)
			
			;Background
			btn_DrawBackground(*bd)
			
			foreColor = btn_GetForeColor(btn)

			;Focus
			If GetActiveGadget() = btn
				btn_DrawFocus(btn, size, foreColor)
			EndIf 
			
			;Options
			drw_ZoomOutCoordinates(0.8, size)

			h = size / 2
			p = size / 32
			VectorSourceColor(foreColor)
			AddPathBox(5*p, p, 5*p, 5*p)
			FillPath()
			MovePathCursor(12*p, 4*p)
			AddPathLine(25*p, 4*p)
			StrokePath(p)
			AddPathBox(5*p, 13*p, 5*p, 5*p)
			FillPath()
			MovePathCursor(12*p, 16*p)
			AddPathLine(25*p, 16*p)
			StrokePath(p)
			AddPathBox(5*p, 25*p, 5*p, 5*p)
			FillPath()
			MovePathCursor(12*p, 27*p)
			AddPathLine(25*p, 27*p)
			StrokePath(p)
			
			StopVectorDrawing()
	EndSelect
EndProcedure

Procedure btnGoBack_CallBack(btn.i, msg.l)
	Protected.BUTTON_DATA *bd
	Protected.i size
	Protected.l foreColor
	
	*bd = btn_GetData(btn)
	If *bd = 0 : ProcedureReturn : EndIf
	
	Select msg
		Case #BUTTON_MSG_DRAW
			StartVectorDrawing(CanvasVectorOutput(btn))			
			size = DesktopScaledX(GadgetWidth(btn))

			;Background
			btn_DrawBackground(*bd)
			
			foreColor = btn_GetForeColor(btn)

			;Focus
			If GetActiveGadget() = btn
				btn_DrawFocus(btn, size, foreColor)
			EndIf 
			
			;Arrow
			drw_ZoomOutCoordinates(0.8, size)
			drw_DrawArrow(size, -90, foreColor)
			
			StopVectorDrawing()
	EndSelect
EndProcedure

Procedure btnGoForward_CallBack(btn.i, msg.l)
	Protected.BUTTON_DATA *bd
	Protected.i size
	Protected.l foreColor
	
	*bd = btn_GetData(btn)
	If *bd = 0 : ProcedureReturn : EndIf
	
	Select msg
		Case #BUTTON_MSG_DRAW
			StartVectorDrawing(CanvasVectorOutput(btn))			
			size = DesktopScaledX(GadgetWidth(btn))

			;Background
			btn_DrawBackground(*bd)
			
	    foreColor = btn_GetForeColor(btn)
			
			;Focus
			If GetActiveGadget() = btn
				btn_DrawFocus(btn, size, foreColor)
			EndIf 
			
			;Arrow
			drw_ZoomOutCoordinates(0.8, size)
			drw_DrawArrow(size, 90, foreColor)
			
			StopVectorDrawing()
	EndSelect
EndProcedure

Procedure btnGoHome_CallBack(btn.i, msg.l)
	Protected.BUTTON_DATA *bd
	Protected.i size
	Protected.l foreColor
	Protected.d w.d, p.d

	*bd = btn_GetData(btn)
	If *bd = 0 : ProcedureReturn : EndIf
	
	Select msg
		Case #BUTTON_MSG_DRAW
			StartVectorDrawing(CanvasVectorOutput(btn))			
			size = DesktopScaledX(GadgetWidth(btn))

			;Background
			btn_DrawBackground(*bd)
			
	    foreColor = btn_GetForeColor(btn)

			;Focus
			If GetActiveGadget() = btn
				btn_DrawFocus(btn, size, foreColor)
			EndIf 
			
			;Home
			w = size / 8
			p = size / 32
      
      VectorSourceColor(foreColor)
      	
			MovePathCursor(4*w, 2*p)
			AddPathLine(w, 4*w+2*p)
			AddPathLine(2*w, 4*w+2*p)
			AddPathLine(2*w, 7*w+2*p)
			AddPathLine(6*w, 7*w+2*p)
			AddPathLine(6*w, 4*w+2*p)
			AddPathLine(7*w, 4*w+2*p)
			ClosePath()
			
			MovePathCursor(3*w, 4*w)
			AddPathLine(3*w, 6*w)
			MovePathCursor(3*w, 5*w)
			AddPathLine(5*w, 5*w)
			MovePathCursor(5*w, 4*w)
			AddPathLine(5*w, 6*w)
			StrokePath(p*2)

			StopVectorDrawing()
	EndSelect
EndProcedure

Procedure btnReload_CallBack(btn.i, msg.l)
	Protected.BUTTON_DATA *bd
	Protected.i size
	Protected.d hw, half, third
	Protected.l foreColor

	*bd = btn_GetData(btn)
	If *bd = 0 : ProcedureReturn : EndIf
	
	Select msg
		Case #BUTTON_MSG_DRAW
			StartVectorDrawing(CanvasVectorOutput(btn))			
			size = DesktopScaledX(GadgetWidth(btn))
						
			;Background
			btn_DrawBackground(*bd)
			
	    foreColor = btn_GetForeColor(btn)
			
			;Focus
			If GetActiveGadget() = btn
				btn_DrawFocus(btn, size, foreColor)
			EndIf 
			
			;Reload
			drw_ZoomOutCoordinates(0.8, size)
			
			hw = size / 12.0
			half = size / 2.0
			third = size / 3.0
			
			drw_DrawRefreshArrow(size, hw, half, third, foreColor)
			RotateCoordinates(half, half, 180.0)
			drw_DrawRefreshArrow(size, hw, half, third, foreColor)
         
			StopVectorDrawing()
	EndSelect
EndProcedure

;-
Procedure controller_AccelKeyPressed(*this.WV2_EVENT_HANDLER, sender.ICoreWebView2Controller, args.ICoreWebView2AcceleratorKeyPressedEventArgs)
	Protected.l keyEventKind, key, handled
	Protected.b showMenu
	
	LockMutex(*this\mutex)
	args\get_KeyEventKind(@keyEventKind)

	handled = #False
	
	If keyEventKind = #COREWEBVIEW2_KEY_EVENT_KIND_KEY_DOWN Or keyEventKind = #COREWEBVIEW2_KEY_EVENT_KIND_SYSTEM_KEY_DOWN
		args\get_VirtualKey(@key)
		
		Select key
			Case #VK_TAB
				If key_IsDown(#VK_SHIFT) And key_IsDown(#VK_CONTROL)
					tab_SelectPrevious(tab_GetSelected())
					handled = #True
					
				ElseIf key_IsDown(#VK_CONTROL)
					tab_SelectNext(tab_GetSelected())
					handled = #True
				EndIf 
				
			Case #VK_T
				If key_IsDown(#VK_CONTROL)
					tab_New()
					handled = #True
				EndIf 
				
			Case #VK_ADD
				If key_IsDown(#VK_CONTROL)
					browser_ZoomIn(browser_GetCurrent())
					handled = #True
				EndIf 
				
			Case #VK_SUBTRACT
				If key_IsDown(#VK_CONTROL)
					browser_ZoomOut(browser_GetCurrent())
					handled = #True
				EndIf 
				
			Case #VK_HOME
				If key_IsDown(#VK_MENU)
					browser_GoHome(browser_GetCurrent())
					handled = #True
				EndIf 
				
			Case #VK_W
				If key_IsDown(#VK_CONTROL)
					tab_Close(tab_GetSelected())
					handled = #True
				EndIf 
				
			Case #VK_L
				If key_IsDown(#VK_CONTROL)
					SetActiveGadget(app\url)
					url_SelectAll()
					handled = #True
				EndIf 
				
			Case #VK_F11
				window_ToggleFullscreen()
				handled = #True

			Case #VK_M
				If key_IsDown(#VK_CONTROL)
					menu_Show()
					handled = #True
				EndIf 
		EndSelect
	EndIf 
	
	args\put_Handled(handled)
	
	UnlockMutex(*this\mutex)
EndProcedure

Procedure controller_Created(*this.WV2_EVENT_HANDLER, result.l, controller.ICoreWebView2Controller)
	Protected.BROWSER *browser
	
	LockMutex(*this\mutex)
	*browser = *this\context
	
	controller\QueryInterface(?IID_ICoreWebView2Controller, @*browser\controller)
	*browser\controller\get_CoreWebView2(@*browser\core)
	SetGadgetItemData(app\tab, *browser\createParam, *browser)
	
	;Events
	;Core
	*browser\evNavigationCompleted = wv2_EventHandler_New(?IID_ICoreWebView2NavigationCompletedEventHandler, @core_NavigationCompleted(), *browser)
	*browser\core\add_NavigationCompleted(*browser\evNavigationCompleted, #Null)
	*browser\evNewWindowRequested = wv2_EventHandler_New(?IID_ICoreWebView2NewWindowRequestedEventHandler, @core_NewWindowRequested(), *browser)
	*browser\core\add_NewWindowRequested(*browser\evNewWindowRequested, #Null)
	*browser\evContainsFullScreenElementChanged = wv2_EventHandler_New(?IID_ICoreWebView2ContainsFullScreenElementChangedEventHandler, @core_ContainsFullScreenElementChanged(), *browser)
	*browser\core\add_ContainsFullScreenElementChanged(*browser\evContainsFullScreenElementChanged, #Null)
	*browser\evHistoryChanged = wv2_EventHandler_New(?IID_ICoreWebView2HistoryChangedEventHandler, @core_HistoryChanged(), *browser)
	*browser\core\add_HistoryChanged(*browser\evHistoryChanged, #Null)
	;Controller
	*browser\evAccelKeyPressed = wv2_EventHandler_New(?IID_ICoreWebView2AcceleratorKeyPressedEventHandler, @controller_AccelKeyPressed(), *browser)
	*browser\controller\add_AcceleratorKeyPressed(*browser\evAccelKeyPressed, #Null)

	;Show window after fisrt browser created
	If CountGadgetItems(app\tab) = 1
		*browser\controller\put_IsVisible(#True)
		HideWindow(app\window, #False)
	EndIf 
	
	*browser\core\Navigate("https://duckduckgo.com")

	tab_Select(*browser\createParam)
	SetActiveGadget(app\url)
	
	UnlockMutex(*this\mutex)
EndProcedure

;-
Procedure env_Created(*this.WV2_EVENT_HANDLER, result.l, env.ICoreWebView2Environment)	
	env\QueryInterface(?IID_ICoreWebView2Environment, @app\env)

	;First tab browser
	browser_New(app\env, 0)
		
	wv2_EventHandler_Release(*this)
EndProcedure

;-
Procedure core_NavigationCompleted(*this.WV2_EVENT_HANDLER, sender.ICoreWebView2, args.ICoreWebView2NavigationCompletedEventArgs)
	Protected.i uri, title
	Protected.s suri, stitle
	Protected.BROWSER *browser, *currBrowser
	
	LockMutex(*this\mutex)
	*browser = *this\context
	
	sender\get_Source(@uri)
	If uri
		suri = PeekS(uri)
		str_FreeCoMemString(uri)
	EndIf
	
	sender\get_DocumentTitle(@title)
	If title
		stitle = PeekS(title)
		str_FreeCoMemString(title)
	EndIf 
	
	SetGadgetText(app\url, suri)
	
	SetGadgetItemText(app\tab, browser_GetTab(*browser), Left(stitle, 15) + " ...")
	
	UnlockMutex(*this\mutex)
EndProcedure

Procedure core_NewWindowRequested(*this.WV2_EVENT_HANDLER, sender.ICoreWebView2, args.ICoreWebView2NewWindowRequestedEventArgs)
	LockMutex(*this\mutex)
	
	UnlockMutex(*this\mutex)
EndProcedure

Procedure core_ContainsFullScreenElementChanged(*this.WV2_EVENT_HANDLER, sender.ICoreWebView2, args.IUnknown)
	Protected.l cfs
	
	LockMutex(*this\mutex)
	sender\get_ContainsFullScreenElement(@cfs)
	If cfs 
		window_SetFullScreen(#True)
		
	Else
		window_SetFullScreen(#False)
	EndIf 
	UnlockMutex(*this\mutex)
EndProcedure

Procedure core_HistoryChanged(*this.WV2_EVENT_HANDLER, sender.ICoreWebView2, args.IUnknown)
	Protected.BROWSER *browser
	
	LockMutex(*this\mutex)
	
	*browser = *this\context
	
	;Nav buttons
	If *browser = browser_GetCurrent()
		toolBar_UpdateNavButtons(*browser)
	EndIf 
	
	UnlockMutex(*this\mutex)
EndProcedure

;-
Procedure browser_GetCurrent()
	Protected.l tabIndex
	
	tabIndex = GetGadgetState(app\tab)
	If tabIndex <> - 1
		ProcedureReturn GetGadgetItemData(app\tab, tabIndex)
	EndIf 
EndProcedure

Procedure browser_GetTab(*browser.BROWSER)
	Protected.l item
	
	For item = 0 To CountGadgetItems(app\tab) - 1
		If GetGadgetItemData(app\tab, item) = *browser
			ProcedureReturn item
		EndIf 
	Next
	
	ProcedureReturn -1
EndProcedure

Procedure browser_New(env.ICoreWebView2Environment, tabIndex.l)
	AddElement(app\browsers())
	app\browsers()\createParam = tabIndex
	
	env\CreateCoreWebView2Controller(WindowID(app\window), wv2_EventHandler_New(?IID_ICoreWebView2CreateCoreWebView2ControllerCompletedHandler, @controller_Created(), @app\browsers()))
EndProcedure

Procedure browser_Free(*browser.BROWSER)
	If *browser = #Null
		ProcedureReturn
	EndIf
	
	If *browser\controller : *browser\controller\Release() : EndIf
	If *browser\core : *browser\core\Release() : EndIf 
	
	If *browser\evNavigationCompleted : wv2_EventHandler_Release(*browser\evNavigationCompleted) : EndIf
	If *browser\evAccelKeyPressed : wv2_EventHandler_Release(*browser\evAccelKeyPressed) : EndIf 
	If *browser\evContainsFullScreenElementChanged : wv2_EventHandler_Release(*browser\evContainsFullScreenElementChanged) : EndIf
	If *browser\evHistoryChanged : wv2_EventHandler_Release(*browser\evHistoryChanged) : EndIf 
	If *browser\evNewWindowRequested : wv2_EventHandler_Free(*browser\evNewWindowRequested) : EndIf 

	ChangeCurrentElement(app\browsers(), *browser)
	DeleteElement(app\browsers())
EndProcedure

Procedure browser_GoBack(*browser.BROWSER)
	If *browser And *browser\core
		*browser\core\GoBack()
	EndIf 
EndProcedure

Procedure browser_GoForward(*browser.BROWSER)
	If *browser And *browser\core
		*browser\core\GoForward()
	EndIf 
EndProcedure

Procedure browser_GoHome(*browser.BROWSER)
	If *browser And *browser\core
		*browser\core\Navigate("https://duckduckgo.com")
	EndIf 
EndProcedure

Procedure browser_ZoomIn(*browser.BROWSER)
	Protected.d zf
	
	If *browser And *browser\controller
		*browser\controller\get_ZoomFactor(@zf)
		*browser\controller\put_ZoomFactor(zf + 0.1)
	EndIf 
EndProcedure

Procedure browser_ZoomOut(*browser.BROWSER)
	Protected.d zf
	
	If *browser And *browser\controller
		*browser\controller\get_ZoomFactor(@zf)
		*browser\controller\put_ZoomFactor(zf - 0.1)
	EndIf 
EndProcedure

Procedure browser_ResetZoom(*browser.BROWSER)
	If *browser And *browser\controller
		*browser\controller\put_ZoomFactor(1)
	EndIf 
EndProcedure

Procedure browser_Reload(*browser.BROWSER)
	If *browser And *browser\core
		*browser\core\Reload()
	EndIf 
EndProcedure

Procedure browser_Stop(*browser.BROWSER)
	If *browser And *browser\core
		*browser\core\Stop()
	EndIf 
EndProcedure

Procedure browser_Navigate(*browser.BROWSER, url.s)
	If *browser And *browser\core
		*browser\core\Navigate(url)
	EndIf 
EndProcedure

Procedure browser_GetVersion()
	MessageRequester(#APP_NAME, "Ohm version: " + #APP_VERSION + #CRLF$ + "Edge version: " + wv2_GetBrowserVersion("") + 
									#CRLF$ + "Copyright(c) omegakode 2020")
EndProcedure

;-
Procedure accel_Add(win.i)
	AddKeyboardShortcut(win, #PB_Shortcut_Tab | #PB_Shortcut_Control, #MENU_ID_NEXT_TAB)
	AddKeyboardShortcut(win, #PB_Shortcut_Tab | #PB_Shortcut_Control | #PB_Shortcut_Shift, #MENU_ID_PREVIOUS_TAB)
	AddKeyboardShortcut(win, #PB_Shortcut_Control | #PB_Shortcut_T, #MENU_ID_NEW_TAB)
	AddKeyboardShortcut(win, #PB_Shortcut_Control | #PB_Shortcut_W, #MENU_ID_CLOSE_TAB)
	AddKeyboardShortcut(win, #PB_Shortcut_Left | #PB_Shortcut_Alt, #MENU_ID_GO_BACK)
	AddKeyboardShortcut(win, #PB_Shortcut_Right | #PB_Shortcut_Alt, #MENU_ID_GO_FORWARD)
	AddKeyboardShortcut(win, #PB_Shortcut_Add | #PB_Shortcut_Control, #MENU_ID_ZOOM_IN)
	AddKeyboardShortcut(win, #PB_Shortcut_Subtract | #PB_Shortcut_Control, #MENU_ID_ZOOM_OUT)
	AddKeyboardShortcut(win, #PB_Shortcut_F5, #MENU_ID_RELOAD)
	AddKeyboardShortcut(win, #PB_Shortcut_Home | #PB_Shortcut_Alt, #MENU_ID_GO_HOME)
	AddKeyboardShortcut(win, #PB_Shortcut_L | #PB_Shortcut_Control, #MENU_ID_URL_SELECT)
	AddKeyboardShortcut(win, #PB_Shortcut_F11, #MENU_ID_TOGGLE_FULLSCREEN)
	AddKeyboardShortcut(win, #PB_Shortcut_Control | #PB_Shortcut_M, #MENU_ID_SHOW_MENU)
EndProcedure

;-
Procedure menu_Create(winId.i)
	Protected.i menu
	
	menu = CreatePopupMenu(#PB_Any)
	MenuItem(#MENU_ID_NEW_TAB, "New tab" + #TAB$ + #TAB$ + "Ctrl + T")
	MenuItem(#MENU_ID_CLOSE_TAB, "Close tab" + #TAB$ + #TAB$ + "Ctrl + W")

	MenuBar()
	MenuItem(#MENU_ID_ZOOM_IN, "Zoom in" + #TAB$ + #TAB$ + "Ctrl +")
	MenuItem(#MENU_ID_ZOOM_OUT, "Zoom out" + #TAB$ + #TAB$ + "Ctrl -")
	MenuItem(#MENU_ID_RESET_ZOOM, "Reset zoom")
	MenuItem(#MENU_ID_TOGGLE_FULLSCREEN, "Fullscreen" + #TAB$ + #TAB$ + "F11")


	MenuBar()
	MenuItem(#MENU_ID_GET_VERSION, "About")
	
	MenuBar()
	MenuItem(#MENU_ID_QUIT, "Quit")
	
	ProcedureReturn menu
EndProcedure

Procedure menu_Show()
	Protected.l x, y 
	
	x = DesktopScaledX(GadgetX(app\btnMenu, #PB_Gadget_ScreenCoordinate))
	y = DesktopScaledY(GadgetY(app\btnMenu, #PB_Gadget_ScreenCoordinate))

	toolBar_HideIfFullscreen()
	DisplayPopupMenu(app\menu, WindowID(app\window), x, y + DesktopScaledY(GadgetHeight(app\btnMenu)))
EndProcedure

;-
Procedure url_On_WM_CHAR(hwnd.i, msg.l, wparam.i, lparam.i)
	Protected.s url
	
	Select wparam
		Case #VK_RETURN
			url = GetGadgetText(app\url)
			If url
				If Left(url, 7) = "http://" Or Left(url, 8) = "https://"
					browser_Navigate(browser_GetCurrent(), url)
					
				Else ;search
					browser_Navigate(browser_GetCurrent(), "https://duckduckgo.com/?q=" + url)
				EndIf 
			EndIf 
	EndSelect
	
	ProcedureReturn CallWindowProc_(app\urlOldProc, hwnd, msg, wparam, lparam)
EndProcedure

Procedure url_On_WM_KEYDOWN(hwnd.i, msg.l, wparam.i, lparam.i)
	Protected.s s1, s2
	Protected.l s1Len
		
	s1 = "http://www."
	s1Len = Len(s1)
	
	If wparam = #VK_L And key_IsDown(#VK_SHIFT) And key_IsDown(#VK_CONTROL)
		SetGadgetText(app\url, s1 + ".com")
		SendMessage_(hwnd, #EM_SETSEL, s1Len, s1Len)
	EndIf 
	
	ProcedureReturn CallWindowProc_(app\urlOldProc, hwnd, msg, wparam, lparam)
EndProcedure

Procedure url_Proc(hwnd.i, msg.l, wparam.i, lparam.i)
	Select msg
		Case #WM_KEYDOWN : ProcedureReturn url_On_WM_KEYDOWN(hwnd, msg, wparam, lparam)

		Case #WM_CHAR : ProcedureReturn url_On_WM_CHAR(hwnd, msg, wparam, lparam)
			
		Default : ProcedureReturn CallWindowProc_(app\urlOldProc, hwnd, msg, wparam, lparam)
	EndSelect
EndProcedure

Procedure url_SelectAll()
	SetActiveGadget(app\url)
	SendMessage_(GadgetID(app\url), #EM_SETSEL, 0, -1)
EndProcedure

;-
Procedure window_Free()
	ForEach app\browsers()
		browser_Free(app\browsers())
	Next
EndProcedure

Procedure window_Quit()
	window_Free()
	
	ProcedureReturn #True
EndProcedure

Procedure window_Close()
	window_Free()
	
	ProcedureReturn #True
EndProcedure

Procedure window_ToggleFullscreen()
	Protected.BROWSER *browser
	Protected.l cfs
	
	*browser = browser_GetCurrent()
	If *browser And *browser\core
		*browser\core\get_ContainsFullScreenElement(@cfs)
		If cfs
			*browser\core\ExecuteScript("document.exitFullscreen()", #Null)
		EndIf
		
		window_SetFullScreen(Bool(Not(app\windowIsFullscreen)))
	EndIf 
EndProcedure

Procedure window_OnTimerFullscreen()
	Protected.POINT pt
	
	GetCursorPos_(@pt)
	
	If pt\y <= 0
		HideGadget(app\toolBar, #False)
		
	ElseIf pt\y > DesktopScaledY(GadgetHeight(app\toolBar))
		HideGadget(app\toolBar, #True)
	EndIf
	
EndProcedure

Procedure window_ProcessEvents(ev.l)
	Select ev
		Case #PB_Event_Gadget			
			Select EventType()
				Case #PB_EventType_Change
					Select EventGadget()
						Case app\tab : tab_Changed()
					EndSelect
					
				Case #PB_EventType_KeyDown
					If GetGadgetAttribute(EventGadget(), #PB_Canvas_Key) = #PB_Shortcut_Space
						btn_OnLeftClickOrSpace(EventGadget())
					EndIf 
					
				Case #PB_EventType_LeftClick
					btn_OnLeftClickOrSpace(EventGadget())
			EndSelect
			
		Case #PB_Event_Menu
			Select EventMenu()
				Case #MENU_ID_NEW_TAB : tab_New()
					
				Case #MENU_ID_CLOSE_TAB : tab_Close(tab_GetSelected())
				
				Case #MENU_ID_NEXT_TAB : tab_SelectNext(tab_GetSelected())
				
				Case #MENU_ID_PREVIOUS_TAB : tab_SelectPrevious(tab_GetSelected())
				
				Case #MENU_ID_QUIT : ProcedureReturn window_Quit()
				
				Case #MENU_ID_GO_BACK : browser_GoBack(browser_GetCurrent())
				
				Case #MENU_ID_GO_FORWARD : browser_GoForward(browser_GetCurrent())
				
				Case #MENU_ID_GO_HOME : browser_GoHome(browser_GetCurrent())
				
				Case #MENU_ID_RELOAD : browser_Reload(browser_GetCurrent())
				
				Case #MENU_ID_STOP : browser_Stop(browser_GetCurrent())
				
				Case #MENU_ID_ZOOM_IN : browser_ZoomIn(browser_GetCurrent())
				
				Case #MENU_ID_ZOOM_OUT : browser_ZoomOut(browser_GetCurrent())
				
				Case #MENU_ID_RESET_ZOOM : browser_ResetZoom(browser_GetCurrent())
				
				Case #MENU_ID_TOGGLE_FULLSCREEN : window_ToggleFullscreen()
				
				Case #MENU_ID_GET_VERSION : browser_GetVersion()
				
				Case #MENU_ID_URL_SELECT : url_SelectAll()
				
				Case #MENU_ID_SHOW_MENU : menu_Show()
			EndSelect
			
		Case #PB_Event_Timer
			Select EventTimer()
				Case #TIMER_ID_FULLSCREEN : window_OnTimerFullscreen()
			EndSelect
			
		Case #PB_Event_CloseWindow : ProcedureReturn window_Close()
	EndSelect
	
	ProcedureReturn #False ;Keep the wvwnt loop running
EndProcedure

Procedure window_SetFullScreen(fs.b)
	Protected.i hwMain
	
	hwMain = WindowID(app\window)
	
	If fs = #True And app\windowIsFullscreen = #False
		app\windowIsFullscreen = #True

		toolBar_Show(#False)
		
		app\windowOldStyle = GetWindowLong_(hwMain, #GWL_STYLE)
		GetWindowPlacement_(hwMain, @app\windowOldPlacement)
		
		SetWindowLong_(hwMain, #GWL_STYLE, app\windowOldStyle & ~(#WS_CAPTION | #WS_THICKFRAME | #WS_MAXIMIZEBOX))
		
		HideMenu(app\menu, #True)
		SetWindowPos_(hwMain, #HWND_TOP, 0, 0, GetSystemMetrics_(#SM_CXSCREEN), GetSystemMetrics_(#SM_CYSCREEN), #SWP_FRAMECHANGED)
		
		AddWindowTimer(app\window, #TIMER_ID_FULLSCREEN, 300)
		
	ElseIf fs = #False And app\windowIsFullscreen = #True 
		app\windowIsFullscreen = #False

		toolBar_Show(#True)
		
		SetWindowLong_(hwMain, #GWL_STYLE, app\windowOldStyle)
		SetWindowPos_(hwMain, 0, 0, 0, 0, 0, #SWP_NOZORDER | #SWP_NOMOVE | #SWP_NOSIZE | #SWP_FRAMECHANGED | #SWP_NOCOPYBITS)

		If app\windowOldPlacement\showCmd = #SW_SHOWMAXIMIZED
			ShowWindow_(hwMain, #SW_SHOWMAXIMIZED)

		Else 
			app\windowOldPlacement\Length = SizeOf(WINDOWPLACEMENT)
			SetWindowPlacement_(hwMain, @app\windowOldPlacement)
		EndIf
		
		HideMenu(app\menu, #False)
		
		RemoveWindowTimer(app\window, #TIMER_ID_FULLSCREEN)
	EndIf 
EndProcedure

Procedure window_Resize()
	Protected.l winw, winh, urlWidth
	Protected.BROWSER *browser
	Protected.RECT rc
	
	winw = WindowWidth(app\window)
	winh = WindowHeight(app\window)
	
	ResizeGadget(app\toolBar, #PB_Ignore, #PB_Ignore, winw, app\toolBarHeight)
	ResizeGadget(app\btnNewTab, #PB_Ignore, #PB_Ignore, app\btnSize, app\btnSize)
	
	ResizeGadget(app\tab, app\btnSize, #PB_Ignore, winw - app\btnSize, app\tabHeight)
	urlWidth = winw - (app\btnSize * 5) - 2
	ResizeGadget(app\url, app\btnSize * 4, #PB_Ignore, urlWidth, app\urlHeight)
	
	ResizeGadget(app\btnGoBack, #PB_Ignore, #PB_Ignore, app\btnSize, app\btnSize)
	ResizeGadget(app\btnGoForward, app\btnSize, #PB_Ignore, app\btnSize, app\btnSize)
	ResizeGadget(app\btnReload, app\btnSize * 2, #PB_Ignore, app\btnSize, app\btnSize)
	ResizeGadget(app\btnGoHome, app\btnSize * 3, #PB_Ignore, app\btnSize, app\btnSize)

	ResizeGadget(app\btnMenu, GadgetX(app\url) + GadgetWidth(app\url), #PB_Ignore, app\btnSize, app\btnSize)
	
	*browser = browser_GetCurrent()

	If *browser
		GetClientRect_(WindowID(app\window), @rc)
		If app\windowIsFullscreen
			rc\top = 0
			
		Else
			rc\top = DesktopScaledY(app\toolBarHeight)
		EndIf 
		*browser\controller\put_IsVisible(#True)
		wv2_Controller_put_Bounds(*browser\controller, @rc)
	EndIf 
EndProcedure

Procedure window_On_MOVE_MOVING()
	Protected.BROWSER *browser
	
	*browser = browser_GetCurrent()
	If *browser And *browser\controller
		wv2_Controller_On_WM_MOVE_MOVING(*browser\controller)
	EndIf 
EndProcedure

Procedure window_On_NOTIFY(hwnd.i, msg.l, wparam.i, *nmh.NMHDR)
	Select *nmh\hwndFrom
		Case GadgetID(app\tab)
			Select *nmh\code
				Case #TCN_SELCHANGING
			
			EndSelect
			
		Case app\tabTip
			Select *nmh\code
				Case #TTN_GETDISPINFO : ProcedureReturn tabTip_On_TTN_GETDISPINFO(hwnd, msg, wparam, *nmh)

			EndSelect
	EndSelect
	
	ProcedureReturn #PB_ProcessPureBasicEvents
EndProcedure

Procedure window_Proc(hwnd.i, msg.l, wparam.i, lparam.i)
	Select msg
		Case #WM_MOVE, #WM_MOVING : window_On_MOVE_MOVING()
		
		Case #WM_NOTIFY : ProcedureReturn window_On_NOTIFY(hwnd.i, msg.l, wparam.i, lparam.i)
		
		Default : ProcedureReturn #PB_ProcessPureBasicEvents
	EndSelect
EndProcedure

Procedure window_Create()
	Protected.i win, winw, winh
	
	Protected.l tbs, tbes
	
	winw = 600
	winh = 400
	win = OpenWindow(#PB_Any, 10, 10, winw, winh, #APP_NAME, #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_SizeGadget | #PB_Window_Invisible)
	SmartWindowRefresh(win, #True)
		
	app\toolBar = ContainerGadget(#PB_Any, 0, 0, 0, 0, #PB_Container_BorderLess)
	app\btnNewTab = btn_Create(0, 0, 0, 0, @btnNewTab_Callback(), #False)

	tbs = GetWindowLong_(GadgetID(app\toolBar), #GWL_STYLE)
	tbes = GetWindowLong_(GadgetID(app\toolBar), #GWL_EXSTYLE)
	SetWindowLong_(GadgetID(app\toolBar), #GWL_STYLE, tbs | #WS_TABSTOP | #WS_CLIPCHILDREN)
	SetWindowLong_(GadgetID(app\toolBar), #GWL_EXSTYLE, tbes | #WS_EX_CONTROLPARENT )

	app\tab = PanelGadget(#PB_Any, 0, 0, 0, 0)	
	app\tabOldProc = SetWindowLongPtr_(GadgetID(app\tab), #GWLP_WNDPROC, @tab_Proc())
	AddGadgetItem(app\tab, -1, "New tab")

	app\tabHeight = GetGadgetAttribute(app\tab, #PB_Panel_TabHeight)
	CloseGadgetList() ;tab
	
	app\btnGoBack = btn_Create(0, app\tabHeight, 0, 0, @btnGoBack_CallBack(), #False)
	app\btnGoForward = btn_Create(0, app\tabHeight, 0, 0, @btnGoForward_CallBack(), #False)
	app\btnReload = btn_Create(0, app\tabHeight, 0, 0, @btnReload_CallBack(), #False)
	app\btnGoHome = btn_Create(0, app\tabHeight, 0, 0, @btnGoHome_CallBack(), #False)
	
	DisableGadget(app\btnGoBack, #True)
	DisableGadget(app\btnGoForward, #True)
	
	app\url = StringGadget(#PB_Any, 0, app\tabHeight, 0, 0, "")
	app\urlOldProc = SetWindowLongPtr_(GadgetID(app\url), #GWLP_WNDPROC, @url_Proc())
	app\urlHeight = GadgetHeight(app\url, #PB_Gadget_RequiredSize) + 4
	app\toolBarHeight = app\tabHeight + app\urlHeight + 2
	app\btnSize = app\urlHeight
	
	app\btnMenu = btn_Create(0, app\tabHeight, 0, 0, @btnMenu_CallBack(), #False)
	
	CloseGadgetList() ;toolbar

	app\tabTip = tabTip_New(WindowID(win), GadgetID(app\tab))
	
	SetWindowCallback(@window_Proc(), win)
	BindEvent(#PB_Event_SizeWindow, @window_Resize())
	
	GadgetToolTip(app\btnNewTab, "New tab (Ctrl + T)")
	GadgetToolTip(app\btnGoBack, "Go back (Alt + Left arrow)")
	GadgetToolTip(app\btnGoForward, "Go forward (Alt + Right arrow)")
	GadgetToolTip(app\btnReload, "Reload (Ctrl + R)")
	GadgetToolTip(app\btnGoHome, "Home (Alt + Home)")
	GadgetToolTip(app\btnMenu, "Options (Ctrl + M)")

	ProcedureReturn win
EndProcedure

;-
Procedure app_Init()
	InitializeStructure(@app, APP_TAG)

	app\tabTipBuffer = AllocateMemory(10)
EndProcedure

Procedure app_Free()
	FreeMemory(app\tabTipBuffer)
	
	If app\env : app\env\Release() : EndIf 
EndProcedure

;-
Procedure main()
	app_Init()

	app\window = window_Create()
	app\menu = menu_Create(WindowID(app\window))
	app\tabMenu = tabMenu_Create()
	accel_Add(app\window)
	
	CreateCoreWebView2EnvironmentWithOptions("", "", #Null, wv2_EventHandler_New(?IID_ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler, @env_Created()))

	Repeat
	Until window_ProcessEvents(WaitWindowEvent()) = #True
	
	app_Free()
EndProcedure

main()




