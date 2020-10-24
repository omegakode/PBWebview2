EnableExplicit

XIncludeFile "WinHttp.WinHttpRequest.5.1.pbi"

#FAVICON_SCRIPT_GET_ICON = "" +
"(function () {" +
"var links;" +
"links = document.head.getElementsByTagName('LINK');" +
"for (let el of links) {" +
	"if (el.getAttribute('rel') == 'icon' || el.getAttribute('rel') == 'shortcut icon') {" +
    	"return el.getAttribute('href');" +
    "}" +
"}" +
"})();"

;- Enum FAVICON_DOWNLOAD_TYPE
Enumeration
	#FAVICON_DOWNLOAD_TYPE_ROOT
	#FAVICON_DOWNLOAD_TYPE_HEAD
EndEnumeration

;- FAVICON_ITEM
Structure FAVICON_ITEM
	host.s
	pic.IPicture
	refCount.l
EndStructure

;- FAVICON
Structure FAVICON
	List icons.FAVICON_ITEM()
	refCount.l
EndStructure

;- FAVICON_HTTP_EVENT
Structure FAVICON_HTTP_EVENT
	vt.i
	refCount.l
	mutex.i
	req.IWinHttpRequest
	host.s
	*favIcon.FAVICON
EndStructure

;- FAVICON_HTTP_EVENT_VTABLE_TAG
Structure FAVICON_HTTP_EVENT_VTABLE_TAG Extends IUnknownVtbl
	OnResponseStart.i
	OnResponseDataAvailable.i
	OnResponseFinished.i
	OnError.i
EndStructure
Global.FAVICON_HTTP_EVENT_VTABLE_TAG FAVICON_HTTP_EVENT_VTABLE

;- DECLARES
Declare favIcon_ItemExists(*this.FAVICON, host.s)
Declare favIcon_AddItem(*this.FAVICON, host.s, hicon.i)

Procedure favIcon_Http_Event_New(*favIcon.FAVICON, req.IWinHttpRequest, host.s)
	Protected.FAVICON_HTTP_EVENT *this
	
	*this = AllocateMemory(SizeOf(FAVICON_HTTP_EVENT))
	*this\vt = @FAVICON_HTTP_EVENT_VTABLE
	*this\favIcon = *favIcon
	*this\req = req
	*this\host = host
	*this\mutex = CreateMutex()
	*this\refCount = 1
	
	ProcedureReturn *this
EndProcedure

Procedure favIcon_Http_Event_Free(*this.FAVICON_HTTP_EVENT)
	FreeMutex(*this\mutex)
	FreeMemory(*this)
EndProcedure

Procedure favIcon_Http_Event_QueryInterface(*this.FAVICON_HTTP_EVENT, *iid.IID, *obj.INTEGER)
	If CompareMemory(*iid, ?IID_IUnknown, SizeOf(IID)) Or CompareMemory(*iid, ?IID_IWinHttpRequestEvents, SizeOf(IID))
		*this\refCount = *this\refCount + 1
		*obj\i = *this
		ProcedureReturn #S_OK
		
	Else
		*obj\i = #Null
		ProcedureReturn #E_NOINTERFACE
	EndIf 
EndProcedure

Procedure favIcon_Http_Event_AddRef(*this.FAVICON_HTTP_EVENT)
	*this\refCount = *this\refCount + 1
	
	ProcedureReturn *this\refCount
EndProcedure

Procedure favIcon_Http_Event_Release(*this.FAVICON_HTTP_EVENT)
	*this\refCount = *this\refCount - 1
	If *this\refCount = 0
		favIcon_Http_Event_Free(*this)
	EndIf 
EndProcedure

Procedure favIcon_Http_Event_OnResponseStart(*this.FAVICON_HTTP_EVENT, status.l, contentType.i)

EndProcedure

Procedure favIcon_Http_Event_OnResponseDataAvailable(*this.FAVICON_HTTP_EVENT, dat.i)

EndProcedure

Procedure favIcon_Http_Event_OnResponseFinished(*this.FAVICON_HTTP_EVENT)
	Protected.VARIANT respUnk
	Protected.IWinHttpRequest req
	Protected.IStream respStm
	Protected.i hIcon, uri, img
	Protected.l status, tabCount, iTab
	Protected.BROWSER *browser
	Protected.s suri
	
	LockMutex(*this\mutex)
	
	req = *this\req
	req\get_Status(@status)
	If req\get_ResponseStream(@respUnk) = #S_OK 
		If respUnk\punkVal\QueryInterface(?IID_IStream, @respStm) = #S_OK
			If GdipLoadImageFromStream(respStm, @img) = #S_OK
				If favIcon_ItemExists(*this\favIcon, *this\host) = #False
					favIcon_AddItem(*this\favIcon, *this\host, img)

					;Find tab
					tabCount = tabCtrl_GetItemCount(app\tab)
					For iTab = 0 To tabCount - 1
						*browser = tabCtrl_GetItemUserData(app\tab, iTab)
						If *browser
							*browser\core\get_Source(@uri)
							If uri
								suri = PeekS(uri)
								str_FreeCoMemString(uri)
								If GetURLPart(suri, #PB_URL_Site) = *this\host
									tabCtrl_SetItemIcon(app\tab, iTab, img)
								EndIf 
							EndIf 
						EndIf 
					Next 
					
				Else
; 						DeleteObject_(hIcon)
				EndIf 
			EndIf 
			
			respStm\Release()
		EndIf 
	EndIf 
	
	req\Release()
	favIcon_Http_Event_Release(*this)
	
	UnlockMutex(*this\mutex)
EndProcedure

Procedure favIcon_Http_Event_OnError(*this.FAVICON_HTTP_EVENT, ErrorNumber.l, ErrorDescription.i)

EndProcedure

Procedure favIcon_New()
	Protected.FAVICON *this

	*this = AllocateStructure(FAVICON)
	*this\refCount = 1
	
	ProcedureReturn *this
EndProcedure

Procedure favIcon_Free(*this.FAVICON)	
	FreeStructure(*this)
EndProcedure

Procedure favIcon_ScriptExecuted(*ev.WV2_EVENT_HANDLER, errCode.l, res.i)
	Protected.BROWSER *browser
	Protected.i uri
	Protected.s suri
	
	LockMutex(*ev\mutex)
	*browser = *ev\context
	
	*browser\core\get_Source(@uri)
	If uri
		str_FreeCoMemString(uri)
	EndIf
	
	UnlockMutex(*ev\mutex)
EndProcedure

Procedure favIcon_ItemExists(*this.FAVICON, host.s)
	ForEach *this\icons()
		If *this\icons()\host = host
			ProcedureReturn #True
		EndIf
	Next
	
	ProcedureReturn #False
EndProcedure

Procedure favIcon_Download(*this.FAVICON, url.s, callBack.i, ctx.i)
	Protected.VARIANT async, body
	Protected.IWinHttpRequest req
	Protected.l evCookie
	Protected.IConnectionPointContainer cpc
	Protected.IConnectionPoint  cp
	Protected.b success
	Protected.FAVICON_HTTP_EVENT *winHttpEv

	If url = "" : ProcedureReturn : EndIf 
	
	success = #False 
	If CoCreateInstance_(?CLSID_WinHttpRequest, #Null, #CLSCTX_INPROC_SERVER, ?IID_IWinHttpRequest, @req) = #S_OK
		If req\QueryInterface(?IID_IConnectionPointContainer, @cpc) = #S_OK
			If cpc\FindConnectionPoint(?IID_IWinHttpRequestEvents, @cp) = #S_OK
				*winHttpEv = favIcon_Http_Event_New(*this, req, GetURLPart(url, #PB_URL_Site))
				If cp\Advise(*winHttpEv, @evCookie) = #S_OK
					async\vt = #VT_BOOL
					async\boolVal = #VARIANT_TRUE
					If req\Open("GET", url, async) = #S_OK
						body\vt = #VT_EMPTY
						If req\Send(body) = #S_OK
							success = #True
						EndIf 
					EndIf 
				
					cp\Release()
				EndIf 
			EndIf 
			cpc\Release()
		EndIf 
	EndIf 
	
	If success = #False
		If *winHttpEv : favIcon_Http_Event_Release(*winHttpEv) : EndIf
		If req : req\Release() : EndIf
	EndIf 
EndProcedure

Procedure favIcon_Item_Release(*this.FAVICON, *item.FAVICON_ITEM)
	*item\refCount = *item\refCount - 1
	If *item\refCount = 0
		ChangeCurrentElement(*this\icons(), *item)
		DeleteElement(*this\icons())
	EndIf 
EndProcedure

Procedure favIcon_Item_AddRef(*this.FAVICON, *item.FAVICON_ITEM)
	*item\refCount = *item\refCount + 1
EndProcedure

Procedure favIcon_AddItem(*this.FAVICON, host.s, pic.IPicture)
	AddElement(*this\icons())
	*this\icons()\host = host
	*this\icons()\pic = pic
	*this\icons()\refCount = *this\icons()\refCount + 1
EndProcedure

;- FAVICON_HTTP_EVENT_VTABLE Construction
FAVICON_HTTP_EVENT_VTABLE\QueryInterface = @favIcon_Http_Event_QueryInterface()
FAVICON_HTTP_EVENT_VTABLE\AddRef = @favIcon_Http_Event_AddRef()
FAVICON_HTTP_EVENT_VTABLE\Release = @favIcon_Http_Event_Release()
FAVICON_HTTP_EVENT_VTABLE\OnResponseStart = @favIcon_Http_Event_OnResponseStart()
FAVICON_HTTP_EVENT_VTABLE\OnResponseDataAvailable = @favIcon_Http_Event_OnResponseDataAvailable()
FAVICON_HTTP_EVENT_VTABLE\OnResponseFinished = @favIcon_Http_Event_OnResponseFinished()
FAVICON_HTTP_EVENT_VTABLE\OnError = @favIcon_Http_Event_OnError()

;- DATA
DataSection
	IID_IConnectionPointContainer:
	Data.l $B196B284
	Data.w $BAB4, $101A
	Data.b $B6, $9C, $00, $AA, $00, $34, $1D, $07
	
	IID_IStream:
	Data.l $0000000c
	Data.w $0000, $0000
	Data.b $C0, $00, $00, $00, $00, $00, $00, $46
EndDataSection


