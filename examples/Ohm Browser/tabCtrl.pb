;tabCtrl.pb

EnableExplicit

XIncludeFile "tabCtrl_public.pbi"
XIncludeFile "font.pb"

Macro drw_PointInRect(x, y, rc)
	Bool((x) >= rc\left And (x) <= rc\right And (y) >= rc\top And (y) <= rc\bottom)
EndMacro

;- ENUM TAB_CTRL_ITEM_PAD
#TAB_CTRL_ITEM_PAD_RIGHT = 6
#TAB_CTRL_ITEM_PAD_LEFT = 6

#TAB_CTRL_CLOSE_BTN_PAD = 4

;- TAB_CTRL_DATA
Structure TAB_CTRL_DATA
	opts.TAB_CTRL_OPTIONS
	
	isMouseOver.b
	itemHot.l
	
	closeBtnHot.l
	closeBtnDown.b
	closeBtnPen.i
	
	oldProc.i
	fontHeight.l
	callback.tabCtrl_Callback
	callbackContext.i
	
	userData.i
EndStructure

;- TAB_CTRL_ITEM_EXTRA
Structure TAB_CTRL_ITEM_EXTRA
	userData.i
	itemText.s
EndStructure

;- DECLARES
Declare tabCtrl_Proc(hwnd.i, msg.l,  wparam.i, lparam.i)
Declare tabCtrl_GetCloseButtonRect(hwnd.i, item.i, *rc.RECT)

Macro tabCtrl_GetTabData(tab)
	GetWindowLongPtr_(tab, #GWLP_USERDATA)
EndMacro

Macro tabCtrl_SetTabData(tab, dat)
	SetWindowLongPtr_(tab, #GWLP_USERDATA, dat)
EndMacro

Procedure tabCtrl_Create(hwParent.i, x.l, y.l, w.l, h.l, callback.tabCtrl_Callback, *opts.TAB_CTRL_OPTIONS = #Null)
	Protected.i hwTab
	Protected.TAB_CTRL_DATA *td
	Protected.LOGBRUSH lb
	
	*td = AllocateMemory(SizeOf(TAB_CTRL_DATA))
	*td\itemHot = -1
	*td\closeBtnHot = -1
	*td\closeBtnDown = #False
	*td\callback = callback
	If *opts
		CopyMemory(*opts, @*td\opts, SizeOf(TAB_CTRL_OPTIONS))
	EndIf 
; 	*td\closeBtnPen = CreatePen_(#PS_SOLID, DesktopScaledX(1), RGB(0, 0, 0))
	
	lb\lbStyle = #BS_SOLID
	lb\lbColor = RGB(0, 0, 0)
	*td\closeBtnPen = ExtCreatePen_(#PS_GEOMETRIC | #PS_SOLID | #PS_INSIDEFRAME | #PS_ENDCAP_ROUND | #PS_JOIN_ROUND, 2, @lb, 0, #Null)
;
	hwTab = CreateWindow_(#WC_TABCONTROL, "", 
        #WS_CHILD | #WS_CLIPSIBLINGS | #WS_VISIBLE | #WS_TABSTOP | #TCS_OWNERDRAWFIXED | #TCS_FLATBUTTONS | #TCS_BUTTONS, 
        DesktopScaledX(x), DesktopScaledY(y), DesktopScaledX(w), DesktopScaledY(h), 
        hwParent, #Null, GetModuleHandle_(0), #Null)
        
  SendMessage_(hwTab, #TCM_SETITEMEXTRA, SizeOf(TAB_CTRL_ITEM_EXTRA), 0)
        
 	SetWindowLongPtr_(hwTab, #GWLP_USERDATA, *td)
	*td\oldProc = SetWindowLongPtr_(hwTab, #GWLP_WNDPROC, @tabCtrl_Proc())
  SendMessage_(hwTab, #WM_SETFONT, GetGadgetFont(#PB_Default), #True)
  
  ;Height
  SendMessage_(hwTab, #TCM_SETIMAGELIST, 0, ImageList_Create_(*td\fontHeight, *td\fontHeight * 2.5, 0, 0, 0))
  ;Widh
  SendMessage_(hwTab, #TCM_SETPADDING, 0, MAKELONG(*td\fontHeight * 2, 0))
  
  ProcedureReturn hwTab
EndProcedure

Procedure tabCtrl_GetUserData(hwnd.i)
	Protected.TAB_CTRL_DATA *td
	
	*td = tabCtrl_GetTabData(hwnd)
	
	If *td
		ProcedureReturn *td\userData
	EndIf 
EndProcedure

Procedure tabCtrl_SetUserData(hwnd.i, dat.i)
	Protected.TAB_CTRL_DATA *td
	
	*td = tabCtrl_GetTabData(hwnd)

	If *td
		*td\userData = dat
	EndIf 
EndProcedure

Procedure tabCtrl_GetItemParam(hwnd.i, item.i)
	Protected.TCITEM tci
	
	tci\mask = #TCIF_PARAM
	SendMessage_(hwnd, #TCM_GETITEM, item, @tci)
	
	ProcedureReturn tci\lParam
EndProcedure

Procedure.s tabCtrl_TruncateItemText(hwnd.i, text.s, maxWidth.l)
	Protected.i hdc
	Protected.l width, maxChars
	Protected.TEXTMETRIC tm
	
	If text = "" : ProcedureReturn "" : EndIf
	
	hdc = GetDC_(hwnd)
		GetTextMetrics_(hdc, @tm)
	ReleaseDC_(hwnd, hdc)

	maxChars = (maxWidth) / tm\tmMaxCharWidth
	
	ProcedureReturn Left(text, maxChars)
EndProcedure


Procedure tabCtrl_SetItemText2(hwnd.i, item.i, text.s, maxWidth.l)
	Protected.s text2
	Protected.TAB_CTRL_ITEM_EXTRA *ie
	
	*ie = tabCtrl_GetItemParam(hwnd, item)
	If *ie
		*ie\itemText = text
		text2 = tabCtrl_TruncateItemText(hwnd, text, maxWidth)
		tabCtrl_SetItemText(hwnd, item, text2)
	EndIf 
EndProcedure

Procedure.s tabCtrl_GetItemText2(hwnd.i, item.i)
	Protected.TAB_CTRL_ITEM_EXTRA *ie
	
	*ie = tabCtrl_GetItemParam(hwnd, item)
	If *ie
		ProcedureReturn *ie\itemText
	EndIf 
EndProcedure

Procedure tabCtrl_GetTabsHeight(hwTab.i)
	Protected.RECT rc
	
	GetClientRect_(hwTab, @rc)
	SendMessage_(hwTab, #TCM_ADJUSTRECT, #False, @rc)
	
	ProcedureReturn DesktopUnscaledY(rc\top)
EndProcedure

Procedure tabCtrl_SetItemUserData(hwnd.i, item.i, dat.i)
	Protected.TCITEM tci
	Protected.TAB_CTRL_ITEM_EXTRA *ie

	tci\mask = #TCIF_PARAM
	SendMessage_(hwnd, #TCM_GETITEM, item, @tci)
	*ie = tci\lParam
	
	If *ie
		*ie\userData = dat
	EndIf
EndProcedure

Procedure tabCtrl_GetItemUserData(hwnd.i, item.i)
	Protected.TCITEM tci
	Protected.TAB_CTRL_ITEM_EXTRA *ie
	
	tci\mask = #TCIF_PARAM
	SendMessage_(hwnd, #TCM_GETITEM, item, @tci)
	*ie = tci\lParam
	
	If *ie
		ProcedureReturn *ie\userData
	EndIf
EndProcedure

Procedure tabCtrl_GetUpDownIfVisible(hwTab.i)
	Protected.i hwUd

	hwUd = GetWindow_(hwTab, #GW_CHILD)
	If hwUd And IsWindowVisible_(hwUd)
		ProcedureReturn hwUd
	EndIf 
EndProcedure

Procedure tabCtrl_GetUpDownRect(hwTab.i, *rc.RECT)
	Protected.i hwBtn
	
	hwBtn = GetWindow_(hwTab, #GW_CHILD)
	If hwBtn And IsWindowVisible_(hwBtn)
		GetClientRect_(hwBtn, *rc)
				
		ProcedureReturn #True
		
	Else
		ProcedureReturn #False
	EndIf 
EndProcedure

Procedure tabCtrl_InsertItem(hwTab, item.l, text.s)
	Protected.TCITEM tci

	tci\mask = #TCIF_TEXT | #TCIF_PARAM
	tci\pszText = @text
	tci\lParam = AllocateMemory(SizeOf(TAB_CTRL_ITEM_EXTRA))
	
	If item = -1
		item = SendMessage_(hwTab, #TCM_GETITEMCOUNT, 0, 0)
	EndIf 
	
	SendMessage_(hwTab, #TCM_INSERTITEM, item, @tci)
EndProcedure

Procedure tabCtrl_InsertItem2(hwTab, item.l, text.s, maxTextWidth.l)
	Protected.TCITEM tci
	Protected.TAB_CTRL_ITEM_EXTRA *ie
	Protected.s text2

	*ie = AllocateMemory(SizeOf(TAB_CTRL_ITEM_EXTRA))
	tci\mask = #TCIF_TEXT | #TCIF_PARAM
	tci\lParam = *ie

	*ie\itemText = text
	text2 = tabCtrl_TruncateItemText(hwTab, text, maxTextWidth)
	tci\pszText = @text2
	
	If item = -1
		item = SendMessage_(hwTab, #TCM_GETITEMCOUNT, 0, 0)
	EndIf 
	
	SendMessage_(hwTab, #TCM_INSERTITEM, item, @tci)
EndProcedure

Procedure tabCtrl_DeleteItem(hwnd.i, item.i)
	Protected.TAB_CTRL_ITEM_EXTRA *ie
	
	*ie = tabCtrl_GetItemParam(hwnd, item)
	
	If SendMessage_(hwnd, #TCM_DELETEITEM, item, 0)
		If *ie
			*ie\itemText = #Null$
			FreeMemory(*ie)
		EndIf 
	EndIf 
EndProcedure

Procedure.s tabCtrl_GetItemText(hwTab.i, item.i)
	Protected.TCITEM tci
	Protected.l bufLen
	Protected.i buf
	Protected.s txt
	
	bufLen = (#MAX_PATH + 1) * SizeOf(CHARACTER)
	
	buf = AllocateMemory(bufLen)
	
	tci\mask = #TCIF_TEXT
	tci\pszText = buf
	tci\cchTextMax = bufLen
	SendMessage_(hwTab, #TCM_GETITEM, item, @tci)
	
	txt = PeekS(buf)
	FreeMemory(buf)
	
	ProcedureReturn txt
EndProcedure

Procedure tabCtrl_SetItemText(hwnd.i, item.i, txt.s)
	Protected.TCITEM tci

	tci\mask = #TCIF_TEXT
	tci\pszText = @txt
	
	ProcedureReturn SendMessage_(hwnd, #TCM_SETITEM, item, @tci)
EndProcedure

Procedure tabCtrl_TrackMouse(hwTab.i)
	Protected.TRACKMOUSEEVENT tme

	tme\cbSize = SizeOf(TRACKMOUSEEVENT)
	tme\dwFlags = #TME_LEAVE
	tme\hwndTrack = hwTab
	tme\dwHoverTime = 0
	TrackMouseEvent_(@tme)
EndProcedure

Procedure tabCtrl_HitTest(hwnd, x.w, y.w)
	Protected.TCHITTESTINFO tch

	tch\pt\x = x
	tch\pt\y = y
	
	ProcedureReturn SendMessage_(hwnd, #TCM_HITTEST, 0, @tch)
EndProcedure

Procedure tabCtrl_InvalidateItem(hwnd, item.l)
	Protected.RECT rcItem, rcBtn, rcTab, rcInt
	
	If tabCtrl_GetItemRect(hwnd, item, @rcItem)
		If tabCtrl_GetUpDownRect(hwnd, @rcBtn)
			GetClientRect_(hwnd, @rcTab)
			rcBtn\left = rcTab\right - rcBtn\right
			rcBtn\right = rcTab\right

			If IntersectRect_(@rcInt, @rcItem, @rcBtn)
				rcItem\right = rcBtn\left
			EndIf 
		EndIf
		
		InvalidateRect_(hwnd, @rcItem, #True)
	EndIf 
EndProcedure

Procedure tabCtrl_On_MOUSEMOVE(hwnd.i, msg.l,  wparam.i, lparam.i)
	Protected.TAB_CTRL_DATA *td
	Protected.l tabIndex
	Protected.RECT rcClose
	
	*td = tabCtrl_GetTabData(hwnd)
	If *td 
		tabIndex =  tabCtrl_HitTest(hwnd, LOWORD(lparam), HIWORD(lparam))
		If tabIndex = -1 : ProcedureReturn : EndIf 
		
		tabCtrl_GetCloseButtonRect(hwnd, tabIndex, @rcClose)

		If drw_PointInRect(LOWORD(lparam), HIWORD(lparam), rcClose)
			If *td\closeBtnHot = -1
				*td\closeBtnHot = tabIndex
				tabCtrl_InvalidateItem(hwnd, tabIndex)
			EndIf 

		ElseIf *td\closeBtnHot <> -1
			*td\closeBtnHot = -1
			tabCtrl_InvalidateItem(hwnd, tabIndex)
		EndIf
		
		If *td\isMouseOver = #False
			;mouse enter
			tabCtrl_TrackMouse(hwnd)
			
			*td\itemHot = tabIndex
			
			*td\isMouseOver = #True
			
			tabCtrl_InvalidateItem(hwnd, *td\itemHot)

		Else
			;mouse move
			If tabIndex <> *td\itemHot 
				;Invalidate previous hot item
				If *td\itemHot <> -1
					tabCtrl_InvalidateItem(hwnd, *td\itemHot)
				EndIf
			
				*td\itemHot = tabIndex
				tabCtrl_InvalidateItem(hwnd, *td\itemHot)
			EndIf
		EndIf
	EndIf 
EndProcedure

Procedure tabCtrl_On_MOUSELEAVE(hwnd.i, msg.l,  wparam.i, lparam.i)
	Protected.TAB_CTRL_DATA *td

	*td = tabCtrl_GetTabData(hwnd)
	If *td 
		tabCtrl_InvalidateItem(hwnd, *td\itemHot)

		*td\itemHot = -1
		*td\closeBtnHot = -1
		*td\isMouseOver = #False
	EndIf 
EndProcedure

Procedure tabCtrl_On_LBUTTONUP(hwnd.i, msg.l, wparam.i, lparam.i)
	Protected.TAB_CTRL_DATA *td
	Protected.RECT rcClose
	Protected.i tabIndex
	
	*td = tabCtrl_GetTabData(hwnd)
	If *td
		tabIndex =  tabCtrl_HitTest(hwnd, LOWORD(lparam), HIWORD(lparam))
		If tabIndex <> -1
			tabCtrl_GetCloseButtonRect(hwnd, tabIndex, @rcClose)
			If drw_PointInRect(LOWORD(lparam), HIWORD(lparam), rcClose)
				*td\closeBtnDown = #False
				tabCtrl_InvalidateItem(hwnd, tabIndex)
				*td\callback(hwnd, #TAB_CTRL_MSG_CLOSE_BUTTON_CLICK, tabIndex, 0)
			EndIf 
		EndIf 
		
		ProcedureReturn CallWindowProc_(*td\oldProc, hwnd, msg, wparam, lparam)
		
	Else
	
		ProcedureReturn DefWindowProc_(hwnd, msg, wparam, lparam)
	EndIf 
EndProcedure

Procedure tabCtrl_On_LBUTTONDOWN(hwnd.i, msg.l, wparam.i, lparam.i)
	Protected.TAB_CTRL_DATA *td
	Protected.RECT rcClose
	Protected.i tabIndex
	Protected.NMHDR nmh
	
	*td = tabCtrl_GetTabData(hwnd)
	If *td
		tabIndex =  tabCtrl_HitTest(hwnd, LOWORD(lparam), HIWORD(lparam))
		If tabIndex <> -1
			tabCtrl_GetCloseButtonRect(hwnd, tabIndex, @rcClose)
			If drw_PointInRect(LOWORD(lparam), HIWORD(lparam), rcClose)
				*td\closeBtnDown = #True
				tabCtrl_InvalidateItem(hwnd, tabIndex)
				
				ProcedureReturn 0
				
			ElseIf GetWindowLong_(hwnd, #GWL_STYLE) & #TCS_BUTTONS = #TCS_BUTTONS
				tabCtrl_SetCurSel(hwnd, tabIndex)
				nmh\code = #TCN_SELCHANGE
				nmh\hwndFrom = hwnd
				SendMessage_(GetParent_(hwnd), #WM_NOTIFY, GetWindowLong_(hwnd, #GWL_ID), @nmh)
				
				ProcedureReturn 0
			EndIf 
		EndIf 
		
		ProcedureReturn CallWindowProc_(*td\oldProc, hwnd, msg, wparam, lparam)
		
	Else
		ProcedureReturn DefWindowProc_(hwnd, msg, wparam, lparam)
	EndIf 
EndProcedure

Procedure tabCtrl_On_RBUTTONUP(hwnd.i, msg.l, wparam.i, lparam.i)
	Protected.TAB_CTRL_DATA *td

	*td = tabCtrl_GetTabData(hwnd)
	
	If *td
		*td\callback(hwnd, #TAB_CTRL_MSG_RBUTTONUP, wparam, lparam)
		ProcedureReturn CallWindowProc_(*td\oldProc, hwnd, msg, wparam, lparam)
		
	Else
	
		ProcedureReturn DefWindowProc_(hwnd, msg, wparam, lparam)
	EndIf 
EndProcedure

Procedure tabCtrl_On_Default(hwnd.i, msg.l,  wparam.i, lparam.i)
	Protected.TAB_CTRL_DATA *td
	
	*td = tabCtrl_GetTabData(hwnd)
	
	If *td And *td\oldProc
		ProcedureReturn CallWindowProc_(*td\oldProc, hwnd, msg, wparam, lparam)
		
	Else
		ProcedureReturn DefWindowProc_(hwnd, msg, wparam, lparam)
	EndIf 
EndProcedure

Procedure tabCtrl_DrawBackground(*di.DRAWITEMSTRUCT)
	Protected.TAB_CTRL_DATA *td
	Protected.l colorBack
	
	*td = GetWindowLongPtr_(*di\hwndItem, #GWLP_USERDATA)
	If *td
		If *di\itemID = SendMessage_(*di\hwndItem, #TCM_GETCURSEL, 0, 0)
			colorBack = #COLOR_WINDOW + 1

		ElseIf *di\itemID = *td\itemHot
			colorBack = #COLOR_3DLIGHT + 1
			
		Else
			colorBack = #COLOR_3DFACE + 1
		EndIf 
		
		If *di\itemID = tabCtrl_GetCurSel(*di\hwndItem)
			*di\rcItem\left + GetSystemMetrics_(#SM_CYEDGE)
		Else
		
		EndIf 

		FillRect_(*di\hDC, @*di\rcItem, colorBack)
	EndIf 
EndProcedure

Procedure tabCtrl_GetCloseButtonRect(hwnd.i, item.i, *rc.RECT)
	Protected.TAB_CTRL_DATA *td
	Protected.l closeSize
	
	*td = tabCtrl_GetTabData(hwnd)
	If *td
		tabCtrl_GetItemRect(hwnd, item, *rc)
		
		closeSize = *td\fontHeight * 1.3
	
		*rc\right = *rc\right - DesktopScaledX(#TAB_CTRL_ITEM_PAD_RIGHT) - GetSystemMetrics_(#SM_CYEDGE) 
		*rc\left = *rc\right - closeSize
		*rc\top = ((*rc\bottom - closeSize) / 2) + GetSystemMetrics_(#SM_CXEDGE)
		*rc\bottom = *rc\top + closeSize
	EndIf 
EndProcedure

Procedure tabCtrl_DrawCloseButton(*di.DRAWITEMSTRUCT, *rcClose.RECT)
	Protected.TAB_CTRL_DATA *td
	Protected.l pad
	Protected.RECT rcFill
		
	*td = tabCtrl_GetTabData(*di\hwndItem)
	If *td
		rcFill\left = *rcClose\left
		rcFill\right = *rcClose\right + 1
		rcFill\top = *rcClose\top
		rcFill\bottom = *rcClose\bottom + 1
					
		If *td\closeBtnHot = *di\itemID
			If *td\closeBtnDown
				FillRect_(*di\hDC, @rcFill, #COLOR_3DSHADOW + 1)
			
			Else 
				FillRect_(*di\hDC, @rcFill, #COLOR_ACTIVEBORDER + 1)
			EndIf 
		EndIf
		
		pad = DesktopScaledX(#TAB_CTRL_CLOSE_BTN_PAD)
		*rcClose\left + pad
		*rcClose\right - pad
		*rcClose\top + pad
		*rcClose\bottom - pad
				
		SelectObject_(*di\hDC, *td\closeBtnPen)
		MoveToEx_(*di\hDC, *rcClose\left, *rcClose\top, #Null)
		LineTo_(*di\hDC, *rcClose\right, *rcClose\bottom)
		MoveToEx_(*di\hDC, *rcClose\left, *rcClose\bottom, #Null)
		LineTo_(*di\hDC, *rcClose\right, *rcClose\top)
	EndIf 
EndProcedure

Procedure tabCtrl_DrawText(*di.DRAWITEMSTRUCT, *rcClose.RECT, *td.TAB_CTRL_DATA)
	Protected.s text
	Protected.RECT rcItem
	Protected.TAB_CTRL_ITEM_EXTRA *ie
	
	*ie = tabCtrl_GetItemParam(*di\hwndItem, *di\itemID)
	If *ie
		If *td\opts\flags & #TAB_CTRL_FLAG_TRUNCATE_TEXT = #TAB_CTRL_FLAG_TRUNCATE_TEXT
			text = *ie\itemText
			
		Else 
			text = tabCtrl_GetItemText(*di\hwndItem, *di\itemID)
		EndIf
		
		tabCtrl_GetItemRect(*di\hwndItem, *di\itemID, @rcItem)
		
		SetBkMode_(*di\hDC, #TRANSPARENT)
		rcItem\left + DesktopScaledX(#TAB_CTRL_ITEM_PAD_LEFT)
		rcItem\right = *rcClose\left - DesktopScaledX(#TAB_CTRL_ITEM_PAD_LEFT)
		DrawText_(*di\hDC, @*ie\itemText, -1, @rcItem, #DT_LEFT | #DT_VCENTER | #DT_SINGLELINE | #DT_END_ELLIPSIS)
	EndIf 
	

EndProcedure

Procedure tabCtrl_Parent_On_DRAWITEM(hwParent.i, msg.l, wparam.i, *di.DRAWITEMSTRUCT)
	Protected.TAB_CTRL_DATA *td
	Protected.RECT rcClose

	*td = tabCtrl_GetTabData(*di\hwndItem)
	If *td
		tabCtrl_DrawBackground(*di)
		tabCtrl_GetCloseButtonRect(*di\hwndItem, *di\itemID, @rcClose)
		tabCtrl_DrawCloseButton(*di, @rcClose)
		tabCtrl_DrawText(*di, @rcClose, *td)
	
		ProcedureReturn #True
	EndIf 
EndProcedure

Procedure tabCtrl_On_SETFONT(hwnd.i, msg.l, wparam.i, lparam.i)
	Protected.TAB_CTRL_DATA *td
	Protected.LOGFONT lf
	
	*td = tabCtrl_GetTabData(hwnd)
	If *td
		GetObject_(wparam, SizeOf(LOGFONT), @lf)
		If lf\lfHeight < 0
			*td\fontHeight = lf\lfHeight * -1
			
		Else
			*td\fontHeight = lf\lfHeight
		EndIf

		ProcedureReturn CallWindowProc_(*td\oldProc, hwnd, msg, wparam, lparam)

	Else
		ProcedureReturn DefWindowProc_(hwnd, msg, wparam, lparam)
	EndIf 
EndProcedure

Procedure tabCtrl_On_MOUSEWHEEL(hwnd.i, msg.l, wparam.i, lparam.i)
	Protected.TAB_CTRL_DATA *td
	Protected.w dist
	Protected.i hwUd
	Protected.i pos, upLimit

	*td = tabCtrl_GetTabData(hwnd)
	If *td
		hwUd = tabCtrl_GetUpDownIfVisible(hwnd)
		If hwUd
			dist = HIWORD(wparam)
			pos = SendMessage_(hwUd, #UDM_GETPOS32, 0, 0)
			SendMessage_(hwUd, #UDM_GETRANGE32, 0, @upLimit)
			
			If dist > 0
				pos + 1
				
			Else
				pos - 1
			EndIf
			
			If pos < 0 : pos = 0 : EndIf 
			If pos > upLimit : pos = upLimit : EndIf 
			
			SendMessage_(hwnd, #WM_HSCROLL, MAKELONG(#SB_THUMBPOSITION, pos), hwUd)
			SendMessage_(hwnd, #WM_HSCROLL, MAKELONG(#SB_ENDSCROLL, pos), hwUd)
		EndIf 
		
		ProcedureReturn CallWindowProc_(*td\oldProc, hwnd, msg, wparam, lparam)
	Else
	
		ProcedureReturn DefWindowProc_(hwnd, msg, wparam, lparam)
	EndIf 
EndProcedure

Procedure tabCtrl_On_DESTROY(hwnd.i, msg.l, wparam.i, lparam.i)
	Protected.TAB_CTRL_DATA *td
	
	*td = tabCtrl_GetTabData(hwnd)
	If *td
		DeleteObject_(*td\closeBtnPen)
		SetWindowLongPtr_(hwnd, #GWLP_WNDPROC, *td\oldProc)
		FreeMemory(*td)
	EndIf
EndProcedure

Procedure tabCtrl_Proc(hwnd.i, msg.l,  wparam.i, lparam.i)
	Select msg
		Case #WM_MOUSEMOVE : ProcedureReturn tabCtrl_On_MOUSEMOVE(hwnd, msg,  wparam, lparam)
					
		Case #WM_MOUSELEAVE : ProcedureReturn tabCtrl_On_MOUSELEAVE(hwnd, msg, wparam, lparam)
		
		Case #WM_LBUTTONUP : ProcedureReturn tabCtrl_On_LBUTTONUP(hwnd, msg, wparam, lparam)
		
		Case #WM_LBUTTONDOWN : ProcedureReturn tabCtrl_On_LBUTTONDOWN(hwnd, msg, wparam, lparam)
		
		Case #WM_RBUTTONUP : ProcedureReturn tabCtrl_On_RBUTTONUP(hwnd, msg, wparam, lparam)
				
		Case #WM_SETFONT : ProcedureReturn tabCtrl_On_SETFONT(hwnd, msg, wparam, lparam)
		
		Case #WM_MOUSEWHEEL : ProcedureReturn tabCtrl_On_MOUSEWHEEL(hwnd, msg, wparam, lparam)
				
		Case #WM_DESTROY : ProcedureReturn tabCtrl_On_DESTROY(hwnd, msg, wparam, lparam)
			
		Default : ProcedureReturn tabCtrl_On_Default(hwnd, msg, wparam, lparam)
	EndSelect
EndProcedure
