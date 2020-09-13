;resource.pb

EnableExplicit

Procedure res_CreateResourceStream(id.i, type.i, hmodule.i = #Null)
	Protected.i hrsrc, hdat, hmem
	Protected.IStream stm
	
	hrsrc = FindResource_(hmodule, id, type)
	If hrsrc
		hdat = LoadResource_(hmodule, hrsrc)
		If hdat
			hmem = LockResource_(hdat)
			If hmem
				stm = stm_CreateStream(hmem, SizeofResource_(hmodule, hrsrc))
			EndIf 
			FreeResource_(hdat)
		EndIf 
	EndIf 
	
	ProcedureReturn stm
EndProcedure