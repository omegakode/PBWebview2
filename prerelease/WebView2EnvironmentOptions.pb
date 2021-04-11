XIncludeFile "..\windows\Unknwn.pbi"
; XIncludeFile "WebView2.pbi"
XIncludeFile "..\string.pb"

EnableExplicit

#CORE_WEBVIEW_TARGET_PRODUCT_VERSION = "91.0.824.0"

;- WV2_ENVIRONMENT_OPTIONS
Structure WV2_ENVIRONMENT_OPTIONS
	vt.i
	refCount.l
	mutex.i
	;Properties
	additionalBrowserArguments.s
	language.s
	targetCompatibleBrowserVersion.s
	allowSingleSignOnUsingOSPrimaryAccount.l
EndStructure

Global.ICoreWebView2EnvironmentOptionsVtbl WV2_ENVIRONMENT_OPTIONS_VTABLE

Procedure wv2_EnvironmentOptions_New()
	Protected.WV2_ENVIRONMENT_OPTIONS *this
	
	*this = AllocateMemory(SizeOf(WV2_ENVIRONMENT_OPTIONS))
	*this\vt = @WV2_ENVIRONMENT_OPTIONS_VTABLE
	*this\targetCompatibleBrowserVersion = #CORE_WEBVIEW_TARGET_PRODUCT_VERSION
	*this\allowSingleSignOnUsingOSPrimaryAccount = #False
	*this\refCount = 1
	
	ProcedureReturn *this
EndProcedure

Procedure wv2_EnvironmentOptions_Free(*this.WV2_ENVIRONMENT_OPTIONS)
	FreeMemory(*this)
EndProcedure

Procedure wv2_EnvironmentOptions_QueryInterface(*this.WV2_ENVIRONMENT_OPTIONS, *id.IID, *obj.INTEGER)	
	If CompareMemory(*id, ?IID_IUnknown, SizeOf(IID)) Or CompareMemory(*id, ?IID_ICoreWebView2EnvironmentOptions, SizeOf(IID))
		*obj\i = *this
		*this\refCount = *this\refCount + 1
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
	*value\i = str_MakeCoMemString(*this\additionalBrowserArguments)
	
	ProcedureReturn #S_OK
EndProcedure

Procedure wv2_EnvironmentOptions_put_AdditionalBrowserArguments(*this.WV2_ENVIRONMENT_OPTIONS, value.s)
	*this\additionalBrowserArguments = value
	
	ProcedureReturn #S_OK
EndProcedure

Procedure wv2_EnvironmentOptions_get_Language(*this.WV2_ENVIRONMENT_OPTIONS, *value.INTEGER)
	*value\i = str_MakeCoMemString(*this\language)
	
	ProcedureReturn #S_OK
EndProcedure

Procedure wv2_EnvironmentOptions_put_Language(*this.WV2_ENVIRONMENT_OPTIONS, value.s)
	*this\language = value
	
	ProcedureReturn #S_OK
EndProcedure

Procedure wv2_EnvironmentOptions_get_TargetCompatibleBrowserVersion(*this.WV2_ENVIRONMENT_OPTIONS, *value.INTEGER)
	*value\i = str_MakeCoMemString(*this\targetCompatibleBrowserVersion)

	ProcedureReturn #S_OK
EndProcedure

Procedure wv2_EnvironmentOptions_put_TargetCompatibleBrowserVersion(*this.WV2_ENVIRONMENT_OPTIONS, value.s)
	*this\targetCompatibleBrowserVersion = value
	
	ProcedureReturn #S_OK
EndProcedure

Procedure wv2_EnvironmentOptions_get_AllowSingleSignOnUsingOSPrimaryAccount(*this.WV2_ENVIRONMENT_OPTIONS, *value.LONG)
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