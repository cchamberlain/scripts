<% ' SSO JWT Identity/Authorize/Deauthorize page for classic asp '
    'CWC 9/10/15 - Unified Login Refactor -> This is the main page that controls authorization / deauthorization of users for unified login on ASP.
    'CWC 9/24/15 - Fixed logoff for non-unified users
    %>
<script language="JScript" runat="server" src="json2.js"></script>
<%
Server.Execute("/Asp/Include/Core.asp")
If Application("CONFIG_WEB_ISPRODUCTION") = "true" AND Request.ServerVariables("HTTPS") <> "on" Then
    Dim strSecureUrl: strSecureURL = "https://"
    strSecureURL = strSecureURL & Request.ServerVariables("SERVER_NAME")
    strSecureURL = strSecureURL & Request.ServerVariables("URL")
    Response.Redirect strSecureURL
Else
    '''->Configuration zone
    Dim aspLog: aspLog = "DEBUG_LOG"
    Dim protectedUrl: protectedUrl = Application("CONFIG_WEB_PROTECTEDURL")
    Dim refreshTokenUrl: refreshTokenUrl = Application("CONFIG_WEB_REFRESHTOKENURL")
    Dim tokensCookieName: tokensCookieName = Application("CONFIG_WEB_TOKENSCOOKIENAME")
    Dim clientId: clientId = Application("CONFIG_WEB_CLIENTID")
    Dim userIdClaim: userIdClaim = Application("CONFIG_WEB_USERIDCLAIM")
    Dim organizationIdClaim: organizationIdClaim = Application("CONFIG_WEB_ORGANIZATIONIDCLAIM")
    Dim delimiter: delimiter = ":"
    Dim isDebug: isDebug = Request.QueryString("isdebug")
    Dim claimsRequest, refreshRequest, responseText, accessToken, refreshToken, base64, hasCookie

    '''->deauthorize query string flag can be optionally passed to force deauthorize
    If Request.QueryString("deauthorize") <> "" Then
        Deauthorize
    Else
        base64 = Request.Cookies(tokensCookieName)
        hasCookie = CBool(Len(base64) > 0)

        If hasCookie Then

            WriteAspLog "cookie was found: " & base64
            Dim decoded: decoded = Base64Decode(base64)
            Dim decodedSplit: decodedSplit = Split(decoded, delimiter, 2)
            accessToken = decodedSplit(0)
            refreshToken = decodedSplit(1)

            RequestClaims
            If claimsRequest.status = 401 Then
                RefreshTokens
                If refreshRequest.status = 200 Then
                    ProcessRefresh
                    RequestClaims
                Else
                    WriteAspLog "Refresh request status: " & refreshRequest.status
                End If
            End If

            WriteAspLog "Claims request status: " & claimsRequest.status

            If claimsRequest.status = 200 Then
                ProcessClaims
            Else
                Deauthorize
            End If
        Else
            ' TODO: //REMOVE IF AND MAKE DEAUTHORIZE RUN FOR ALL USERS WHEN WE ROLL OUT TO EVERYONE
            If Session("OrganizationNumber") = "1" Then
                WriteAspLog "No cookie was found but user is a Tix User. Deauthorizing! This will eventually be the norm for all users."
                ' TODO: //LEAVE THIS LINE
                Deauthorize
            End If
            ' TODO: //END
        End If
    End If

    If isDebug Then
        WriteDebug
    End If
End If

Sub RequestClaims()
    WriteAspLog "hitting protected url with accessToken"
    Set claimsRequest = Server.CreateObject("MSXML2.ServerXMLHTTP")
    claimsRequest.Open "GET", protectedUrl, False
    claimsRequest.SetRequestHeader "Authorization", "BEARER " + accessToken
    claimsRequest.Send
End Sub

Sub RefreshTokens()
    Dim payload: payload = "{""ClientId"":""" & clientId & """,""RefreshToken"":""" & refreshToken & """}"
    WriteAspLog "hitting refresh url with payload"
    Set refreshRequest = Server.CreateObject("MSXML2.ServerXMLHTTP")
    refreshRequest.Open "POST", refreshTokenUrl, False
    refreshRequest.setRequestHeader "Content-type","application/json"
    refreshRequest.setRequestHeader "Accept","application/json"
    refreshRequest.Send payload
    WriteAspLog "Refresh response: " & refreshRequest.responseText
End Sub

Sub ProcessRefresh()
    Dim jsonResponse : Set jsonResponse = JSON.parse(refreshRequest.responseText)
    accessToken = jsonResponse.access_token
    refreshToken = jsonResponse.refresh_token
    WriteAspLog "Tokens parsed -> accessToken=[" & accessToken & "] refreshToken=[" & refreshToken & "]"
    Dim compiled : compiled = accessToken & delimiter & refreshToken
    WriteAspLog "Compiled tokens -> " & compiled
    Dim encoded: encoded = Base64Encode(compiled)
    WriteAspLog "Encoded tokens -> " & encoded
    Response.Cookies(tokensCookieName)=encoded
    Response.Cookies(tokensCookieName).Expires=DateAdd("d",14,Now())
    Response.Cookies(tokensCookieName).Path="/"
End Sub

Sub ProcessClaims()
    Dim jsonResponse : Set jsonResponse = JSON.parse(claimsRequest.responseText)
    Dim claim, userId, organizationId

    For Each claim in jsonResponse
        If claim.Type = userIdClaim Then
            WriteAspLog "UserIdClaim: " & userIdClaim
            userId = claim.Value
        End If
        If claim.Type = organizationIdClaim Then
            WriteAspLog "OrganizationIdClaim: " & organizationIdClaim
            organizationId = claim.Value
        End If
    Next

    If IsValid(userId) And IsValid(organizationId) Then
        Authorize userId,organizationId
    Else
        Deauthorize
    End If
End Sub

Sub Authorize(userId, organizationId)
    WriteAspLog "[AUTHORIZE] -> userId=[" & userId & "] organizationId=[" & organizationId & "]"
    Session("IsAuthorized") = True
    Session("UserNumber") = userId
    Session("OrganizationNumber") = organizationId
End Sub

Sub Deauthorize()
    WriteAspLog "[DEAUTHORIZE]"
    
    ' TODO: REMOVE THIS BLOCK COMPLETELY WHEN UNIFIED GOES LIVE
    Dim IsTixUser : IsTixUser = False
    If Session("UserNumber") = "1" Then
      IsTixUser = True
    End If
    
    
    Session.Abandon
    Session("IsAuthorized") = False

    '''->Expire the cookie
    Response.Cookies(tokensCookieName).Expires = DateAdd("d",-1,Now())

    '''->If set (flag) will send user to login with returnpage
    Dim relogin : relogin=Request.QueryString("relogin")

    '''->If set overrides the relogin returnpage
    Dim returnpage : returnpage=Request.QueryString("returnpage")

    If relogin<>"" OR Session("AUTHORIZE_RELOGIN")<>"" Then
        '''->Redirect to login with return page
        If returnpage = "" Then
            returnpage="/management"
        End If
        
        ' TODO: REMOVE IF AND USE THE UNIFIED LOGIN (FIRST) PATH WHEN UNIFIED GOES LIVE
        If IsTixUser = True Then
          Response.Redirect "/forms/identity/authorize.aspx?returntopage=" & returnpage
        Else
          Response.Redirect "/management?returntopage=" & returnpage
        End If
    Else
        '''->Redirect to homepage or return page
        If returnpage = "" Then
            returnpage="/management"
        End If
        Response.Redirect returnpage
    End If
End Sub

Function IsValid(str)
    IsValid = VarType(str) = 8 And Len(str) > 0
End Function

Sub DEBUG(msg)
    Response.Redirect("http://www.google.com?q=" & msg)
End Sub

Sub WriteAspLog(str)
    aspLog = aspLog & "<br />" & str
End Sub

Sub WriteDebug()
    Session.Contents.Remove("DEBUG_LOG")
    Dim debugLog : debugLog=""
    debugLog = debugLog & "<div class=""tix-panel""><div class=""row""><div class=""col-md-12 p-right-10""><h3 class=""pull-left"">ASP Debug Panel</h3>"
    debugLog = debugLog & "<span class=""pull-right m-top-10""><i class=""fa fa-bug fa-lg fa-secondary-1""></i></span></div></div><hr />"

    if NOT IsEmpty(claimsRequest) Then
        If claimsRequest.status = 200 Then
            debugLog = debugLog & "<h4>JWT Token</h4><pre class=""font-xs"">" & accessToken & "</pre><a class=""btn btn-info"" target=""_blank"" href=""http://jwt.io/?value=" & accessToken & """><i class=""fa fa-file-code-o fa-lg m-right-5""></i>To JWT.io</a>"

            Dim jsonResponse : Set jsonResponse = JSON.parse(claimsRequest.responseText)
            Dim claim, sessionVariable

            debugLog = debugLog & "<hr /><h4>Tix.Resource.Api Claims</h4>"
            debugLog = debugLog & "<table class=""table table-striped font-xs"">"
            debugLog = debugLog & "<thead><tr><td>Claim</td><td>Value</td></tr></thead><tbody>"
            For Each claim in jsonResponse
                debugLog = debugLog & "<tr>"
                debugLog = debugLog & "<td>" & claim.Type & "</td><td>" & claim.Value & "</td>"
                debugLog = debugLog & "</tr>"
            Next
            debugLog = debugLog & "</tbody></table>"

            debugLog = debugLog & "<hr /><h4>Session</h4>"
            debugLog = debugLog & "<table class=""table table-striped font-xs"">"
            debugLog = debugLog & "<thead><tr><td>Variable</td><td>Value</td></tr></thead><tbody>"
            For Each sessionVariable in Session.Contents
                debugLog = debugLog & "<tr>"
                debugLog = debugLog & "<td>" & sessionVariable & "</td><td>" & Session(sessionVariable) & "</td>"
                debugLog = debugLog & "</tr>"
            Next
            debugLog = debugLog & "</tbody></table>"
        Else
            debugLog = debugLog & "<h4>Authenticate Failed</h4><p>Status: "
            debugLog = debugLog & claimsRequest.status & "<br />Message: " & claimsRequest.statusText
            debugLog = debugLog & "</p>"
        End If
    End If
    debugLog = debugLog & "<br /><pre><code>" & aspLog & "</pre></code>"
    debugLog = debugLog & "</div>"
    Session("DEBUG_LOG") = debugLog
End Sub

Function Base64Encode(sText)
    Dim oXML, oNode
    Set oXML = CreateObject("Msxml2.DOMDocument.3.0")
    Set oNode = oXML.CreateElement("base64")
    oNode.dataType = "bin.base64"
    oNode.nodeTypedValue =Stream_StringToBinary(sText)
    Base64Encode = oNode.text
    Set oNode = Nothing
    Set oXML = Nothing
End Function

Function Base64Decode(ByVal vCode)
    Dim oXML, oNode
    Set oXML = CreateObject("Msxml2.DOMDocument.3.0")
    Set oNode = oXML.CreateElement("base64")
    oNode.dataType = "bin.base64"
    oNode.text = vCode
    Base64Decode = Stream_BinaryToString(oNode.nodeTypedValue)
    Set oNode = Nothing
    Set oXML = Nothing
End Function

Function Stream_StringToBinary(Text)
  Const adTypeText = 2
  Const adTypeBinary = 1

  'Create Stream object
  Dim BinaryStream 'As New Stream
  Set BinaryStream = CreateObject("ADODB.Stream")

  'Specify stream type - we want To save text/string data.
  BinaryStream.Type = adTypeText

  'Specify charset For the source text (unicode) data.
  'BinaryStream.CharSet = "UTF-8"
  BinaryStream.CharSet = "us-ascii"

  'Open the stream And write text/string data To the object
  BinaryStream.Open
  BinaryStream.WriteText Text

  'Change stream type To binary
  BinaryStream.Position = 0
  BinaryStream.Type = adTypeBinary

  'Ignore first two bytes - sign of
  BinaryStream.Position = 0

  'Open the stream And get binary data from the object
  Stream_StringToBinary = BinaryStream.Read

  Set BinaryStream = Nothing
End Function

Function Stream_BinaryToString(Binary)
  Const adTypeText = 2
  Const adTypeBinary = 1

  'Create Stream object
  Dim BinaryStream 'As New Stream
  Set BinaryStream = CreateObject("ADODB.Stream")

  'Specify stream type - we want To save binary data.
  BinaryStream.Type = adTypeBinary

  'Open the stream And write binary data To the object
  BinaryStream.Open
  BinaryStream.Write Binary

  'Change stream type To text/string
  BinaryStream.Position = 0
  BinaryStream.Type = adTypeText

  'Specify charset For the output text (unicode) data.
  'BinaryStream.CharSet = "UTF-8"
  BinaryStream.CharSet = "us-ascii"

  'Open the stream And get text/string data from the object
  Stream_BinaryToString = BinaryStream.ReadText
  Set BinaryStream = Nothing
End Function
%>