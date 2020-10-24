EnableExplicit

Procedure str_MakeCoMemString(str.s)
	Protected.I byteLen, buf
	
	byteLen = StringByteLength(str) + SizeOf(CHARACTER)
	buf = CoTaskMemAlloc_(byteLen)
	If buf
		PokeS(buf, str)
	EndIf 
	
	ProcedureReturn buf
EndProcedure

Macro str_FreeCoMemString(memStr)
	CoTaskMemFree_(memStr)
EndMacro

Procedure.s str_GetCoMemString(str.i)	
	If str
		ProcedureReturn PeekS(str)
	EndIf 
EndProcedure

Procedure.s str_GetCoMemString2(str.i, free.b = #True)
	Protected.s ret
	
	If str
		ret = PeekS(str)
		
		If free
			str_FreeCoMemString(str)
		EndIf 
	EndIf 
	
	ProcedureReturn ret
EndProcedure

Macro str_FreeBstr(bstr)
	SysFreeString_(bstr)
EndMacro