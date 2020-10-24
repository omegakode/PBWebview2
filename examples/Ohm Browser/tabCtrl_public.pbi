;tabCtrl_public.pbi

;- ENUM TAB_CTRL_FLAG
EnumerationBinary
	#TAB_CTRL_FLAG_TRUNCATE_TEXT
EndEnumeration

;- ENUM TAB_MSG
Enumeration UserMsg #WM_USER
	#TAB_CTRL_MSG_CLOSE_BUTTON_CLICK
	#TAB_CTRL_MSG_RBUTTONUP
EndEnumeration

;- TAB_CTRL_OPTIONS
Structure TAB_CTRL_OPTIONS
	flags.l
EndStructure

Prototype tabCtrl_Callback(hwnd.i, msg.l, param1.i, param2.i)

;- DECLARES
Declare tabCtrl_Create(hwParent.i, x.l, y.l, w.l, h.l, callback.tabCtrl_Callback, *opts.TAB_CTRL_OPTIONS = #Null)
Declare tabCtrl_GetUserData(hwnd.i)
Declare tabCtrl_SetUserData(hwnd.i, dat.i)
Declare tabCtrl_GetTabsHeight(hwnd.i)
Declare tabCtrl_SetItemUserData(hwnd.i, item.i, dat.i)
Declare tabCtrl_GetItemUserData(hwnd.i, item.i)
Declare tabCtrl_InsertItem(hwnd, item.l, text.s, icon.i = 0)
Declare tabCtrl_SetItemText(hwnd.i, item.i, txt.s)
Declare.s tabCtrl_GetItemText(hwnd.i, item.i)
Declare tabCtrl_SetItemText2(hwnd.i, item.i, text.s, maxWidth.l)
Declare.s tabCtrl_GetItemText2(hwnd.i, item.i)
Declare tabCtrl_Parent_On_DRAWITEM(hwParent.i, msg.l, wparam.i, *di.DRAWITEMSTRUCT)
Declare tabCtrl_DeleteItem(hwnd.i, item.i)

Macro tabCtrl_Move(hwnd, x, y, w, h, r = #True)
	MoveWindow_(hwnd, DesktopScaledX(x), DesktopScaledY(y), DesktopScaledX(w), DesktopScaledY(h), r)
EndMacro 

Macro tabCtrl_GetItemCount(hwnd)
	SendMessage_(hwnd, #TCM_GETITEMCOUNT, 0, 0)
EndMacro

Macro tabCtrl_GetCurSel(hwnd)
	SendMessage_(hwnd, #TCM_GETCURSEL, 0, 0)
EndMacro

Macro tabCtrl_GetItemRect(hwnd, item, prc)
	SendMessage_(hwnd, #TCM_GETITEMRECT, item, prc)
EndMacro

Macro tabCtrl_SetCurSel(hwnd, item)
	SendMessage_(hwnd, #TCM_SETCURSEL, item, 0)
EndMacro
