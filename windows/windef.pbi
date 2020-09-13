;windef.pbi

Macro HIWORD(Value)
	(((Value) >> 16) & $FFFF)
EndMacro

Macro LOWORD(Value)
	((Value) & $FFFF)
EndMacro

Macro MAKELONG(l, h)
	(((h) << 16) | (l))
EndMacro

;- POINTL
Structure POINTL
	x.l
	y.l
EndStructure


; IDE Options = PureBasic 5.72 (Windows - x64)
; CursorPosition = 12
; Folding = -
; EnableXP
; DPIAware