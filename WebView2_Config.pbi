;WebView2_Config.pbi

;LINKING
Enumeration 
	#WV2_CONFIG_LINKING_STATIC
	#WV2_CONFIG_LINKING_DYNAMIC
EndEnumeration

;- Compiler Switches
;WV2_CONFIG_LINKING Enum
#WV2_CONFIG_LINKING = #WV2_CONFIG_LINKING_DYNAMIC

;True / False
#WV2_CONFIG_USE_RESIDENT = #True

CompilerIf #WV2_CONFIG_LINKING = #WV2_CONFIG_LINKING_STATIC And #PB_Compiler_Version  < 610
	MessageRequester("PBWebView2", "Error, PB 6.10 is required for static linking.")
CompilerEndIf

