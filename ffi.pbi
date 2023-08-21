XIncludeFile "ffitarget.pbi"

CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
	#LIB_PATH = "x64\"
	
CompilerElse
	#LIB_PATH = "x86\"
CompilerEndIf

;- imports
;asm backend needs libgcc.a
CompilerIf #PB_Compiler_Backend = #PB_Backend_Asm
	Import #LIB_PATH + "libgcc.a"
	EndImport
CompilerEndIf

ImportC #LIB_PATH + "libffi.a"
	ffi_call(cif.i, fn.i, rvalue.i, avalue.i)
	ffi_prep_cif(cif.i, ffi_abi.l, nargs.l, rtype.i, atypes.i)
EndImport

;- enum ffi_status
Enumeration
	#FFI_OK = 0
	#FFI_BAD_TYPEDEF
	#FFI_BAD_ABI
EndEnumeration

;- enum FFI_TYPE
#FFI_TYPE_VOID       = 0    
#FFI_TYPE_INT        = 1
#FFI_TYPE_FLOAT      = 2    
#FFI_TYPE_DOUBLE     = 3
CompilerIf #True
	#FFI_TYPE_LONGDOUBLE = 4
CompilerElse 
	#FFI_TYPE_LONGDOUBLE = #FFI_TYPE_DOUBLE
CompilerEndIf 
#FFI_TYPE_UINT8      = 5   
#FFI_TYPE_SINT8      = 6
#FFI_TYPE_UINT16     = 7 
#FFI_TYPE_SINT16     = 8
#FFI_TYPE_UINT32     = 9
#FFI_TYPE_SINT32     = 10
#FFI_TYPE_UINT64     = 11
#FFI_TYPE_SINT64     = 12
#FFI_TYPE_STRUCT     = 13
#FFI_TYPE_POINTER    = 14
#FFI_TYPE_COMPLEX    = 15
#FFI_TYPE_LAST       = #FFI_TYPE_COMPLEX

;- ffi_type
Structure ffi_type Align #PB_Structure_AlignC
	size.i
	alignment.u
	type.u
	*elements.ffi_type
EndStructure

;- ffi_cif
Structure ffi_cif Align #PB_Structure_AlignC
	abi.l
	nargs.l
	*arg_types.ffi_type
	*rtype.ffi_type
	bytes.l
	flags.l
EndStructure

;- types.c
Macro FFI_TYPEDEF(name, _type, id)
	Structure ffi_struct_align_#name Align #PB_Structure_AlignC
		c.c
		x._type
	EndStructure
	
	Global.ffi_type ffi_type_#name
	ffi_type_#name\size = SizeOf(_type)
	ffi_type_#name\alignment = OffsetOf(ffi_struct_align_#name#\x)
	ffi_type_#name\type = id
	ffi_type_#name\elements = #Null
EndMacro

Global.ffi_type ffi_type_void
ffi_type_void\type = #FFI_TYPE_VOID

FFI_TYPEDEF(pointer, INTEGER, #FFI_TYPE_POINTER)
FFI_TYPEDEF(float, FLOAT, #FFI_TYPE_FLOAT)
FFI_TYPEDEF(double, DOUBLE, #FFI_TYPE_DOUBLE)
FFI_TYPEDEF(sint64, QUAD, #FFI_TYPE_SINT64)
FFI_TYPEDEF(sint32, LONG, #FFI_TYPE_SINT32)
FFI_TYPEDEF(sint16, WORD, #FFI_TYPE_SINT16)

CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
	FFI_TYPEDEF(sint, QUAD, #FFI_TYPE_SINT64)

CompilerElseIf #PB_Compiler_Processor = #PB_Processor_x86
	FFI_TYPEDEF(sint, LONG, #FFI_TYPE_SINT32)
CompilerEndIf






