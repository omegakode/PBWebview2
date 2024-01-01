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

Procedure str_MakeStringArray(count.l)
	If count <= 0 : ProcedureReturn 0 : EndIf 
	
	ProcedureReturn CoTaskMemAlloc_(count * SizeOf(INTEGER))
EndProcedure

Procedure str_FreeStringArray(*arr.VECTOR_INT, count.l)
	Protected.i index
	
	If *arr = #Null Or count <= 0 : ProcedureReturn #False : EndIf 
	
	For index = 0 To count - 1
		CoTaskMemFree_(*arr\item[index])
	Next 
	
	CoTaskMemFree_(*arr)
	
	ProcedureReturn #True
EndProcedure

Procedure str_PutStringArrayElement(*arr.VECTOR_INT, index.l, st.s)
	If index < 0 Or *arr = #Null: ProcedureReturn #False : EndIf
	
	*arr\item[index] = str_MakeCoMemString(st)
	ProcedureReturn #True
EndProcedure

Procedure.s str_GetStringArrayElement(*arr.VECTOR_INT, index.l)
	If index < 0 Or *arr = #Null: ProcedureReturn "" : EndIf
	
	ProcedureReturn PeekS(*arr\item[index])
EndProcedure

Procedure str_CopyStringArray(*arr.VECTOR_INT, count.l)
	Protected.VECTOR_INT *retArr
	Protected.l index
	
	If *arr = #Null Or count <= 0 : ProcedureReturn #Null : EndIf
	
	*retArr = str_MakeStringArray(count)
	If *retArr
		For index = 0 To count - 1
			*retArr\item[index] = str_MakeCoMemString(PeekS(*arr\item[index]))
		Next 
	EndIf
	
	ProcedureReturn *retArr
EndProcedure
