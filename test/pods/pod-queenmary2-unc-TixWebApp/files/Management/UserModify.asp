<%
'CHANGE LOG
'    11/7/11 - Add button 'Return To Listing' back to UserMaintenance
'REE 11/16/11 - Added Video Tutorial Link.
'REE 5/18/12 - Disabled Updates for TestDrive Org.
'REE 6/27/12 - Added Logging (History) for User and Security updates
'JAI 7/23/14 - Disabled AutoComplete for Password fields
'JAI 11/20/14 - Added CRM Menu Options
'GDL 9/28/15 - Replaced calls updating TixDB.User with an API call to Upsert into Identity.User (Which contains triggers to sync with TixDB.User)
%>

<!--#INCLUDE VIRTUAL=GlobalInclude.asp -->
<!--#INCLUDE VIRTUAL="dbOpenInclude.asp"-->
<!--#include virtual="/Asp/Cryptography/Rijndael.asp"-->

<%
Page = "ManagementUserModify"

If Session("UserNumber") = "" Or IsNull(Session("UserNumber")) Then Response.Redirect("Default.asp")

'REE 1/27/9 - Make sure the user is authorized to use this program
'REE 8/19/9 - Added Security Logging.
If SecurityCheck("UserMaintenance") <> True Then 
    SecurityLog(Page & " - Unauthorized Access Attempt")
    Response.Redirect("Default.asp")
Else
    SecurityLog(Page & " - Program Access")
End If    

Select Case Clean(Request("UserAction"))
	Case "Update"
		Call UpdateUser
	Case "Delete"
		Call DeleteUser
	Case Else
		Call ModifyUser(Message)
End Select

Sub ModifyUser(Message)
%>
<HTML>
<HEAD>
<TITLE>Tix - User Maintenance</TITLE>
<SCRIPT LANGUAGE="JavaScript">    

<!-- Hide code from non-js browsers
     function validateForm() {
	    formObj = document.Information;
        if (formObj.FirstName.value == "") {
            alert("Please enter the First Name.");
            formObj.Address1.focus();
            return false;
            }
        else if (formObj.LastName.value == "") {
            alert("Please enter the Last Name.");
            formObj.LastName.focus();
            return false;
            } 
       else if (formObj.UserID.value == "") {
            alert("Please enter the User ID.");
            formObj.UserID.focus();
            return false;
            } 

        else if (formObj.Password1.value == "") {
            alert("Please enter the Password.");
            formObj.Password1.focus();
            return false;
            }
        else if (formObj.Password2.value == "") {
            alert("Please re-enter the password in the Confirm Password field.");
            formObj.Password2.focus();
            return false;
            }
        else if (formObj.Password1.value != formObj.Password2.value) {
			alert("The passwords do not match.  To insure the password is entered correctly, enter the same password in the 'Password' and 'Confirm Password' fields.");
			formObj.Password1.focus();
			return false;
			}
        }    // end hiding -->
</SCRIPT>
</HEAD>

<%
If Message = "" Then
	Response.Write "<BODY BGCOLOR=#FFFFFF>" & vbCrLf
Else
	Response.Write "<BODY BGCOLOR=#FFFFFF onLoad=" & CHR(34) & "alert('" & Message & "')" & CHR(34) & ">" & vbCrLf
End If
Message = ""

%>

<CENTER>
<!--#INCLUDE VIRTUAL="TopNavInclude.asp"-->
<BR>

<FORM ACTION="UserModify.asp" METHOD="POST" NAME="Information" onsubmit="return validateForm()"><INPUT TYPE=hidden NAME=UserAction VALUE=Update>
<FONT FACE="verdana, arial, helvetica" COLOR="#008400" SIZE="2"><H3>User Details <img src="/images/tixtv.gif" alt="User Maintenance Video Tutorial" border="none" onClick="window.open('http://www.tix.com/tutorials/videotutorial.asp?TutorialTitle=User%20Maintenance%20Tutorial&TutorialURL=http://player.vimeo.com/video/32222600?title=0&amp;byline=0&amp;portrait=0','Tutorial','width=800,height=600,toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,copyhistory=no,resizable=no');" /></H3></FONT>
<%

'REE 10/11/5 - Added Session Organization criteria to only allow access to Users belonging to logged in Session Organization.
SQLUser = "SELECT Users.UserNumber, Users.FirstName, Users.LastName, Users.UserID, Users.Password, Users.UserType, Users.Status, Users.EMailAddress, Users.SecretQuestion, Users.SecretAnswer, Organization.OrganizationNumber, Organization.Organization FROM Users (NOLOCK) INNER JOIN Organization (NOLOCK) ON Users.OrganizationNumber = Organization.OrganizationNumber WHERE UserNumber = " & CleanNumeric(Request("UserNumber")) & " AND Users.OrganizationNumber = " & Session("OrganizationNumber")
Set rsUser = OBJdbConnection.Execute(SQLUser)

Call DBOpen(OBJdbConnection2)

If Not rsUser.EOF Then
    Dim SecretQuestion(6)
    SecretQuestion(1) = "What is the name of your favorite pet?"
    SecretQuestion(2) = "In what city were you born?"
    SecretQuestion(3) = "What high school did you attend?"
    SecretQuestion(4) = "What is your favorite movie?"
    SecretQuestion(5) = "What was the make of your first car?"
    SecretQuestion(6) = "What is your favorite color?"
%>
	<FONT FACE="verdana, arial, helvetica" SIZE="2">Fields marked with </FONT><FONT FACE="Times" COLOR="#CC0000" SIZE="3">*</FONT><FONT FACE="verdana, arial, helvetica" SIZE="2"> are required.</FONT><BR>
	<BR>
	<TABLE>
		<TR><TD ALIGN="right"><FONT FACE="verdana, arial, helvetica" SIZE="2"><B>First Name:</B></FONT></TD><TD><FONT COLOR="#CC0000">*</FONT></TD><TD><INPUT TYPE="text" NAME="FirstName" SIZE="20" MAXLENGTH="20" VALUE="<%= rsUser("FirstName") %>"></TD></TR>
		<TR><TD ALIGN="right"><FONT FACE="verdana, arial, helvetica" SIZE="2"><B>Last Name:</B></FONT></TD><TD><FONT COLOR="#CC0000">*</FONT></TD><TD><INPUT TYPE="text" NAME="LastName" SIZE="20" MAXLENGTH="20" VALUE="<%= rsUser("LastName") %>"></TD></TR>
		<TR><TD ALIGN="right"><FONT FACE="verdana, arial, helvetica" SIZE="2"><B>User ID:</B></FONT></TD><TD><FONT COLOR="#CC0000">*</FONT></TD><TD><INPUT TYPE="text" NAME="UserID" SIZE="20" MAXLENGTH="20" VALUE="<%= rsUser("UserID") %>"></TD></TR>
		<TR><TD ALIGN="right"><FONT FACE="verdana, arial, helvetica" SIZE="2"><B>Password:</B></FONT></TD><TD><FONT COLOR="#CC0000">*</FONT></TD><TD><INPUT TYPE="password" NAME="Password1" AUTOCOMPLETE="off" SIZE="20" MAXLENGTH="20" VALUE="<%= rsUser("Password") %>"></TD></TR>
		<TR><TD ALIGN="right"><FONT FACE="verdana, arial, helvetica" SIZE="2"><B>Confirm Password:</B></FONT></TD><TD><FONT COLOR="#CC0000">*</FONT></TD><TD><INPUT TYPE="password" NAME="Password2" AUTOCOMPLETE="off" SIZE="20" MAXLENGTH="20" VALUE="<%= rsUser("Password") %>"></TD></TR>
		<TR><TD ALIGN="right"><FONT FACE="verdana, arial, helvetica" SIZE="2"><B>Email Address:</B></FONT></TD><TD>&nbsp;</TD><TD><INPUT TYPE="text" NAME="EmailAddress" AUTOCOMPLETE="off" SIZE="37" VALUE="<%= rsUser("EMailAddress") %>"></TD></TR>
		<TR><TD ALIGN="right"><FONT FACE="verdana, arial, helvetica" SIZE="2"><B>Secret Question:</B></FONT></TD><TD>&nbsp;</TD>
		<TD><select name="SecretQuestion">
		  <option value="">- Select a Question -</option>
		<% For i = 1 To 6 %>
		  <option value="<%=SecretQuestion(i)%>"<% If rsUser("SecretQuestion") = SecretQuestion(i) Then %> selected="selected"<% End If %>><%=SecretQuestion(i)%></option>
		<% Next %>
		</select></TD></TR>
		<TR><TD ALIGN="right"><FONT FACE="verdana, arial, helvetica" SIZE="2"><B>Secret Answer:</B></FONT></TD><TD>&nbsp;</TD><TD><INPUT TYPE="password" NAME="SecretAnswer" AUTOCOMPLETE="off" SIZE="37" VALUE="<%= rsUser("SecretAnswer") %>"></TD></TR>
<%
	'REE 10/21/3 - Added Organization Name to Banner
	SQLName = "SELECT Organization.OrganizationNumber FROM Users (NOLOCK) INNER JOIN Organization (NOLOCK) ON Users.OrganizationNumber = Organization.OrganizationNumber WHERE UserNumber = " & Session("UserNumber")
	Set rsName = OBJdbConnection.Execute(SQLName)
	OrgOrgNumber = rsName("OrganizationNumber")
	rsName.Close
	Set rsName = nothing
		
	If OrgOrgNumber = 1 Then
		If rsUser("UserType") = "C" Then
			CallCenterNo = ""
			CallCenterYes = "SELECTED"
		Else
			CallCenterNo = "SELECTED"
			CallCenterYes = ""
		End If					
		If rsUser("Status") = "A" Then
			StatusActive = "SELECTED"
			StatusDisabled = ""
		Else
			StatusActive = ""
			StatusDisabled = "SELECTED"
		End If					
'		Response.Write "<TR><TD ALIGN=""right""><FONT FACE=""verdana,arial,helvetica"" SIZE=""2""><B>User Status:</B></FONT></TD><TD><FONT COLOR=""#CC0000"">*</FONT></TD><TD><SELECT NAME=""Status""><OPTION VALUE=""A"" " & StatusActive & ">Active<OPTION VALUE=""D"" " & StatusDisabled & ">Disabled</SELECT></TD></TR>"
		Response.Write "<TR><TD ALIGN=""right""><FONT FACE=""verdana,arial,helvetica"" SIZE=""2""><B>Call Center Only:</B></FONT></TD><TD><FONT COLOR=""#CC0000"">*</FONT></TD><TD><SELECT NAME=""UserType""><OPTION VALUE=""FALSE"" " & CallCenterNo & ">No<OPTION VALUE=""TRUE"" " & CallCenterYes & ">Yes</SELECT></TD></TR>"
'		Response.Write "<TR><TD ALIGN=""right""><FONT FACE=""verdana, arial, helvetica"" SIZE=""2""><B>Organization:</B></FONT></TD><TD><FONT COLOR=""#CC0000"">*</FONT></TD><TD><SELECT NAME=""OrganizationNumber"">"
'		Response.Write "<OPTION VALUE=" & rsUser("OrganizationNumber") & " SELECTED>" & rsUser("Organization") & vbCrLf
'		SQLOrganization = "SELECT OrganizationNumber, Organization FROM Organization (NOLOCK) ORDER BY Organization"
'		Set rsOrganization = OBJdbConnection.Execute(SQLOrganization)
'		Do Until rsOrganization.EOF
'			Response.Write "<OPTION VALUE=" & rsOrganization("OrganizationNumber") & ">" & rsOrganization("Organization") & vbCrLf
'			rsOrganization.MoveNext
'		Loop
'		Response.Write "</SELECT></TD></TR>"
	End If
%>
</TABLE>
<BR>
<TABLE CELLSPACING="0" CELLPADDING="0">
	<TR ALIGN="CENTER" BGCOLOR="#008400">
	  <TD COLSPAN="9" HEIGHT="23"><FONT FACE="verdana,arial,helvetica" COLOR="#FFFFFF" SIZE="3"><B>Menu & Function Authorization</B></FONT>
	  </TD>
	</TR>
	<TR>
	  <TD HEIGHT="12">
	  </TD>
	</TR>
	<TR VALIGN="TOP">
	  <TD>
		<TABLE CELLSPACING="2" CELLPADDING="3">
		  <TR BGCOLOR=#008400><TD ALIGN="CENTER"><FONT FACE="verdana,arial,helvetica" SIZE="2" COLOR="#FFFFFF"><B>X</B></FONT></TD><TD NOWRAP><FONT FACE="verdana,arial,helvetica" SIZE="2" COLOR="#FFFFFF"><B>Managment Menu</B></FONT></TD></TR>
			<%
			'Management Menu
			SQLMenu = "SELECT SecurityMenu.MenuName, SecurityMenu.MenuOrder, SecurityMenu.FunctionCode, SecurityMenu.FunctionDescription, SecurityMenu.DefaultMenuOption FROM SecurityMenu (NOLOCK) INNER JOIN Security (NOLOCK) ON SecurityMenu.FunctionCode = Security.FunctionCode WHERE MenuName = 'ManagementMenu' AND Security.UserNumber = " & Session("UserNumber") & " AND Security.Authorized = 1 ORDER BY MenuOrder"
			Set rsMenu = OBJdbConnection2.Execute(SQLMenu)
			
			Do Until rsMenu.EOF
			
				'Check User Authorization
				SQLUserAuthorization = "SELECT Authorized FROM Security (NOLOCK) WHERE UserNumber = " & CleanNumeric(Request("UserNumber")) & " AND FunctionCode = '" & rsMenu("FunctionCode") & "' AND Authorized = 1"
				Set rsUserAuthorization = OBJdbConnection.Execute(SQLUserAuthorization)
				
				If Not rsUserAuthorization.EOF Then
					AuthorizationCheck = " CHECKED"
				Else
					AuthorizationCheck = ""
				End If
				
				rsUserAuthorization.Close
				Set rsUserAuthorization = nothing
				
				'Check Tix Only
				If rsMenu("DefaultMenuOption") = "T" Then
					TixOnly = "<BR><B>(TIX ONLY)</B>"
					BGColor = "#CC0000"
				Else
					TixOnly = ""
					BGColor = "#EEEEEE"
				End If
				
				
				Response.Write "<TR BGCOLOR=""" & BGColor & """><TD ALIGN=""CENTER""><FONT FACE=""verdana,arial,helvetica"" SIZE=""2""><INPUT TYPE=""checkbox"" NAME=""UserSecurity"" VALUE=""" & rsMenu("FunctionCode") & """" & AuthorizationCheck & "></FONT></TD><TD><FONT FACE=""verdana,arial,helvetica"" SIZE=""2"">" & rsMenu("FunctionDescription") & TixOnly & "</FONT></TD></TR>"
				
				rsMenu.MoveNext
				
			Loop
			
			rsMenu.Close
			Set rsMenu = nothing
				
			%>		  
		</TABLE>
	  </TD>
	  <TD WIDTH="1">
	  </TD>
	  <TD>
		<TABLE CELLSPACING="2" CELLPADDING="3">
		  <TR BGCOLOR=#008400><TD ALIGN="CENTER"><FONT FACE="verdana,arial,helvetica" SIZE="2" COLOR="#FFFFFF"><B>X</B></FONT></TD><TD NOWRAP><FONT FACE="verdana,arial,helvetica" SIZE="2" COLOR="#FFFFFF"><B>Ticket Sales Menu</B></FONT></TD></TR>
			<%
			'Ticket Sales Menu
			SQLMenu = "SELECT SecurityMenu.MenuName, SecurityMenu.MenuOrder, SecurityMenu.FunctionCode, SecurityMenu.FunctionDescription, SecurityMenu.DefaultMenuOption FROM SecurityMenu (NOLOCK) INNER JOIN Security (NOLOCK) ON SecurityMenu.FunctionCode = Security.FunctionCode WHERE MenuName = 'TicketSalesMenu' AND Security.UserNumber = " & Session("UserNumber") & " AND Security.Authorized = 1 ORDER BY MenuOrder"
			Set rsMenu = OBJdbConnection2.Execute(SQLMenu)
			
			Do Until rsMenu.EOF
			
				'Check User Authorization
				SQLUserAuthorization = "SELECT Authorized FROM Security (NOLOCK) WHERE UserNumber = " & CleanNumeric(Request("UserNumber")) & " AND FunctionCode = '" & rsMenu("FunctionCode") & "' AND Authorized = 1"
				Set rsUserAuthorization = OBJdbConnection.Execute(SQLUserAuthorization)
				
				If Not rsUserAuthorization.EOF Then
					AuthorizationCheck = " CHECKED"
				Else
					AuthorizationCheck = ""
				End If
				
				rsUserAuthorization.Close
				Set rsUserAuthorization = nothing
				
				Response.Write "<TR BGCOLOR=""#EEEEEE""><TD ALIGN=""CENTER""><FONT FACE=""verdana,arial,helvetica"" SIZE=""2""><INPUT TYPE=""checkbox"" NAME=""UserSecurity"" VALUE=""" & rsMenu("FunctionCode") & """" & AuthorizationCheck & "></FONT></TD><TD><FONT FACE=""verdana,arial,helvetica"" SIZE=""2"">" & rsMenu("FunctionDescription") & "</FONT></TD></TR>"
				
				rsMenu.MoveNext
				
			Loop
			
			rsMenu.Close
			Set rsMenu = nothing
			%>
		</TABLE>
        <br />
		<TABLE CELLSPACING="2" CELLPADDING="3">
		  <TR BGCOLOR=#008400><TD ALIGN="CENTER"><FONT FACE="verdana,arial,helvetica" SIZE="2" COLOR="#FFFFFF"><B>X</B></FONT></TD><TD NOWRAP><FONT FACE="verdana,arial,helvetica" SIZE="2" COLOR="#FFFFFF"><B>CRM</B></FONT></TD></TR>
			<%
			'Ticket Sales Menu
			SQLMenu = "SELECT SecurityMenu.MenuName, SecurityMenu.MenuOrder, SecurityMenu.FunctionCode, SecurityMenu.FunctionDescription, SecurityMenu.DefaultMenuOption FROM SecurityMenu (NOLOCK) INNER JOIN Security (NOLOCK) ON SecurityMenu.FunctionCode = Security.FunctionCode WHERE MenuName = 'CRM' AND Security.UserNumber = " & Session("UserNumber") & " AND Security.Authorized = 1 ORDER BY MenuOrder"
			Set rsMenu = OBJdbConnection2.Execute(SQLMenu)
			
			Do Until rsMenu.EOF
			
				'Check User Authorization
				SQLUserAuthorization = "SELECT Authorized FROM Security (NOLOCK) WHERE UserNumber = " & CleanNumeric(Request("UserNumber")) & " AND FunctionCode = '" & rsMenu("FunctionCode") & "' AND Authorized = 1"
				Set rsUserAuthorization = OBJdbConnection.Execute(SQLUserAuthorization)
				
				If Not rsUserAuthorization.EOF Then
					AuthorizationCheck = " CHECKED"
				Else
					AuthorizationCheck = ""
				End If
				
				rsUserAuthorization.Close
				Set rsUserAuthorization = nothing
				
				Response.Write "<TR BGCOLOR=""#EEEEEE""><TD ALIGN=""CENTER""><FONT FACE=""verdana,arial,helvetica"" SIZE=""2""><INPUT TYPE=""checkbox"" NAME=""UserSecurity"" VALUE=""" & rsMenu("FunctionCode") & """" & AuthorizationCheck & "></FONT></TD><TD><FONT FACE=""verdana,arial,helvetica"" SIZE=""2"">" & rsMenu("FunctionDescription") & "</FONT></TD></TR>"
				
				rsMenu.MoveNext
				
			Loop
			
			rsMenu.Close
			Set rsMenu = nothing
			%>
		</TABLE>
	  </TD>
	  <TD WIDTH="1">
	  </TD>
	  <TD>
		<TABLE CELLSPACING="2" CELLPADDING="3">
		  <TR BGCOLOR=#008400><TD ALIGN="CENTER"><FONT FACE="verdana,arial,helvetica" SIZE="2" COLOR="#FFFFFF"><B>X</B></FONT></TD><TD NOWRAP><FONT FACE="verdana,arial,helvetica" SIZE="2" COLOR="#FFFFFF"><B>Report Menu</B></FONT></TD></TR>
<%
        Call DBOpen(OBJdbConnection3)

        SQLSecurityMenu = "SELECT FunctionCode, FunctionDescription FROM SecurityMenu (NOLOCK) WHERE MenuName = 'ReportMenu' AND FunctionCode IN('ReportMenuFinancial','ReportMenuMarketing','ReportMenuOperations','ReportMenuSales') AND ProgramName IS NULL AND DefaultMenuOption = 'Y' ORDER BY FunctionCode"
        Set rsSecurityMenu = OBJdbConnection3.Execute(SQLSecurityMenu)
        Do Until rsSecurityMenu.EOF
        			
			'Report Menu
			SQLMenu = "SELECT SecurityMenu.MenuName, SecurityMenu.MenuOrder, SecurityMenu.FunctionCode, SecurityMenu.FunctionDescription, SecurityMenu.DefaultMenuOption FROM SecurityMenu (NOLOCK) INNER JOIN Security (NOLOCK) ON SecurityMenu.FunctionCode = Security.FunctionCode WHERE MenuName = '" & rsSecurityMenu("FunctionCode") & "' AND Security.UserNumber = " & Session("UserNumber") & " AND Security.Authorized = 1 ORDER BY MenuOrder"
			Set rsMenu = OBJdbConnection2.Execute(SQLMenu)
			If Not rsMenu.EOF Then
	            'write out the category
	            Response.Write "<TR BGCOLOR=""#CCCCCC""><TD COLSPAN=""2""><FONT FACE=""verdana,arial,helvetica"" SIZE=""2""><B>" & rsSecurityMenu("FunctionDescription") & "</B></FONT></TD></TR>"
    	        
			    Do Until rsMenu.EOF
    			
				    'Check User Authorization
				    SQLUserAuthorization = "SELECT Authorized FROM Security (NOLOCK) WHERE UserNumber = " & CleanNumeric(Request("UserNumber")) & " AND FunctionCode = '" & rsMenu("FunctionCode") & "' AND Authorized = 1"
				    Set rsUserAuthorization = OBJdbConnection.Execute(SQLUserAuthorization)
    				
				    If Not rsUserAuthorization.EOF Then
					    AuthorizationCheck = " CHECKED"
				    Else
					    AuthorizationCheck = ""
				    End If
    				
				    rsUserAuthorization.Close
				    Set rsUserAuthorization = nothing
    				
				    Response.Write "<TR BGCOLOR=""#EEEEEE""><TD ALIGN=""CENTER""><FONT FACE=""verdana,arial,helvetica"" SIZE=""2""><INPUT TYPE=""checkbox"" NAME=""UserSecurity"" VALUE=""" & rsMenu("FunctionCode") & """" & AuthorizationCheck & "></FONT></TD><TD><FONT FACE=""verdana,arial,helvetica"" SIZE=""2"">" & rsMenu("FunctionDescription") & "</FONT></TD></TR>"
    				
				    rsMenu.MoveNext
    				
			    Loop
			End If
			rsMenu.Close
			Set rsMenu = nothing
			
			rsSecurityMenu.MoveNext
        Loop
        rsSecurityMenu.Close
        Set rsSecurityMenu = Nothing

        Call DBOpen(OBJdbConnection3)
%>
		</TABLE>
	  </TD>
<%
        SQLCustomMenu = "SELECT SecurityMenu.FunctionCode FROM Security (NOLOCK) INNER JOIN SecurityMenu (NOLOCK) ON Security.FunctionCode = SecurityMenu.FunctionCode WHERE Security.UserNumber = " & Session("UserNumber") & " AND SecurityMenu.MenuName = 'CustomMenu'"
        Set rsCustomMenu = OBJdbConnection.Execute(SQLCustomMenu)
        
        If Not rsCustomMenu.EOF Then
            CustomMenu = "Y"
        End If
        
        rsCustomMenu.Close
        Set rsCustomMenu = nothing
        
        If CustomMenu = "Y" Then
%>	  
	  <TD WIDTH="1">
	  </TD>
	  <TD>
		<TABLE CELLSPACING="2" CELLPADDING="3">
		  <TR BGCOLOR=#008400><TD ALIGN="CENTER"><FONT FACE="verdana,arial,helvetica" SIZE="2" COLOR="#FFFFFF"><B>X</B></FONT></TD><TD NOWRAP><FONT FACE="verdana,arial,helvetica" SIZE="2" COLOR="#FFFFFF"><B>Custom Menu</B></FONT></TD></TR>
<%
			'Custom Menu
			'REE 8/27/8 - Modified to display all Org specific custom menu options for Tix users.
            SQLUserOrg = "SELECT OrganizationNumber FROM Users (NOLOCK) WHERE UserNumber = " & Session("UserNumber")
            Set rsUserOrg = OBJdbConnection.Execute(SQLUserOrg)

            UserOrg = rsUserOrg("OrganizationNumber")

            rsUserOrg.Close
            Set rsUserOrg = nothing

            If UserOrg <> 1 Then
                SQLMenu = "SELECT SecurityMenu.MenuName, SecurityMenu.FunctionCode, SecurityMenu.FunctionDescription, SecurityMenu.DefaultMenuOption FROM SecurityMenu (NOLOCK) INNER JOIN Security (NOLOCK) ON SecurityMenu.FunctionCode = Security.FunctionCode WHERE SecurityMenu.Menuname = 'CustomMenu' AND Security.UserNumber = " & Session("UserNumber") & " AND Security.Authorized = 1 AND SecurityMenu.OrganizationNumber = " & Session("OrganizationNumber") & " ORDER BY SecurityMenu.FunctionDescription"
            Else
                SQLMenu = "SELECT SecurityMenu.MenuName, SecurityMenu.FunctionCode, SecurityMenu.FunctionDescription, SecurityMenu.DefaultMenuOption FROM SecurityMenu (NOLOCK) WHERE SecurityMenu.MenuName = 'CustomMenu' AND SecurityMenu.OrganizationNumber = " & Session("OrganizationNumber") & " ORDER BY SecurityMenu.FunctionDescription"
            End If         

			Set rsMenu = OBJdbConnection2.Execute(SQLMenu)
			
			Do Until rsMenu.EOF
			
				'Check User Authorization
				SQLUserAuthorization = "SELECT Authorized FROM Security (NOLOCK) WHERE UserNumber = " & CleanNumeric(Request("UserNumber")) & " AND FunctionCode = '" & rsMenu("FunctionCode") & "' AND Authorized = 1"
				Set rsUserAuthorization = OBJdbConnection.Execute(SQLUserAuthorization)
				
				If Not rsUserAuthorization.EOF Then
					AuthorizationCheck = " CHECKED"
				Else
					AuthorizationCheck = ""
				End If
				
				rsUserAuthorization.Close
				Set rsUserAuthorization = nothing
				
				Response.Write "<TR BGCOLOR=""#EEEEEE""><TD ALIGN=""CENTER""><FONT FACE=""verdana,arial,helvetica"" SIZE=""2""><INPUT TYPE=""checkbox"" NAME=""UserSecurity"" VALUE=""" & rsMenu("FunctionCode") & """" & AuthorizationCheck & "></FONT></TD><TD><FONT FACE=""verdana,arial,helvetica"" SIZE=""2"">" & rsMenu("FunctionDescription") & "</FONT></TD></TR>"
				
				rsMenu.MoveNext
				
			Loop
			
			rsMenu.Close
			Set rsMenu = nothing
%>
		</TABLE>
	  </TD>
<%
        End If 'Custom Menu
%>	  
	  <TD>
	  </TD WIDTH="1">
	  <TD>
		<TABLE CELLSPACING="2" CELLPADDING="3">
		  <TR BGCOLOR=#008400><TD ALIGN="CENTER"><FONT FACE="verdana,arial,helvetica" SIZE="2" COLOR="#FFFFFF"><B>X</B></FONT></TD><TD NOWRAP><FONT FACE="verdana,arial,helvetica" SIZE="2" COLOR="#FFFFFF"><B>Functions</B></FONT></TD></TR>
<%
			'Function Menu
			SQLMenu = "SELECT SecurityMenu.MenuName, SecurityMenu.MenuOrder, SecurityMenu.FunctionCode, SecurityMenu.FunctionDescription, SecurityMenu.DefaultMenuOption FROM SecurityMenu (NOLOCK) INNER JOIN Security (NOLOCK) ON SecurityMenu.FunctionCode = Security.FunctionCode WHERE MenuName = 'Maintenance' AND Security.UserNumber = " & Session("UserNumber") & " AND Security.Authorized = 1 ORDER BY MenuOrder"
			Set rsMenu = OBJdbConnection2.Execute(SQLMenu)
			
			Do Until rsMenu.EOF
			
				'Check User Authorization
				SQLUserAuthorization = "SELECT Authorized FROM Security (NOLOCK) WHERE UserNumber = " & CleanNumeric(Request("UserNumber")) & " AND FunctionCode = '" & rsMenu("FunctionCode") & "' AND Authorized = 1"
				Set rsUserAuthorization = OBJdbConnection.Execute(SQLUserAuthorization)
				
				If Not rsUserAuthorization.EOF Then
					AuthorizationCheck = " CHECKED"
				Else
					AuthorizationCheck = ""
				End If
				
				rsUserAuthorization.Close
				Set rsUserAuthorization = nothing
				
				Response.Write "<TR BGCOLOR=""#EEEEEE""><TD ALIGN=""CENTER""><FONT FACE=""verdana,arial,helvetica"" SIZE=""2""><INPUT TYPE=""checkbox"" NAME=""UserSecurity"" VALUE=""" & rsMenu("FunctionCode") & """" & AuthorizationCheck & "></FONT></TD><TD><FONT FACE=""verdana,arial,helvetica"" SIZE=""2"">" & rsMenu("FunctionDescription") & "</FONT></TD></TR>"
				
				rsMenu.MoveNext
				
			Loop
			
			rsMenu.Close
			Set rsMenu = nothing
%>
		</TABLE>
	  </TD>
	</TR>	  
</TABLE>
<BR><BR>
<TABLE>
	<TR VALIGN="TOP">
	    <TD ALIGN="right"><INPUT TYPE="hidden" NAME="UserNumber" VALUE="<%= CleanNumeric(Request("UserNumber")) %>"><INPUT TYPE="submit" VALUE="Update"></TD><td>&nbsp;&nbsp;&nbsp;</td>
	    <TD><INPUT TYPE="reset" VALUE="Reset" id=reset1 name=reset1></FORM></TD><td>&nbsp;&nbsp;&nbsp;</td>
	    <% If Session("OrganizationNumber") <> 1 Then %>
	    <TD><FORM ACTION="UserAdd.asp" METHOD="post"><INPUT TYPE="hidden" NAME="UserNumber" VALUE="<%= rsUser("UserNumber") %>"><INPUT TYPE="submit" VALUE="Copy User"></FORM></TD><td>&nbsp;&nbsp;&nbsp;</td>
	    <% End If %>
	    <TD><FORM ACTION="UserModify.asp" METHOD="post"><INPUT TYPE="hidden" NAME="UserAction" VALUE="Delete"><INPUT TYPE="hidden" NAME="UserNumber" VALUE="<%= rsUser("UserNumber") %>"><INPUT TYPE="submit" VALUE="Delete"></FORM></TD><td>&nbsp;&nbsp;&nbsp;</td>
	    <TD><input type="button" value="Return To Listing" onclick="location.href='/Management/UserMaintenance.asp';" /></TD>
	</TR>
</TABLE>

<%

Else

	Response.Write "<FONT FACE=verdana, arial, helvetica COLOR=#FF0000 SIZE=2>Invalid User</FONT><BR><BR>" & vbCrLf
	Response.Write "<FORM ACTION=UserMaintenance.asp METHOD=post><INPUT TYPE=submit VALUE=Back></FORM><BR>" & vbCrLf
	
End If

Call DBClose(OBJdbConnection2)

rsUser.Close
Set rsUser = Nothing

%>

</CENTER>

<!--#INCLUDE VIRTUAL="FooterInclude.asp"-->

</BODY>
</HTML>

<%

End Sub

'--------------------


Sub UpdateUser

OrganizationNumber = Session("OrganizationNumber")

'REE 5/18/12 - Disabled Updates for TestDrive Org.
If OrganizationNumber = 2 Then 'It's a TestDrive.  Do not update the User
    Message = "Updates to User Information is not available in the Test Drive"
    Call ModifyUser(Message)
    Exit Sub
End If

SQLUserNumber = "SELECT UserNumber FROM Users (NOLOCK) WHERE UserNumber = " & CleanNumeric(Request("UserNumber")) & " AND OrganizationNumber = " & OrganizationNumber
Set rsUserNumber = OBJdbConnection.Execute(SQLUserNumber)

If Not rsUserNumber.EOF Then
	UserNumber = rsUserNumber("UserNumber")
Else
	UserNumber = 0
End If

rsUserNumber.Close
Set rsUserNumber = nothing

If Clean(Request("Status")) <>  "" Then 
	StatusUpdate = ", Status = '" & Clean(Request("Status")) & "'"
Else
	StatusUpdate = ""
End If
If Clean(Request("UserType")) =  "TRUE" Then 
	UserType = "C"
Else
	UserType = ""
End If

SecretAnswer = ""
If Request("SecretQuestion") = "" Then
    If Request("SecretAnswer") <> "" Then
        SecretAnswer = ""
    End If
Else
    If Request("SecretAnswer") = "" Then
        Message = "Secret answer must be entered when secret question is selected"
	    Call ModifyUser(Message)
	    Exit Sub
    Else
        SecretAnswer = Clean(Request("SecretAnswer"))
    End If        
End If

'Make sure the UserID isn't already in the database.
SQLUser = "SELECT UserNumber FROM Users (NOLOCK) WHERE UserID = '" & Clean(Request("UserID")) & "' AND UserNumber <> '" & UserNumber & "'"
Set rsUser = OBJdbConnection.Execute(SQLUser)
If Not rsUser.EOF Then
	Message = "This User ID is already in use.  Please choose another User ID."
	Call ModifyUser(Message)
Else
    SecurityLog("Management - Modify User - User # Modified: " & CleanNumeric(Request("UserNumber")))

    'REE 6/27/12 - Log User Changes.
    ModifyDate = Now()

    'Get current values
    SQLUser = "SELECT FirstName, LastName, UserID, Password, UserType, EMailAddress, SecretQuestion, SecretAnswer FROM Users (NOLOCK) WHERE UserNumber = " & UserNumber
    Set rsUser = OBJdbConnection.Execute(SQLUser)
    If Not rsUser.EOF Then
        FirstNameB = rsUser("FirstName")
        LastNameB = rsUser("LastName")
        UserIDB = rsUser("UserID")
        PasswordB = rsUser("Password")
        UserTypeB = rsUser("UserType")
        EmailAddressB = rsUser("EmailAddress")
        SecretQuestionB = rsUser("SecretQuestion")
        SecretAnswerB = rsUser("SecretAnswer")
    End If
    rsUser.Close
    Set rsUser = nothing  
    
    'REE 7/27/12 - Added Password complexity check
    If PasswordB <> Clean(Request("Password1")) Then 'The password is being changed.  Make sure it meets the complexity requirements, if any.

        'REE 6/27/12 - Check for Password Restrictions
        SQLPasswordEnhanced = "SELECT OptionValue AS PW FROM OrganizationOptions (NOLOCK) INNER JOIN Users (NOLOCK) ON OrganizationOptions.OrganizationNumber = Users.OrganizationNumber WHERE UserNumber = " & UserNumber & " AND OptionName = 'UserPasswordEnhanced' AND OptionValue = 'Y'"
        Set rsPasswordEnhanced = OBJdbConnection.Execute(SQLPasswordEnhanced)

        If Not rsPasswordEnhanced.EOF Then
            PasswordEnhanced = "Y"
        End If

        rsPasswordEnhanced.Close
        Set rsPasswordEnhanced = nothing

        If PasswordEnhanced = "Y" Then

            'Make sure it's a strong password.
            If Not IsStrongPassword(Clean(Request("Password1"))) Then

                Message = "Password must be at least 8 characters long and include a combination of upper case letters, lower case letters, numbers, and special characters (#, !, %, etc.)"
                Call ModifyUser(Message)
                Exit Sub

            End If    	
            
            If Not IsValidPasswordUsage(UserNumber, Clean(Request("Password1")), "days", 540) Then            
            
                Message = "You must select a password that has not been used in the last 18 months."
                Call ModifyUser(Message)
                Exit Sub

            End If    	            

        End If    
    End If
    
    If FirstNameB <> Clean(Request("FirstName")) OR _
            LastNameB <> Clean(Request("LastName")) OR _
            UserIDB <> Clean(Request("UserID")) OR _
            PasswordB <> Clean(Request("Password1")) OR _
            UserTypeB <> UserType OR _
            EMailAddressB <> Clean(Request("EmailAddress")) OR _
            SecretQuestionB <> Clean(Request("SecretQuestion")) OR _
            SecretAnswerB <> SecretAnswer Then

        'Log the existing entry
        SQLLog = "INSERT UserHistory SELECT UserNumber, OrganizationNumber, UserID, Password, FirstName, LastName, DateEntered, Status, UserType, EmailAddress, SecretQuestion, SecretAnswer, '" & ModifyDate & "', 'Before', " & Session("UserNumber") & ", '" & Request.ServerVariables("REMOTE_ADDR") & "' FROM Users (NOLOCK) WHERE UserNumber = " & UserNumber
        Set rsLog = OBJdbConnection.Execute(SQLLog)
        
	    'SQLUpdateUser = "UPDATE Users WITH (ROWLOCK) SET FirstName = '" & Clean(Request("FirstName")) & "', LastName = '" & Clean(Request("LastName")) & "', UserID = '" & Clean(Request("UserID")) & "', Password = '" & Clean(Request("Password1")) & "', OrganizationNumber = '" & OrganizationNumber & "', UserType = '" & UserType & "'" & StatusUpdate & ", EMailAddress = '" & Clean(Request("EmailAddress")) & "', SecretQuestion = '" & Clean(Request("SecretQuestion")) & "', SecretAnswer = '" & SecretAnswer & "' WHERE UserNumber = " & UserNumber & " AND OrganizationNumber = " & Session("OrganizationNumber") & " AND UserNumber <> 1"
	    'Set rsUpdateUser = OBJdbConnection.Execute(SQLUpdateUser)

        Status = Clean(Request("Status"))
        CALL UpdateUserApi
	    
        'Log the new entry
        SQLLog = "INSERT UserHistory SELECT UserNumber, OrganizationNumber, UserID, Password, FirstName, LastName, DateEntered, Status, UserType, EmailAddress, SecretQuestion, SecretAnswer, '" & ModifyDate & "', 'After', " & Session("UserNumber") & ", '" & Request.ServerVariables("REMOTE_ADDR") & "' FROM Users (NOLOCK) WHERE UserNumber = " & UserNumber
        Set rsLog = OBJdbConnection.Execute(SQLLog)

    End If	    
	
	'REE 2/3/9 - Modified to delete all Security entries if User Org is Tix.
    SQLUserOrg = "SELECT OrganizationNumber FROM Users (NOLOCK) WHERE UserNumber = " & Session("UserNumber")
    Set rsUserOrg = OBJdbConnection.Execute(SQLUserOrg)

    UserOrg = rsUserOrg("OrganizationNumber")

    rsUserOrg.Close
    Set rsUserOrg = nothing
    
    'REE 6/27/12 - Log all existing security entries for this User.
    SQLLog = "INSERT SecurityHistory SELECT UserNumber, FunctionCode, Authorized, StatusDate, '" & ModifyDate & "', 'Before', " & Session("UserNumber") & ", '" & Request.ServerVariables("REMOTE_ADDR") & "' FROM Security (NOLOCK) WHERE UserNumber = " & UserNumber
    Set rsLog = OBJdbConnection.Execute(SQLLog)
	
	If UserOrg <> 1 Then 'The user is not Tix.  Delete only those entries that the session user has access to.
	    'Delete Existing Entries.  Do not delete anything that the Session User does not have access to.  This is in case the Session User has more limited access than the user being modified.
	    SQLDeleteSecurity = "DELETE Security WHERE UserNumber = " & CleanNumeric(Request("UserNumber")) & " AND FunctionCode IN (SELECT FunctionCode FROM Security (NOLOCK) WHERE UserNumber = " & Session("UserNumber") & " AND Authorized = 1)"
	Else 'It's a Tix user.  Delete all entries.
	    SQLDeleteSecurity = "DELETE Security WHERE UserNumber = " & CleanNumeric(Request("UserNumber"))
	End If
	Set rsDeleteSecurity = OBJdbConnection.Execute(SQLDeleteSecurity)
	
	'Add New Entries
	For Each FunctionCode in Request("UserSecurity")

		SQLInsertSecurity = "INSERT Security (UserNumber, FunctionCode, Authorized, StatusDate) VALUES(" & UserNumber & ", '" & Clean(FunctionCode) & "', 1, GETDATE())"
		Set rsInsertSecurity = OBJdbConnection.Execute(SQLInsertSecurity)
		
	Next

    'REE 6/27/12 - Log all new security entries for this User.
    SQLLog = "INSERT SecurityHistory SELECT UserNumber, FunctionCode, Authorized, StatusDate, '" & ModifyDate & "', 'After', " & Session("UserNumber") & ", '" & Request.ServerVariables("REMOTE_ADDR") & "' FROM Security (NOLOCK) WHERE UserNumber = " & UserNumber
    Set rsLog = OBJdbConnection.Execute(SQLLog)

	Response.Redirect("/Management/UserMaintenance.asp")
	'Response.Redirect("UserModify.asp?UserNumber=" & UserNumber)

End If

rsUser.Close
Set rsUser = Nothing

End Sub 'UpdateUser

'--------------------

Sub DeleteUser

SecurityLog("Management - Delete User - User # Deleted: " & CleanNumeric(Request("UserNumber")))

ModifyDate = Now()

'Log the existing entry
SQLLog = "INSERT UserHistory SELECT UserNumber, OrganizationNumber, UserID, Password, FirstName, LastName, DateEntered, Status, UserType, EmailAddress, SecretQuestion, SecretAnswer, '" & ModifyDate & "', 'Before', " & Session("UserNumber") & ", '" & Request.ServerVariables("REMOTE_ADDR") & "' FROM Users (NOLOCK) WHERE UserNumber = " & CleanNumeric(Request("UserNumber"))
Set rsLog = OBJdbConnection.Execute(SQLLog)

'SQLDeleteUser = "UPDATE Users WITH (ROWLOCK) SET Status = 'D' WHERE UserNumber = " & CleanNumeric(Request("UserNumber")) & " AND OrganizationNumber = " & Session("OrganizationNumber") & " AND UserNumber <> 1"
'Set rsDeleteUser = OBJdbConnection.Execute(SQLDeleteUser)
Status = "D"
CALL UpdateUserApi

'Log the new entry
SQLLog = "INSERT UserHistory SELECT UserNumber, OrganizationNumber, UserID, Password, FirstName, LastName, DateEntered, Status, UserType, EmailAddress, SecretQuestion, SecretAnswer, '" & ModifyDate & "', 'After', " & Session("UserNumber") & ", '" & Request.ServerVariables("REMOTE_ADDR") & "' FROM Users (NOLOCK) WHERE UserNumber = " & CleanNumeric(Request("UserNumber"))
Set rsLog = OBJdbConnection.Execute(SQLLog)

Response.Redirect("UserMaintenance.asp")

End Sub

Sub UpdateUserApi
    Fingerprint=EncryptAes(Session("OrganizationNumber") & "|" & Session("UserNumber") & "|" & FormatDateTime(Now))
    Dim updateUserUrl: updateUserUrl = Application("CONFIG_WEB_UPDATEUSERURL")
    Dim payload: payload = "{""UserId"":""" & Clean(Request("UserID")) & """,""OrganizationNumber"":""" & Session("OrganizationNumber") & """,""FirstName"":""" & Clean(Request("FirstName")) & """,""LastName"":""" & Clean(Request("LastName")) & """,""UserType"":""" & UserType & """,""SecretQuestion"":""" & Clean(Request("SecretQuestion")) & """,""SecretAnswer"":""" & SecretAnswer & """,""EmailAddress"":""" & Clean(Request("EmailAddress")) & """,""Status"":""" & Status & """,""Password"":""" & Clean(Request("Password1")) & """,""UserNumber"":""" &  CleanNumeric(Request("UserNumber")) & """,""DateEntered"":""" & Now() & """,""Fingerprint"":""" & FingerPrint & """}"
    Set updateUserRequest = Server.CreateObject("MSXML2.ServerXMLHTTP")
    updateUserRequest.Open "POST", updateUserUrl, False
    updateUserRequest.setRequestHeader "Content-type","application/json"
    updateUserRequest.setRequestHeader "Accept","application/json"
    updateUserRequest.Send payload

End Sub
%>

