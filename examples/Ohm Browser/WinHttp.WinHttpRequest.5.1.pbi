;- Enum WinHttpRequestOption
#WinHttpRequestOption_UserAgentString = 0
#WinHttpRequestOption_URL = 1
#WinHttpRequestOption_URLCodePage = 2
#WinHttpRequestOption_EscapePercentInURL = 3
#WinHttpRequestOption_SslErrorIgnoreFlags = 4
#WinHttpRequestOption_SelectCertificate = 5
#WinHttpRequestOption_EnableRedirects = 6
#WinHttpRequestOption_UrlEscapeDisable = 7
#WinHttpRequestOption_UrlEscapeDisableQuery = 8
#WinHttpRequestOption_SecureProtocols = 9
#WinHttpRequestOption_EnableTracing = 10
#WinHttpRequestOption_RevertImpersonationOverSsl = 11
#WinHttpRequestOption_EnableHttpsToHttpRedirects = 12
#WinHttpRequestOption_EnablePassportAuthentication = 13
#WinHttpRequestOption_MaxAutomaticRedirects = 14
#WinHttpRequestOption_MaxResponseHeaderSize = 15
#WinHttpRequestOption_MaxResponseDrainSize = 16
#WinHttpRequestOption_EnableHttp1_1 = 17
#WinHttpRequestOption_EnableCertificateRevocationCheck = 18
#WinHttpRequestOption_RejectUserpwd = 19

;- Enum WinHttpRequestAutoLogonPolicy
#AutoLogonPolicy_Always = 0
#AutoLogonPolicy_OnlyIfBypassProxy = 1
#AutoLogonPolicy_Never = 2

;- Enum WinHttpRequestSslErrorFlags
#SslErrorFlag_UnknownCA = 256
#SslErrorFlag_CertWrongUsage = 512
#SslErrorFlag_CertCNInvalid = 4096
#SslErrorFlag_CertDateInvalid = 8192
#SslErrorFlag_Ignore_All = 13056

;- Enum WinHttpRequestSecureProtocols
#SecureProtocol_SSL2 = 8
#SecureProtocol_SSL3 = 32
#SecureProtocol_TLS1 = 128
#SecureProtocol_TLS1_1 = 512
#SecureProtocol_TLS1_2 = 2048
#SecureProtocol_ALL = 168

;- IWinHttpRequest

DataSection
	IID_IWinHttpRequest:
	Data.l $16FE2EC
	Data.w $B2C8, $45F8
	Data.b $B2, $3B, $39, $E5, $3A, $75, $39, $6B
EndDataSection

Interface IWinHttpRequest Extends IDispatch
	SetProxy(ProxySetting.l, ProxyServer.p-variant, BypassList.p-variant)
	SetCredentials(UserName.p-bstr, Password.p-bstr, Flags.l)
	Open(Method.p-bstr, Url.p-bstr, Async.p-variant)
	SetRequestHeader(Header.p-bstr, Value.p-bstr)
	GetResponseHeader(Header.p-bstr, prop.i)
	GetAllResponseHeaders(prop.i)
	Send(Body.p-variant)
	get_Status(prop.i)
	get_StatusText(prop.i)
	get_ResponseText(prop.i)
	get_ResponseBody(prop.i)
	get_ResponseStream(prop.i)
	get_Option(Option.l, prop.i)
	put_Option(Option.l, Option.p-variant)
	WaitForResponse(Timeout.p-variant, prop.i)
	Abort()
	SetTimeouts(ResolveTimeout.l, ConnectTimeout.l, SendTimeout.l, ReceiveTimeout.l)
	SetClientCertificate(ClientCertificate.p-bstr)
	SetAutoLogonPolicy(AutoLogonPolicy.l)
EndInterface 

;- IWinHttpRequestEvents

DataSection
	IID_IWinHttpRequestEvents:
	Data.l $F97F4E15
	Data.w $B787, $4212
	Data.b $80, $D1, $D3, $80, $CB, $BF, $98, $2E
EndDataSection

Interface IWinHttpRequestEvents Extends IUnknown
	OnResponseStart(Status.l, ContentType.p-bstr)
	OnResponseDataAvailable(Data.i)
	OnResponseFinished()
	OnError(ErrorNumber.l, ErrorDescription.p-bstr)
EndInterface 

;- Class WinHttpRequest
DataSection
	CLSID_WinHttpRequest:
	Data.l $2087C2F4
	Data.w $2CEF, $4953
	Data.b $A8, $AB, $66, $77, $9B, $67, $4, $95
EndDataSection

