;MS Compiler
; #_MSC_VER = #True

;- enum ffi_abi
Enumeration
	#FFI_FIRST_ABI = 0

  ;Intel x86 Win32
	CompilerIf (#PB_Compiler_OS = #PB_OS_Windows And #PB_Compiler_Processor = #PB_Processor_x86)
		#FFI_SYSV
		#FFI_STDCALL
		#FFI_THISCALL
		#FFI_FASTCALL
		#FFI_MS_CDECL
		#FFI_PASCAL
		#FFI_REGISTER
		#FFI_LAST_ABI
		CompilerIf Defined(_MSC_VER, #PB_Constant)
			#FFI_DEFAULT_ABI = #FFI_MS_CDECL
		CompilerElse
			#FFI_DEFAULT_ABI = #FFI_SYSV
		CompilerEndIf

	CompilerElseIf (#PB_Compiler_OS = #PB_OS_Windows And #PB_Compiler_Processor = #PB_Processor_x64)
  	#FFI_WIN64
  	#FFI_LAST_ABI
  	#FFI_DEFAULT_ABI = #FFI_WIN64

	CompilerElse
		;Intel x86 And AMD x86-64
		#FFI_SYSV
		#FFI_UNIX64
		#FFI_THISCALL
		#FFI_FASTCALL
		#FFI_STDCALL
		#FFI_PASCAL
		#FFI_REGISTER
		#FFI_LAST_ABI
		CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
			#FFI_DEFAULT_ABI = #FFI_SYSV

		CompilerElse
  		#FFI_DEFAULT_ABI = #FFI_UNIX64
		CompilerEndIf
	CompilerEndIf
EndEnumeration