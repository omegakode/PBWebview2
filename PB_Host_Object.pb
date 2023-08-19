;PB_Host_Object.pb
;Copyright(c) Justin 2020

; XIncludeFile "windows\oaidl.pbi"
; XIncludeFile "vector.pbi"
; XIncludeFile "VCall.pb"

EnableExplicit

;- CONSTANTS

;- Enum Method
#WV2_PBOBJ_METHOD_CALL_RT_PROC = "callRTProc"	;Call a pb runtime procedure with no return value.
#WV2_PBOBJ_METHOD_CALL_RT_PROC_NUM = "callRTProcNum"	;Call a pb runtime procedure that returns a number.
#WV2_PBOBJ_METHOD_CALL_RT_PROC_STR = "callRTProcStr"	;Call a pb runtime procedure that returns a string.
#WV2_PBOBJ_METHOD_CALL_RT_PROC_OBJ = "callRTProcObj"	;Call a pb runtime procedure that returns an object.

;Syntax:
;callRTProc(procName, [args..])
;procName	:	runtime procedure name.
;args			:	any number of arguments of any type, must match the pb runtime procedure argument types.
;Supported types:
;javascript number	-> pb double
;javascript string	-> pb integer (bstr)
;javascript object	-> pb integer (IDispatch)
;javascript boolean	-> pb integer (#true / #false)

;- Enum DISPID
Enumeration 1
	#WV2_PBOBJ_DISPID_CALL_RT_PROC
	#WV2_PBOBJ_DISPID_CALL_RT_PROC_NUM
	#WV2_PBOBJ_DISPID_CALL_RT_PROC_STR
	#WV2_PBOBJ_DISPID_CALL_RT_PROC_OBJ
EndEnumeration

;- WV2_PBOBJ
Structure WV2_PBOBJ
	*vt.WV2_PBOBJ_VTABLE_TAG
	refCount.l
	mutex.i
EndStructure

;- WV2_PBOBJ_VTABLE
Structure WV2_PBOBJ_VTABLE_TAG Extends IDispatchVtbl

EndStructure
Global.WV2_PBOBJ_VTABLE_TAG WV2_PBOBJ_VTABLE

;- DECLARES
Declare wv2_PBObj_New()
Declare wv2_PBObj_Free(*this.WV2_PBOBJ)
Declare wv2_PBObj_QueryInterface(*this.WV2_PBOBJ, *iid.IID, *obj.INTEGER)
Declare wv2_PBObj_AddRef(*this.WV2_PBOBJ)
Declare wv2_PBObj_Release(*this.WV2_PBOBJ)
Declare wv2_PBObj_GetTypeInfoCount(*this.WV2_PBOBJ, *pctinfo.LONG)
Declare wv2_PBObj_GetTypeInfo(*this.WV2_PBOBJ, iTInfo.l, lcid.l, ppTInfo.i)
Declare wv2_PBObj_GetIDsOfNames(*this.WV2_PBOBJ, *riid.IID, rgszNames.i, cNames.l, lcid.l, *rgDispId.LONG)
Declare wv2_PBObj_Invoke(*this.WV2_PBOBJ, dispIdMember.l, *riid.IID, lcid.l, wFlags.w, *pDispParams.DISPPARAMS, *pVarResult.VARIANT, *pExcepInfo.EXCEPINFO, *puArgErr.LONG)

Declare wv2_PBObj_Invoke_CallRTProc(retType.w, *pDispParams.DISPPARAMS_, *pVarResult.VARIANT, *pExcepInfo.EXCEPINFO, *puArgErr.LONG)

;- WV2_PBOBJ_VTABLE Construction
WV2_PBOBJ_VTABLE\QueryInterface = @wv2_PBObj_QueryInterface()
WV2_PBOBJ_VTABLE\AddRef = @wv2_PBObj_AddRef()
WV2_PBOBJ_VTABLE\Release = @wv2_PBObj_Release()
WV2_PBOBJ_VTABLE\GetTypeInfoCount = @wv2_PBObj_GetTypeInfoCount()
WV2_PBOBJ_VTABLE\GetTypeInfo = @wv2_PBObj_GetTypeInfo()
WV2_PBOBJ_VTABLE\GetIDsOfNames = @wv2_PBObj_GetIDsOfNames()
WV2_PBOBJ_VTABLE\Invoke = @wv2_PBObj_Invoke()

Procedure wv2_PBObj_New()
	Protected.WV2_PBOBJ *this
	
	*this = AllocateMemory(SizeOf(WV2_PBOBJ))
	*this\vt = @WV2_PBOBJ_VTABLE
	*this\mutex = CreateMutex()
	*this\refCount = 1
	
	ProcedureReturn *this
EndProcedure

Procedure wv2_PBObj_Free(*this.WV2_PBOBJ)
	FreeMutex(*this\mutex)
	FreeMemory(*this)
EndProcedure

Procedure wv2_PBObj_QueryInterface(*this.WV2_PBOBJ, *iid.IID, *obj.INTEGER)
	If CompareMemory(*iid, ?IID_IUnknown, SizeOf(IID)) Or CompareMemory(*iid, ?IID_IDispatch, SizeOf(IID))
		*obj\i = *this
		wv2_PBObj_AddRef(*this)
		
		ProcedureReturn #S_OK
		
	Else
		*obj\i = #Null
		ProcedureReturn #E_NOINTERFACE
	EndIf 
EndProcedure

Procedure wv2_PBObj_AddRef(*this.WV2_PBOBJ)
	*this\refCount = *this\refCount + 1
	
	ProcedureReturn *this\refCount
EndProcedure

Procedure wv2_PBObj_Release(*this.WV2_PBOBJ)
	*this\refCount = *this\refCount - 1
	
	If *this\refCount = 0
		wv2_PBObj_Free(*this)
	EndIf 
EndProcedure

Procedure wv2_PBObj_GetTypeInfoCount(*this.WV2_PBOBJ, *pctinfo.LONG)
	*pctinfo\l = 0
	
	ProcedureReturn #S_OK
EndProcedure

Procedure wv2_PBObj_GetTypeInfo(*this.WV2_PBOBJ, iTInfo.l, lcid.l, ppTInfo.i)
	ProcedureReturn #E_NOTIMPL
EndProcedure

Procedure wv2_PBObj_GetIDsOfNames(*this.WV2_PBOBJ, *riid.IID, *rgszNames.VECTOR_INT, cNames.l, lcid.l, *rgDispId.VECTOR_LONG)
	Select PeekS(*rgszNames\item[0])
		Case #WV2_PBOBJ_METHOD_CALL_RT_PROC
			*rgDispId\item[0] = #WV2_PBOBJ_DISPID_CALL_RT_PROC
			ProcedureReturn #S_OK
			
		Case #WV2_PBOBJ_METHOD_CALL_RT_PROC_NUM
			*rgDispId\item[0] = #WV2_PBOBJ_DISPID_CALL_RT_PROC_NUM
			ProcedureReturn #S_OK
			
		Case #WV2_PBOBJ_METHOD_CALL_RT_PROC_STR
			*rgDispId\item[0] = #WV2_PBOBJ_DISPID_CALL_RT_PROC_STR
			ProcedureReturn #S_OK
			
		Case #WV2_PBOBJ_METHOD_CALL_RT_PROC_OBJ
			*rgDispId\item[0] = #WV2_PBOBJ_DISPID_CALL_RT_PROC_OBJ
			ProcedureReturn #S_OK
			
		Default
			*rgDispId\Item[0] = #DISPID_UNKNOWN
			ProcedureReturn #DISP_E_UNKNOWNNAME
	EndSelect
EndProcedure

Procedure wv2_PBObj_Invoke(*this.WV2_PBOBJ, dispIdMember.l, *riid.IID, lcid.l, wFlags.w, *pDispParams.DISPPARAMS_, *pVarResult.VARIANT, *pExcepInfo.EXCEPINFO, *puArgErr.LONG)		
	If wFlags & #DISPATCH_METHOD = #DISPATCH_METHOD
		Select dispIdMember
			Case #WV2_PBOBJ_DISPID_CALL_RT_PROC
				ProcedureReturn wv2_PBObj_Invoke_CallRTProc(#VT_EMPTY, *pDispParams, *pVarResult, *pExcepInfo, *puArgErr)
		
			Case #WV2_PBOBJ_DISPID_CALL_RT_PROC_NUM
				ProcedureReturn wv2_PBObj_Invoke_CallRTProc(#VT_R8, *pDispParams, *pVarResult, *pExcepInfo, *puArgErr)
				
			Case #WV2_PBOBJ_DISPID_CALL_RT_PROC_STR
				ProcedureReturn wv2_PBObj_Invoke_CallRTProc(#VT_BSTR, *pDispParams, *pVarResult, *pExcepInfo, *puArgErr)

			Case #WV2_PBOBJ_DISPID_CALL_RT_PROC_OBJ
				ProcedureReturn wv2_PBObj_Invoke_CallRTProc(#VT_DISPATCH, *pDispParams, *pVarResult, *pExcepInfo, *puArgErr)

			Default
				ProcedureReturn #DISP_E_MEMBERNOTFOUND
		EndSelect
		
	Else
	
		ProcedureReturn #DISP_E_MEMBERNOTFOUND
	EndIf
EndProcedure

Procedure wv2_PBObj_Invoke_CallRTProc(retType.w, *pDispParams.DISPPARAMS_, *pVarResult.VARIANT, *pExcepInfo.EXCEPINFO, *puArgErr.LONG)
	Protected.s procName
	Protected.i procAddr
			
	;Zero params error.
	If *pDispParams\cArgs < 1 ;error
		ProcedureReturn #E_INVALIDARG
	EndIf 
	
	;Proc name, must be a string.
	If *pDispParams\rgvarg\item[*pDispParams\cArgs - 1]\vt <> #VT_BSTR
		ProcedureReturn #E_INVALIDARG
	EndIf 
	
	procName = PeekS(*pDispParams\rgvarg\item[*pDispParams\cArgs - 1]\bstrVal)
	procAddr = GetRuntimeInteger(procName + "()")
	;Proc not found.
	If procAddr = 0
		ProcedureReturn #E_INVALIDARG
	EndIf 
	
	CompilerIf #PB_Compiler_Backend = #PB_Backend_Asm
		Protected.s vcTypes
		Protected.l pVCArgs, iArgVC, iArg
		
		;Args
		vcTypes = ""
		If *pDispParams\cArgs > 1
			Dim vcArgs.VCall::VCArgument(*pDispParams\cArgs - 2)
			iArgVC = 0
			
			For iArg = *pDispParams\cArgs - 2 To 0 Step -1 ;Params are in reverse order.
				Select *pDispParams\rgvarg\item[iArg]\vt
					Case #VT_I4
						vcTypes + "d"
						vcArgs(iArgVC)\d = *pDispParams\rgvarg\item[iArg]\lVal
						
					Case #VT_BOOL
						vcTypes + "i"
						If *pDispParams\rgvarg\item[iArg]\boolVal = #VARIANT_TRUE
							vcArgs(iArgVC)\i = #True
							
						Else
							vcArgs(iArgVC)\i = #False
						EndIf 
						
					Case #VT_R8
						vcTypes + "d"
						vcArgs(iArgVC)\d = *pDispParams\rgvarg\item[iArg]\dblVal
						
					Case #VT_BSTR
						vcTypes + "i"
						vcArgs(iArgVC)\i = *pDispParams\rgvarg\item[iArg]\bstrVal
						
					Case #VT_DISPATCH
						vcTypes + "i"
						vcArgs(iArgVC)\i = *pDispParams\rgvarg\item[iArg]\pdispVal
				EndSelect
				
				iArgVC + 1
			Next 
			
			pVCArgs = @vcArgs()
			
		Else ;No args
			pVCArgs = #Null
		EndIf 
		
		;Result
		*pVarResult\vt = retType
		Select retType
			Case #VT_R8
				*pVarResult\dblVal = VCall::VCallD(procAddr, pVCArgs, @vcTypes)
		
			Case #VT_BSTR
				*pVarResult\bstrVal = VCall::VCall(procAddr, pVCArgs, @vcTypes)
				
			Case #VT_DISPATCH
				*pVarResult\pdispVal = VCall::VCall(procAddr, pVCArgs, @vcTypes)
				
			Case #VT_EMPTY
				VCall::VCall(procAddr, pVCArgs, @vcTypes)
		EndSelect
	
	CompilerElseIf #PB_Compiler_Backend = #PB_Backend_C
		Protected.ffi_cif cif
		Protected.d result
		Protected.l iArgFFI, iArg
		Protected.i ffiRetType, ffiRetVal, ffiArgsCount, pArgTypes
		Protected.d dVal

		ffiArgsCount = *pDispParams\cArgs - 1
		If ffiArgsCount > 0
			Dim *arg_types.ffi_type(ffiArgsCount - 1)
			Dim *arg_values(ffiArgsCount - 1)
			
			pArgTypes = @*arg_types()

			iArgFFI = 0
			For iArg = *pDispParams\cArgs - 2 To 0 Step -1 ;Params are in reverse order.
				Select *pDispParams\rgvarg\item[iArg]\vt
					Case #VT_I4
						*arg_types(iArgFFI) = ffi_type_double
						*pDispParams\rgvarg\item[iArg]\dblVal = *pDispParams\rgvarg\item[iArg]\lVal
						*arg_values(iArgFFI) = @*pDispParams\rgvarg\item[iArg]\dblVal
						
					Case #VT_R8
						*arg_types(iArgFFI) = ffi_type_double
						*arg_values(iArgFFI) = @*pDispParams\rgvarg\item[iArg]\dblVal
						
					Case #VT_BSTR
						*arg_types(iArgFFI) = ffi_type_pointer
						*arg_values(iArgFFI) = @*pDispParams\rgvarg\item[iArg]\bstrVal

					Case #VT_DISPATCH
						*arg_types(iArgFFI) = ffi_type_pointer
						*arg_values(iArgFFI) = @*pDispParams\rgvarg\item[iArg]\pdispVal
						
					Case #VT_BOOL
						*arg_types(iArgFFI) = ffi_type_sint16
						
						If *pDispParams\rgvarg\item[iArg]\boolVal = #VARIANT_TRUE
							*pDispParams\rgvarg\item[iArg]\boolVal = #True
							
						Else
							*pDispParams\rgvarg\item[iArg]\boolVal = #False
						EndIf 
						
						*arg_values(iArgFFI) = @*pDispParams\rgvarg\item[iArg]\boolVal
				EndSelect
				
				iArgFFI + 1
			Next 
			
		Else ;no params
			pArgTypes = #Null 
		EndIf 
			
		;Result
		*pVarResult\vt = retType
		Select retType
			Case #VT_R8
				ffiRetType = @ffi_type_double
				ffiRetVal = @*pVarResult\dblVal
				
			Case #VT_BSTR
				ffiRetType = @ffi_type_pointer
				ffiRetVal = @*pVarResult\bstrVal
				
			Case #VT_DISPATCH
				ffiRetType = @ffi_type_pointer
				ffiRetVal = @*pVarResult\pdispVal
				
			Case #VT_EMPTY
				ffiRetType = @ffi_type_void
				ffiRetVal = #Null
		EndSelect
			
		If ffi_prep_cif(@cif, #FFI_DEFAULT_ABI, ffiArgsCount, ffiRetType, pArgTypes) = #FFI_OK
			ffi_call(@cif, procAddr, ffiRetVal, @*arg_values())
		EndIf 
	CompilerEndIf
	
	ProcedureReturn #S_OK
EndProcedure





