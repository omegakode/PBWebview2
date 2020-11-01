; XIncludeFile "windows\Unknwn.pbi"
; XIncludeFile "windows\objidl.pbi"
; 
; XIncludeFile "WebView2.pbi"
; XIncludeFile "WebView2Loader.pbi"

EnableExplicit

;- VERSION
#WV2_VERSION = "0.1.2"

;- CONSTANTS
#WV2_FIRST_CUSTOM_EVENT = #PB_Event_FirstCustomValue

Enumeration #WV2_FIRST_CUSTOM_EVENT
	#WV2_CUSTOM_EVENT_ENVIRONMENT_CREATED = #WV2_FIRST_CUSTOM_EVENT
	#WV2_CUSTOM_EVENT_CONTROLLER_CREATED
	#WV2_CUSTOM_EVENT_SCRIPT_EXECUTED
EndEnumeration

;- WV2_EVENT_HANDLER
Structure WV2_EVENT_HANDLER
	*vt.WV2_EVENT_HANDLER_VTBL
	refCount.l
	mutex.i
	*iid.IID
	retVal.i
	retValStr.s
	context.i
EndStructure

Prototype wv2_EventHandler_Invoke(*this.WV2_EVENT_HANDLER, sender.i, args.i)

;- WV2_EVENT_HANDLER_VTBL
Structure WV2_EVENT_HANDLER_VTBL Extends IUnknownVtbl
	Invoke.i
EndStructure

;- PROTOTYPES
Prototype wv2_Window_ProcessEvent(ev.l)

;- DECLARES
Declare.s wv2_GetBrowserVersion(browserExecutableFolder.s)
Declare wv2_Controller_put_Bounds(wvc.ICoreWebView2Controller, *bounds.RECT)

Declare wv2_EventHandler_New(*id.IID, invokeHandler.wv2_EventHandler_Invoke, context.i = 0)
Declare wv2_EventHandler_Free(*this.WV2_EVENT_HANDLER)
Declare wv2_EventHandler_QueryInterface(*this.WV2_EVENT_HANDLER, *id.IID, *obj.INTEGER)
Declare wv2_EventHandler_AddRef(*this.WV2_EVENT_HANDLER)
Declare wv2_EventHandler_Release(*this.WV2_EVENT_HANDLER)
Declare wv2_EventHandler_LockMutex(*this.WV2_EVENT_HANDLER)
Declare wv2_EventHandler_UnlockMutex(*this.WV2_EVENT_HANDLER)
Declare wv2_EventHandler_GetContext(*this.WV2_EVENT_HANDLER)

Declare wv2_CreateCoreWebView2EnvironmentWithOptionsSync(browserExecutableFolder.s, userDataFolder.s, environmentOptions.i, proecessEvent.wv2_Window_ProcessEvent)

Declare wv2_Environment_Created_Sync(*this.WV2_EVENT_HANDLER, result.l, environment.ICoreWebView2Environment)	
Declare wv2_Environment_CreateCoreWebView2ControllerSync(environment.ICoreWebView2Environment, parentWindow.i, proecessEvent.wv2_Window_ProcessEvent)

Declare wv2_Controller_Created_Sync(*this.WV2_EVENT_HANDLER, result.l, controller.ICoreWebView2Controller)

Declare wv2_Core_ScriptExecuted_Sync(*this.WV2_EVENT_HANDLER, errorCode.l, resultObjectAsJson.i)
Declare.s wv2_Core_ExecuteScriptSync(wvCore.ICoreWebView2, script.s, processEvent.wv2_Window_ProcessEvent, *errorCode.LONG = #Null)

Declare.s wv2_CreateJSHostObjectProxy(hostObjName.s)

Procedure wv2_EventHandler_New(*iid.IID, invokeHandler.wv2_EventHandler_Invoke, context.i = 0)
	Protected.WV2_EVENT_HANDLER *this
	
	*this = AllocateMemory(SizeOf(WV2_EVENT_HANDLER))
	*this\vt = AllocateMemory(SizeOf(WV2_EVENT_HANDLER_VTBL))
	*this\vt\QueryInterface = @wv2_EventHandler_QueryInterface()
	*this\vt\AddRef = @wv2_EventHandler_AddRef()
	*this\vt\Release = @wv2_EventHandler_Release()
	*this\vt\Invoke = invokeHandler

	*this\iid = *iid
	*this\mutex = CreateMutex()
	*this\refCount = 1
	*this\context = context
	
	ProcedureReturn *this
EndProcedure

Procedure wv2_EventHandler_Free(*this.WV2_EVENT_HANDLER)
	FreeMutex(*this\mutex)
	FreeMemory(*this\vt)
	FreeMemory(*this)
EndProcedure

Procedure wv2_EventHandler_QueryInterface(*this.WV2_EVENT_HANDLER, *iid.IID, *obj.INTEGER)
	If CompareMemory(*iid, ?IID_IUnknown, SizeOf(IID)) Or CompareMemory(*iid, *this\iid, SizeOf(IID))
		*obj\i = *this
		wv2_EventHandler_AddRef(*this)
		
		ProcedureReturn #S_OK
		
	Else
		*obj\i = #Null
		ProcedureReturn #E_NOINTERFACE
	EndIf 
EndProcedure

Procedure wv2_EventHandler_AddRef(*this.WV2_EVENT_HANDLER)
	*this\refCount = *this\refCount + 1
EndProcedure

Procedure wv2_EventHandler_Release(*this.WV2_EVENT_HANDLER)
	*this\refCount = *this\refCount - 1
	If *this\refCount = 0
		wv2_EventHandler_Free(*this)
	EndIf 
EndProcedure

Procedure wv2_DeleteUserDataFolder(folder.s, processId.l, timeout.l)
	Protected.i processHandle
	Protected.l waitResult, elapsed, delResult

	processHandle = OpenProcess_(#SYNCHRONIZE , #True, processId)
	If processHandle
		waitResult = WaitForSingleObject_(processHandle, timeout)
		CloseHandle_(processHandle)
		If waitResult = #WAIT_OBJECT_0
			elapsed = 0
			delResult = #False
			While (delResult = #False And elapsed <= timeout)
				delResult = DeleteDirectory(folder, "", #PB_FileSystem_Recursive | #PB_FileSystem_Force)
				Delay(1)
				elapsed + 1
			Wend
			
			ProcedureReturn delResult
			
		Else
			ProcedureReturn #False 
		EndIf
		
	Else
		ProcedureReturn #False
	EndIf 
EndProcedure

Procedure.s wv2_CreateJSHostObjectProxy(hostObjName.s)
	ProcedureReturn "var " + hostObjName + " = new Proxy({}, {get: (target, prop) => window.chrome.webview.hostObjects.sync." + hostObjName + "[prop]});"
EndProcedure

Procedure.s wv2_GetBrowserVersion(browserExecutableFolder.s)
	Protected.i vi
	Protected.s vs
	
	If GetAvailableCoreWebView2BrowserVersionString(browserExecutableFolder, @vi) = #S_OK
		If vi
			vs = PeekS(vi)
			CoTaskMemFree_(vi)
		EndIf 
	EndIf 

	ProcedureReturn vs
EndProcedure

Procedure wv2_Controller_put_Bounds(wvc.ICoreWebView2Controller, *bounds.RECT)
	CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
		wvc\put_Bounds(*bounds)
		
	CompilerElse
		wvc\put_Bounds(*bounds\left, *bounds\top, *bounds\right, *bounds\bottom)
	CompilerEndIf
EndProcedure

Procedure wv2_Controller_On_WM_MOVE_MOVING(wvc.ICoreWebView2Controller)
	If wvc
		wvc\NotifyParentWindowPositionChanged()
	EndIf 
EndProcedure

Procedure wv2_Environment_Created_Sync(*this.WV2_EVENT_HANDLER, result.l, environment.ICoreWebView2Environment)	
	If result = #S_OK
		environment\QueryInterface(?IID_ICoreWebView2Environment, @*this\retVal)
	
	Else
		*this\retVal = #Null
	EndIf 
	
	PostEvent(#WV2_CUSTOM_EVENT_ENVIRONMENT_CREATED)
EndProcedure

Procedure wv2_CreateCoreWebView2EnvironmentWithOptionsSync(browserExecutableFolder.s, userDataFolder.s, environmentOptions.i, processEvent.wv2_Window_ProcessEvent)
	Protected.WV2_EVENT_HANDLER *evEnvCreated
	Protected.i environment
	Protected.l winEv
	
	*evEnvCreated = wv2_EventHandler_New(?IID_ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler, @wv2_Environment_Created_Sync())
	CreateCoreWebView2EnvironmentWithOptions(browserExecutableFolder, userDataFolder, environmentOptions, *evEnvCreated)

	Repeat
		winEv = WaitWindowEvent()
	Until processEvent(winEv) = #True Or winEv = #WV2_CUSTOM_EVENT_ENVIRONMENT_CREATED
	
	environment = *evEnvCreated\retVal
	wv2_EventHandler_Release(*evEnvCreated)
	
	ProcedureReturn environment
EndProcedure

Procedure wv2_Controller_Created_Sync(*this.WV2_EVENT_HANDLER, result.l, controller.ICoreWebView2Controller)
	If result = #S_OK
		controller\QueryInterface(?IID_ICoreWebView2Controller, @*this\retVal)
		
	Else
		*this\retVal = #Null
	EndIf 
	
	PostEvent(#WV2_CUSTOM_EVENT_CONTROLLER_CREATED)
EndProcedure

Procedure wv2_Environment_CreateCoreWebView2ControllerSync(environment.ICoreWebView2Environment, parentWindow.i, processEvent.wv2_Window_ProcessEvent)
	Protected.WV2_EVENT_HANDLER *evControllerCreated
	Protected.i controller
	Protected.l winEv
	
	*evControllerCreated = wv2_EventHandler_New(?IID_ICoreWebView2CreateCoreWebView2ControllerCompletedHandler, @wv2_Controller_Created_Sync())
	environment\CreateCoreWebView2Controller(parentWindow, *evControllerCreated)

	Repeat
		winEv = WaitWindowEvent()
	Until processEvent(winEv) = #True Or winEv = #WV2_CUSTOM_EVENT_CONTROLLER_CREATED
	
	controller = *evControllerCreated\retVal
	wv2_EventHandler_Release(*evControllerCreated)
	
	ProcedureReturn controller
EndProcedure

Procedure wv2_Core_ScriptExecuted_Sync(*this.WV2_EVENT_HANDLER, errorCode.l, resultObjectAsJson.i)		
	If resultObjectAsJson
		*this\retValStr = PeekS(resultObjectAsJson)
	EndIf 

	PostEvent(#WV2_CUSTOM_EVENT_SCRIPT_EXECUTED)
EndProcedure

Procedure.s wv2_Core_ExecuteScriptSync(wvCore.ICoreWebView2, script.s, processEvent.wv2_Window_ProcessEvent, *errorCode.LONG = #Null)
	Protected.WV2_EVENT_HANDLER *evScriptExecuted
	Protected.s ret
	Protected.l winEv
	
	*evScriptExecuted = wv2_EventHandler_New(?IID_ICoreWebView2ExecuteScriptCompletedHandler, @wv2_Core_ScriptExecuted_Sync())
	wvCore\ExecuteScript(script, *evScriptExecuted)

	Repeat
		winEv = WaitWindowEvent()
	Until processEvent(winEv) = #True Or winEv = #WV2_CUSTOM_EVENT_SCRIPT_EXECUTED
	
	ret = *evScriptExecuted\retValStr
	wv2_EventHandler_Release(*evScriptExecuted)

	ProcedureReturn ret
EndProcedure


