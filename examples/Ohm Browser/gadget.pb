Macro gadget_Enable(gd, enable)
	DisableGadget(gd, Bool(Not(enable)))
EndMacro

Macro gadget_Show(gd, show)
	HideGadget(gd, Bool(Not(show)))
EndMacro

Macro gadget_GetRight(g)
	(GadgetX(g) + GadgetWidth(g))
EndMacro

Macro gadget_GetClientRectPx(gd, rc)
	GetClientRect_(GadgetID(gd), rc)
EndMacro

Procedure gadget_GetClientPosPx(gd.i, parent.i, *rc.RECT)
	GetWindowRect_(GadgetID(gd), *rc)
	ScreenToClient_(GadgetID(parent), @*rc\left)
	ScreenToClient_(GadgetID(parent), @*rc\right)
EndProcedure

Macro gadget_MovePx(gd, x, y, w, h, r = #True)
	MoveWindow_(GadgetID(gd), x, y, w, h, r)
EndMacro