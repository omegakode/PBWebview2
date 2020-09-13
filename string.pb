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

Macro str_FreeBstr(bstr)
	SysFreeString_(bstr)
EndMacro