#_DEBUG = 0 ;For autocomplete

;- Enum DEBUG_LEVEL
Enumeration
	#_DEBUG_LEVEL_OFF
	#_DEBUG_LEVEL_FATAL
	#_DEBUG_LEVEL_ERROR
	#_DEBUG_LEVEL_WARN 
	#_DEBUG_LEVEL_DEBUG
	#_DEBUG_LEVEL_ALL
EndEnumeration

;- Enum DEBUG_LEVEL_NAME
#_DEBUG_LEVEL_NAME_FATAL = "Fatal"
#_DEBUG_LEVEL_NAME_ERROR = "Error"
#_DEBUG_LEVEL_NAME_WARNING = "Warning"

Macro __debug_dq__
"
EndMacro

Macro _debug_proc
#PB_Compiler_Procedure
EndMacro

Macro _debug_line
#PB_Compiler_Line
EndMacro

Macro __debug_format(levelName, level, msg)
	Debug levelName + ": " + _debug_proc + "(" + _debug_line + "): " + msg, level
EndMacro

Macro __debug_assert_format(expr)
	Debug "Assert: " + _debug_proc + "(" + _debug_line + "): " + __debug_dq__#expr#__debug_dq__
EndMacro

Macro _debug(msg)
	Debug msg, #_DEBUG_LEVEL_DEBUG
EndMacro

Macro _debug_fatal(msg)
	__debug_format(#_DEBUG_LEVEL_NAME_FATAL, #_DEBUG_LEVEL_FATAL, msg)
EndMacro

Macro _debug_err(msg)
	__debug_format(#_DEBUG_LEVEL_NAME_ERROR, #_DEBUG_LEVEL_ERROR, msg)
EndMacro

Macro _debug_warn(msg)
	__debug_format(#_DEBUG_LEVEL_NAME_ERROR, #_DEBUG_LEVEL_WARN, msg)
EndMacro

Macro _debug_assert(expr)
	CompilerIf #PB_Compiler_Debugger
		If expr
			__debug_assert_format(expr)
		EndIf
	CompilerEndIf
EndMacro






