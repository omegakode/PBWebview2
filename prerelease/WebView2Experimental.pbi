;Generated by PB Type Library Importer Version: 1.0
;1.0.2194-prerelease

;- ICoreWebView2Experimental16

DataSection
	IID_ICoreWebView2Experimental16:
	Data.l $679DDF3F
	Data.w $9044, $486F
	Data.b $84, $58, $16, $65, $3A, $E, $16, $3
EndDataSection

Interface ICoreWebView2Experimental16 Extends IUnknown
	AddWebResourceRequestedFilterWithRequestSourceKinds(uri.s, resourceContext.l, requestSourceKinds.l)
	RemoveWebResourceRequestedFilterWithRequestSourceKinds(uri.s, resourceContext.l, requestSourceKinds.l)
EndInterface 

;- Enum COREWEBVIEW2_WEB_RESOURCE_CONTEXT
#COREWEBVIEW2_WEB_RESOURCE_CONTEXT_ALL = 0
#COREWEBVIEW2_WEB_RESOURCE_CONTEXT_DOCUMENT = 1
#COREWEBVIEW2_WEB_RESOURCE_CONTEXT_STYLESHEET = 2
#COREWEBVIEW2_WEB_RESOURCE_CONTEXT_IMAGE = 3
#COREWEBVIEW2_WEB_RESOURCE_CONTEXT_MEDIA = 4
#COREWEBVIEW2_WEB_RESOURCE_CONTEXT_FONT = 5
#COREWEBVIEW2_WEB_RESOURCE_CONTEXT_SCRIPT = 6
#COREWEBVIEW2_WEB_RESOURCE_CONTEXT_XML_HTTP_REQUEST = 7
#COREWEBVIEW2_WEB_RESOURCE_CONTEXT_FETCH = 8
#COREWEBVIEW2_WEB_RESOURCE_CONTEXT_TEXT_TRACK = 9
#COREWEBVIEW2_WEB_RESOURCE_CONTEXT_EVENT_SOURCE = 10
#COREWEBVIEW2_WEB_RESOURCE_CONTEXT_WEBSOCKET = 11
#COREWEBVIEW2_WEB_RESOURCE_CONTEXT_MANIFEST = 12
#COREWEBVIEW2_WEB_RESOURCE_CONTEXT_SIGNED_EXCHANGE = 13
#COREWEBVIEW2_WEB_RESOURCE_CONTEXT_PING = 14
#COREWEBVIEW2_WEB_RESOURCE_CONTEXT_CSP_VIOLATION_REPORT = 15
#COREWEBVIEW2_WEB_RESOURCE_CONTEXT_OTHER = 16

;- Enum COREWEBVIEW2_WEB_RESOURCE_REQUEST_SOURCE_KINDS
#COREWEBVIEW2_WEB_RESOURCE_REQUEST_SOURCE_KINDS_NONE = 0
#COREWEBVIEW2_WEB_RESOURCE_REQUEST_SOURCE_KINDS_DOCUMENT = 1
#COREWEBVIEW2_WEB_RESOURCE_REQUEST_SOURCE_KINDS_SHARED_WORKER = 2
#COREWEBVIEW2_WEB_RESOURCE_REQUEST_SOURCE_KINDS_SERVICE_WORKER = 4
#COREWEBVIEW2_WEB_RESOURCE_REQUEST_SOURCE_KINDS_ALL = -1

;- ICoreWebView2Experimental19

DataSection
	IID_ICoreWebView2Experimental19:
	Data.l $4C765E35
	Data.w $5BEB, $4631
	Data.b $B9, $31, $5E, $52, $D9, $B0, $A9, $BE
EndDataSection

Interface ICoreWebView2Experimental19 Extends IUnknown
	ExecuteScriptWithResult(javaScript.s, handler.i)
EndInterface 

;- ICoreWebView2ExperimentalExecuteScriptWithResultCompletedHandler

DataSection
	IID_ICoreWebView2ExperimentalExecuteScriptWithResultCompletedHandler:
	Data.l $1BB5317B
	Data.w $8238, $4C67
	Data.b $A7, $FF, $BA, $F6, $55, $8F, $28, $9D
EndDataSection

Interface ICoreWebView2ExperimentalExecuteScriptWithResultCompletedHandler Extends IUnknown
	Invoke(errorCode.l, result.i)
EndInterface 

;- ICoreWebView2ExperimentalExecuteScriptResult

DataSection
	IID_ICoreWebView2ExperimentalExecuteScriptResult:
	Data.l $CE15963
	Data.w $3698, $4DF7
	Data.b $93, $99, $71, $ED, $6C, $DD, $8C, $9F
EndDataSection

Interface ICoreWebView2ExperimentalExecuteScriptResult Extends IUnknown
	get_Succeeded(value.i)
	get_ResultAsJson(jsonResult.i)
	TryGetResultAsString(stringResult.i, value.i)
	get_Exception(Exception.i)
EndInterface 

;- ICoreWebView2ExperimentalScriptException

DataSection
	IID_ICoreWebView2ExperimentalScriptException:
	Data.l $54DAE00
	Data.w $84A3, $49FF
	Data.b $BC, $17, $40, $12, $A9, $B, $C9, $FD
EndDataSection

Interface ICoreWebView2ExperimentalScriptException Extends IUnknown
	get_LineNumber(value.i)
	get_ColumnNumber(value.i)
	get_Name(value.i)
	get_Message(value.i)
	get_ToJson(value.i)
EndInterface 

;- ICoreWebView2Experimental20

DataSection
	IID_ICoreWebView2Experimental20:
	Data.l $5A4D0ECF
	Data.w $3FE5, $4456
	Data.b $AC, $E5, $D3, $17, $CC, $A0, $EF, $F1
EndDataSection

Interface ICoreWebView2Experimental20 Extends IUnknown
	get_CustomDataPartitionId(CustomDataPartitionId.i)
	put_CustomDataPartitionId(CustomDataPartitionId.s)
EndInterface 

;- ICoreWebView2Experimental22

DataSection
	IID_ICoreWebView2Experimental22:
	Data.l $6C2FC9EE
	Data.w $83F1, $4F0B
	Data.b $80, $E3, $D8, $2A, $B9, $77, $E6, $98
EndDataSection

Interface ICoreWebView2Experimental22 Extends IUnknown
	add_NotificationReceived(eventHandler.i, token.i)
	remove_NotificationReceived(token.q)
EndInterface 

;- ICoreWebView2ExperimentalNotificationReceivedEventHandler

DataSection
	IID_ICoreWebView2ExperimentalNotificationReceivedEventHandler:
	Data.l $89C5D598
	Data.w $8788, $423B
	Data.b $BE, $97, $E6, $E0, $1C, $F, $9E, $E3
EndDataSection

Interface ICoreWebView2ExperimentalNotificationReceivedEventHandler Extends IUnknown
	Invoke(sender.i, args.i)
EndInterface 

;- Enum COREWEBVIEW2_WEB_ERROR_STATUS
#COREWEBVIEW2_WEB_ERROR_STATUS_UNKNOWN = 0
#COREWEBVIEW2_WEB_ERROR_STATUS_CERTIFICATE_COMMON_NAME_IS_INCORRECT = 1
#COREWEBVIEW2_WEB_ERROR_STATUS_CERTIFICATE_EXPIRED = 2
#COREWEBVIEW2_WEB_ERROR_STATUS_CLIENT_CERTIFICATE_CONTAINS_ERRORS = 3
#COREWEBVIEW2_WEB_ERROR_STATUS_CERTIFICATE_REVOKED = 4
#COREWEBVIEW2_WEB_ERROR_STATUS_CERTIFICATE_IS_INVALID = 5
#COREWEBVIEW2_WEB_ERROR_STATUS_SERVER_UNREACHABLE = 6
#COREWEBVIEW2_WEB_ERROR_STATUS_TIMEOUT = 7
#COREWEBVIEW2_WEB_ERROR_STATUS_ERROR_HTTP_INVALID_SERVER_RESPONSE = 8
#COREWEBVIEW2_WEB_ERROR_STATUS_CONNECTION_ABORTED = 9
#COREWEBVIEW2_WEB_ERROR_STATUS_CONNECTION_RESET = 10
#COREWEBVIEW2_WEB_ERROR_STATUS_DISCONNECTED = 11
#COREWEBVIEW2_WEB_ERROR_STATUS_CANNOT_CONNECT = 12
#COREWEBVIEW2_WEB_ERROR_STATUS_HOST_NAME_NOT_RESOLVED = 13
#COREWEBVIEW2_WEB_ERROR_STATUS_OPERATION_CANCELED = 14
#COREWEBVIEW2_WEB_ERROR_STATUS_REDIRECT_FAILED = 15
#COREWEBVIEW2_WEB_ERROR_STATUS_UNEXPECTED_ERROR = 16
#COREWEBVIEW2_WEB_ERROR_STATUS_VALID_AUTHENTICATION_CREDENTIALS_REQUIRED = 17
#COREWEBVIEW2_WEB_ERROR_STATUS_VALID_PROXY_AUTHENTICATION_REQUIRED = 18

;- Enum COREWEBVIEW2_SCRIPT_DIALOG_KIND
#COREWEBVIEW2_SCRIPT_DIALOG_KIND_ALERT = 0
#COREWEBVIEW2_SCRIPT_DIALOG_KIND_CONFIRM = 1
#COREWEBVIEW2_SCRIPT_DIALOG_KIND_PROMPT = 2
#COREWEBVIEW2_SCRIPT_DIALOG_KIND_BEFOREUNLOAD = 3

;- Enum COREWEBVIEW2_PERMISSION_KIND
#COREWEBVIEW2_PERMISSION_KIND_UNKNOWN_PERMISSION = 0
#COREWEBVIEW2_PERMISSION_KIND_MICROPHONE = 1
#COREWEBVIEW2_PERMISSION_KIND_CAMERA = 2
#COREWEBVIEW2_PERMISSION_KIND_GEOLOCATION = 3
#COREWEBVIEW2_PERMISSION_KIND_NOTIFICATIONS = 4
#COREWEBVIEW2_PERMISSION_KIND_OTHER_SENSORS = 5
#COREWEBVIEW2_PERMISSION_KIND_CLIPBOARD_READ = 6
#COREWEBVIEW2_PERMISSION_KIND_MULTIPLE_AUTOMATIC_DOWNLOADS = 7
#COREWEBVIEW2_PERMISSION_KIND_FILE_READ_WRITE = 8
#COREWEBVIEW2_PERMISSION_KIND_AUTOPLAY = 9
#COREWEBVIEW2_PERMISSION_KIND_LOCAL_FONTS = 10
#COREWEBVIEW2_PERMISSION_KIND_MIDI_SYSTEM_EXCLUSIVE_MESSAGES = 11
#COREWEBVIEW2_PERMISSION_KIND_WINDOW_MANAGEMENT = 12

;- Enum COREWEBVIEW2_PERMISSION_STATE
#COREWEBVIEW2_PERMISSION_STATE_DEFAULT = 0
#COREWEBVIEW2_PERMISSION_STATE_ALLOW = 1
#COREWEBVIEW2_PERMISSION_STATE_DENY = 2

;- Enum COREWEBVIEW2_PROCESS_FAILED_KIND
#COREWEBVIEW2_PROCESS_FAILED_KIND_BROWSER_PROCESS_EXITED = 0
#COREWEBVIEW2_PROCESS_FAILED_KIND_RENDER_PROCESS_EXITED = 1
#COREWEBVIEW2_PROCESS_FAILED_KIND_RENDER_PROCESS_UNRESPONSIVE = 2
#COREWEBVIEW2_PROCESS_FAILED_KIND_FRAME_RENDER_PROCESS_EXITED = 3
#COREWEBVIEW2_PROCESS_FAILED_KIND_UTILITY_PROCESS_EXITED = 4
#COREWEBVIEW2_PROCESS_FAILED_KIND_SANDBOX_HELPER_PROCESS_EXITED = 5
#COREWEBVIEW2_PROCESS_FAILED_KIND_GPU_PROCESS_EXITED = 6
#COREWEBVIEW2_PROCESS_FAILED_KIND_PPAPI_PLUGIN_PROCESS_EXITED = 7
#COREWEBVIEW2_PROCESS_FAILED_KIND_PPAPI_BROKER_PROCESS_EXITED = 8
#COREWEBVIEW2_PROCESS_FAILED_KIND_UNKNOWN_PROCESS_EXITED = 9

;- Enum COREWEBVIEW2_CAPTURE_PREVIEW_IMAGE_FORMAT
#COREWEBVIEW2_CAPTURE_PREVIEW_IMAGE_FORMAT_PNG = 0
#COREWEBVIEW2_CAPTURE_PREVIEW_IMAGE_FORMAT_JPEG = 1

;- ICoreWebView2ExperimentalNotificationReceivedEventArgs

DataSection
	IID_ICoreWebView2ExperimentalNotificationReceivedEventArgs:
	Data.l $1512DD5B
	Data.w $5514, $4F85
	Data.b $88, $6E, $21, $C3, $A4, $C9, $CF, $E6
EndDataSection

Interface ICoreWebView2ExperimentalNotificationReceivedEventArgs Extends IUnknown
	get_SenderOrigin(value.i)
	get_Notification(value.i)
	put_Handled(value.l)
	get_Handled(value.i)
	GetDeferral(deferral.i)
EndInterface 

;- ICoreWebView2ExperimentalNotification

DataSection
	IID_ICoreWebView2ExperimentalNotification:
	Data.l $B7434D98
	Data.w $6BC8, $419D
	Data.b $9D, $A5, $FB, $5A, $96, $D4, $DA, $CD
EndDataSection

Interface ICoreWebView2ExperimentalNotification Extends IUnknown
	add_CloseRequested(eventHandler.i, token.i)
	remove_CloseRequested(token.q)
	ReportShown()
	ReportClicked()
	ReportClosed()
	get_Body(value.i)
	get_Direction(value.i)
	get_Language(value.i)
	get_Tag(value.i)
	get_IconUri(value.i)
	get_title(value.i)
	get_BadgeUri(value.i)
	get_BodyImageUri(value.i)
	get_ShouldRenotify(value.i)
	get_RequiresInteraction(value.i)
	get_IsSilent(value.i)
	get_Timestamp(value.i)
	GetVibrationPattern(count.i, vibrationPattern.i)
EndInterface 

;- ICoreWebView2ExperimentalNotificationCloseRequestedEventHandler

DataSection
	IID_ICoreWebView2ExperimentalNotificationCloseRequestedEventHandler:
	Data.l $47C32D23
	Data.w $1E94, $4733
	Data.b $85, $F1, $D9, $BF, $4A, $CD, $9, $74
EndDataSection

Interface ICoreWebView2ExperimentalNotificationCloseRequestedEventHandler Extends IUnknown
	Invoke(sender.i, args.i)
EndInterface 

;- Enum COREWEBVIEW2_TEXT_DIRECTION_KIND
#COREWEBVIEW2_TEXT_DIRECTION_KIND_DEFAULT = 0
#COREWEBVIEW2_TEXT_DIRECTION_KIND_LEFT_TO_RIGHT = 1
#COREWEBVIEW2_TEXT_DIRECTION_KIND_RIGHT_TO_LEFT = 2

;- ICoreWebView2Experimental23

DataSection
	IID_ICoreWebView2Experimental23:
	Data.l $D69032E2
	Data.w $1F6A, $11EE
	Data.b $BE, $56, $2, $42, $AC, $12, $0, $2
EndDataSection

Interface ICoreWebView2Experimental23 Extends IUnknown
	get_FrameId(id.i)
EndInterface 

;- ICoreWebView2ExperimentalCompositionController4

DataSection
	IID_ICoreWebView2ExperimentalCompositionController4:
	Data.l $E6041D7F
	Data.w $18AC, $4654
	Data.b $A0, $4E, $8B, $3F, $81, $25, $1C, $33
EndDataSection

Interface ICoreWebView2ExperimentalCompositionController4 Extends IUnknown
	get_AutomationProvider(provider.i)
	CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
		CreateCoreWebView2PointerInfoFromPointerId(PointerId.l, parentWindow.i, transform.i, pointerInfo.i)
	CompilerElse
		CreateCoreWebView2PointerInfoFromPointerId(PointerId.l, parentWindow.i, transform_COREWEBVIEW2_MATRIX_4X4__11.f, transform_COREWEBVIEW2_MATRIX_4X4__12.f, transform_COREWEBVIEW2_MATRIX_4X4__13.f, transform_COREWEBVIEW2_MATRIX_4X4__14.f, transform_COREWEBVIEW2_MATRIX_4X4__21.f, transform_COREWEBVIEW2_MATRIX_4X4__22.f, transform_COREWEBVIEW2_MATRIX_4X4__23.f, transform_COREWEBVIEW2_MATRIX_4X4__24.f, transform_COREWEBVIEW2_MATRIX_4X4__31.f, transform_COREWEBVIEW2_MATRIX_4X4__32.f, transform_COREWEBVIEW2_MATRIX_4X4__33.f, transform_COREWEBVIEW2_MATRIX_4X4__34.f, transform_COREWEBVIEW2_MATRIX_4X4__41.f, transform_COREWEBVIEW2_MATRIX_4X4__42.f, transform_COREWEBVIEW2_MATRIX_4X4__43.f, transform_COREWEBVIEW2_MATRIX_4X4__44.f, pointerInfo.i)
	CompilerEndIf
EndInterface 

;- ICoreWebView2ExperimentalClearCustomDataPartitionCompletedHandler

DataSection
	IID_ICoreWebView2ExperimentalClearCustomDataPartitionCompletedHandler:
	Data.l $FE753727
	Data.w $5758, $4FEA
	Data.b $8C, $AD, $1E, $68, $5B, $9C, $3A, $E8
EndDataSection

Interface ICoreWebView2ExperimentalClearCustomDataPartitionCompletedHandler Extends IUnknown
	Invoke(errorCode.l)
EndInterface 

;- ICoreWebView2ExperimentalEnvironment3

DataSection
	IID_ICoreWebView2ExperimentalEnvironment3:
	Data.l $9A2BE885
	Data.w $7F0B, $4B26
	Data.b $B6, $DD, $C9, $69, $BA, $A0, $B, $F1
EndDataSection

Interface ICoreWebView2ExperimentalEnvironment3 Extends IUnknown
	UpdateRuntime(handler.i)
EndInterface 

;- ICoreWebView2ExperimentalUpdateRuntimeCompletedHandler

DataSection
	IID_ICoreWebView2ExperimentalUpdateRuntimeCompletedHandler:
	Data.l $F1D2D722
	Data.w $3721, $499C
	Data.b $87, $F5, $4C, $40, $52, $60, $69, $7A
EndDataSection

Interface ICoreWebView2ExperimentalUpdateRuntimeCompletedHandler Extends IUnknown
	Invoke(errorCode.l, result.i)
EndInterface 

;- ICoreWebView2ExperimentalUpdateRuntimeResult

DataSection
	IID_ICoreWebView2ExperimentalUpdateRuntimeResult:
	Data.l $DD503E49
	Data.w $AB19, $47C0
	Data.b $B2, $AD, $6D, $DD, $9, $CC, $3E, $3A
EndDataSection

Interface ICoreWebView2ExperimentalUpdateRuntimeResult Extends IUnknown
	get_Status(Status.i)
	get_ExtendedError(error.i)
EndInterface 

;- Enum COREWEBVIEW2_UPDATE_RUNTIME_STATUS
#COREWEBVIEW2_UPDATE_RUNTIME_STATUS_LATEST_VERSION_INSTALLED = 0
#COREWEBVIEW2_UPDATE_RUNTIME_STATUS_UPDATE_ALREADY_RUNNING = 1
#COREWEBVIEW2_UPDATE_RUNTIME_STATUS_BLOCKED_BY_POLICY = 2
#COREWEBVIEW2_UPDATE_RUNTIME_STATUS_FAILED = 3

;- ICoreWebView2ExperimentalEnvironment13

DataSection
	IID_ICoreWebView2ExperimentalEnvironment13:
	Data.l $F1416A0
	Data.w $3BC3, $11EE
	Data.b $BE, $56, $2, $42, $AC, $12, $0, $2
EndDataSection

Interface ICoreWebView2ExperimentalEnvironment13 Extends IUnknown
	GetProcessExtendedInfos(handler.i)
EndInterface 

;- ICoreWebView2ExperimentalGetProcessExtendedInfosCompletedHandler

DataSection
	IID_ICoreWebView2ExperimentalGetProcessExtendedInfosCompletedHandler:
	Data.l $F45E55AA
	Data.w $3BC2, $11EE
	Data.b $BE, $56, $2, $42, $AC, $12, $0, $2
EndDataSection

Interface ICoreWebView2ExperimentalGetProcessExtendedInfosCompletedHandler Extends IUnknown
	Invoke(errorCode.l, value.i)
EndInterface 

;- ICoreWebView2ExperimentalProcessExtendedInfoCollection

DataSection
	IID_ICoreWebView2ExperimentalProcessExtendedInfoCollection:
	Data.l $32EFA696
	Data.w $407A, $11EE
	Data.b $BE, $56, $2, $42, $AC, $12, $0, $2
EndDataSection

Interface ICoreWebView2ExperimentalProcessExtendedInfoCollection Extends IUnknown
	get_count(count.i)
	GetValueAtIndex(index.l, ProcessInfo.i)
EndInterface 

;- ICoreWebView2ExperimentalProcessExtendedInfo

DataSection
	IID_ICoreWebView2ExperimentalProcessExtendedInfo:
	Data.l $AF4C4C2E
	Data.w $45DB, $11EE
	Data.b $BE, $56, $2, $42, $AC, $12, $0, $2
EndDataSection

Interface ICoreWebView2ExperimentalProcessExtendedInfo Extends IUnknown
	get_ProcessInfo(ProcessInfo.i)
	get_AssociatedFrameInfos(frames.i)
EndInterface 

;- Enum COREWEBVIEW2_PROCESS_KIND
#COREWEBVIEW2_PROCESS_KIND_BROWSER = 0
#COREWEBVIEW2_PROCESS_KIND_RENDERER = 1
#COREWEBVIEW2_PROCESS_KIND_UTILITY = 2
#COREWEBVIEW2_PROCESS_KIND_SANDBOX_HELPER = 3
#COREWEBVIEW2_PROCESS_KIND_GPU = 4
#COREWEBVIEW2_PROCESS_KIND_PPAPI_PLUGIN = 5
#COREWEBVIEW2_PROCESS_KIND_PPAPI_BROKER = 6

;- ICoreWebView2ExperimentalFrame5

DataSection
	IID_ICoreWebView2ExperimentalFrame5:
	Data.l $CFE70560
	Data.w $1F6A, $11EE
	Data.b $BE, $56, $2, $42, $AC, $12, $0, $2
EndDataSection

Interface ICoreWebView2ExperimentalFrame5 Extends IUnknown
	get_FrameId(id.i)
EndInterface 

;- ICoreWebView2ExperimentalFrameInfo

DataSection
	IID_ICoreWebView2ExperimentalFrameInfo:
	Data.l $C76EC710
	Data.w $1F6A, $11EE
	Data.b $BE, $56, $2, $42, $AC, $12, $0, $2
EndDataSection

Interface ICoreWebView2ExperimentalFrameInfo Extends IUnknown
	get_ParentFrameInfo(frameInfo.i)
	get_FrameId(id.i)
	get_FrameKind(Kind.i)
EndInterface 

;- Enum COREWEBVIEW2_FRAME_KIND
#COREWEBVIEW2_FRAME_KIND_UNKNOWN = 0
#COREWEBVIEW2_FRAME_KIND_MAIN_FRAME = 1
#COREWEBVIEW2_FRAME_KIND_IFRAME = 2
#COREWEBVIEW2_FRAME_KIND_EMBED = 3
#COREWEBVIEW2_FRAME_KIND_OBJECT = 4

;- ICoreWebView2ExperimentalProfile7

DataSection
	IID_ICoreWebView2ExperimentalProfile7:
	Data.l $11A14762
	Data.w $7780, $46A1
	Data.b $A1, $C3, $73, $DE, $81, $2D, $AE, $12
EndDataSection

Interface ICoreWebView2ExperimentalProfile7 Extends IUnknown
	ClearCustomDataPartition(CustomDataPartitionId.s, handler.i)
EndInterface 

;- ICoreWebView2ExperimentalWebResourceRequestedEventArgs

DataSection
	IID_ICoreWebView2ExperimentalWebResourceRequestedEventArgs:
	Data.l $8F3EC528
	Data.w $596, $4D51
	Data.b $9F, $9E, $2D, $A5, $80, $AC, $97, $87
EndDataSection

Interface ICoreWebView2ExperimentalWebResourceRequestedEventArgs Extends IUnknown
	get_RequestedSourceKind(RequestedSourceKind.i)
EndInterface 

;- ICoreWebView2ExperimentalRenderAdapterLUIDChangedEventHandler

DataSection
	IID_ICoreWebView2ExperimentalRenderAdapterLUIDChangedEventHandler:
	Data.l $431721E0
	Data.w $F18, $4D7B
	Data.b $BD, $4D, $E5, $B1, $52, $2B, $B1, $10
EndDataSection

Interface ICoreWebView2ExperimentalRenderAdapterLUIDChangedEventHandler Extends IUnknown
	Invoke(sender.i, args.i)
EndInterface 

;- ICoreWebView2ExperimentalEnvironment12

DataSection
	IID_ICoreWebView2ExperimentalEnvironment12:
	Data.l $96C27A45
	Data.w $F142, $4873
	Data.b $80, $AD, $9D, $C, $D8, $99, $B2, $B9
EndDataSection

Interface ICoreWebView2ExperimentalEnvironment12 Extends IUnknown
	CreateTextureStream(streamId.s, d3dDevice.i, value.i)
	get_RenderAdapterLUID(value.i)
	add_RenderAdapterLUIDChanged(eventHandler.i, token.i)
	remove_RenderAdapterLUIDChanged(token.q)
EndInterface 

;- ICoreWebView2ExperimentalTextureStream

DataSection
	IID_ICoreWebView2ExperimentalTextureStream:
	Data.l $AFCA8431
	Data.w $633F, $4528
	Data.b $AB, $FE, $7F, $C3, $BE, $DD, $89, $62
EndDataSection

Interface ICoreWebView2ExperimentalTextureStream Extends IUnknown
	get_id(value.i)
	AddAllowedOrigin(origin.s, value.l)
	RemoveAllowedOrigin(origin.s)
	add_StartRequested(eventHandler.i, token.i)
	remove_StartRequested(token.q)
	add_Stopped(eventHandler.i, token.i)
	remove_Stopped(token.q)
	CreateTexture(widthInTexels.l, heightInTexels.l, texture.i)
	GetAvailableTexture(texture.i)
	CloseTexture(texture.i)
	PresentTexture(texture.i)
	Stop()
	add_ErrorReceived(eventHandler.i, token.i)
	remove_ErrorReceived(token.q)
	SetD3DDevice(d3dDevice.i)
	add_WebTextureReceived(eventHandler.i, token.i)
	remove_WebTextureReceived(token.q)
	add_WebTextureStreamStopped(eventHandler.i, token.i)
	remove_WebTextureStreamStopped(token.q)
EndInterface 

;- ICoreWebView2ExperimentalTextureStreamStartRequestedEventHandler

DataSection
	IID_ICoreWebView2ExperimentalTextureStreamStartRequestedEventHandler:
	Data.l $62D09330
	Data.w $A9, $41BF
	Data.b $A9, $AE, $55, $AA, $EF, $8B, $3C, $44
EndDataSection

Interface ICoreWebView2ExperimentalTextureStreamStartRequestedEventHandler Extends IUnknown
	Invoke(sender.i, args.i)
EndInterface 

;- ICoreWebView2ExperimentalTextureStreamStoppedEventHandler

DataSection
	IID_ICoreWebView2ExperimentalTextureStreamStoppedEventHandler:
	Data.l $4111102A
	Data.w $D19F, $4438
	Data.b $AF, $46, $EF, $C5, $63, $B2, $B9, $CF
EndDataSection

Interface ICoreWebView2ExperimentalTextureStreamStoppedEventHandler Extends IUnknown
	Invoke(sender.i, args.i)
EndInterface 

;- ICoreWebView2ExperimentalTexture

DataSection
	IID_ICoreWebView2ExperimentalTexture:
	Data.l $836F09C
	Data.w $34BD, $47BF
	Data.b $91, $4A, $99, $FB, $56, $AE, $2D, $7
EndDataSection

Interface ICoreWebView2ExperimentalTexture Extends IUnknown
	get_Handle(value.i)
	get_Resource(value.i)
	get_Timestamp(value.i)
	put_Timestamp(value.q)
EndInterface 

;- ICoreWebView2ExperimentalTextureStreamErrorReceivedEventHandler

DataSection
	IID_ICoreWebView2ExperimentalTextureStreamErrorReceivedEventHandler:
	Data.l $52CB8898
	Data.w $C711, $401A
	Data.b $8F, $97, $36, $46, $83, $1B, $A7, $2D
EndDataSection

Interface ICoreWebView2ExperimentalTextureStreamErrorReceivedEventHandler Extends IUnknown
	Invoke(sender.i, args.i)
EndInterface 

;- ICoreWebView2ExperimentalTextureStreamErrorReceivedEventArgs

DataSection
	IID_ICoreWebView2ExperimentalTextureStreamErrorReceivedEventArgs:
	Data.l $E1730C1
	Data.w $3DF, $4AD2
	Data.b $B8, $47, $BE, $4D, $63, $AD, $F7, $0
EndDataSection

Interface ICoreWebView2ExperimentalTextureStreamErrorReceivedEventArgs Extends IUnknown
	get_Kind(value.i)
	get_texture(value.i)
EndInterface 

;- Enum COREWEBVIEW2_TEXTURE_STREAM_ERROR_KIND
#COREWEBVIEW2_TEXTURE_STREAM_ERROR_NO_VIDEO_TRACK_STARTED = 0
#COREWEBVIEW2_TEXTURE_STREAM_ERROR_TEXTURE_ERROR = 1
#COREWEBVIEW2_TEXTURE_STREAM_ERROR_TEXTURE_IN_USE = 2

;- ICoreWebView2ExperimentalTextureStreamWebTextureReceivedEventHandler

DataSection
	IID_ICoreWebView2ExperimentalTextureStreamWebTextureReceivedEventHandler:
	Data.l $9EA4228C
	Data.w $295A, $11ED
	Data.b $A2, $61, $2, $42, $AC, $12, $0, $2
EndDataSection

Interface ICoreWebView2ExperimentalTextureStreamWebTextureReceivedEventHandler Extends IUnknown
	Invoke(sender.i, args.i)
EndInterface 

;- ICoreWebView2ExperimentalTextureStreamWebTextureReceivedEventArgs

DataSection
	IID_ICoreWebView2ExperimentalTextureStreamWebTextureReceivedEventArgs:
	Data.l $A4C2FA3A
	Data.w $295A, $11ED
	Data.b $A2, $61, $2, $42, $AC, $12, $0, $2
EndDataSection

Interface ICoreWebView2ExperimentalTextureStreamWebTextureReceivedEventArgs Extends IUnknown
	get_WebTexture(value.i)
EndInterface 

;- ICoreWebView2ExperimentalWebTexture

DataSection
	IID_ICoreWebView2ExperimentalWebTexture:
	Data.l $B94265AE
	Data.w $4C1E, $11ED
	Data.b $BD, $C3, $2, $42, $AC, $12, $0, $2
EndDataSection

Interface ICoreWebView2ExperimentalWebTexture Extends IUnknown
	get_Handle(value.i)
	get_Resource(value.i)
	get_Timestamp(value.i)
EndInterface 

;- ICoreWebView2ExperimentalTextureStreamWebTextureStreamStoppedEventHandler

DataSection
	IID_ICoreWebView2ExperimentalTextureStreamWebTextureStreamStoppedEventHandler:
	Data.l $77EB4638
	Data.w $2F05, $11ED
	Data.b $A2, $61, $2, $42, $AC, $12, $0, $2
EndDataSection

Interface ICoreWebView2ExperimentalTextureStreamWebTextureStreamStoppedEventHandler Extends IUnknown
	Invoke(sender.i, args.i)
EndInterface 

;- ICoreWebView2ExperimentalProcessFailedEventArgs

DataSection
	IID_ICoreWebView2ExperimentalProcessFailedEventArgs:
	Data.l $A9FC1AF8
	Data.w $F934, $4F0F
	Data.b $A7, $88, $7B, $E0, $80, $8C, $32, $9B
EndDataSection

Interface ICoreWebView2ExperimentalProcessFailedEventArgs Extends IUnknown
	get_FailureSourceModulePath(modulePath.i)
EndInterface 

