Macro enum_HasFlag(value, flag)
	Bool((value) & (flag) = flag)
EndMacro 

Procedure enum_PutFlag(*value.LONG, flag.l)
	*value\l | flag
EndProcedure

Procedure enum_RemoveFlag(*value.LONG, flag.l)
	*value\l & ~flag
EndProcedure