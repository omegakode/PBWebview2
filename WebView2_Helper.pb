;WebView2_Helper.pb

EnableExplicit

;- VERSION
#WV2_VERSION = "0.2.0"

Prototype wv2_EventHandler_Invoke(this.i, sender.i, args.i)
Prototype wv2_EventHandler_Finalize(this.i)

;-
;- WV2_EVENT_HANDLER_CLASS
Structure WV2_EVENT_HANDLER_CLASS
	*parent.WV2_EVENT_HANDLER_CLASS
	finalize.wv2_EventHandler_Finalize
EndStructure

;- WV2_EVENT_HANDLER
Structure WV2_EVENT_HANDLER
	vt.i
	*class.WV2_EVENT_HANDLER_CLASS
	refCount.l
	mutex.i
	context.i
	invokeHandler.wv2_EventHandler_Invoke
EndStructure

;- WV2_EVENT_HANDLER_VTBL
Structure WV2_EVENT_HANDLER_VTBL Extends IUnknownVtbl
	Invoke.i
	GetContext.i
	SetContext.i
	LockMutex.i
	UnlockMutex.i
EndStructure

;- IWV2EventHandler
Interface IWV2EventHandler Extends IUnknown
	Invoke(sender.i, args.i)
	GetContext()
	SetContext(context.i)
	LockMutex()
	UnlockMutex()
EndInterface

;-
;- WV2_EVENT_HANDLER_WAITABLE_CLASS
Structure WV2_EVENT_HANDLER_WAITABLE_CLASS Extends WV2_EVENT_HANDLER_CLASS
EndStructure

;- WV2_EVENT_HANDLER_WAITABLE
Structure WV2_EVENT_HANDLER_WAITABLE Extends WV2_EVENT_HANDLER
	_event.i	;api event
	args.i 
EndStructure

;- WV2_EVENT_HANDLER_WAITABLE_VTBL
Structure WV2_EVENT_HANDLER_WAITABLE_VTBL Extends WV2_EVENT_HANDLER_VTBL
	WaitForCompletion.i
	StopWaiting.i
	GetArgs.i
	SetArgs.i
EndStructure

;- IWV2EventHandlerWaitable
Interface IWV2EventHandlerWaitable Extends IWV2EventHandler
	WaitForCompletion(timeout.l = #INFINITE)
	StopWaiting()
	GetArgs()
	SetArgs(args.i)
EndInterface

;-
;- DECLARES
Declare.s wv2_GetBrowserVersion(browserExecutableFolder.s)
Declare wv2_Controller_put_Bounds(wvc.ICoreWebView2Controller, *bounds.RECT)

Declare wv2_EventHandler_New(invokeHandler.wv2_EventHandler_Invoke, context.i)
Declare wv2_EventHandler_Finalize(*this.WV2_EVENT_HANDLER)
Declare wv2_EventHandler_Free(*this.WV2_EVENT_HANDLER)

Declare wv2_EventHandler_QueryInterface(*this.WV2_EVENT_HANDLER, *id.IID, *obj.INTEGER)
Declare wv2_EventHandler_AddRef(*this.WV2_EVENT_HANDLER)
Declare wv2_EventHandler_Release(*this.WV2_EVENT_HANDLER)
Declare wv2_EventHandler_Invoke(*this.WV2_EVENT_HANDLER, sender.i, args.i)
Declare wv2_EventHandler_GetContext(*this.WV2_EVENT_HANDLER)
Declare wv2_EventHandler_SetContext(*this.WV2_EVENT_HANDLER, context.i)
Declare wv2_EventHandler_LockMutex(*this.WV2_EVENT_HANDLER)
Declare wv2_EventHandler_UnlockMutex(*this.WV2_EVENT_HANDLER)


Declare wv2_EventHandler_LockMutex(*this.WV2_EVENT_HANDLER)
Declare wv2_EventHandler_UnlockMutex(*this.WV2_EVENT_HANDLER)

Declare wv2_EventHandlerWaitable_Finalize(*this.WV2_EVENT_HANDLER_WAITABLE)

Declare wv2_EventHandlerWaitable_WaitForCompletion(*this.WV2_EVENT_HANDLER_WAITABLE, timeout.l = #INFINITE)
Declare wv2_EventHandlerWaitable_StopWaiting(*this.WV2_EVENT_HANDLER_WAITABLE)
Declare wv2_EventHandlerWaitable_GetArgs(*this.WV2_EVENT_HANDLER_WAITABLE)
Declare wv2_EventHandlerWaitable_SetArgs(*this.WV2_EVENT_HANDLER_WAITABLE, args.i)

Declare wv2_CreateCoreWebView2EnvironmentWithOptionsSync(browserExecutableFolder.s, userDataFolder.s, environmentOptions.i)

Declare wv2_Environment_Created_Sync(*this.WV2_EVENT_HANDLER, result.l, environment.ICoreWebView2Environment)	
Declare wv2_Environment_CreateCoreWebView2ControllerSync(environment.ICoreWebView2Environment, parentWindow.i)

Declare wv2_Controller_Created_Sync(*this.WV2_EVENT_HANDLER, result.l, controller.ICoreWebView2Controller)

Declare wv2_Core_ScriptExecuted_Sync(*this.WV2_EVENT_HANDLER, errorCode.l, resultObjectAsJson.i)
Declare.s wv2_Core_ExecuteScriptSync(wvCore.ICoreWebView2, script.s, *errorCode.LONG = #Null)

Declare.s wv2_CreateJSHostObjectProxy(hostObjName.s)

;-
Procedure wv2_EventHandler_Class()
	Static.WV2_EVENT_HANDLER_CLASS *class
	
	If *class = #Null
		*class = AllocateMemory(SizeOf(WV2_EVENT_HANDLER_CLASS))
		*class\parent = #Null
		*class\finalize = @wv2_EventHandler_Finalize()
	EndIf
	
	ProcedureReturn *class
EndProcedure

Procedure wv2_EventHandler_VTable()
	Static.WV2_EVENT_HANDLER_VTBL *vt
	
	If *vt = #Null
		*vt = AllocateMemory(SizeOf(WV2_EVENT_HANDLER_VTBL))
		*vt\QueryInterface = @wv2_EventHandler_QueryInterface()
		*vt\AddRef = @wv2_EventHandler_AddRef()
		*vt\Release = @wv2_EventHandler_Release()
		*vt\Invoke = @wv2_EventHandler_Invoke()
		*vt\GetContext = @wv2_EventHandler_GetContext()
		*vt\SetContext = @wv2_EventHandler_SetContext()
		*vt\LockMutex = @wv2_EventHandler_LockMutex()
		*vt\UnlockMutex = @wv2_EventHandler_UnlockMutex()
	EndIf
	
	ProcedureReturn *vt
EndProcedure

Procedure wv2_EventHandler_Init(*this.WV2_EVENT_HANDLER, invokeHandler.wv2_EventHandler_Invoke, context.i)
	*this\invokeHandler = invokeHandler
	*this\context = context
	
	*this\mutex = CreateMutex()
	*this\refCount = 1
EndProcedure

Procedure  wv2_EventHandler_Finalize(*this.WV2_EVENT_HANDLER)
	FreeMutex(*this\mutex)
	FreeMemory(*this)
EndProcedure

Procedure wv2_EventHandler_New(invokeHandler.wv2_EventHandler_Invoke, context.i)
	Protected.WV2_EVENT_HANDLER *this
	
	*this = AllocateMemory(SizeOf(WV2_EVENT_HANDLER))
	*this\vt = wv2_EventHandler_VTable()
	*this\class = wv2_EventHandler_Class()

	wv2_EventHandler_Init(*this, invokeHandler, context)
		
	ProcedureReturn *this
EndProcedure

Procedure wv2_EventHandler_QueryInterface(*this.WV2_EVENT_HANDLER, *iid.IID, *obj.INTEGER)
	If CompareMemory(*iid, ?IID_IUnknown, SizeOf(IID))
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
		*this\class\finalize(*this)
	EndIf 
	
	ProcedureReturn *this\refCount
EndProcedure

Procedure wv2_EventHandler_Invoke(*this.WV2_EVENT_HANDLER, sender.i, args.i)
	If *this\invokeHandler : *this\invokeHandler(*this, sender, args) : EndIf 
EndProcedure

Procedure wv2_EventHandler_GetContext(*this.WV2_EVENT_HANDLER)
	ProcedureReturn *this\context
EndProcedure

Procedure wv2_EventHandler_SetContext(*this.WV2_EVENT_HANDLER, context.i)
	*this\context = context
EndProcedure

Procedure wv2_EventHandler_LockMutex(*this.WV2_EVENT_HANDLER)
	LockMutex(*this\mutex)
EndProcedure

Procedure wv2_EventHandler_UnlockMutex(*this.WV2_EVENT_HANDLER)
	UnlockMutex(*this\mutex)
EndProcedure
;-

Procedure wv2_EventHandlerWaitable_Class()
	Static.WV2_EVENT_HANDLER_WAITABLE_CLASS *class
	
	If *class = #Null
		*class = AllocateMemory(SizeOf(WV2_EVENT_HANDLER_WAITABLE_CLASS))
		*class\parent = wv2_EventHandler_Class()
		*class\finalize = @wv2_EventHandlerWaitable_Finalize()
	EndIf
	
	ProcedureReturn *class
EndProcedure

Procedure wv2_EventHandlerWaitable_VTable()
	Static.WV2_EVENT_HANDLER_WAITABLE_VTBL *vt
	
	If *vt = #Null
		*vt = AllocateMemory(SizeOf(WV2_EVENT_HANDLER_WAITABLE_VTBL))
		CopyMemory(wv2_EventHandler_VTable(), *vt, SizeOf(WV2_EVENT_HANDLER_VTBL))
		*vt\WaitForCompletion = @wv2_EventHandlerWaitable_WaitForCompletion()
		*vt\StopWaiting = @wv2_EventHandlerWaitable_StopWaiting()
		*vt\GetArgs = @wv2_EventHandlerWaitable_GetArgs()
		*vt\SetArgs = @wv2_EventHandlerWaitable_SetArgs()
	EndIf
	
	ProcedureReturn *vt
EndProcedure

Procedure wv2_EventHandlerWaitable_Init(*this.WV2_EVENT_HANDLER_WAITABLE, invokeHandler.wv2_EventHandler_Invoke, context.i)
	wv2_EventHandler_Init(*this, invokeHandler, context)
	*this\_event = CreateEvent_(#Null, #False, #False, #Null)
EndProcedure

Procedure wv2_EventHandlerWaitable_Finalize(*this.WV2_EVENT_HANDLER_WAITABLE)
	CloseHandle_(*this\_event)
	
	If *this\class\parent
		*this\class\parent\finalize(*this)
	EndIf 
EndProcedure

Procedure wv2_EventHandlerWaitable_New(invokeHandler.wv2_EventHandler_Invoke, context.i)
	Protected.WV2_EVENT_HANDLER_WAITABLE *this
	
	*this = AllocateMemory(SizeOf(WV2_EVENT_HANDLER_WAITABLE))
	*this\vt = wv2_EventHandlerWaitable_VTable()
	*this\class = wv2_EventHandlerWaitable_Class()

	wv2_EventHandlerWaitable_Init(*this, invokeHandler, context)
	
	ProcedureReturn *this
EndProcedure

Procedure wv2_EventHandlerWaitable_WaitForCompletion(*this.WV2_EVENT_HANDLER_WAITABLE, timeout.l = #INFINITE)
	Protected.i arrHand
	Protected.l idx
	
	PokeI(@arrHand, *this\_event)
	ole32::CoWaitForMultipleHandles(#COWAIT_DISPATCH_WINDOW_MESSAGES | #COWAIT_DISPATCH_CALLS | #COWAIT_INPUTAVAILABLE, timeout, 1, @arrHand, @idx)
EndProcedure

Procedure wv2_EventHandlerWaitable_StopWaiting(*this.WV2_EVENT_HANDLER_WAITABLE)
	SetEvent_(*this\_event)
EndProcedure

Procedure wv2_EventHandlerWaitable_GetArgs(*this.WV2_EVENT_HANDLER_WAITABLE)
	ProcedureReturn *this\args
EndProcedure

Procedure wv2_EventHandlerWaitable_SetArgs(*this.WV2_EVENT_HANDLER_WAITABLE, args.i)
	*this\args = args
EndProcedure
;-

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

Procedure.s wv2_GetRuntimeVersionFromRegistry()
	Protected.i buf, hkey
	Protected.s subkey, rtVersion
	Protected.l bufLen, type
		
	CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
		subkey = "SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}"
		
	CompilerElse
	
		subkey = "SOFTWARE\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}"
	CompilerEndIf
	
	If RegOpenKey_(#HKEY_LOCAL_MACHINE, subkey, @hkey) = 0
		;Get len
		If RegQueryValueEx_(hkey, "pv", #Null, @type, #Null, @bufLen) = 0
			If bufLen > 0 And type = #REG_SZ
				bufLen = bufLen + SizeOf(CHARACTER)
				buf = AllocateMemory(buflen)

				;Get data
				If RegQueryValueEx_(hkey, "pv", #Null, #Null, buf, @bufLen) = 0
					rtVersion = PeekS(buf)
				EndIf
				
				FreeMemory(buf)
			EndIf 
		EndIf 
		
		RegCloseKey_(hkey)
	EndIf 
	
	ProcedureReturn rtVersion
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

Procedure wv2_Environment_Created_Sync(this.IWV2EventHandlerWaitable, result.l, environment.ICoreWebView2Environment)
	Protected.ICoreWebView2Environment env
	
	If result = #S_OK
		environment\QueryInterface(?IID_ICoreWebView2Environment, @env)
		this\SetArgs(env)
	EndIf 
	
	this\StopWaiting()
EndProcedure

Procedure wv2_CreateCoreWebView2EnvironmentWithOptionsSync(browserExecutableFolder.s, userDataFolder.s, environmentOptions.i)
	Protected.IWV2EventHandlerWaitable evEnvCreated
	Protected.ICoreWebView2Environment environment
	
	evEnvCreated = wv2_EventHandlerWaitable_New(@wv2_Environment_Created_Sync(), 0)
	CreateCoreWebView2EnvironmentWithOptions(browserExecutableFolder, userDataFolder, environmentOptions, evEnvCreated)
	evEnvCreated\WaitForCompletion()
	
	environment = evEnvCreated\GetArgs()

	evEnvCreated\Release()
	
	ProcedureReturn environment
EndProcedure

Procedure wv2_Controller_Created_Sync(this.IWV2EventHandlerWaitable, result.l, controller.ICoreWebView2Controller)
	Protected.ICoreWebView2Controller cont
	
	If result = #S_OK
		controller\QueryInterface(?IID_ICoreWebView2Controller, @cont)
		this\SetArgs(cont)
	EndIf 
	
	this\StopWaiting()
EndProcedure

Procedure wv2_Environment_CreateCoreWebView2ControllerSync(environment.ICoreWebView2Environment, parentWindow.i)
	Protected.IWV2EventHandlerWaitable evControllerCreated
	Protected.ICoreWebView2Controller controller
	
	evControllerCreated = wv2_EventHandlerWaitable_New(@wv2_Controller_Created_Sync(), 0)
	environment\CreateCoreWebView2Controller(parentWindow, evControllerCreated)
	evControllerCreated\WaitForCompletion()
	
	controller = evControllerCreated\GetArgs()
	evControllerCreated\Release()
	
	ProcedureReturn controller
EndProcedure

Procedure wv2_Core_ScriptExecuted_Sync(this.IWV2EventHandlerWaitable, errorCode.l, resultObjectAsJson.i)
	Protected.VECTOR_INT *args
	
	this\LockMutex()
	
	*args = AllocateMemory(SizeOf(Integer) * 2)
	*args\item[0] = errorCode
	*args\item[1] = AllocateMemory((lstrlen_(resultObjectAsJson) + 1) * SizeOf(Character))
	lstrcpy_(*args\item[1], resultObjectAsJson)
	
	this\SetArgs(*args)
	this\StopWaiting()
	
	this\UnlockMutex()
EndProcedure

;Executes a script synchronously, returns the script result as a json string.
;script : script to execute.
;*errorCode : address of a variable that will receive the script  error code.
Procedure.s wv2_Core_ExecuteScriptSync(wvCore.ICoreWebView2, script.s, *errorCode.LONG = #Null)
	Protected.IWV2EventHandlerWaitable evScriptExecuted
	Protected.s ret
	Protected.VECTOR_INT *args
	
	If *errorCode : *errorCode\l = 0 : EndIf
	
	evScriptExecuted = wv2_EventHandlerWaitable_New(@wv2_Core_ScriptExecuted_Sync(), 0)

	wvCore\ExecuteScript(script, evScriptExecuted)
	evScriptExecuted\WaitForCompletion()
	
	*args = evScriptExecuted\GetArgs()
	If *args
		If *errorCode : *errorCode\l = *args\item[0] : EndIf 
		
		ret = PeekS(*args\item[1], -1, #PB_Unicode)

		FreeMemory(*args\item[1])
		FreeMemory(*args)
	EndIf 

	evScriptExecuted\Release()
	
	ProcedureReturn ret
EndProcedure


