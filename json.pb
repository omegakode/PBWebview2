EnableExplicit

Procedure.s json_GetString(jsonStr.s)
	Protected.s ret
	Protected.i json
	
	json = ParseJSON(#PB_Any, jsonStr)
	ret = GetJSONString(JSONValue(json))
	FreeJSON(json)
	
	ProcedureReturn ret
EndProcedure