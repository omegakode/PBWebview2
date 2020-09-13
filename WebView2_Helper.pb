XIncludeFile "windows\Unknwn.pbi"
XIncludeFile "windows\objidl.pbi"

XIncludeFile "WebView2.pbi"
XIncludeFile "WebView2Loader.pbi"

EnableExplicit

;- VERSION
#WV2_VERSION = "0.1.1"

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

;- 
;- WV2_HTTP_HEADER
Structure WV2_HTTP_HEADER
	name.s
	value.s
EndStructure

;- WV2_HTTP_HEADERS_COLLECTION
Structure WV2_HTTP_HEADERS_COLLECTION
	refCount.l
	mutex.i
	List col.WV2_HTTP_HEADER()
EndStructure

Procedure wv2_HttpHeadersCollection_New()
	Protected.WV2_HTTP_HEADERS_COLLECTION *this
	
	*this = AllocateStructure(WV2_HTTP_HEADERS_COLLECTION)
	*this\refCount = 1
	
	ProcedureReturn *this
EndProcedure

Procedure wv2_HttpHeadersCollection_Free(*this.WV2_HTTP_HEADERS_COLLECTION)
	FreeList(*this\col())
	FreeStructure(*this)
EndProcedure

Procedure wv2_HttpHeadersCollection_AddRef(*this.WV2_HTTP_HEADERS_COLLECTION)
	*this\refCount = *this\refCount + 1
	
	ProcedureReturn *this\refCount
EndProcedure

Procedure wv2_HttpHeadersCollection_Release(*this.WV2_HTTP_HEADERS_COLLECTION)
	*this\refCount = *this\refCount - 1
	
	If *this\refCount = 0
		wv2_HttpHeadersCollection_Free(*this)
		ProcedureReturn 0
		
	Else
		ProcedureReturn *this\refCount
	EndIf 
EndProcedure

;-
;- WV2_HTTP_HEADERS_COLLECTION_ITERATOR
Structure WV2_HTTP_HEADERS_COLLECTION_ITERATOR
	vt.i
	refCount.l
	mutex.i
	*currentHeader.WV2_HTTP_HEADER
	*headersCol.WV2_HTTP_HEADERS_COLLECTION
EndStructure

Global.ICoreWebView2HttpHeadersCollectionIteratorVtbl WV2_HTTP_HEADERS_COLLECTION_ITERATOR_VTABLE

Procedure wv2_HttpHeadersCollectionIterator_New(*headersCol.WV2_HTTP_HEADERS_COLLECTION)
	Protected.WV2_HTTP_HEADERS_COLLECTION_ITERATOR *this
	
	*this = AllocateMemory(SizeOf(WV2_HTTP_HEADERS_COLLECTION_ITERATOR))
	*this\vt = @WV2_HTTP_HEADERS_COLLECTION_ITERATOR_VTABLE
	*this\refCount = 1
	
	*this\headersCol = *headersCol
	*this\currentHeader = #Null
	
	ProcedureReturn *this
EndProcedure

Procedure wv2_HttpHeadersCollectionIterator_Free(*this.WV2_HTTP_HEADERS_COLLECTION_ITERATOR)
	wv2_HttpHeadersCollection_Release(*this\headersCol)
	FreeMemory(*this)
EndProcedure

Procedure wv2_HttpHeadersCollectionIterator_QueryInterface(*this.WV2_HTTP_HEADERS_COLLECTION_ITERATOR, *id.IID, *obj.INTEGER)	
	If CompareMemory(*id, ?IID_IUnknown, SizeOf(IID)) Or CompareMemory(*id, ?IID_ICoreWebView2HttpHeadersCollectionIterator, SizeOf(IID))
		*obj\i = *this
		*this\refCount = *this\refCount + 1
		ProcedureReturn #S_OK
		
	Else
		*obj\i = #Null
		ProcedureReturn #E_NOINTERFACE
	EndIf 
EndProcedure
	
Procedure wv2_HttpHeadersCollectionIterator_AddRef(*this.WV2_HTTP_HEADERS_COLLECTION_ITERATOR)		
	*this\refCount = *this\refCount + 1
	
	ProcedureReturn *this\refCount
EndProcedure

Procedure wv2_HttpHeadersCollectionIterator_Release(*this.WV2_HTTP_HEADERS_COLLECTION_ITERATOR)	
	*this\refCount = *this\refCount - 1

	If *this\refCount = 0
		wv2_HttpHeadersCollectionIterator_Free(*this)
		ProcedureReturn 0
		
	Else
		ProcedureReturn *this\refCount
	EndIf 
EndProcedure

Procedure wv2_HttpHeadersCollectionIterator_getCurrentHeader(*this.WV2_HTTP_HEADERS_COLLECTION_ITERATOR, *name.INTEGER, *value.INTEGER)
	Protected.i nameBuf, valueBuf
	
	If *name = #Null Or *value = #Null : ProcedureReturn #E_INVALIDARG : EndIf 
	
	*name\i = #Null
	*value\i = #Null
	
	If *this\currentHeader
		nameBuf = CoTaskMemAlloc_(StringByteLength(*this\currentHeader\name))
		valueBuf = CoTaskMemAlloc_(StringByteLength(*this\currentHeader\value))
		If nameBuf And valueBuf
			*name\i = nameBuf
			*value\i = valueBuf
			
			ProcedureReturn #S_OK
			
		Else
			ProcedureReturn #E_OUTOFMEMORY
		EndIf 
		
	Else
		ProcedureReturn #E_FAIL
	EndIf 
EndProcedure

Procedure	wv2_HttpHeadersCollectionIterator_get_HasCurrentHeader(*this.WV2_HTTP_HEADERS_COLLECTION_ITERATOR, *hasCurrent.LONG)
	If *hasCurrent = #Null : ProcedureReturn #E_INVALIDARG : EndIf
	
	If *this\currentHeader
		*hasCurrent\l = #True
		
	Else
		*hasCurrent\l = #False
	EndIf
	
	ProcedureReturn #S_OK
EndProcedure

Procedure wv2_HttpHeadersCollectionIterator_moveNext(*this.WV2_HTTP_HEADERS_COLLECTION_ITERATOR, *hasNext.LONG)
	If *hasNext = #Null : ProcedureReturn #E_INVALIDARG : EndIf

	ChangeCurrentElement(*this\headersCol\col(), *this\currentHeader)
	*this\currentHeader = NextElement(*this\headersCol\col())
	
	If *this\currentHeader
		*hasNext\l = #True
		
	Else
		*hasNext\l = #False
	EndIf 
EndProcedure

;- VTABLE CONSTRUCTION
WV2_HTTP_HEADERS_COLLECTION_ITERATOR_VTABLE\QueryInterface = @wv2_HttpHeadersCollectionIterator_QueryInterface()
WV2_HTTP_HEADERS_COLLECTION_ITERATOR_VTABLE\AddRef = @wv2_HttpHeadersCollectionIterator_AddRef()
WV2_HTTP_HEADERS_COLLECTION_ITERATOR_VTABLE\Release = @wv2_httpHeadersCollectionIterator_Release()
WV2_HTTP_HEADERS_COLLECTION_ITERATOR_VTABLE\GetCurrentHeader = @wv2_HttpHeadersCollectionIterator_getCurrentHeader()
WV2_HTTP_HEADERS_COLLECTION_ITERATOR_VTABLE\get_HasCurrentHeader = @wv2_HttpHeadersCollectionIterator_get_HasCurrentHeader()
WV2_HTTP_HEADERS_COLLECTION_ITERATOR_VTABLE\MoveNext = @wv2_HttpHeadersCollectionIterator_moveNext()

;-
;- WV2_HTTP_RESPONSE_HEADERS
Structure WV2_HTTP_RESPONSE_HEADERS
	vt.i
	refCount.l
	mutex.i
	*headersCol.WV2_HTTP_HEADERS_COLLECTION
EndStructure

Global.ICoreWebView2HttpResponseHeadersVtbl WV2_HTTP_RESPONSE_HEADERS_VTABLE

Procedure wv2_HttpResponseHeaders_New()
	Protected.WV2_HTTP_RESPONSE_HEADERS *this
	
	*this = AllocateMemory(SizeOf(WV2_HTTP_RESPONSE_HEADERS))
	*this\vt = @WV2_HTTP_RESPONSE_HEADERS_VTABLE
	*this\refCount = 1
	
	*this\headersCol = wv2_HttpHeadersCollection_New()
		
	ProcedureReturn *this
EndProcedure

Procedure wv2_HttpResponseHeaders_Free(*this.WV2_HTTP_RESPONSE_HEADERS)
	If *this\headersCol
		wv2_HttpHeadersCollection_Release(*this\headersCol)
	EndIf 
	
	FreeMemory(*this)
EndProcedure

Procedure wv2_HttpResponseHeaders_QueryInterface(*this.WV2_HTTP_RESPONSE_HEADERS, *id.IID, *obj.INTEGER)	
	If CompareMemory(*id, ?IID_IUnknown, SizeOf(IID)) Or CompareMemory(*id, ?IID_ICoreWebView2HttpResponseHeaders, SizeOf(IID))
		*obj\i = *this
		*this\refCount = *this\refCount + 1
		ProcedureReturn #S_OK
		
	Else
		*obj\i = #Null
		ProcedureReturn #E_NOINTERFACE
	EndIf 
EndProcedure
	
Procedure wv2_HttpResponseHeaders_AddRef(*this.WV2_HTTP_RESPONSE_HEADERS)	
	*this\refCount = *this\refCount + 1
	
	ProcedureReturn *this\refCount
EndProcedure

Procedure wv2_HttpResponseHeaders_Release(*this.WV2_HTTP_RESPONSE_HEADERS)
	*this\refCount = *this\refCount - 1

	If *this\refCount = 0
		wv2_HttpResponseHeaders_Free(*this)
		ProcedureReturn 0
		
	Else
		ProcedureReturn *this\refCount
	EndIf 
EndProcedure

Procedure wv2_HttpResponseHeaders_AppendHeader(*this.WV2_HTTP_RESPONSE_HEADERS, name.s, value.s)	
	If name = "" : ProcedureReturn #E_INVALIDARG : EndIf
	
	AddElement(*this\headersCol\col())
	*this\headersCol\col()\name = name
	*this\headersCol\col()\value = value
	
	ProcedureReturn #S_OK
EndProcedure

Procedure wv2_HttpResponseHeaders_Contains(*this.WV2_HTTP_RESPONSE_HEADERS, name.s, *contains.LONG)	
	If *contains = #Null : ProcedureReturn #E_INVALIDARG : EndIf
	
	*contains\l = #False

	ForEach *this\headersCol\col()
		If *this\headersCol\col()\name = name
			*contains\l = #True
			Break
		EndIf
	Next 
	
	ProcedureReturn #S_OK
EndProcedure

Procedure	wv2_HttpResponseHeaders_getHeader(*this.WV2_HTTP_RESPONSE_HEADERS, name.s, *value.INTEGER)
	Protected.i buf
	
	If *value = #Null : ProcedureReturn #E_INVALIDARG : EndIf
	
	ForEach *this\headersCol\col()
		If *this\headersCol\col()\name = name
			buf = CoTaskMemAlloc_(StringByteLength(*this\headersCol\col()\value))
			If buf
				PokeS(buf, *this\headersCol\col()\value)
				*value\i = buf
				
			Else
				ProcedureReturn #E_OUTOFMEMORY
			EndIf 
			
			Break
		EndIf 
	Next 
	
	ProcedureReturn #S_OK
EndProcedure

Procedure	wv2_HttpResponseHeaders_getHeaders(*this.WV2_HTTP_RESPONSE_HEADERS, name.s, *pIterator.INTEGER)
	Protected.WV2_HTTP_HEADERS_COLLECTION_ITERATOR *it
		
	If *pIterator = #Null : ProcedureReturn #E_INVALIDARG : EndIf 

	*it = wv2_HttpHeadersCollectionIterator_New(wv2_HttpHeadersCollection_New())
	If *it = #Null : ProcedureReturn #E_FAIL : EndIf 
	
	ForEach *this\headersCol\col()
		If *this\headersCol\col()\name = name
			AddElement(*it\headersCol\col())
			*it\headersCol\col()\name = *this\headersCol\col()\name
			*it\headersCol\col()\value = *this\headersCol\col()\value
		EndIf 
	Next 
	
	*pIterator\i = *it
	
	ProcedureReturn #S_OK
EndProcedure

Procedure	wv2_HttpResponseHeaders_getIterator(*this.WV2_HTTP_RESPONSE_HEADERS, *iterator.INTEGER)
	Protected.ICoreWebView2HttpHeadersCollectionIterator it
	
	If *iterator = #Null : ProcedureReturn #E_INVALIDARG : EndIf 
	
	*iterator\i = #Null
	
	*iterator\i = wv2_HttpHeadersCollectionIterator_New(*this\headersCol)
	If *iterator\i = #Null : ProcedureReturn #E_FAIL : EndIf

	wv2_HttpHeadersCollection_AddRef(*this\headersCol)
	
	ProcedureReturn #S_OK
EndProcedure

;- VTABLE CONSTRUCTION
WV2_HTTP_RESPONSE_HEADERS_VTABLE\QueryInterface = @wv2_HttpResponseHeaders_QueryInterface()
WV2_HTTP_RESPONSE_HEADERS_VTABLE\AddRef = @wv2_HttpResponseHeaders_AddRef()
WV2_HTTP_RESPONSE_HEADERS_VTABLE\Release = @wv2_HttpResponseHeaders_Release()
WV2_HTTP_RESPONSE_HEADERS_VTABLE\AppendHeader = @wv2_HttpResponseHeaders_appendHeader()
WV2_HTTP_RESPONSE_HEADERS_VTABLE\Contains = @wv2_HttpResponseHeaders_contains()
WV2_HTTP_RESPONSE_HEADERS_VTABLE\GetHeader = @wv2_HttpResponseHeaders_getHeader()
WV2_HTTP_RESPONSE_HEADERS_VTABLE\GetHeaders = @wv2_HttpResponseHeaders_getHeaders()
WV2_HTTP_RESPONSE_HEADERS_VTABLE\GetIterator = @wv2_HttpResponseHeaders_getIterator()

;-
;- WV2_WEB_RESOURCE_RESPONSE
Structure WV2_WEB_RESOURCE_RESPONSE
	vt.i
	refCount.l
	mutex.i
	statusCode.l
	reasonPhrase.s
	content.IStream
	headers.ICoreWebView2HttpResponseHeaders
EndStructure

Global.ICoreWebView2WebResourceResponseVtbl WV2_WEB_RESOURCE_RESPONSE_VTABLE

Procedure wv2_WebResourceResponse_New()
	Protected.WV2_WEB_RESOURCE_RESPONSE *this
	
	*this = AllocateMemory(SizeOf(WV2_WEB_RESOURCE_RESPONSE))
	*this\vt = @WV2_WEB_RESOURCE_RESPONSE_VTABLE
	*this\refCount = 1
	*this\headers = wv2_HttpResponseHeaders_New()
	
	ProcedureReturn *this
EndProcedure

Procedure wv2_WebResourceResponse_New2(contStream.IStream, contType.s)
	Protected.ICoreWebView2WebResourceResponse resp
	Protected.ICoreWebView2HttpResponseHeaders respHdr
	Protected.STATSTG st
	
	;Get stream size
	contStream\Stat(@st, #STATFLAG_NONAME)

	resp =  wv2_WebResourceResponse_New()
	resp\put_StatusCode(200)
	resp\put_ReasonPhrase("OK")
	
	resp\get_Headers(@respHdr)
	respHdr\AppendHeader("Content-Length", Str(st\cbSize))
	respHdr\AppendHeader("Content-Type", contType)
	respHdr\Release()
	
	resp\put_Content(contStream)

	ProcedureReturn resp
EndProcedure

Procedure wv2_WebResourceResponse_Free(*this.WV2_WEB_RESOURCE_RESPONSE)
	If *this\headers
		*this\headers\Release()
	EndIf
	
	FreeMemory(*this)
EndProcedure

Procedure wv2_WebResourceResponse_QueryInterface(*this.WV2_WEB_RESOURCE_RESPONSE, *id.IID, *obj.INTEGER)	
	If CompareMemory(*id, ?IID_IUnknown, SizeOf(IID)) Or CompareMemory(*id, ?IID_ICoreWebView2WebResourceResponse, SizeOf(IID))
		*obj\i = *this
		*this\refCount = *this\refCount + 1
		ProcedureReturn #S_OK
		
	Else
		*obj\i = #Null
		ProcedureReturn #E_NOINTERFACE
	EndIf 
EndProcedure
	
Procedure wv2_WebResourceResponse_AddRef(*this.WV2_WEB_RESOURCE_RESPONSE)	
	*this\refCount = *this\refCount + 1
	
	ProcedureReturn *this\refCount
EndProcedure

Procedure wv2_WebResourceResponse_Release(*this.WV2_WEB_RESOURCE_RESPONSE)
	*this\refCount = *this\refCount - 1

	If *this\refCount = 0
		wv2_WebResourceResponse_Free(*this)
		ProcedureReturn 0
		
	Else
		ProcedureReturn *this\refCount
	EndIf 
EndProcedure

Procedure	wv2_WebResourceResponse_get_content(*this.WV2_WEB_RESOURCE_RESPONSE, *content.INTEGER)
	If *content
		*content\i = *this\content
		If *this\content
			*this\content\AddRef()
		EndIf
		
		ProcedureReturn #S_OK
		
	Else		
		ProcedureReturn #E_INVALIDARG
	EndIf 
EndProcedure

Procedure	wv2_WebResourceResponse_put_content(*this.WV2_WEB_RESOURCE_RESPONSE, content.i)
	*this\content = content
	
	ProcedureReturn #S_OK
EndProcedure

Procedure	wv2_WebResourceResponse_get_headers(*this.WV2_WEB_RESOURCE_RESPONSE, *headers.INTEGER)
	If *headers
		*headers\i = *this\headers
		*this\headers\AddRef()
		
		ProcedureReturn #S_OK
		
	Else
		ProcedureReturn #E_INVALIDARG
	EndIf
EndProcedure

Procedure	wv2_WebResourceResponse_get_statusCode(*this.WV2_WEB_RESOURCE_RESPONSE, *statusCode.LONG)
	If *statusCode
		*statusCode\l = *this\statusCode
		ProcedureReturn #S_OK
		
	Else
		ProcedureReturn #E_INVALIDARG
	EndIf
EndProcedure

Procedure	wv2_WebResourceResponse_put_statusCode(*this.WV2_WEB_RESOURCE_RESPONSE, statusCode.l)
	*this\statusCode = statusCode
	
	ProcedureReturn #S_OK
EndProcedure

Procedure	wv2_WebResourceResponse_get_reasonPhrase(*this.WV2_WEB_RESOURCE_RESPONSE, *reasonPhrase.INTEGER)
	Protected.i buf
	
	If *reasonPhrase = #Null : ProcedureReturn #E_INVALIDARG : EndIf 
	
	buf = CoTaskMemAlloc_(StringByteLength(*this\reasonPhrase))
	If buf
		PokeS(buf, *this\reasonPhrase)
		*reasonPhrase\i = buf
		ProcedureReturn #S_OK
		
	Else
		*reasonPhrase\i = #Null
		ProcedureReturn #E_OUTOFMEMORY
	EndIf 
EndProcedure

Procedure wv2_WebResourceResponse_put_reasonPhrase(*this.WV2_WEB_RESOURCE_RESPONSE, reasonPhrase.s)
	*this\reasonPhrase = reasonPhrase
	
	ProcedureReturn #S_OK
EndProcedure

;- VTABLE CONSTRUCTION
WV2_WEB_RESOURCE_RESPONSE_VTABLE\QueryInterface = @wv2_WebResourceResponse_QueryInterface()
WV2_WEB_RESOURCE_RESPONSE_VTABLE\AddRef = @wv2_WebResourceResponse_AddRef()
WV2_WEB_RESOURCE_RESPONSE_VTABLE\Release = @wv2_WebResourceResponse_Release()
WV2_WEB_RESOURCE_RESPONSE_VTABLE\get_Content = @wv2_WebResourceResponse_get_content()
WV2_WEB_RESOURCE_RESPONSE_VTABLE\put_Content = @wv2_WebResourceResponse_put_content()
WV2_WEB_RESOURCE_RESPONSE_VTABLE\get_Headers = @wv2_WebResourceResponse_get_headers()
WV2_WEB_RESOURCE_RESPONSE_VTABLE\get_StatusCode = @wv2_WebResourceResponse_get_statusCode()
WV2_WEB_RESOURCE_RESPONSE_VTABLE\put_StatusCode = @wv2_WebResourceResponse_put_statusCode()
WV2_WEB_RESOURCE_RESPONSE_VTABLE\get_ReasonPhrase = @wv2_WebResourceResponse_get_reasonPhrase()
WV2_WEB_RESOURCE_RESPONSE_VTABLE\put_ReasonPhrase = @wv2_WebResourceResponse_put_reasonPhrase()
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


