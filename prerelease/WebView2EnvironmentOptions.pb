;WebView2EnvironmentOptions.pb

XIncludeFile "..\windows\Unknwn.pbi"
; XIncludeFile "WebView2.pbi"
XIncludeFile "..\string.pb"
XIncludeFile "..\WebView2EnvironmentOptions.pbi"
EnableExplicit

;- DECLARES
Declare wv2_EnvironmentOptions2_New()
Declare wv2_EnvironmentOptions2_AddRef(this.i)
Declare wv2_EnvironmentOptions2_Release(this.i)

Declare wv2_EnvironmentOptions3_New()
Declare wv2_EnvironmentOptions3_AddRef(this.i)
Declare wv2_EnvironmentOptions3_Release(this.i)

Declare wv2_EnvironmentOptions4_New()
Declare wv2_EnvironmentOptions4_AddRef(this.i)
Declare wv2_EnvironmentOptions4_Release(this.i)

Declare wv2_EnvironmentOptions5_New()
Declare wv2_EnvironmentOptions5_AddRef(this.i)
Declare wv2_EnvironmentOptions5_Release(this.i)

Declare wv2_EnvironmentOptions6_New()
Declare wv2_EnvironmentOptions6_AddRef(this.i)
Declare wv2_EnvironmentOptions6_Release(this.i)

Declare wv2_CustomSchemeRegistration_AddRef(this.i)


#CORE_WEBVIEW_TARGET_PRODUCT_VERSION = "120.0.2194.0"

;- GLOBALS
Global.ICoreWebView2CustomSchemeRegistrationVtbl WV2_CUSTOM_SCHEME_REGISTRATION_VTABLE

Global.ICoreWebView2EnvironmentOptionsVtbl WV2_ENVIRONMENT_OPTIONS_VTABLE
Global.ICoreWebView2EnvironmentOptions2Vtbl WV2_ENVIRONMENT_OPTIONS2_VTABLE
Global.ICoreWebView2EnvironmentOptions3Vtbl WV2_ENVIRONMENT_OPTIONS3_VTABLE
Global.ICoreWebView2EnvironmentOptions4Vtbl WV2_ENVIRONMENT_OPTIONS4_VTABLE
Global.ICoreWebView2EnvironmentOptions5Vtbl WV2_ENVIRONMENT_OPTIONS5_VTABLE
Global.ICoreWebView2EnvironmentOptions6Vtbl WV2_ENVIRONMENT_OPTIONS6_VTABLE

;- WV2_VECTOR_ICUSTOM_SCHEME_REGISTRATION
Structure WV2_VECTOR_ICUSTOM_SCHEME_REGISTRATION
	item.ICoreWebView2CustomSchemeRegistration[0]
EndStructure

Procedure wv2_CustomSchemeRegistration_MakeArray(count.l)
	ProcedureReturn CoTaskMemAlloc_(count * SizeOf(INTEGER))
EndProcedure

Procedure wv2_CustomSchemeRegistration_ReleaseArray(*arr.WV2_VECTOR_ICUSTOM_SCHEME_REGISTRATION, count.l)
	Protected.i index
	
	If *arr = #Null Or count <= 0 : ProcedureReturn #False : EndIf
	
	For index = 0 To count -1
		If *arr\item[index]
			*arr\item[index]\Release()
		EndIf 
	Next
	
	CoTaskMemFree_(*arr)
	
	ProcedureReturn #True
EndProcedure

;- WV2_CUSTOM_SCHEME_REGISTRATION
Structure WV2_CUSTOM_SCHEME_REGISTRATION
	vt.i
	refCount.i
	mutex.i
	;Properties
	schemeName.s
	treatAsSecure.l
	hasAuthorityComponent.l
	*allowedOrigins.VECTOR_INT
	allowedOriginsCount.l
EndStructure

Procedure wv2_CustomSchemeRegistration_New(schemeName.s)
	Protected.WV2_CUSTOM_SCHEME_REGISTRATION *this
	
	*this = AllocateMemory(SizeOf(WV2_CUSTOM_SCHEME_REGISTRATION))
	*this\vt = @WV2_CUSTOM_SCHEME_REGISTRATION_VTABLE
	*this\refCount = 1
	
	*this\schemeName = schemeName
	*this\TreatAsSecure = #False
	*this\HasAuthorityComponent = #False
	
	ProcedureReturn *this
EndProcedure

Procedure wv2_CustomSchemeRegistration_Free(*this.WV2_CUSTOM_SCHEME_REGISTRATION)
	If *this\allowedOrigins
		str_FreeStringArray(*this\allowedOrigins, *this\allowedOriginsCount)
	EndIf
	
	FreeMemory(*this)
EndProcedure

Procedure wv2_CustomSchemeRegistration_QueryInterface(*this.WV2_CUSTOM_SCHEME_REGISTRATION, *id.IID, *obj.INTEGER)
	If *id = #Null Or *obj = #Null : ProcedureReturn #E_POINTER : EndIf
	
	If CompareMemory(*id, ?IID_IUnknown, SizeOf(IID)) Or CompareMemory(*id, ?IID_ICoreWebView2CustomSchemeRegistration, SizeOf(IID))
		*obj\i = *this
		wv2_CustomSchemeRegistration_AddRef(*this)
		ProcedureReturn #S_OK
		
	Else
		*obj\i = #Null
		ProcedureReturn #E_NOINTERFACE
	EndIf 
EndProcedure

Procedure wv2_CustomSchemeRegistration_AddRef(*this.WV2_CUSTOM_SCHEME_REGISTRATION)
	*this\refCount = *this\refCount + 1
	
	ProcedureReturn *this\refCount
EndProcedure

Procedure wv2_CustomSchemeRegistration_Release(*this.WV2_CUSTOM_SCHEME_REGISTRATION)
	*this\refCount = *this\refCount -1
	
	If *this\refCount = 0
		wv2_CustomSchemeRegistration_Free(*this)
		ProcedureReturn 0
	
	Else 
		ProcedureReturn *this\refCount
	EndIf 
EndProcedure

Procedure wv2_CustomSchemeRegistration_get_SchemeName(*this.WV2_CUSTOM_SCHEME_REGISTRATION, *schemeName.INTEGER)
	If *schemeName = #Null
		ProcedureReturn #E_POINTER
		
	Else
		*schemeName\i = str_MakeCoMemString(*this\schemeName)
		ProcedureReturn #S_OK
	EndIf 
EndProcedure

Procedure wv2_CustomSchemeRegistration_get_TreatAsSecure(*this.WV2_CUSTOM_SCHEME_REGISTRATION, *treatAsSecure.LONG)
	If *treatAsSecure = #Null
		ProcedureReturn #E_POINTER
		
	Else
		*treatAsSecure\l = *this\treatAsSecure
		ProcedureReturn #S_OK
	EndIf 
EndProcedure

Procedure wv2_CustomSchemeRegistration_put_TreatAsSecure(*this.WV2_CUSTOM_SCHEME_REGISTRATION, treatAsSecure.l)
	*this\treatAsSecure = treatAsSecure
	ProcedureReturn #S_OK
EndProcedure

Procedure wv2_CustomSchemeRegistration_GetAllowedOrigins(*this.WV2_CUSTOM_SCHEME_REGISTRATION, *allowedOriginsCount.LONG, *allowedOrigins.INTEGER)
	If *allowedOriginsCount = #Null Or *allowedOrigins = #Null
		ProcedureReturn #E_POINTER
	EndIf
	
	*allowedOriginsCount\l = *this\allowedOriginsCount
	If *this\allowedOriginsCount = 0
		*allowedOrigins\i = #Null
		
	Else
		*allowedOrigins\i = str_CopyStringArray(*this\allowedOrigins, *this\allowedOriginsCount)
	EndIf
	
	ProcedureReturn #S_OK
EndProcedure

Procedure wv2_CustomSchemeRegistration_SetAllowedOrigins(*this.WV2_CUSTOM_SCHEME_REGISTRATION, allowedOriginsCount.l, *allowedOrigins.VECTOR_INT)
	If allowedOriginsCount < 0 : ProcedureReturn #E_INVALIDARG : EndIf 

	str_FreeStringArray(*this\allowedOrigins, *this\allowedOriginsCount)
	*this\allowedOrigins = #Null
	*this\allowedOriginsCount = 0
	
	If *allowedOrigins
		*this\allowedOrigins = str_CopyStringArray(*allowedOrigins, allowedOriginsCount)
	EndIf 
	
	ProcedureReturn #S_OK
EndProcedure

Procedure wv2_CustomSchemeRegistration_get_HasAuthorityComponent(*this.WV2_CUSTOM_SCHEME_REGISTRATION, *hasAuthorityComponent.LONG)
	If *hasAuthorityComponent = #Null
		ProcedureReturn #E_POINTER
		
	Else
		*hasAuthorityComponent\l = *this\hasAuthorityComponent
		ProcedureReturn #S_OK
	EndIf 
EndProcedure

Procedure wv2_CustomSchemeRegistration_put_HasAuthorityComponent(*this.WV2_CUSTOM_SCHEME_REGISTRATION, hasAuthorityComponent.l)
	*this\hasAuthorityComponent = hasAuthorityComponent
	ProcedureReturn #S_OK
EndProcedure

;- VTABLE CREATION
WV2_CUSTOM_SCHEME_REGISTRATION_VTABLE\QueryInterface = @wv2_CustomSchemeRegistration_QueryInterface()
WV2_CUSTOM_SCHEME_REGISTRATION_VTABLE\AddRef = @wv2_CustomSchemeRegistration_AddRef()
WV2_CUSTOM_SCHEME_REGISTRATION_VTABLE\Release = @wv2_CustomSchemeRegistration_Release()
WV2_CUSTOM_SCHEME_REGISTRATION_VTABLE\get_SchemeName = @wv2_CustomSchemeRegistration_get_SchemeName()
WV2_CUSTOM_SCHEME_REGISTRATION_VTABLE\get_TreatAsSecure = @wv2_CustomSchemeRegistration_get_TreatAsSecure()
WV2_CUSTOM_SCHEME_REGISTRATION_VTABLE\put_TreatAsSecure = @wv2_CustomSchemeRegistration_put_TreatAsSecure()
WV2_CUSTOM_SCHEME_REGISTRATION_VTABLE\GetAllowedOrigins = @wv2_CustomSchemeRegistration_GetAllowedOrigins()
WV2_CUSTOM_SCHEME_REGISTRATION_VTABLE\SetAllowedOrigins = @wv2_CustomSchemeRegistration_SetAllowedOrigins()
WV2_CUSTOM_SCHEME_REGISTRATION_VTABLE\get_HasAuthorityComponent = @wv2_CustomSchemeRegistration_get_HasAuthorityComponent()
WV2_CUSTOM_SCHEME_REGISTRATION_VTABLE\put_HasAuthorityComponent = @wv2_CustomSchemeRegistration_put_HasAuthorityComponent()

;- WV2_ENVIRONMENT_OPTIONS
Structure WV2_ENVIRONMENT_OPTIONS
	vt.i
	refCount.l
	mutex.i
	*opt2.WV2_ENVIRONMENT_OPTIONS2
	*opt3.WV2_ENVIRONMENT_OPTIONS3
	*opt4.WV2_ENVIRONMENT_OPTIONS4
	*opt5.WV2_ENVIRONMENT_OPTIONS5
	*opt6.WV2_ENVIRONMENT_OPTIONS6

	;Properties
	additionalBrowserArguments.s
	language.s
	targetCompatibleBrowserVersion.s
	allowSingleSignOnUsingOSPrimaryAccount.l
EndStructure

Procedure wv2_EnvironmentOptions_New()
	Protected.WV2_ENVIRONMENT_OPTIONS *this
	
	*this = AllocateMemory(SizeOf(WV2_ENVIRONMENT_OPTIONS))
	*this\vt = @WV2_ENVIRONMENT_OPTIONS_VTABLE
	*this\targetCompatibleBrowserVersion = #CORE_WEBVIEW_TARGET_PRODUCT_VERSION
	*this\allowSingleSignOnUsingOSPrimaryAccount = #False
	*this\refCount = 1
	
	*this\opt2 = wv2_EnvironmentOptions2_New()
	*this\opt3 = wv2_EnvironmentOptions3_New()
	*this\opt4 = wv2_EnvironmentOptions4_New()
	*this\opt5 = wv2_EnvironmentOptions5_New()
	*this\opt6 = wv2_EnvironmentOptions6_New()

	ProcedureReturn *this
EndProcedure

Procedure wv2_EnvironmentOptions_Free(*this.WV2_ENVIRONMENT_OPTIONS)
	If *this\opt2 : wv2_EnvironmentOptions2_Release(*this\opt2) : EndIf 
	If *this\opt3 : wv2_EnvironmentOptions3_Release(*this\opt3) : EndIf 
	If *this\opt4 : wv2_EnvironmentOptions4_Release(*this\opt4) : EndIf 
	If *this\opt5 : wv2_EnvironmentOptions5_Release(*this\opt5) : EndIf 
	If *this\opt6 : wv2_EnvironmentOptions6_Release(*this\opt6) : EndIf 

	FreeMemory(*this)
EndProcedure

Procedure wv2_EnvironmentOptions_QueryInterface(*this.WV2_ENVIRONMENT_OPTIONS, *id.IID, *obj.INTEGER)
	If *id = #Null Or *obj = #Null : ProcedureReturn #E_POINTER : EndIf

	If CompareMemory(*id, ?IID_IUnknown, SizeOf(IID)) Or CompareMemory(*id, ?IID_ICoreWebView2EnvironmentOptions, SizeOf(IID))
		*obj\i = *this
		*this\refCount = *this\refCount + 1
		ProcedureReturn #S_OK
		
	ElseIf CompareMemory(*id, ?IID_ICoreWebView2EnvironmentOptions2, SizeOf(IID))
		*obj\i = *this\opt2
		wv2_EnvironmentOptions2_AddRef(*this\opt2)
		
		ProcedureReturn #S_OK
		
	ElseIf CompareMemory(*id, ?IID_ICoreWebView2EnvironmentOptions3, SizeOf(IID))
		*obj\i = *this\opt3
		wv2_EnvironmentOptions3_AddRef(*this\opt3)
		
		ProcedureReturn #S_OK
		
	ElseIf CompareMemory(*id, ?IID_ICoreWebView2EnvironmentOptions4, SizeOf(IID))
		*obj\i = *this\opt4
		wv2_EnvironmentOptions4_AddRef(*this\opt4)
		
		ProcedureReturn #S_OK
		
	ElseIf CompareMemory(*id, ?IID_ICoreWebView2EnvironmentOptions5, SizeOf(IID))
		*obj\i = *this\opt5
		wv2_EnvironmentOptions5_AddRef(*this\opt5)
		
		ProcedureReturn #S_OK
		
	ElseIf CompareMemory(*id, ?IID_ICoreWebView2EnvironmentOptions6, SizeOf(IID))
		*obj\i = *this\opt6
		wv2_EnvironmentOptions6_AddRef(*this\opt6)
		
		ProcedureReturn #S_OK
		
	Else
		*obj\i = #Null
		ProcedureReturn #E_NOINTERFACE
	EndIf 
EndProcedure

Procedure wv2_EnvironmentOptions_AddRef(*this.WV2_ENVIRONMENT_OPTIONS)
	*this\refCount = *this\refCount + 1
	
	ProcedureReturn *this\refCount
EndProcedure

Procedure wv2_EnvironmentOptions_Release(*this.WV2_ENVIRONMENT_OPTIONS)
	*this\refCount = *this\refCount -1
	
	If *this\refCount = 0
		wv2_EnvironmentOptions_Free(*this)
		ProcedureReturn 0
	
	Else 
		ProcedureReturn *this\refCount
	EndIf 
EndProcedure

Procedure wv2_EnvironmentOptions_get_AdditionalBrowserArguments(*this.WV2_ENVIRONMENT_OPTIONS, *value.INTEGER)
	If *value = #Null : ProcedureReturn #E_POINTER : EndIf
	
	*value\i = str_MakeCoMemString(*this\additionalBrowserArguments)
	
	ProcedureReturn #S_OK
EndProcedure

Procedure wv2_EnvironmentOptions_put_AdditionalBrowserArguments(*this.WV2_ENVIRONMENT_OPTIONS, value.s)
	*this\additionalBrowserArguments = value
	
	ProcedureReturn #S_OK
EndProcedure

Procedure wv2_EnvironmentOptions_get_Language(*this.WV2_ENVIRONMENT_OPTIONS, *value.INTEGER)
	If *value = #Null : ProcedureReturn #E_POINTER : EndIf

	*value\i = str_MakeCoMemString(*this\language)
	
	ProcedureReturn #S_OK
EndProcedure

Procedure wv2_EnvironmentOptions_put_Language(*this.WV2_ENVIRONMENT_OPTIONS, value.s)
	*this\language = value
	
	ProcedureReturn #S_OK
EndProcedure

Procedure wv2_EnvironmentOptions_get_TargetCompatibleBrowserVersion(*this.WV2_ENVIRONMENT_OPTIONS, *value.INTEGER)
	If *value = #Null : ProcedureReturn #E_POINTER : EndIf

	*value\i = str_MakeCoMemString(*this\targetCompatibleBrowserVersion)

	ProcedureReturn #S_OK
EndProcedure

Procedure wv2_EnvironmentOptions_put_TargetCompatibleBrowserVersion(*this.WV2_ENVIRONMENT_OPTIONS, value.s)
	*this\targetCompatibleBrowserVersion = value
	
	ProcedureReturn #S_OK
EndProcedure

Procedure wv2_EnvironmentOptions_get_AllowSingleSignOnUsingOSPrimaryAccount(*this.WV2_ENVIRONMENT_OPTIONS, *value.LONG)
	If *value = #Null : ProcedureReturn #E_POINTER : EndIf

	*value\l = *this\allowSingleSignOnUsingOSPrimaryAccount
	
	ProcedureReturn #S_OK
EndProcedure

Procedure wv2_EnvironmentOptions_put_AllowSingleSignOnUsingOSPrimaryAccount(*this.WV2_ENVIRONMENT_OPTIONS, value.l)
	*this\allowSingleSignOnUsingOSPrimaryAccount = value
	
	ProcedureReturn #S_OK
EndProcedure

;- VTABLE_CONSTRUCTION
WV2_ENVIRONMENT_OPTIONS_VTABLE\QueryInterface = @wv2_EnvironmentOptions_QueryInterface()
WV2_ENVIRONMENT_OPTIONS_VTABLE\AddRef = @wv2_EnvironmentOptions_AddRef()
WV2_ENVIRONMENT_OPTIONS_VTABLE\Release = @wv2_EnvironmentOptions_Release()
WV2_ENVIRONMENT_OPTIONS_VTABLE\get_AdditionalBrowserArguments = @wv2_EnvironmentOptions_get_AdditionalBrowserArguments()
WV2_ENVIRONMENT_OPTIONS_VTABLE\put_AdditionalBrowserArguments = @wv2_EnvironmentOptions_put_AdditionalBrowserArguments()
WV2_ENVIRONMENT_OPTIONS_VTABLE\get_Language = @wv2_EnvironmentOptions_get_Language()
WV2_ENVIRONMENT_OPTIONS_VTABLE\put_Language = @wv2_EnvironmentOptions_put_Language()
WV2_ENVIRONMENT_OPTIONS_VTABLE\get_TargetCompatibleBrowserVersion = @wv2_EnvironmentOptions_get_TargetCompatibleBrowserVersion()
WV2_ENVIRONMENT_OPTIONS_VTABLE\put_TargetCompatibleBrowserVersion = @wv2_EnvironmentOptions_put_TargetCompatibleBrowserVersion()
WV2_ENVIRONMENT_OPTIONS_VTABLE\get_AllowSingleSignOnUsingOSPrimaryAccount = @wv2_EnvironmentOptions_get_AllowSingleSignOnUsingOSPrimaryAccount()
WV2_ENVIRONMENT_OPTIONS_VTABLE\put_AllowSingleSignOnUsingOSPrimaryAccount = @wv2_EnvironmentOptions_put_AllowSingleSignOnUsingOSPrimaryAccount()

;- WV2_ENVIRONMENT_OPTIONS2
Structure WV2_ENVIRONMENT_OPTIONS2
	vt.i
	refCount.l
	mutex.i
	;Properties
	ExclusiveUserDataFolderAccess.l
EndStructure

Procedure wv2_EnvironmentOptions2_New()
	Protected.WV2_ENVIRONMENT_OPTIONS2 *this
	
	*this = AllocateMemory(SizeOf(WV2_ENVIRONMENT_OPTIONS2))
	*this\vt = @WV2_ENVIRONMENT_OPTIONS2_VTABLE
	*this\refCount = 1
	
	*this\ExclusiveUserDataFolderAccess = #False

	ProcedureReturn *this
EndProcedure

Procedure wv2_EnvironmentOptions2_Free(*this.WV2_ENVIRONMENT_OPTIONS2)
	FreeMemory(*this)
EndProcedure

Procedure wv2_EnvironmentOptions2_QueryInterface(*this.WV2_ENVIRONMENT_OPTIONS2, *id.IID, *obj.INTEGER)
	If *id = #Null Or *obj = #Null : ProcedureReturn #E_POINTER : EndIf
	
	If CompareMemory(*id, ?IID_IUnknown, SizeOf(IID)) Or CompareMemory(*id, ?IID_ICoreWebView2EnvironmentOptions2, SizeOf(IID))
		*obj\i = *this
		*this\refCount = *this\refCount + 1
		ProcedureReturn #S_OK
		
	Else
		*obj\i = #Null
		ProcedureReturn #E_NOINTERFACE
	EndIf 
EndProcedure

Procedure wv2_EnvironmentOptions2_AddRef(*this.WV2_ENVIRONMENT_OPTIONS2)
	*this\refCount = *this\refCount + 1
	
	ProcedureReturn *this\refCount
EndProcedure

Procedure wv2_EnvironmentOptions2_Release(*this.WV2_ENVIRONMENT_OPTIONS2)
	*this\refCount = *this\refCount -1
	
	If *this\refCount = 0
		wv2_EnvironmentOptions2_Free(*this)
		ProcedureReturn 0
	
	Else 
		ProcedureReturn *this\refCount
	EndIf 
EndProcedure

Procedure wv2_EnvironmentOptions2_get_ExclusiveUserDataFolderAccess(*this.WV2_ENVIRONMENT_OPTIONS2, *ExclusiveUserDataFolderAccess.LONG)
	If *ExclusiveUserDataFolderAccess = #Null : ProcedureReturn #E_POINTER : EndIf
	
	*ExclusiveUserDataFolderAccess\l = *this\ExclusiveUserDataFolderAccess
	ProcedureReturn #S_OK
EndProcedure

Procedure wv2_EnvironmentOptions2_put_ExclusiveUserDataFolderAccess(*this.WV2_ENVIRONMENT_OPTIONS2, ExclusiveUserDataFolderAccess.l)
	*this\ExclusiveUserDataFolderAccess = ExclusiveUserDataFolderAccess
	ProcedureReturn #S_OK
EndProcedure

;- VTABLE_CONSTRUCTION
WV2_ENVIRONMENT_OPTIONS2_VTABLE\QueryInterface = @wv2_EnvironmentOptions2_QueryInterface()
WV2_ENVIRONMENT_OPTIONS2_VTABLE\AddRef = @wv2_EnvironmentOptions2_AddRef()
WV2_ENVIRONMENT_OPTIONS2_VTABLE\Release = @wv2_EnvironmentOptions2_Release()
WV2_ENVIRONMENT_OPTIONS2_VTABLE\get_ExclusiveUserDataFolderAccess = @wv2_EnvironmentOptions2_get_ExclusiveUserDataFolderAccess()
WV2_ENVIRONMENT_OPTIONS2_VTABLE\put_ExclusiveUserDataFolderAccess = @wv2_EnvironmentOptions2_put_ExclusiveUserDataFolderAccess()

;- WV2_ENVIRONMENT_OPTIONS3
Structure WV2_ENVIRONMENT_OPTIONS3
	vt.i
	refCount.l
	mutex.i
	;Properties
	IsCustomCrashReportingEnabled.l
EndStructure

Procedure wv2_EnvironmentOptions3_New()
	Protected.WV2_ENVIRONMENT_OPTIONS3 *this
	
	*this = AllocateMemory(SizeOf(WV2_ENVIRONMENT_OPTIONS3))
	*this\vt = @WV2_ENVIRONMENT_OPTIONS3_VTABLE
	*this\refCount = 1
	
	*this\IsCustomCrashReportingEnabled = #False

	ProcedureReturn *this
EndProcedure

Procedure wv2_EnvironmentOptions3_Free(*this.WV2_ENVIRONMENT_OPTIONS3)
	FreeMemory(*this)
EndProcedure

Procedure wv2_EnvironmentOptions3_QueryInterface(*this.WV2_ENVIRONMENT_OPTIONS3, *id.IID, *obj.INTEGER)	
	If *id = #Null Or *obj = #Null : ProcedureReturn #E_POINTER : EndIf

	If CompareMemory(*id, ?IID_IUnknown, SizeOf(IID)) Or CompareMemory(*id, ?IID_ICoreWebView2EnvironmentOptions3, SizeOf(IID))
		*obj\i = *this
		*this\refCount = *this\refCount + 1
		ProcedureReturn #S_OK
		
	Else
		*obj\i = #Null
		ProcedureReturn #E_NOINTERFACE
	EndIf 
EndProcedure

Procedure wv2_EnvironmentOptions3_AddRef(*this.WV2_ENVIRONMENT_OPTIONS3)
	*this\refCount = *this\refCount + 1
	
	ProcedureReturn *this\refCount
EndProcedure

Procedure wv2_EnvironmentOptions3_Release(*this.WV2_ENVIRONMENT_OPTIONS3)
	*this\refCount = *this\refCount -1
	
	If *this\refCount = 0
		wv2_EnvironmentOptions3_Free(*this)
		ProcedureReturn 0
	
	Else 
		ProcedureReturn *this\refCount
	EndIf 
EndProcedure

Procedure wv2_EnvironmentOptions3_get_IsCustomCrashReportingEnabled(*this.WV2_ENVIRONMENT_OPTIONS3, *IsCustomCrashReportingEnabled.LONG)
	If *IsCustomCrashReportingEnabled = #Null : ProcedureReturn #E_POINTER : EndIf
	
	*IsCustomCrashReportingEnabled\l = *this\IsCustomCrashReportingEnabled
	
	ProcedureReturn #S_OK
EndProcedure

Procedure wv2_EnvironmentOptions3_put_IsCustomCrashReportingEnabled(*this.WV2_ENVIRONMENT_OPTIONS3, IsCustomCrashReportingEnabled.l)
	*this\IsCustomCrashReportingEnabled = IsCustomCrashReportingEnabled
	
	ProcedureReturn #S_OK
EndProcedure

;- VTABLE_CONSTRUCTION
WV2_ENVIRONMENT_OPTIONS3_VTABLE\QueryInterface = @wv2_EnvironmentOptions3_QueryInterface()
WV2_ENVIRONMENT_OPTIONS3_VTABLE\AddRef = @wv2_EnvironmentOptions3_AddRef()
WV2_ENVIRONMENT_OPTIONS3_VTABLE\Release = @wv2_EnvironmentOptions3_Release()
WV2_ENVIRONMENT_OPTIONS3_VTABLE\get_IsCustomCrashReportingEnabled = @wv2_EnvironmentOptions3_get_IsCustomCrashReportingEnabled()
WV2_ENVIRONMENT_OPTIONS3_VTABLE\put_IsCustomCrashReportingEnabled = @wv2_EnvironmentOptions3_put_IsCustomCrashReportingEnabled()

;- WV2_ENVIRONMENT_OPTIONS4
Structure WV2_ENVIRONMENT_OPTIONS4
	vt.i
	refCount.l
	mutex.i
	;Properties
	*customSchemeRegistrations.WV2_VECTOR_ICUSTOM_SCHEME_REGISTRATION
	customSchemeRegistrationsCount.l
EndStructure

Procedure wv2_EnvironmentOptions4_New()
	Protected.WV2_ENVIRONMENT_OPTIONS4 *this
	
	*this = AllocateMemory(SizeOf(WV2_ENVIRONMENT_OPTIONS4))
	*this\vt = @WV2_ENVIRONMENT_OPTIONS4_VTABLE
	*this\refCount = 1
	
	*this\customSchemeRegistrations = #Null
	*this\customSchemeRegistrationsCount = 0
	
	ProcedureReturn *this
EndProcedure

Procedure wv2_EnvironmentOptions4_Free(*this.WV2_ENVIRONMENT_OPTIONS4)
	If *this\customSchemeRegistrations
		wv2_CustomSchemeRegistration_ReleaseArray(*this\customSchemeRegistrations, *this\customSchemeRegistrationsCount)
	EndIf 
	FreeMemory(*this)
EndProcedure

Procedure wv2_EnvironmentOptions4_QueryInterface(*this.WV2_ENVIRONMENT_OPTIONS4, *id.IID, *obj.INTEGER)
	If *id = #Null Or *obj = #Null : ProcedureReturn #E_POINTER : EndIf
	
	If CompareMemory(*id, ?IID_IUnknown, SizeOf(IID)) Or CompareMemory(*id, ?IID_ICoreWebView2EnvironmentOptions4, SizeOf(IID))
		*obj\i = *this
		*this\refCount = *this\refCount + 1
		ProcedureReturn #S_OK
		
	Else
		*obj\i = #Null
		ProcedureReturn #E_NOINTERFACE
	EndIf 
EndProcedure

Procedure wv2_EnvironmentOptions4_AddRef(*this.WV2_ENVIRONMENT_OPTIONS4)
	*this\refCount = *this\refCount + 1
	
	ProcedureReturn *this\refCount
EndProcedure

Procedure wv2_EnvironmentOptions4_Release(*this.WV2_ENVIRONMENT_OPTIONS4)
	*this\refCount = *this\refCount -1
	
	If *this\refCount = 0
		wv2_EnvironmentOptions4_Free(*this)
		ProcedureReturn 0
	
	Else 
		ProcedureReturn *this\refCount
	EndIf 
EndProcedure

Procedure wv2_EnvironmentOptions4_GetCustomSchemeRegistrations(*this.WV2_ENVIRONMENT_OPTIONS4, *count.LONG, *ptrSchemeRegistrations.INTEGER)
	Protected.WV2_VECTOR_ICUSTOM_SCHEME_REGISTRATION *schemeRegistrations
	Protected.l index
	
	If *count = #Null Or *ptrSchemeRegistrations = #Null
		ProcedureReturn #E_POINTER
	EndIf
		
	*count\l = 0
	If *this\customSchemeRegistrationsCount = 0
		*ptrSchemeRegistrations\i = #Null
		ProcedureReturn #S_OK
		
	Else
		*schemeRegistrations = CoTaskMemAlloc_(*this\customSchemeRegistrationsCount * SizeOf(INTEGER))
		For index = 0 To *this\customSchemeRegistrationsCount -1
			*schemeRegistrations\item[index] = *this\customSchemeRegistrations\item[index]
			*schemeRegistrations\item[index]\AddRef()
		Next 
		
		*count\l = *this\customSchemeRegistrationsCount
		*ptrSchemeRegistrations\i = *schemeRegistrations
		ProcedureReturn #S_OK
	EndIf 
EndProcedure

Procedure wv2_EnvironmentOptions4_SetCustomSchemeRegistrations(*this.WV2_ENVIRONMENT_OPTIONS4, count.l, *schemeRegistrations.WV2_VECTOR_ICUSTOM_SCHEME_REGISTRATION)
	Protected.l index
	
	If count < 0 : ProcedureReturn #E_INVALIDARG : EndIf
	
	wv2_CustomSchemeRegistration_ReleaseArray(*this\customSchemeRegistrations, *this\customSchemeRegistrationsCount)
	*this\customSchemeRegistrations = #Null
	*this\customSchemeRegistrationsCount = 0
	
	*this\customSchemeRegistrations = CoTaskMemAlloc_(count * SizeOf(INTEGER))
	If *this\customSchemeRegistrations = #Null
		ProcedureReturn GetLastError_()
	EndIf
	
	For index = 0 To count - 1
		*this\customSchemeRegistrations\item[index] = *schemeRegistrations\item[index]
		*this\customSchemeRegistrations\item[index]\AddRef()
	Next 
	
	*this\customSchemeRegistrationsCount = count
	
	ProcedureReturn #S_OK
EndProcedure

;- VTABLE CONSTRUCTION
WV2_ENVIRONMENT_OPTIONS4_VTABLE\QueryInterface = @wv2_EnvironmentOptions4_QueryInterface()
WV2_ENVIRONMENT_OPTIONS4_VTABLE\AddRef = @wv2_EnvironmentOptions4_AddRef()
WV2_ENVIRONMENT_OPTIONS4_VTABLE\Release = @wv2_EnvironmentOptions4_Release()
WV2_ENVIRONMENT_OPTIONS4_VTABLE\GetCustomSchemeRegistrations = @wv2_EnvironmentOptions4_GetCustomSchemeRegistrations()
WV2_ENVIRONMENT_OPTIONS4_VTABLE\SetCustomSchemeRegistrations = @wv2_EnvironmentOptions4_SetCustomSchemeRegistrations()

;- WV2_ENVIRONMENT_OPTIONS5
Structure WV2_ENVIRONMENT_OPTIONS5
	vt.i
	refCount.l
	mutex.i
	;Properties
	EnableTrackingPrevention.l
EndStructure

Procedure wv2_EnvironmentOptions5_New()
	Protected.WV2_ENVIRONMENT_OPTIONS5 *this
	
	*this = AllocateMemory(SizeOf(WV2_ENVIRONMENT_OPTIONS5))
	*this\vt = @WV2_ENVIRONMENT_OPTIONS5_VTABLE
	*this\refCount = 1
	
	*this\EnableTrackingPrevention = #True
	
	ProcedureReturn *this
EndProcedure

Procedure wv2_EnvironmentOptions5_Free(*this.WV2_ENVIRONMENT_OPTIONS5)
	FreeMemory(*this)
EndProcedure

Procedure wv2_EnvironmentOptions5_QueryInterface(*this.WV2_ENVIRONMENT_OPTIONS5, *id.IID, *obj.INTEGER)
	If *id = #Null Or *obj = #Null : ProcedureReturn #E_POINTER : EndIf
	
	If CompareMemory(*id, ?IID_IUnknown, SizeOf(IID)) Or CompareMemory(*id, ?IID_ICoreWebView2EnvironmentOptions5, SizeOf(IID))
		*obj\i = *this
		*this\refCount = *this\refCount + 1
		ProcedureReturn #S_OK
		
	Else
		*obj\i = #Null
		ProcedureReturn #E_NOINTERFACE
	EndIf 
EndProcedure

Procedure wv2_EnvironmentOptions5_AddRef(*this.WV2_ENVIRONMENT_OPTIONS5)
	*this\refCount = *this\refCount + 1
	
	ProcedureReturn *this\refCount
EndProcedure

Procedure wv2_EnvironmentOptions5_Release(*this.WV2_ENVIRONMENT_OPTIONS5)
	*this\refCount = *this\refCount -1
	
	If *this\refCount = 0
		wv2_EnvironmentOptions5_Free(*this)
		ProcedureReturn 0
	
	Else 
		ProcedureReturn *this\refCount
	EndIf 
EndProcedure

Procedure wv2_EnvironmentOptions5_get_EnableTrackingPrevention(*this.WV2_ENVIRONMENT_OPTIONS5, *value.LONG)
	If *value = #Null : ProcedureReturn #E_POINTER : EndIf	

	*value\l = *this\EnableTrackingPrevention
	ProcedureReturn #S_OK
EndProcedure

Procedure wv2_EnvironmentOptions5_put_EnableTrackingPrevention(*this.WV2_ENVIRONMENT_OPTIONS5, value.l)
	*this\EnableTrackingPrevention = value
	ProcedureReturn #S_OK
EndProcedure

;- VTABLE CONSTRUCTION
WV2_ENVIRONMENT_OPTIONS5_VTABLE\QueryInterface = @wv2_EnvironmentOptions5_QueryInterface()
WV2_ENVIRONMENT_OPTIONS5_VTABLE\AddRef = @wv2_EnvironmentOptions5_AddRef()
WV2_ENVIRONMENT_OPTIONS5_VTABLE\Release = @wv2_EnvironmentOptions5_Release()
WV2_ENVIRONMENT_OPTIONS5_VTABLE\get_EnableTrackingPrevention = @wv2_EnvironmentOptions5_get_EnableTrackingPrevention()
WV2_ENVIRONMENT_OPTIONS5_VTABLE\put_EnableTrackingPrevention = @wv2_EnvironmentOptions5_put_EnableTrackingPrevention()

;- WV2_ENVIRONMENT_OPTIONS6
Structure WV2_ENVIRONMENT_OPTIONS6
	vt.i
	refCount.l
	mutex.i
	;Properties
	areBrowserExtensionsEnabled.l
EndStructure

Procedure wv2_EnvironmentOptions6_New()
	Protected.WV2_ENVIRONMENT_OPTIONS6 *this
	
	*this = AllocateMemory(SizeOf(WV2_ENVIRONMENT_OPTIONS6))
	*this\vt = @WV2_ENVIRONMENT_OPTIONS6_VTABLE
	*this\refCount = 1
	
	*this\areBrowserExtensionsEnabled = #False
	
	ProcedureReturn *this
EndProcedure

Procedure wv2_EnvironmentOptions6_Free(*this.WV2_ENVIRONMENT_OPTIONS6)
	FreeMemory(*this)
EndProcedure

Procedure wv2_EnvironmentOptions6_QueryInterface(*this.WV2_ENVIRONMENT_OPTIONS6, *id.IID, *obj.INTEGER)
	If *id = #Null Or *obj = #Null : ProcedureReturn #E_POINTER : EndIf
	
	If CompareMemory(*id, ?IID_IUnknown, SizeOf(IID)) Or CompareMemory(*id, ?IID_ICoreWebView2EnvironmentOptions6, SizeOf(IID))
		*obj\i = *this
		*this\refCount = *this\refCount + 1
		ProcedureReturn #S_OK
		
	Else
		*obj\i = #Null
		ProcedureReturn #E_NOINTERFACE
	EndIf 
EndProcedure

Procedure wv2_EnvironmentOptions6_AddRef(*this.WV2_ENVIRONMENT_OPTIONS6)
	*this\refCount = *this\refCount + 1
	
	ProcedureReturn *this\refCount
EndProcedure

Procedure wv2_EnvironmentOptions6_Release(*this.WV2_ENVIRONMENT_OPTIONS6)
	*this\refCount = *this\refCount -1
	
	If *this\refCount = 0
		wv2_EnvironmentOptions6_Free(*this)
		ProcedureReturn 0
	
	Else 
		ProcedureReturn *this\refCount
	EndIf 
EndProcedure

Procedure wv2_EnvironmentOptions6_get_AreBrowserExtensionsEnabled(*this.WV2_ENVIRONMENT_OPTIONS6, *value.LONG)
	If *value = #Null : ProcedureReturn #E_POINTER : EndIf
		
	*value\l = *this\areBrowserExtensionsEnabled
	ProcedureReturn #S_OK
EndProcedure

Procedure wv2_EnvironmentOptions6_put_AreBrowserExtensionsEnabled(*this.WV2_ENVIRONMENT_OPTIONS6, value.l)	
	*this\areBrowserExtensionsEnabled = value
	ProcedureReturn #S_OK
EndProcedure

;- VTABLE CONSTRUCTION
WV2_ENVIRONMENT_OPTIONS6_VTABLE\QueryInterface = @wv2_EnvironmentOptions6_QueryInterface()
WV2_ENVIRONMENT_OPTIONS6_VTABLE\AddRef = @wv2_EnvironmentOptions6_AddRef()
WV2_ENVIRONMENT_OPTIONS6_VTABLE\Release = @wv2_EnvironmentOptions6_Release()
WV2_ENVIRONMENT_OPTIONS6_VTABLE\get_AreBrowserExtensionsEnabled = @wv2_EnvironmentOptions6_get_AreBrowserExtensionsEnabled()
WV2_ENVIRONMENT_OPTIONS6_VTABLE\put_AreBrowserExtensionsEnabled = @wv2_EnvironmentOptions6_put_AreBrowserExtensionsEnabled()

