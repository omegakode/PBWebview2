;Ohm.pb

XIncludeFile "..\..\prerelease\PBWebView2.pb"

XIncludeFile "..\..\windows\commctrl.pbi"
XIncludeFile "..\..\windows\windef.pbi"
XIncludeFile "..\..\windows\ocidl.pbi"

XIncludeFile "gdiplus\gdiplus.pbi"

XIncludeFile "gadget.pb"
XIncludeFile "button.pb"
XIncludeFile "tabCtrl.pb"
XIncludeFile "Ohm.pbi"
XIncludeFile "favIcon.pb"

EnableExplicit



;- DECLARES
Declare browser_New(env.ICoreWebView2Environment, tanIndex.l, url.s = "")
Declare tab_GetCurrentBrowser()
Declare browser_GoBack(*browser.BROWSER)
Declare browser_GoForward(*browser.BROWSER)
Declare browser_ZoomIn(*browser.BROWSER)
Declare browser_ZoomOut(*browser.BROWSER)
Declare browser_GoHome(*browser.BROWSER)
Declare browser_Free(*browser.BROWSER)
Declare browser_GetTabIndex(*browser.BROWSER)
Declare browser_Reload(*browser.BROWSER)

Declare window_Resize()
Declare window_SetFullScreen(fs.b)
Declare window_ToggleFullscreen()

Declare toolBar_HideIfFullscreen()
Declare toolBar_UpdateNavButtons(*browser.BROWSER)

Declare url_Edit_SetText(url.i, text.s)
Declare url_Edit_SetHttp()
Declare url_Edit_SetBrowserSource(*bowser.BROWSER)

Declare menu_Show()

Declare url_Edit_SelectAll(url.i)

Declare core_NavigationCompleted(*this.WV2_EVENT_HANDLER, sender.ICoreWebView2, args.ICoreWebView2NavigationCompletedEventArgs)
Declare core_NavigationStaring(*this.WV2_EVENT_HANDLER, sender.ICoreWebView2, args.ICoreWebView2NavigationStartingEventArgs)
Declare core_NewWindowRequested(*this.WV2_EVENT_HANDLER, sender.ICoreWebView2, args.ICoreWebView2NewWindowRequestedEventArgs)
Declare core_ContainsFullScreenElementChanged(*this.WV2_EVENT_HANDLER, sender.ICoreWebView2, args.IUnknown)
Declare core_HistoryChanged(*this.WV2_EVENT_HANDLER, sender.ICoreWebView2, args.IUnknown)

;-
Macro tab_GetBrowser(tabIndex)
	tabCtrl_GetItemUserData(app\tab, tabIndex)
EndMacro

Macro tab_DeleteItem(item)
 tabCtrl_DeleteItem(app\tab, item)
EndMacro

Macro tab_GetSelected()
	tabCtrl_GetCurSel(app\tab)
EndMacro

;-
;- SEARCH PROVIDERS
Procedure sp_Add(name.s, url.s)
	LastElement(app\spProviders())
	AddElement(app\spProviders())
	app\spProviders()\name = name
	app\spProviders()\url = url
EndProcedure

Procedure sp_SelectProvider(index.l)
	Protected.l currIndex
	
	If index < 1  Or index > ListSize(app\spProviders()) : ProcedureReturn : EndIf
	
	currIndex = ListIndex(app\spProviders()) 
	If currIndex <> -1
		SetMenuItemState(app\spMenu, currIndex + 1, #False)
	EndIf 
	
	SelectElement(app\spProviders(), index - 1)
	SetMenuItemState(app\spMenu, index, #True)
EndProcedure

Procedure sp_CreateMenu()
	Protected.l cmd
	
	If ListSize(app\spProviders()) = 0 : ProcedureReturn : EndIf
	
	If app\spMenu
		FreeMenu(app\spMenu)
	EndIf
	
	app\spMenu = CreatePopupMenu(#PB_Any)
	cmd = 1
	ForEach app\spProviders()
		MenuItem(cmd, app\spProviders()\name)      
		cmd + 1
	Next 
	
; 	FirstElement(app\spProviders())
; 	SetMenuItemState(app\spMenu, 1, #True)
; 	sp_SelectProvider(1)
EndProcedure

Procedure sp_Init()
	sp_Add("DuckDuckGo", "https://duckduckgo.com/?q=%s")
	sp_Add("Google", "https://www.google.com/search?q=%s")
	sp_Add("Bing", "https://www.bing.com/search?q=%s")
	sp_Add("Purebasic", ~"https://duckduckgo.com/?q=site:forums.purebasic.com +\"%s\"")

	sp_CreateMenu()
EndProcedure



Procedure sp_ShowMenu()
	Protected.l cmd, x, y
	
	x = DesktopScaledX(GadgetX(app\btnSearch, #PB_Gadget_ScreenCoordinate))
	y = DesktopScaledY(GadgetY(app\btnSearch, #PB_Gadget_ScreenCoordinate)) + DesktopScaledY(GadgetHeight(app\btnSearch))

	cmd = TrackPopupMenu_(MenuID(app\spMenu), #TPM_LEFTALIGN | #TPM_TOPALIGN | #TPM_RETURNCMD | #TPM_LEFTBUTTON | #TPM_NONOTIFY, x, y, 0, WindowID(app\window), #Null)
	If cmd <> 0
		sp_SelectProvider(cmd)
	EndIf 
EndProcedure


;-
Procedure tab_New(url.s = "")
	Protected.l tabIndex
	
	tabCtrl_InsertItem(app\tab, -1, "New Tab")
	tabIndex = tabCtrl_GetItemCount(app\tab) - 1
	app\tabCurrent = tabIndex
	browser_New(app\env, tabIndex, url)
EndProcedure

Procedure tab_Select(index.l)
	Protected.BROWSER *currBrowser, *newBrowser

	*currBrowser = tab_GetCurrentBrowser()
	*newBrowser = tab_GetBrowser(index)
	
	If *currBrowser
		If *currBrowser\controller
			*currBrowser\controller\put_IsVisible(#False)
		EndIf 
	EndIf
	
	If *newBrowser
		If *newBrowser\controller
			*newBrowser\controller\put_IsVisible(#True)
		EndIf 
		url_Edit_SetBrowserSource(*newBrowser)
	EndIf
	
	tabCtrl_SetCurSel(app\tab, index)
	app\tabCurrent = index
	
	toolBar_UpdateNavButtons(tab_GetCurrentBrowser())
	
	window_Resize()
EndProcedure

Procedure tab_GetCurrentBrowser()
	Protected.l tabIndex
	
	tabIndex = tabCtrl_GetCurSel(app\tab)
	If tabIndex <> - 1
		ProcedureReturn tabCtrl_GetItemUserData(app\tab, tabIndex)
	EndIf 
EndProcedure

Procedure tab_On_SELCHANGE(hwndParent.i, msg.l, wparam.i, *nmh.NMHDR)
	Protected.BROWSER *currBrowser, *newBrowser
	
	*currBrowser = tab_GetBrowser(app\tabCurrent)
	*newBrowser = tab_GetBrowser(tabCtrl_GetCurSel(app\tab))
	
	If *currBrowser
		If *currBrowser\controller : *currBrowser\controller\put_IsVisible(#False) : EndIf 
	EndIf
	
	If *newBrowser
		If *newBrowser\controller : *newBrowser\controller\put_IsVisible(#True) : EndIf 
		url_Edit_SetBrowserSource(*newBrowser)
	EndIf
	
	app\tabCurrent = tabCtrl_GetCurSel(app\tab)
	
	toolBar_UpdateNavButtons(tab_GetCurrentBrowser())
	
	window_Resize()
	
	toolBar_HideIfFullscreen()
	
	ProcedureReturn 0
EndProcedure

Procedure tab_SelectNext(currentTab.l)
	Protected.l tabCount, nextTab
	
	tabCount = tabCtrl_GetItemCount(app\tab)
	If tabCount <= 1 : ProcedureReturn : EndIf
	
	nextTab = currentTab + 1
	If nextTab = tabCount
		nextTab = 0
	EndIf
	
	tab_Select(nextTab)
EndProcedure

Procedure tab_SelectPrevious(currentTab.l)
	Protected.l tabCount, prevTab
	
	tabCount = tabCtrl_GetItemCount(app\tab)
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
	
	tabCount = tabCtrl_GetItemCount(app\tab)
	If tabCount = 1 ;Close app
		PostEvent(#PB_Event_CloseWindow, app\window, 0)
	EndIf 
	
	*browser = tab_GetBrowser(item)
	
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

Procedure tab_On_RBUTTONUP(hwnd.i, msg.l, wparam.i, lparam.i)
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
			Case #MENU_ID_NEW_TAB : tab_New()
			Case #MENU_ID_RELOAD : browser_Reload(tab_GetBrowser(tabIndex))
		EndSelect
	EndIf 
EndProcedure

Procedure tab_Callback(hwnd.i, msg.l, param1.i, param2.i)
	Select msg
		Case #TAB_CTRL_MSG_CLOSE_BUTTON_CLICK
			tab_Close(param1)
			
		Case #TAB_CTRL_MSG_RBUTTONUP
			tab_On_RBUTTONUP(hwnd, msg, param1, param2)
			
	EndSelect
EndProcedure

;-
Procedure tabMenu_Create()
	Protected.i men
	
	men = CreatePopupMenu(#PB_Any)
	MenuItem(#MENU_ID_NEW_TAB, "New tab")
	MenuBar()
	MenuItem(#MENU_ID_RELOAD, "Reload")
	MenuItem(#MENU_ID_CLOSE_TAB, "Close tab")
	
	ProcedureReturn men
EndProcedure

;-
Procedure tabTip_Create(hwParent.i, hwPanel.i)
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
	Protected.TAB_CTRL_ITEM_EXTRA *ie
		
	GetCursorPos_(@tcht\pt)
	ScreenToClient_(app\tab, @tcht\pt)
	tabIndex = SendMessage_(app\tab, #TCM_HITTEST, 0, @tcht)
	If tabIndex <> -1
		*ie = tabCtrl_GetItemParam(app\tab, tabIndex)
		If *ie			
			*ttdi\lpszText = @*ie\itemText
		EndIf 
	EndIf 
	
	ProcedureReturn #PB_ProcessPureBasicEvents
EndProcedure

;-
Macro toolBar_Show(show)
	gadget_Show(app\toolBar, show)
EndMacro

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

Procedure toolBar_On_Default(hwnd.i, msg.l, wparam.i, lparam.i)
	If app\toolBarOldProc
		ProcedureReturn CallWindowProc_(app\toolBarOldProc, hwnd, msg, wparam, lparam)
		
	Else
		ProcedureReturn DefWindowProc_(hwnd, msg, wparam, lparam)
	EndIf 
EndProcedure

Procedure toolBar_On_DRAWITEM(hwnd.i, msg.l, wparam.i, *di.DRAWITEMSTRUCT)
	Select *di\hwndItem
		Case app\tab : ProcedureReturn tabCtrl_Parent_On_DRAWITEM(hwnd, msg, wparam, *di)
		
		Default : ProcedureReturn #False
	EndSelect
EndProcedure

Procedure toolBar_On_NOTIFY(hwnd.i, msg.l, wparam.i, *nmh.NMHDR)
	Select *nmh\hwndFrom
		Case app\tab
			Select *nmh\code
				Case #TCN_SELCHANGE : ProcedureReturn tab_On_SELCHANGE(hwnd, msg, wparam, *nmh)
				
		EndSelect
	EndSelect
	
	ProcedureReturn toolBar_On_Default(hwnd, msg, wparam, *nmh)
EndProcedure

Procedure toolBar_Proc(hwnd.i, msg.l, wparam.i, lparam.i)
	Select msg
		Case #WM_NOTIFY : ProcedureReturn toolBar_On_NOTIFY(hwnd, msg, wparam, lparam)
		
		Case #WM_DRAWITEM : ProcedureReturn tabCtrl_Parent_On_DRAWITEM(hwnd, msg, wparam, lparam)
		
		Default : ProcedureReturn toolBar_On_Default(hwnd, msg, wparam, lparam)
	EndSelect
EndProcedure

;-
Procedure btn_OnLeftClickOrSpace(btn.i)
	Select btn
		Case app\btnNewTab : tab_New()
		Case app\btnGoBack : browser_GoBack(tab_GetCurrentBrowser())
		Case app\btnGoForward : browser_GoForward(tab_GetCurrentBrowser())
		Case app\btnReload : browser_Reload(tab_GetCurrentBrowser())
		Case app\btnGoHome : browser_GoHome(tab_GetCurrentBrowser())
		Case app\btnMenu : menu_Show()
		Case app\btnSearch : sp_ShowMenu()

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
	    w = DesktopScaledX(1)
	    
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
			drw_ZoomOutCoordinates(0.6, size)

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
			drw_ZoomOutCoordinates(0.6, size)
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
			drw_ZoomOutCoordinates(0.6, size)
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
      p = DesktopScaledX(1)
      
      drw_ZoomOutCoordinates(0.6, size)

      VectorSourceColor(foreColor)
      	
			MovePathCursor(4*w, 2*p)
			AddPathLine(w, 4*w+2*p)
			AddPathLine(2*w, 4*w+2*p)
			AddPathLine(2*w, 7*w+2*p)
			AddPathLine(6*w, 7*w+2*p)
			AddPathLine(6*w, 4*w+2*p)
			AddPathLine(7*w, 4*w+2*p)
			ClosePath()
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
			drw_ZoomOutCoordinates(0.6, size)
			
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
					browser_ZoomIn(tab_GetCurrentBrowser())
					handled = #True
				EndIf 
				
			Case #VK_SUBTRACT
				If key_IsDown(#VK_CONTROL)
					browser_ZoomOut(tab_GetCurrentBrowser())
					handled = #True
				EndIf 
				
			Case #VK_HOME
				If key_IsDown(#VK_MENU)
					browser_GoHome(tab_GetCurrentBrowser())
					handled = #True
				EndIf 
				
			Case #VK_W
				If key_IsDown(#VK_CONTROL)
					tab_Close(tab_GetSelected())
					handled = #True
				EndIf 
				
			Case #VK_L
				If key_IsDown(#VK_CONTROL) And key_IsDown(#VK_SHIFT)
					url_Edit_SetHttp()
					handled = #True
					
				ElseIf key_IsDown(#VK_CONTROL)
					url_Edit_SelectAll(app\url)
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
	tabCtrl_SetItemUserData(app\tab, *browser\createParam, *browser)
	
	;Set zoom as dpi scaling
	*browser\controller\put_ZoomFactor(DesktopResolutionX())

	;Events
	;Core
	*browser\evNavigationStarting = wv2_EventHandler_New(?IID_ICoreWebView2NavigationStartingEventHandler, @core_NavigationStaring(), *browser)
	*browser\core\add_NavigationStarting(*browser\evNavigationStarting, #Null)
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
	If tabCtrl_GetItemCount(app\tab) = 1
		*browser\controller\put_IsVisible(#True)
		HideWindow(app\window, #False)
	EndIf 
	
	If *browser\createUrl
		*browser\core\Navigate(*browser\createUrl)
		*browser\createUrl = #Null$
		
	Else 
		*browser\core\Navigate("about:blank")
	EndIf 

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
Procedure core_NavigationStaring(*this.WV2_EVENT_HANDLER, sender.ICoreWebView2, args.ICoreWebView2NavigationStartingEventArgs)
	Protected.i uri
	Protected.s suri
	Protected.BROWSER *browser
	
	LockMutex(*this\mutex)
	*browser = *this\context
	
	UnlockMutex(*this\mutex)
EndProcedure

Procedure core_NavigationCompleted(*this.WV2_EVENT_HANDLER, sender.ICoreWebView2, args.ICoreWebView2NavigationCompletedEventArgs)
	Protected.i uri, title
	Protected.s suri, stitle, host, iconUrl
	Protected.BROWSER *browser, *currBrowser
	
	LockMutex(*this\mutex)
	*browser = *this\context
	
	sender\get_Source(@uri)
	If uri
		suri = PeekS(uri)
		str_FreeCoMemString(uri)
	EndIf
	
	host = GetURLPart(suri, #PB_URL_Site)
	If host
		
		;Get favicon	
; 		*browser\core\ExecuteScript(#FAVICON_SCRIPT_GET_ICON, wv2_EventHandler_New(?IID_ICoreWebView2ExecuteScriptCompletedHandler, @favicon_ScriptExecuted(), *browser))
	EndIf 
	
	sender\get_DocumentTitle(@title)
	If title
		stitle = PeekS(title)
		str_FreeCoMemString(title)
	EndIf 
	
	url_Edit_SetText(app\url, suri)
	
	If stitle = ""
		stitle = "New tab"
	EndIf 
	
	tabCtrl_SetItemText2(app\tab, browser_GetTabIndex(*browser), stitle, #TAB_MAX_ITEM_WIDTH)

	UnlockMutex(*this\mutex)
EndProcedure

Procedure core_NewWindowRequested(*this.WV2_EVENT_HANDLER, sender.ICoreWebView2, args.ICoreWebView2NewWindowRequestedEventArgs)
	Protected.i uriBuf
	Protected.s uriStr
	
	LockMutex(*this\mutex)
		args\get_uri(@uriBuf)
		If uriBuf
			uriStr = PeekS(uriBuf)
		
			tab_New(uriStr)
			
			args\put_Handled(#True)
			
			str_FreeCoMemString(uriBuf)
		EndIf 
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
	If *browser = tab_GetCurrentBrowser()
		toolBar_UpdateNavButtons(*browser)
	EndIf 
	
	UnlockMutex(*this\mutex)
EndProcedure

;-
Procedure browser_GetTabIndex(*browser.BROWSER)
	Protected.l item
	
	For item = 0 To tabCtrl_GetItemCount(app\tab) - 1
		If tabCtrl_GetItemUserData(app\tab, item) = *browser
			ProcedureReturn item
		EndIf 
	Next
	
	ProcedureReturn -1
EndProcedure

Procedure browser_New(env.ICoreWebView2Environment, tabIndex.l, url.s = "")
	AddElement(app\browsers())
	app\browsers()\createParam = tabIndex
	app\browsers()\createUrl = url
	
	env\CreateCoreWebView2Controller(WindowID(app\window), wv2_EventHandler_New(?IID_ICoreWebView2CreateCoreWebView2ControllerCompletedHandler, @controller_Created(), @app\browsers()))
EndProcedure

Procedure browser_Free(*browser.BROWSER)
	If *browser = #Null
		ProcedureReturn
	EndIf
	
	If *browser\core 
		*browser\core\Stop()
		*browser\core\Release()
	EndIf 

	If *browser\controller
		 *browser\controller\Close()
		 *browser\controller\Release()
	EndIf
	
	If *browser\evNavigationCompleted : wv2_EventHandler_Release(*browser\evNavigationCompleted) : EndIf
	If *browser\evNavigationStarting : wv2_EventHandler_Release(*browser\evNavigationStarting) : EndIf
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
	AddKeyboardShortcut(win, #PB_Shortcut_L | #PB_Shortcut_Control | #PB_Shortcut_Shift, #MENU_ID_URL_SET_HTTP)
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
Macro url_IsValidProtocol(prot)
	Bool(FindString(#URL_VALID_PROTOCOLS, LCase(prot)))
EndMacro

Macro url_GetData(url)
	GetGadgetData(url)
EndMacro

Procedure url_Edit_SelectAll(url.i)
	Protected.URL_DATA	 *ud
	
	*ud = url_GetData(url)
	If *ud
		SetActiveGadget(*ud\edit)
		SendMessage_(GadgetID(*ud\edit), #EM_SETSEL, 0, -1)
	EndIf 
EndProcedure

Procedure url_Edit_SetBrowserSource(*bowser.BROWSER)
	Protected.i uriBuf
	Protected.s uriStr
	
	If *bowser And *bowser\core
		*bowser\core\get_Source(@uriBuf)
		If uriBuf
			uriStr = PeekS(uriBuf)
			url_Edit_SetText(app\url, uriStr)
			str_FreeCoMemString(uriBuf)
		EndIf 
	EndIf 
EndProcedure

Procedure.s url_Edit_GetText(url.i)
	Protected.URL_DATA	 *ud
	
	*ud = url_GetData(url)
	If *ud
		ProcedureReturn GetGadgetText(*ud\edit)
	EndIf
EndProcedure

Procedure url_Edit_SetText(url.i, text.s)
	Protected.URL_DATA	 *ud
	
	*ud = url_GetData(url)
	If *ud
		SetGadgetText(*ud\edit, text)
	EndIf
EndProcedure

Procedure url_Edit_Resize(*ud.URL_DATA)
	Protected.RECT rcEdit, rcUrl
	Protected.l editHeight, edity, btnSize
	
	gadget_GetClientRectPx(*ud\url, @rcUrl)
	
	;Vertical align
	editHeight = GadgetHeight(*ud\edit, #PB_Gadget_RequiredSize)
	editHeight - DesktopScaledY((GetSystemMetrics_(#SM_CYBORDER) * 2))


	edity = (GadgetHeight(*ud\url) - editHeight) / 2
	
	btnSize = editHeight
	ResizeGadget(app\btnSearch, #URL_FRAME_WIDTH + #URL_PADDING_LEFT, edity, btnSize, btnSize)
	
	ResizeGadget(*ud\edit, GadgetX(app\btnSearch) + btnSize + #URL_PADDING_LEFT, edity, 0, editHeight)

	;Width
	gadget_GetClientPosPx(*ud\edit, *ud\url, @rcEdit)
	gadget_MovePx(*ud\edit, rcEdit\left, rcEdit\top, 
		rcUrl\right - (rcEdit\left + DesktopScaledX(#URL_FRAME_WIDTH) + DesktopScaledX(#URL_PADDING_RIGHT)), 
		rcEdit\bottom - rcEdit\top)
EndProcedure

Procedure url_DrawFramePx(x.l, y.l, width.l, height.l, frameWidth.l, color.l)
	Protected.l i, offset

	offset = 0
	DrawingMode(#PB_2DDrawing_Outlined)
	For i = 1 To frameWidth
		Box(x + offset, y + offset, width - (offset * 2), height - (offset *2), color)
		offset + 1
	Next
EndProcedure

Procedure url_Draw(url)	
	Protected.URL_DATA *ud
	Protected.l frameColor
	
	*ud = url_GetData(url)
	If *ud
		StartDrawing(CanvasOutput(url))
			If *ud\state = #URL_STATE_FOCUSED
				frameColor = GetSysColor_(#COLOR_ACTIVECAPTION)
				
			Else
				frameColor = GetSysColor_(#COLOR_3DLIGHT)
			EndIf 
			
			url_DrawFramePx(0, 0, OutputWidth(), OutputHeight(), DesktopScaledX(#URL_FRAME_WIDTH), frameColor)
		StopDrawing()
	EndIf
EndProcedure

Macro url_Edit_GetData(hwEdit)
	GetWindowLongPtr_(hwEdit, #GWLP_USERDATA)
EndMacro

Procedure url_Edit_OnDefault(hwnd.i, msg.l, wparam.i, lparam.i)
	Protected.URL_DATA *ud
	
	*ud = url_Edit_GetData(hwnd)
	If *ud
		ProcedureReturn CallWindowProc_(*ud\editOldProc, hwnd, msg, wparam, lparam)
		
	Else
		ProcedureReturn DefWindowProc_(hwnd, msg, wparam, lparam)
	EndIf 
EndProcedure

Procedure url_Edit_On_CHAR(hwnd.i, msg.l, wparam.i, lparam.i)
	Protected.s url, prot, searchUrl
	Protected.URL_DATA *ud
	Protected.SEARCH_PROVIDER *sp
	
	*ud = url_Edit_GetData(hwnd)
	If *ud
		Select wparam
			Case #VK_RETURN
				url = Trim(url_Edit_GetText(app\url))
				If url
					prot = GetURLPart(url, #PB_URL_Protocol)
					If prot And url_IsValidProtocol(prot)
						browser_Navigate(tab_GetCurrentBrowser(), url)
						
					Else ;search
						If ListIndex(app\spProviders()) <> -1
							*sp = @app\spProviders()
							searchUrl = ReplaceString(*sp\url, "%s", url)
							browser_Navigate(tab_GetCurrentBrowser(), searchUrl)
						EndIf	
					EndIf 
				EndIf 
				
				ProcedureReturn 0
		EndSelect
		
		ProcedureReturn CallWindowProc_(*ud\editOldProc, hwnd, msg, wparam, lparam)
	
	Else
		ProcedureReturn DefWindowProc_(hwnd, msg, wparam, lparam)
	EndIf 
EndProcedure

Procedure url_Edit_SetHttp()
	Protected.s s1
	Protected.l s1Len
	Protected.URL_DATA *ud
	
	*ud = url_GetData(app\url)
	If *ud
		s1 = "http://www."
		s1Len = Len(s1)
		
		url_Edit_SetText(app\url, s1 + ".com")
		SendMessage_(GadgetID(*ud\edit), #EM_SETSEL, s1Len, s1Len)
		SetActiveGadget(*ud\edit)
	EndIf 
EndProcedure

Procedure url_Edit_On_SETFOCUS(hwnd.i, msg.l, wparam.i, lparam.i)
	Protected.URL_DATA *ud
	
	*ud = url_Edit_GetData(hwnd)
	If *ud
		*ud\state = #URL_STATE_FOCUSED
		url_Draw(*ud\url)
		
		ProcedureReturn CallWindowProc_(*ud\editOldProc, hwnd, msg, wparam, lparam)
		
	Else
		ProcedureReturn DefWindowProc_(hwnd, msg, wparam, lparam)
	EndIf 
EndProcedure

Procedure url_Edit_On_KILLFOCUS(hwnd.i, msg.l, wparam.i, lparam.i)
	Protected.URL_DATA *ud
	
	*ud = url_Edit_GetData(hwnd)
	If *ud
		*ud\state = #URL_STATE_NORMAL
		url_Draw(*ud\url)

		ProcedureReturn CallWindowProc_(*ud\editOldProc, hwnd, msg, wparam, lparam)
		
	Else
		ProcedureReturn DefWindowProc_(hwnd, msg, wparam, lparam)
	EndIf 
EndProcedure



Procedure url_Edit_Proc(hwnd.i, msg.l, wparam.i, lparam.i)
	Select msg
		Case #WM_CHAR : ProcedureReturn url_Edit_On_CHAR(hwnd, msg, wparam, lparam)
				
		Case #WM_SETFOCUS : ProcedureReturn url_Edit_On_SETFOCUS(hwnd, msg, wparam, lparam)
			
		Case #WM_KILLFOCUS : ProcedureReturn url_Edit_On_KILLFOCUS(hwnd, msg, wparam, lparam)
				
		Default : ProcedureReturn url_Edit_OnDefault(hwnd, msg, wparam, lparam)
	EndSelect
EndProcedure

Procedure url_OnResize()
	Protected.URL_DATA *ud
	
	*ud = GetGadgetData(EventGadget())
	If *ud
		url_Edit_Resize(*ud)
		url_Draw(EventGadget())
	EndIf 
EndProcedure

Procedure url_OnLeftButtonDown()
	Protected.URL_DATA *ud
	
	*ud = GetGadgetData(EventGadget())
	If *ud
		SetActiveGadget(*ud\edit)
	EndIf 
EndProcedure

Procedure url_Btn_DrawBackground(*bd.BUTTON_DATA)
	Protected.l bColor
	
	If enum_HasFlag(*bd\state, #BUTTON_STATE_PUSHED)
		bColor = GetSysColor_(#COLOR_3DSHADOW)

	ElseIf enum_HasFlag(*bd\state, #BUTTON_STATE_HIGHLIGHTED)
		bColor = GetSysColor_(#COLOR_3DLIGHT)
		
	Else
		bColor = GetSysColor_(#COLOR_WINDOW)
	EndIf
	
	VectorSourceColor(RGBA(Red(bColor), Green(bColor), Blue(bColor), 255))
	FillVectorOutput()
EndProcedure

Procedure url_BtnSearch_Callback(btn.i, msg.l)
	Protected.BUTTON_DATA *bd
	Protected.i size
	Protected.l foreColor

	*bd = btn_GetData(btn)
	If *bd = 0 : ProcedureReturn : EndIf
	
	Select msg
		Case #BUTTON_MSG_DRAW
			StartVectorDrawing(CanvasVectorOutput(btn))
			size = DesktopScaledX(GadgetWidth(btn))

			url_btn_DrawBackground(*bd)
			
			foreColor = btn_GetForeColor(btn)
			
			;Focus
			If GetActiveGadget() = btn
				btn_DrawFocus(btn, size, foreColor)
			EndIf
			
			VectorSourceColor(foreColor)
			
      drw_ZoomOutCoordinates(0.7, size)
			drw_DrawMagnifyingGlass(0, 0, size)

			StopVectorDrawing()
	EndSelect
EndProcedure

Procedure url_Create(x.l, y.l, w.l, h.l)
	Protected.URL_DATA *ud
	Protected.l editHeight, edity, editXPos
	
	*ud = AllocateMemory(SizeOf(URL_DATA))
	*ud\url = CanvasGadget(#PB_Any, x, y, w, h, #PB_Canvas_Container)
	SetGadgetData(*ud\url, *ud)
	SetGadgetAttribute(*ud\url, #PB_Canvas_Cursor, #PB_Cursor_IBeam)
	
	;Search button
	app\btnSearch = btn_Create(0, 0, 0, 0, @url_BtnSearch_Callback(), #False)
	
	;Edit
	*ud\edit = StringGadget(#PB_Any, #URL_FRAME_WIDTH + #URL_PADDING_LEFT, 0, 0, 0, "", #PB_String_BorderLess)
	SetWindowLongPtr_(GadgetID(*ud\edit), #GWLP_USERDATA, *ud)
	*ud\editOldProc = SetWindowLongPtr_(GadgetID(*ud\edit), #GWLP_WNDPROC, @url_Edit_Proc())
	SetGadgetFont(*ud\edit, font_GetDefault(1.2))

	url_Edit_Resize(*ud)
	CloseGadgetList()
	
	BindGadgetEvent(*ud\url, @url_OnResize(), #PB_EventType_Resize)
	BindGadgetEvent(*ud\url, @url_OnLeftButtonDown(), #PB_EventType_LeftButtonDown)

	url_Draw(*ud\url)
	
	ProcedureReturn *ud\url
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
	
	*browser = tab_GetCurrentBrowser()
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
	
	If GetCursorPos_(@pt) 
		If pt\y <= 0
			toolBar_Show(#True)
			
		ElseIf pt\y > DesktopScaledY(GadgetHeight(app\toolBar))
			toolBar_Show(#False)
		EndIf
	EndIf 
EndProcedure

Procedure window_ProcessEvents(ev.l)
	Select ev
		Case #PB_Event_Gadget			
			Select EventType()					
				Case #PB_EventType_KeyDown
					If GetGadgetAttribute(EventGadget(), #PB_Canvas_Key) = #PB_Shortcut_Space
						btn_OnLeftClickOrSpace(EventGadget())
					EndIf 
					
				Case #PB_EventType_LeftClick
					btn_OnLeftClickOrSpace(EventGadget())
					
				Case #PB_EventType_DragStart
					Debug "ds"
			EndSelect
			
		Case #PB_Event_Menu
			Select EventMenu()
				Case #MENU_ID_NEW_TAB : tab_New()
					
				Case #MENU_ID_CLOSE_TAB : tab_Close(tab_GetSelected())
				
				Case #MENU_ID_NEXT_TAB : tab_SelectNext(tab_GetSelected())
				
				Case #MENU_ID_PREVIOUS_TAB : tab_SelectPrevious(tab_GetSelected())
				
				Case #MENU_ID_QUIT : ProcedureReturn window_Quit()
				
				Case #MENU_ID_GO_BACK : browser_GoBack(tab_GetCurrentBrowser())
				
				Case #MENU_ID_GO_FORWARD : browser_GoForward(tab_GetCurrentBrowser())
				
				Case #MENU_ID_GO_HOME : browser_GoHome(tab_GetCurrentBrowser())
				
				Case #MENU_ID_RELOAD : browser_Reload(tab_GetCurrentBrowser())
				
				Case #MENU_ID_STOP : browser_Stop(tab_GetCurrentBrowser())
				
				Case #MENU_ID_ZOOM_IN : browser_ZoomIn(tab_GetCurrentBrowser())
				
				Case #MENU_ID_ZOOM_OUT : browser_ZoomOut(tab_GetCurrentBrowser())
				
				Case #MENU_ID_RESET_ZOOM : browser_ResetZoom(tab_GetCurrentBrowser())
				
				Case #MENU_ID_TOGGLE_FULLSCREEN : window_ToggleFullscreen()
				
				Case #MENU_ID_GET_VERSION : browser_GetVersion()
				
				Case #MENU_ID_URL_SET_HTTP : url_Edit_SetHttp()
					
				Case #MENU_ID_URL_SELECT : url_Edit_SelectAll(app\url)
				
				Case #MENU_ID_SHOW_MENU : menu_Show()
			EndSelect
			
		Case #PB_Event_Timer
			Select EventTimer()
				Case #TIMER_ID_FULLSCREEN : window_OnTimerFullscreen()
			EndSelect
			
		Case #PB_Event_CloseWindow : ProcedureReturn window_Close()
	EndSelect
	
	ProcedureReturn #False ;Keep the event loop running
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
		
		RemoveWindowTimer(app\window, #TIMER_ID_FULLSCREEN)
	EndIf 
EndProcedure

Procedure window_Resize()
	Protected.l winw, winh, urlWidth, urlBtnCount, tabWidth, btnXPos, urlXPos
	Protected.BROWSER *browser
	Protected.RECT rc
	
	winw = WindowWidth(app\window)
	winh = WindowHeight(app\window)
	
	urlBtnCount = 5
	
	;Toolbar
	ResizeGadget(app\toolBar, #PB_Ignore, #PB_Ignore, winw, app\toolBarHeight)
	
	;Button New
	ResizeGadget(app\btnNewTab, #TOOLBAR_PADDING_LEFT, 0, app\btnSize, app\btnSize)
	
	;Tab
	tabWidth = winw - #TOOLBAR_PADDING_LEFT - #TOOLBAR_PADDING_RIGHT - app\btnSize - #BTN_MARGIN
	tabCtrl_Move(app\tab, gadget_GetRight(app\btnNewTab) + #BTN_MARGIN, 0, tabWidth, app\tabHeight, #True)

	;Nav buttons
	btnXPos = #TOOLBAR_PADDING_LEFT
	ResizeGadget(app\btnGoBack, btnXPos, #PB_Ignore, app\btnSize, app\btnSize)
	btnXPos + app\btnSize + #BTN_MARGIN
	ResizeGadget(app\btnGoForward, btnXPos, #PB_Ignore, app\btnSize, app\btnSize)
	btnXPos + app\btnSize + #BTN_MARGIN
	ResizeGadget(app\btnReload, btnXPos, #PB_Ignore, app\btnSize, app\btnSize)
	btnXPos + app\btnSize + #BTN_MARGIN
	ResizeGadget(app\btnGoHome, btnXPos, #PB_Ignore, app\btnSize, app\btnSize)
	
	;Url
	urlXPos = btnXPos + app\btnSize + #BTN_MARGIN
	urlWidth = winw - urlXPos - #BTN_MARGIN - app\btnSize - #TOOLBAR_PADDING_RIGHT
	ResizeGadget(app\url, urlXPos, #PB_Ignore, urlWidth, app\urlHeight)
	
	;Button Menu
	ResizeGadget(app\btnMenu, urlXPos + urlWidth + #BTN_MARGIN, #PB_Ignore, app\btnSize, app\btnSize)
	
	*browser = tab_GetCurrentBrowser()

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
	
	*browser = tab_GetCurrentBrowser()
	If *browser And *browser\controller
		wv2_Controller_On_WM_MOVE_MOVING(*browser\controller)
	EndIf 
EndProcedure

Procedure window_On_NOTIFY(hwnd.i, msg.l, wparam.i, *nmh.NMHDR)
	Select *nmh\hwndFrom
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
		
		Case #WM_NOTIFY : ProcedureReturn window_On_NOTIFY(hwnd, msg, wparam, lparam)
				
		Default : ProcedureReturn #PB_ProcessPureBasicEvents
	EndSelect
EndProcedure

Procedure window_Create()
	Protected.i win, winw, winh
	Protected.URL_DATA *ud
	Protected.l tbs, tbes
	Protected.TAB_CTRL_OPTIONS tabOpts
	
	winw = 600
	winh = 400
	win = OpenWindow(#PB_Any, 10, 10, winw, winh, #APP_NAME, #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_SizeGadget | #PB_Window_Invisible)
	SmartWindowRefresh(win, #True)
	
	;Toolbar
	app\toolBar = ContainerGadget(#PB_Any, 0, 0, 0, 0, #PB_Container_BorderLess)
	
	;Button New
	app\btnNewTab = btn_Create(#TOOLBAR_PADDING_LEFT, 0, 0, 0, @btnNewTab_Callback(), #False)

	;Toolbar
	tbs = GetWindowLong_(GadgetID(app\toolBar), #GWL_STYLE)
	tbes = GetWindowLong_(GadgetID(app\toolBar), #GWL_EXSTYLE)
	SetWindowLong_(GadgetID(app\toolBar), #GWL_STYLE, tbs | #WS_TABSTOP | #WS_CLIPCHILDREN)
	SetWindowLong_(GadgetID(app\toolBar), #GWL_EXSTYLE, tbes | #WS_EX_CONTROLPARENT)
	app\toolBarOldProc = SetWindowLongPtr_(GadgetID(app\toolBar), #GWLP_WNDPROC, @toolBar_Proc())

	;Tab
	tabOpts\flags = #TAB_CTRL_FLAG_TRUNCATE_TEXT
	app\tab = tabCtrl_Create(GadgetID(app\toolBar), 0, 0, 0, 0, @tab_Callback(), @tabOpts)

	tabCtrl_InsertItem(app\tab, -1, "New tab", app\iconTest)

	app\tabHeight = tabCtrl_GetTabsHeight(app\tab)
	
	;Nav Buttons
	app\btnGoBack = btn_Create(0, app\tabHeight, 0, 0, @btnGoBack_CallBack(), #False)
	app\btnGoForward = btn_Create(0, app\tabHeight, 0, 0, @btnGoForward_CallBack(), #False)
	app\btnReload = btn_Create(0, app\tabHeight, 0, 0, @btnReload_CallBack(), #False)
	app\btnGoHome = btn_Create(0, app\tabHeight, 0, 0, @btnGoHome_CallBack(), #False)
	
	DisableGadget(app\btnGoBack, #True)
	DisableGadget(app\btnGoForward, #True)
	
	;URL
	app\urlHeight = app\tabHeight - (#URL_OFFSET_Y * 2)
	app\url = url_Create(0, app\tabHeight + #URL_OFFSET_Y, app\urlHeight, 0)

	app\toolBarHeight = (app\tabHeight * 2) + #TOOLBAR_PADDING_BOTTOM
	app\btnSize = app\tabHeight
	
	app\btnMenu = btn_Create(0, app\tabHeight, 0, 0, @btnMenu_CallBack(), #False)
	
	CloseGadgetList() ;toolbar

	app\tabTip = tabTip_Create(WindowID(win), app\tab)

	SetWindowCallback(@window_Proc(), win)
	BindEvent(#PB_Event_SizeWindow, @window_Resize())
	
	GadgetToolTip(app\btnNewTab, "New tab (Ctrl + T)")
	GadgetToolTip(app\btnGoBack, "Go back (Alt + Left arrow)")
	GadgetToolTip(app\btnGoForward, "Go forward (Alt + Right arrow)")
	GadgetToolTip(app\btnReload, "Reload (Ctrl + R)")
	GadgetToolTip(app\btnGoHome, "Home (Alt + Home)")
	GadgetToolTip(app\btnMenu, "Options (Ctrl + M)")
	GadgetToolTip(app\btnSearch, "Search providers")

	sp_SelectProvider(1)

	ProcedureReturn win
EndProcedure

;-
Procedure app_Init()
	Protected.GdiplusStartupInput si
	
	InitializeStructure(@app, APP_TAG)
	sp_Init()
	app\favIcon = favIcon_New()
	
	si\GdiplusVersion = 1
	GdiplusStartup(@app\gdipStartupToken, @si, 0)
EndProcedure

Procedure app_Free()
	If app\env : app\env\Release() : EndIf 
	
	GdiplusShutdown(app\gdipStartupToken)
EndProcedure

;-
Procedure main()
	app_Init()

	app\window = window_Create()
	app\menu = menu_Create(WindowID(app\window))
	app\tabMenu = tabMenu_Create()
	accel_Add(app\window)
	
	If CreateCoreWebView2EnvironmentWithOptions("", "", #Null, wv2_EventHandler_New(?IID_ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler, @env_Created())) <> #S_OK
		MessageRequester(#APP_NAME, "Error, failed to created WebView2 Environment.")
		End
	EndIf 

	Repeat
	Until window_ProcessEvents(WaitWindowEvent()) = #True
	
	app_Free()
EndProcedure

main()




