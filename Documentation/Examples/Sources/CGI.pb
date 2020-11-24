;
; ------------------------------------------------------------
;
;   PureBasic - CGI example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

; To test it, you will need to compile it as an standalone executable and put it in the /cgi-bin/ folder of your
; webserver.
;

If Not InitCGI() Or Not ReadCGI()
  End
EndIf

WriteCGIHeader(#PB_CGI_HeaderContentType, "text/html", #PB_CGI_LastHeader) ; Write the headers to inform the browser of the content format

WriteCGIString("<html><title>PureBasic CGI</title><body>")

Procedure WriteCGIConstant(Constant$)
  WriteCGIString(Constant$ + ": " + CGIVariable(Constant$)+"<br>")
EndProcedure

WriteCGIConstant(#PB_CGI_AuthType)
WriteCGIConstant(#PB_CGI_ContentLength)
WriteCGIConstant(#PB_CGI_HeaderContentType)
WriteCGIConstant(#PB_CGI_DocumentRoot)
WriteCGIConstant(#PB_CGI_GatewayInterface)
WriteCGIConstant(#PB_CGI_PathInfo)
WriteCGIConstant(#PB_CGI_PathTranslated)
WriteCGIConstant(#PB_CGI_QueryString)
WriteCGIConstant(#PB_CGI_RemoteAddr)
WriteCGIConstant(#PB_CGI_RemoteHost)
WriteCGIConstant(#PB_CGI_RemoteIdent)
WriteCGIConstant(#PB_CGI_RemotePort)
WriteCGIConstant(#PB_CGI_RemoteUser)
WriteCGIConstant(#PB_CGI_RequestURI)
WriteCGIConstant(#PB_CGI_RequestMethod)
WriteCGIConstant(#PB_CGI_ScriptName)
WriteCGIConstant(#PB_CGI_ScriptFilename)
WriteCGIConstant(#PB_CGI_ServerAdmin)
WriteCGIConstant(#PB_CGI_ServerName)
WriteCGIConstant(#PB_CGI_ServerPort)
WriteCGIConstant(#PB_CGI_ServerProtocol)
WriteCGIConstant(#PB_CGI_ServerSignature)
WriteCGIConstant(#PB_CGI_ServerSoftware)
WriteCGIConstant(#PB_CGI_HttpAccept)
WriteCGIConstant(#PB_CGI_HttpAcceptEncoding)
WriteCGIConstant(#PB_CGI_HttpAcceptLanguage)
WriteCGIConstant(#PB_CGI_HttpCookie)
WriteCGIConstant(#PB_CGI_HttpForwarded)
WriteCGIConstant(#PB_CGI_HttpHost)
WriteCGIConstant(#PB_CGI_HttpPragma)
WriteCGIConstant(#PB_CGI_HttpReferer)
WriteCGIConstant(#PB_CGI_HttpUserAgent)

WriteCGIString("</body></html>")
