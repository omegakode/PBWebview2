EnableExplicit

Procedure stm_CreateStream(cbuf.i, clen.i)
	Protected.i hmem, buf
	Protected.IStream stm
	
  hmem = GlobalAlloc_(#GMEM_MOVEABLE, clen)
  If hmem
  	buf = GlobalLock_(hmem)
  	If buf
  		CopyMemory(cbuf, buf, clen)
  		CreateStreamOnHGlobal_(hmem, #True, @stm)
  	EndIf 
  	
  	GlobalUnlock_(hmem)
  EndIf 
  
  ProcedureReturn stm
EndProcedure