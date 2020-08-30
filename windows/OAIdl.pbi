;oaidl.pbi

XIncludeFile "Unknwn.pbi"
XIncludeFile "..\vector.pbi"
	
;- enum CALLCONV
#CC_FASTCALL    = 0
#CC_CDECL       = 1
#CC_MSCPASCAL   = ( #CC_CDECL + 1 )
#CC_PASCAL      = #CC_MSCPASCAL
#CC_MACPASCAL   = ( #CC_PASCAL + 1 )
#CC_STDCALL     = ( #CC_MACPASCAL + 1 )
#CC_FPFASTCALL  = ( #CC_STDCALL + 1 )
#CC_SYSCALL     = ( #CC_FPFASTCALL + 1 )
#CC_MPWCDECL    = ( #CC_SYSCALL + 1 )
#CC_MPWPASCAL   = ( #CC_MPWCDECL + 1 )
#CC_MAX         = ( #CC_MPWPASCAL + 1 )

;- enum DISPID
#DISPID_UNKNOWN	= -1
#DISPID_VALUE	= 0
#DISPID_PROPERTYPUT	= -3
#DISPID_NEWENUM	= -4
#DISPID_EVALUATE = -5
#DISPID_CONSTRUCTOR	= -6
#DISPID_DESTRUCTOR = -7
#DISPID_COLLECT = -8

; #IID_IDispatch$ = "{00020400-0000-0000-C000-000000000046}"

DataSection
	IID_IDispatch:
	Data.l $00020400
	Data.w $0000, $0000
	Data.b $C0, $00, $00, $00, $00, $00, $00, $46
EndDataSection

;- IDispatchVtbl
Structure IDispatchVtbl Extends IUnknownVtbl
	GetTypeInfoCount.i
	GetTypeInfo.i
	GetIDsOfNames.i
	Invoke.i
EndStructure

;- enum TYPEKIND
Enumeration
	#TKIND_ENUM
	#TKIND_RECORD
	#TKIND_MODULE
	#TKIND_INTERFACE
	#TKIND_DISPATCH
	#TKIND_COCLASS
	#TKIND_ALIAS
	#TKIND_UNION
	#TKIND_MAX
EndEnumeration

;- enum TYPEFLAGS
#TYPEFLAG_FAPPOBJECT	= $1
#TYPEFLAG_FCANCREATE	= $2
#TYPEFLAG_FLICENSED	= $4
#TYPEFLAG_FPREDECLID	= $8
#TYPEFLAG_FHIDDEN	= $10
#TYPEFLAG_FCONTROL	= $20
#TYPEFLAG_FDUAL	= $40
#TYPEFLAG_FNONEXTENSIBLE	= $80
#TYPEFLAG_FOLEAUTOMATION	= $100
#TYPEFLAG_FRESTRICTED	= $200
#TYPEFLAG_FAGGREGATABLE	= $400
#TYPEFLAG_FREPLACEABLE	= $800
#TYPEFLAG_FDISPATCHABLE	= $1000
#TYPEFLAG_FREVERSEBIND	= $2000
#TYPEFLAG_FPROXY	= $4000

;- enum VARKIND
Enumeration
	#VAR_PERINSTANCE
	#VAR_STATIC
	#VAR_CONST
	#VAR_DISPATCH
EndEnumeration

;- enum INVOKEKIND
Enumeration
	#INVOKE_FUNC	= 1
	#INVOKE_PROPERTYGET	= 2
	#INVOKE_PROPERTYPUT	= 4
	#INVOKE_PROPERTYPUTREF	= 8
EndEnumeration

;- enum SYSKIND
Enumeration SYSKIND
	#SYS_WIN16
	#SYS_WIN32
	#SYS_MAC
	#SYS_WIN64
EndEnumeration

;- enum PARAMFLAG
#PARAMFLAG_NONE	= 0 
#PARAMFLAG_FIN	= $1
#PARAMFLAG_FOUT	= $2
#PARAMFLAG_FLCID = $4
#PARAMFLAG_FRETVAL = $8
#PARAMFLAG_FOPT = $10
#PARAMFLAG_FHASDEFAULT = $20
#PARAMFLAG_FHASCUSTDATA = $40

;- DISPPARAMS_
Structure DISPPARAMS_ Align #PB_Structure_AlignC
	*rgvarg.VECTOR_VARIANT
	*rgdispidNamedArgs.VECTOR_INT
	cArgs.l
	cNamedArgs.l
EndStructure

;- TYPEDESC
Structure TYPEDESC Align #PB_Structure_AlignC
	StructureUnion
		*lptdesc.TYPEDESC
		lpadesc.i
		hreftype.l
	EndStructureUnion 
  vt.w  
EndStructure

;- IDLDESC
Structure IDLDESC Align #PB_Structure_AlignC
	dwReserved.l
	wIDLFlags.w
EndStructure

;- PARAMDESCEX
Structure PARAMDESCEX
	cBytes.l
	varDefaultValue.VARIANT
EndStructure

;- PARAMDESC
Structure PARAMDESC
	*pparamdescex.PARAMDESCEX
	wParamFlags.w
EndStructure

;- ELEMDESC
Structure ELEMDESC Align #PB_Structure_AlignC
	tdesc.TYPEDESC        
	StructureUnion
		idldesc.IDLDESC     
		paramdesc.PARAMDESC 
	EndStructureUnion
EndStructure

;- VARDESC
Structure VARDESC Align #PB_Structure_AlignC
	memid.l
	lpstrSchema.i
	StructureUnion
		oInst.l
		*lpvarValue.VARIANT
	EndStructureUnion
	elemdescVar.ELEMDESC
	wVarFlags.w
	varkind.l
EndStructure

;- FUNCDESC
Structure FUNCDESC Align #PB_Structure_AlignC
	memid.l
	*lprgscode.LONG
	*lprgelemdescParam.ELEMDESC
	funckind.l
	invkind.l
	callconv.l
	cParams.w
	cParamsOpt.w
	oVft.w
	cScodes.w
	elemdescFunc.ELEMDESC
	wFuncFlags.w
EndStructure

;- TYPEATTR
Structure TYPEATTR Align #PB_Structure_AlignC
	guid.GUID               
	lcid.l                                 
	dwReserved.l
	memidConstructor.l                       
	memidDestructor.l                       
	lpstrSchema.i  
	cbSizeInstance.l                     
	typekind.l         
	cFuncs.w      
	cVars.w      
	cImplTypes.w   
	cbSizeVft.w   
	cbAlignment.w   
	wTypeFlags.w
	wMajorVerNum.w  
	wMinorVerNum.w   
	tdescAlias.TYPEDESC                         
	idldescType.IDLDESC
EndStructure 

;- TLIBATTR
Structure TLIBATTR Align #PB_Structure_AlignC
	guid.GUID
	lcid.l
	syskind.l
	wMajorVerNum.w
	wMinorVerNum.w
	wLibFlags.w
EndStructure
	