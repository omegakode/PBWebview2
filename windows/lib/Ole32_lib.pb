;ole32_lib.pb

DeclareModule ole32
	Declare CoWaitForMultipleHandles(dwFlags.l, dwTimeout.l, cHandles.l, pHandles.i, lpdwindex.i)
EndDeclareModule

Module ole32
	EnableExplicit
	
	Declare init()
	
	Prototype p_CoWaitForMultipleHandles(dwFlags.l, dwTimeout.l, cHandles.l, pHandles.i, lpdwindex.i)
	
	Global.p_CoWaitForMultipleHandles CoWaitForMultipleHandles_
	
	init()
	
	Procedure init()
		Protected.i hlib

		hlib = OpenLibrary(#PB_Any, "Ole32.dll")
		If hlib
			CoWaitForMultipleHandles_ = GetFunction(hlib, "CoWaitForMultipleHandles")
			
			CloseLibrary(hlib)
		EndIf 
	EndProcedure
	
	Procedure CoWaitForMultipleHandles(dwFlags.l, dwTimeout.l, cHandles.l, pHandles.i, lpdwindex.i)
		ProcedureReturn CoWaitForMultipleHandles_(dwFlags.l, dwTimeout.l, cHandles.l, pHandles.i, lpdwindex.i)
	EndProcedure
EndModule
