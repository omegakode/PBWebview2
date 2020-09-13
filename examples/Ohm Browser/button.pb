;button.pb

EnableExplicit

IncludeFile "drawing.pb"

;- Enum BUTTON_STATE
EnumerationBinary
	#BUTTON_STATE_NORMAL
	#BUTTON_STATE_HIGHLIGHTED
	#BUTTON_STATE_PUSHED
EndEnumeration

Enumeration 1
	#BUTTON_MSG_DRAW
EndEnumeration

Prototype btn_Callback(btn.i, msg.i)

;- BUTTON_DATA
Structure BUTTON_DATA
	state.l
	callBack.btn_Callback
	oldProc.i
EndStructure

Macro btn_GetData(btn)
	GetWindowLongPtr_(GadgetID(btn), #GWLP_USERDATA)
EndMacro

Procedure btn_Draw(btn.i)
	Protected.BUTTON_DATA *bd
		
	*bd = btn_GetData(btn)
	If *bd
		*bd\callBack(btn, #BUTTON_MSG_DRAW)
	EndIf 
EndProcedure

Procedure btn_OnFocus()	
	btn_Draw(EventGadget())
EndProcedure

Procedure btn_OnLostFocus()	
	btn_Draw(EventGadget())
EndProcedure

Procedure btn_OnMouseEnter()
	Protected.BUTTON_DATA *bd
	Protected.i gd
	
	gd = EventGadget()
	*bd = btn_GetData(gd)
	enum_PutFlag(@*bd\state, #BUTTON_STATE_HIGHLIGHTED)
	
	btn_Draw(gd)
EndProcedure

Procedure btn_OnMouseLeave()
	Protected.BUTTON_DATA *bd
	Protected.i gd
	
	gd = EventGadget()
	*bd = btn_GetData(gd)
	enum_RemoveFlag(@*bd\state, #BUTTON_STATE_HIGHLIGHTED)
	
	btn_Draw(gd)
EndProcedure

Procedure btn_OnLeftButtonDown()
	Protected.BUTTON_DATA *bd
	Protected.i gd
	
	gd = EventGadget()
	*bd = btn_GetData(gd)
	enum_PutFlag(@*bd\state, #BUTTON_STATE_PUSHED)
	
	btn_Draw(gd)
EndProcedure

Procedure btn_OnLeftButtonUp()
	Protected.BUTTON_DATA *bd
	Protected.i gd
	
	gd = EventGadget()
	*bd = btn_GetData(gd)
	enum_RemoveFlag(@*bd\state, #BUTTON_STATE_PUSHED)
	
	btn_Draw(gd)
EndProcedure

Procedure btn_OnResize()
	btn_Draw(EventGadget())
EndProcedure

Procedure btn_On_Default(hwnd.i, msg.l, wparam.i, lparam.i)
	Protected.BUTTON_DATA *bd
	
	*bd = GetWindowLongPtr_(hwnd, #GWLP_USERDATA)
	If *bd
		ProcedureReturn CallWindowProc_(*bd\oldProc, hwnd, msg, wparam, lparam)
		
	Else
		ProcedureReturn DefWindowProc_(hwnd, msg, wparam, lparam)
	EndIf 
EndProcedure

Procedure btn_On_Destroy(hwnd.i, msg.l, wparam.i, lparam.i)
	Protected.BUTTON_DATA *bd
	
	*bd = GetWindowLongPtr_(hwnd, #GWLP_USERDATA)
	If *bd
		SetWindowLongPtr_(hwnd, #GWLP_WNDPROC, *bd\oldProc)
		FreeMemory(*bd)
	EndIf 
EndProcedure

Procedure btn_Proc(hwnd.i, msg.l, wparam.i, lparam.i)
	Select msg
		;Prevent receiving focus when clicking.
		Case #WM_MOUSEACTIVATE : ProcedureReturn 0
		
		Case #WM_DESTROY : ProcedureReturn btn_On_Destroy(hwnd, msg, wparam, lparam)

		Default : ProcedureReturn btn_On_Default(hwnd, msg, wparam, lparam)
	EndSelect
EndProcedure

Procedure btn_Create(x.l, y.l, width.l, height.l, callback.btn_Callback, draw.b = #True)
	Protected.i btn
	Protected.BUTTON_DATA *bd
	
	*bd = AllocateMemory(SizeOf(BUTTON_DATA))
	*bd\callBack = callback
	
	btn = CanvasGadget(#PB_Any, x, y, width, height, #PB_Canvas_Keyboard)
	SetGadgetData(btn, *bd)
	*bd\oldProc = SetWindowLongPtr_(GadgetID(btn), #GWLP_WNDPROC, @btn_Proc())
	SetWindowLongPtr_(GadgetID(btn), #GWLP_USERDATA, *bd)
	
	BindGadgetEvent(btn, @btn_OnFocus(), #PB_EventType_Focus)
	BindGadgetEvent(btn, @btn_OnLostFocus(), #PB_EventType_LostFocus)
	BindGadgetEvent(btn, @btn_OnMouseEnter(), #PB_EventType_MouseEnter)
	BindGadgetEvent(btn, @btn_OnMouseLeave(), #PB_EventType_MouseLeave)
	BindGadgetEvent(btn, @btn_OnResize(), #PB_EventType_Resize)
	BindGadgetEvent(btn, @btn_OnLeftButtonDown(), #PB_EventType_LeftButtonDown)
	BindGadgetEvent(btn, @btn_OnLeftButtonUp(), #PB_EventType_LeftButtonUp)

	If draw
		btn_Draw(btn)
	EndIf 
	
	ProcedureReturn btn
EndProcedure



