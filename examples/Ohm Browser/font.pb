Procedure font_GetDefault(heightFactor.f = 1.0)
	Protected.NONCLIENTMETRICS ncm
	
	ncm\cbSize = SizeOf(NONCLIENTMETRICS)
	If SystemParametersInfo_(#SPI_GETNONCLIENTMETRICS, SizeOf(NONCLIENTMETRICS), @ncm, #Null)
		ncm\lfMessageFont\lfHeight * heightFactor
		
		ProcedureReturn CreateFontIndirect_(@ncm\lfMessageFont)
	EndIf	
EndProcedure