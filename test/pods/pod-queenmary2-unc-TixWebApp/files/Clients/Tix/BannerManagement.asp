<!--#INCLUDE VIRTUAL=GlobalInclude.asp -->
<!--#INCLUDE VIRTUAL="dbOpenInclude.asp"-->
<%
'CHANGE LOG
'REE 3/25/12 - Separated Management Banner into its own script.
'JAI 5/30/12 - Added table width 100%
'REE 6/4/12 - Added TixManagementContent div
'REE 10/10/12 - Converted Nav Menu from Superfish to MegaMenu.  Added drop down menu items.
'REE 10/17/12 - Fixed Center alignment issues in Chrome.
'REE 10/20/12 - Added Session Org to Menu SQL criteria
'REE 10/13/12 - Added Folder names for Management and Ticket Sales Menu options
'REE 10/24/12 - Hiding menu until loaded.
'REE 11/1/12 - Show main menu options (Management Menu, Ticket Sales, Report Menu, Custom Menus automatically on load for temporary menu ( during page loading) and for browsers without Javascript enabled.
'REE 11/5/12 - Added Log Off button to Temp Menu.
'REE 11/7/12 - Added Management Search.  Moved log out to link above menu bar.
'GGB 12/11/2012 - Changed OrgnizationMaintenance to OrginazationSettings
'REE 1/4/13 - Added Organization Tooltip
'REE 11/14/14 - Added Management Submenus and CRM Menu.  Replaced Shopping Cart menu button with icon. Removed hardcoded folder names. Moved User/Org/Logout line to top.
'REE 11/20/14 - Fix shopping cart alignment issue for IE in compatibility mode.
'JAI 12/10/14 - Redirect to https if not currently set.
'JAI 6/4/15 - Changed SecurityCheck for CustomerInquiry to CustomerLookup
'REE 6/18/15 - Added Google Tracking Code

Dim TempMenu

'Redirect to https if not set.  Ensures all Management pages which use TopNavInclude are secure.
If  Request.ServerVariables("HTTPS") <> "on" And Request.ServerVariables("Server_Port") <> "81" Then
    RedirectPage = True
End If
If RedirectPage Then
	ServerName = Request.ServerVariables("SERVER_NAME")
	PathInfo = Request.ServerVariables("PATH_INFO")
	QueryString = Request.ServerVariables("QUERY_STRING")
	Response.Redirect("https://" & SubDomain & ServerName & PathInfo & "?" & QueryString)
End If	

'Section used for Management Top Nav
If Session("UserNumber") = "" Then
    LogInName = ""
    ManagementLogOff = ""
Else

    TooltipIncludeFlag = "Y"

    If SecurityCheck("OrderLookup") Then 
        boolOrderLookup = True
    Else
        boolOrderLookup = False   
    End If                     
    If SecurityCheck("CustomerLookup") Then 
        boolCustomerInquiry = True
    Else
        boolCustomerInquiry = False
    End If                        

    If boolOrderLookup = True Or boolCustomerInquiry = True Then

        If boolOrderLookup = True And boolCustomerInquiry = True Then

            SearchPlaceholder = "Order #, Customer, etc."

        ElseIf boolOrderLookup = True Then

            SearchPlaceholder = "Enter Order Number"

        ElseIf boolCustomerInquiry = True Then

            SearchPlaceholder = "Customer Name, etc."

        End If

        SearchForm = "<li style=""padding: 7px; float: right;""><form method=""post"" action=""/Reports/ManagementSearch.aspx"" style=""display: inline;""><input type=""text"" name=""keyword"" placeholder=""" & SearchPlaceholder & """ size=""20"" class=""placeholder"" />&nbsp;&nbsp;<input id=""btnSearch"" type=""submit"" value=""Search"" /></form></li>"

    End If
    
    Call DBOpen(OBJdbConnectionTNI1)
    'REE 10/21/3 - Added Organization Name to Banner
    SQLName = "SELECT FirstName, LastName, Organization.OrganizationNumber, Organization FROM Users (NOLOCK) INNER JOIN Organization (NOLOCK) ON Users.OrganizationNumber = Organization.OrganizationNumber WHERE UserNumber = " & Session("UserNumber")
    Set rsName = OBJdbConnectionTNI1.Execute(SQLName)
    OrgFirstName = rsName("FirstName")
    OrgLastName = rsName("LastName")
    OrgOrgNumber = rsName("OrganizationNumber")
    OrgOrganization = rsName("Organization")
    rsName.Close
    Set rsName = nothing
		
    'If Organization is Tix, Check Session Organization.  Tix users have the ability to change Session Organizations.
    If OrgOrgNumber = 1 Then 'It's Tix
        SQLOrg = "SELECT Organization FROM Organization (NOLOCK) WHERE OrganizationNumber = " & Session("OrganizationNumber")
        Set rsOrg = OBJdbConnectionTNI1.Execute(SQLOrg)
        OrgOrganization = rsOrg("Organization")
        rsOrg.Close
        Set rsOrg = nothing
			
        'REE 11/15/3 - Added link for Tix users to change organization.
        'REE 1/17/6 - Added Org Number to display.
        LogInName = OrgFirstName & " " & OrgLastName & " is logged on&nbsp;&nbsp;<a href=""/Management/LogOff.asp"">(Log Off)</a>"
        'REE 1/4/13 - Added Organization Tooltip
        Organization = "<A HREF=""/Management/OrganizationSessionChange.asp"" onmouseover=""ttDelay=setTimeout('eventTooltip(\'/AJAX/OrganizationInfo.asp?OrganizationNumber=" & Session("OrganizationNumber") & "\', this)', 200);"" onmouseout=""clearTimeout(ttDelay);hideTooltip();"">" & OrgOrganization & "</A> (<A HREF=/Management/OrganizationSettings.aspx?OrganizationNumber=" & Session("OrganizationNumber") & " onmouseover=""ttDelay=setTimeout('eventTooltip(\'/AJAX/OrganizationInfo.asp?OrganizationNumber=" & Session("OrganizationNumber") & "\', this)', 200);"" onmouseout=""clearTimeout(ttDelay);hideTooltip();"">" & Session("OrganizationNumber") & "</A>)"
        'REE 4/25/5 - Added link to switch back to Tix organization if it's not already.
        If Session("OrganizationNumber") <> 1 Then
	        Organization = Organization & "&nbsp;(<A HREF=""/Management/OrganizationSessionChange.asp?OrganizationNumber=1"">TIX</A>)"
        End If				
        LogInName = LoginName
    Else
        LogInName = OrgFirstName & " " & OrgLastName & " is logged on&nbsp;&nbsp;<a href=""/Management/LogOff.asp"">(Log Off)</a>"
        Organization = OrgOrganization
    End If
		
    Call DBClose(OBJdbConnectionTNI1)

    Select Case Session("OrderTypeNumber")
    Case 1
        OrderType = "Internet Sales"
    Case 2
        OrderType = "Phone Order Sales"
    Case 3
        OrderType = "Fax Order Sales"
    Case 4
        OrderType = "Mail Order Sales"
    Case 5
        OrderType = "Comp Sales"
    Case 7
        OrderType = "Box Office Sales"
    Case Else
        OrderType = "&nbsp;"
    End Select
		
End If	

If Session("OrderNumber") <> "" Then
    ShoppingCartLink = "<a href=""/management/shoppingcart.asp""><img src=""/images/shoppingcarticon.png"" alt=""Shopping Cart"" title=""Shopping Cart"" border=""0"" /></a>"
Else
    ShoppingCartLink = ""
End If

Function LoadMenu(MenuName)

    LoadMenu = ""
    
    If Session("UserNumber") <> "" Then

        MenuItems = ""
        
        Select Case MenuName
            Case "ReportMenu"
                SQLMenu = "SELECT SecurityMenu.MenuName, SecurityMenu.FunctionDescription, ProgramName, IsNull(MenuOptionDescription.Description,'') AS Description FROM SecurityMenu WITH (NOLOCK) INNER JOIN Security WITH (NOLOCK) ON SecurityMenu.FunctionCode = Security.FunctionCode LEFT JOIN MenuOptionDescription WITH (NOLOCK) ON SecurityMenu.FunctionCode = MenuOptionDescription.FunctionCode WHERE Security.UserNumber = " & Session("UserNumber") & " AND SecurityMenu.MenuName IN ('ReportMenuFinancial', 'ReportMenuMarketing', 'ReportMenuOperations', 'ReportMenuSales') AND SecurityMenu.OrganizationNumber IN (0," & Session("OrganizationNumber") & ") AND Security.Authorized = 1 ORDER BY SecurityMenu.MenuName, SecurityMenu.FunctionDescription"
            Case "CustomMenu"
                SQLUserOrg = "SELECT OrganizationNumber FROM Users (NOLOCK) WHERE UserNumber = " & Session("UserNumber")
                Set rsUserOrg = OBJdbConnection.Execute(SQLUserOrg)

                UserOrg = rsUserOrg("OrganizationNumber")

                rsUserOrg.Close
                Set rsUserOrg = nothing

                If UserOrg <> 1 Then
                    SQLMenu = "SELECT SecurityMenu.MenuName, SecurityMenu.FunctionDescription, SecurityMenu.ProgramName, IsNull(MenuOptionDescription.Description,'') AS Description FROM SecurityMenu (NOLOCK) INNER JOIN Security (NOLOCK) ON SecurityMenu.FunctionCode = Security.FunctionCode LEFT JOIN MenuOptionDescription WITH (NOLOCK) ON SecurityMenu.FunctionCode = MenuOptionDescription.FunctionCode WHERE SecurityMenu.Menuname = 'CustomMenu' AND Security.UserNumber = " & Session("UserNumber") & " AND Security.Authorized = 1 AND SecurityMenu.OrganizationNumber = " & Session("OrganizationNumber") & " ORDER BY SecurityMenu.FunctionDescription"
                Else
                    SQLMenu = "SELECT SecurityMenu.MenuName, SecurityMenu.FunctionDescription, SecurityMenu.ProgramName, IsNull(MenuOptionDescription.Description,'') AS Description FROM SecurityMenu (NOLOCK) LEFT JOIN MenuOptionDescription WITH (NOLOCK) ON SecurityMenu.FunctionCode = MenuOptionDescription.FunctionCode WHERE SecurityMenu.MenuName = 'CustomMenu' AND SecurityMenu.OrganizationNumber IN (1, " & Session("OrganizationNumber") & ") AND (SecurityMenu.OrganizationNumber = 1 AND SecurityMenu.FunctionCode IN (SELECT FunctionCode FROM Security (NOLOCK) WHERE UserNumber = " & Session("UserNumber") & " AND Authorized = 1) OR SecurityMenu.OrganizationNumber <> 1) ORDER BY SecurityMenu.OrganizationNumber, SecurityMenu.FunctionDescription"
                End If      
            Case Else
                SQLMenu = "SELECT SecurityMenu.MenuName, SecurityMenu.FunctionDescription, ProgramName, IsNull(MenuOptionDescription.Description,'') AS Description, SecurityMenu.SubMenuName FROM SecurityMenu WITH (NOLOCK) INNER JOIN Security WITH (NOLOCK) ON SecurityMenu.FunctionCode = Security.FunctionCode LEFT JOIN MenuOptionDescription WITH (NOLOCK) ON SecurityMenu.FunctionCode = MenuOptionDescription.FunctionCode WHERE Security.UserNumber = " & Session("UserNumber") & " AND SecurityMenu.MenuName = '" & MenuName & "' AND SecurityMenu.OrganizationNumber IN (0," & Session("OrganizationNumber") & ") AND Security.Authorized = 1 ORDER BY SecurityMenu.FunctionDescription"
        End Select            
        Set rsMenu = OBJdbConnection.Execute(SQLMenu)
        
        Do Until rsMenu.EOF
        
            If rsMenu("Description") <> "" Then
                ToolTip = " onmouseover=""TixTooltip('<b>" & rsMenu("FunctionDescription") & "</b> - " & rsMenu("Description") & "',this);"" onmouseout=""hideTooltip();"""
            Else
                Tooltip = ""            
            End If

            Select Case rsMenu("MenuName")
                Case "ManagementMenu"
                    Select Case rsMenu("SubMenuName")
                        Case "Administration"
                            ManagementMenuItemsAdministration = ManagementMenuItemsAdministration & "<li><a href=""" & rsMenu("ProgramName") & """" & ToolTip & ">" & rsMenu("FunctionDescription") & "</a></li>" & vbCrLf
                        Case "Financial"
                            ManagementMenuItemsFinancial = ManagementMenuItemsFinancial & "<li><a href=""" & rsMenu("ProgramName") & """" & ToolTip & ">" & rsMenu("FunctionDescription") & "</a></li>" & vbCrLf
                        Case "Marketing"
                            ManagementMenuItemsMarketing = ManagementMenuItemsMarketing & "<li><a href=""" & rsMenu("ProgramName") & """" & ToolTip & ">" & rsMenu("FunctionDescription") & "</a></li>" & vbCrLf
                        Case "Operations"
                            ManagementMenuItemsOperations = ManagementMenuItemsOperations & "<li><a href=""" & rsMenu("ProgramName") & """" & ToolTip & ">" & rsMenu("FunctionDescription") & "</a></li>" & vbCrLf
                    End Select
                Case "ReportMenuFinancial"
                    ReportMenuItemsFinancial = ReportMenuItemsFinancial & "<li><a href=""" & rsMenu("ProgramName") & """" & ToolTip & ">" & rsMenu("FunctionDescription") & "</a></li>" & vbCrLf
                Case "ReportMenuMarketing"
                    ReportMenuItemsMarketing = ReportMenuItemsMarketing & "<li><a href=""" & rsMenu("ProgramName") & """" & ToolTip & ">" & rsMenu("FunctionDescription") & "</a></li>" & vbCrLf
                Case "ReportMenuOperations"
                    ReportMenuItemsOperations = ReportMenuItemsOperations & "<li><a href=""" & rsMenu("ProgramName") & """" & ToolTip & ">" & rsMenu("FunctionDescription") & "</a></li>" & vbCrLf
                Case "ReportMenuSales"
                    ReportMenuItemsSales = ReportMenuItemsSales & "<li><a href=""" & rsMenu("ProgramName") & """" & ToolTip & ">" & rsMenu("FunctionDescription") & "</a></li>" & vbCrLf
                Case "CRM"
                    Select Case rsMenu("SubMenuName")
                        Case "Management"
                            CRMMenuItemsManagement = CRMMenuItemsManagement & "<li><a href=""" & rsMenu("ProgramName") & """" & ToolTip & ">" & rsMenu("FunctionDescription") & "</a></li>" & vbCrLf
                        Case "Reports"
                            CRMMenuItemsReports = CRMMenuItemsReports & "<li><a href=""" & rsMenu("ProgramName") & """" & ToolTip & ">" & rsMenu("FunctionDescription") & "</a></li>" & vbCrLf
                    End Select
                Case "TicketSalesMenu"
                    MenuItems = MenuItems & "<li><a href=""" & rsMenu("ProgramName") & """" & ToolTip & ">" & rsMenu("FunctionDescription") & "</a></li>" & vbCrLf
                Case Else
                    MenuItems = MenuItems & "<li><a href=""" & rsMenu("ProgramName") & """" & ToolTip & ">" & rsMenu("FunctionDescription") & "</a></li>" & vbCrLf
            End Select
            
            ItemCount = ItemCount + 1

            rsMenu.MoveNext
        Loop

        rsMenu.Close
        Set rsMenu = nothing
        
        If ItemCount > 0 Then

            Select Case MenuName
                Case "ManagementMenu"
                    LoadMenu = "<li><a href=""/Management/Default.asp"">Management Menu</a>" & vbCrLf & vbCrLf
                    LoadMenu = LoadMenu & "<ul>" & vbCrLf
                    If ManagementMenuItemsAdministration <> "" Then
                        LoadMenu = LoadMenu & "<li><a href=""#"">Administration</a>" & vbCrLf
                        LoadMenu = LoadMenu & "<ul>" & ManagementMenuItemsAdministration & "</ul></li>" & vbCrLf & vbCrLf
                    End If
                    If ManagementMenuItemsFinancial <> "" Then
                        LoadMenu = LoadMenu & "<li><a href=""#"">Financial</a>" & vbCrLf
                        LoadMenu = LoadMenu & "<ul>" & ManagementMenuItemsFinancial & "</ul></li>" & vbCrLf & vbCrLf
                    End If
                    If ManagementMenuItemsMarketing <> "" Then
                        LoadMenu = LoadMenu & "<li><a href=""#"">Marketing</a>" & vbCrLf
                        LoadMenu = LoadMenu & "<ul>" & ManagementMenuItemsMarketing & "</ul></li>" & vbCrLf & vbCrLf
                    End If
                    If ManagementMenuItemsOperations <> "" Then
                        LoadMenu = LoadMenu & "<li><a href=""#"">Operations</a>" & vbCrLf
                        LoadMenu = LoadMenu & "<ul>" & ManagementMenuItemsOperations & "</ul></li>" & vbCrLf & vbCrLf
                    End If
                    LoadMenu = LoadMenu & "</ul></li>" & vbCrLf
                    FooterManagementMenuLink = "<a href=""/Management/Default.asp"">Management Menu</a>"
                    LoadMenu = LoadMenu & "<ul>" & MenuItems & "</ul></li>" & vbCrLf & vbCrLf
                    TempMenu = TempMenu & "<li><a href=""/Management/Default.asp"">Management Menu</a></li>" & vbCrLf
                Case "TicketSalesMenu"
                    LoadMenu = "<li><a href=""/Management/TicketSalesMenu.asp"">Ticket Sales</a>" & vbCrLf & vbCrLf
                    FooterTicketSalesMenuLink = "<a href=""/Management/TicketSalesMenu.asp"">Ticket Sales</a>"
                    LoadMenu = LoadMenu & "<ul>" & MenuItems & "</ul></li>" & vbCrLf & vbCrLf
                    TempMenu = TempMenu & "<li><a href=""/Management/TicketSalesMenu.asp"">Ticket Sales</a></li>" & vbCrLf & vbCrLf
                Case "ReportMenu"
                    LoadMenu = "<li><a href=""/Reports/Default.asp"">Report Menu</a>" & vbCrLf & vbCrLf
                    LoadMenu = LoadMenu & "<ul>" & vbCrLf
                    If ReportMenuItemsFinancial <> "" Then
                        LoadMenu = LoadMenu & "<li><a href=""#"">Financial Reports</a>" & vbCrLf
                        LoadMenu = LoadMenu & "<ul>" & ReportMenuItemsFinancial & "</ul></li>" & vbCrLf & vbCrLf
                    End If
                    If ReportMenuItemsMarketing <> "" Then
                        LoadMenu = LoadMenu & "<li><a href=""#"">Marketing Reports</a>" & vbCrLf
                        LoadMenu = LoadMenu & "<ul>" & ReportMenuItemsMarketing & "</ul></li>" & vbCrLf & vbCrLf
                    End If
                    If ReportMenuItemsOperations <> "" Then
                        LoadMenu = LoadMenu & "<li><a href=""#"">Operations Reports</a>" & vbCrLf
                        LoadMenu = LoadMenu & "<ul>" & ReportMenuItemsOperations & "</ul></li>" & vbCrLf & vbCrLf
                    End If
                    If ReportMenuItemsSales <> "" Then
                        LoadMenu = LoadMenu & "<li><a href=""#"">Sales Reports</a>" & vbCrLf
                        LoadMenu = LoadMenu & "<ul>" & ReportMenuItemsSales & "</ul></li>" & vbCrLf & vbCrLf
                    End If
                    LoadMenu = LoadMenu & "</ul></li>" & vbCrLf
                    FooterReportMenuLink = "<a href=""/Reports/Default.asp"">Report Menu</a>"
                    TempMenu = TempMenu & "<li><a href=""/Reports/Default.asp"">Report Menu</a></li>" & vbCrLf & vbCrLf
                Case "CRM"
                    LoadMenu = "<li><a href=""/Management/CRMMenu.asp"">CRM</a>" & vbCrLf & vbCrLf
                    LoadMenu = LoadMenu & "<ul>" & vbCrLf
                    If CRMMenuItemsManagement <> "" Then
                        LoadMenu = LoadMenu & "<li><a href=""#"">Management</a>" & vbCrLf
                        LoadMenu = LoadMenu & "<ul>" & CRMMenuItemsManagement & "</ul></li>" & vbCrLf & vbCrLf
                    End If
                    If CRMMenuItemsReports <> "" Then
                        LoadMenu = LoadMenu & "<li><a href=""#"">Reports</a>" & vbCrLf
                        LoadMenu = LoadMenu & "<ul>" & CRMMenuItemsReports & "</ul></li>" & vbCrLf & vbCrLf
                    End If
                    LoadMenu = LoadMenu & "</ul></li>" & vbCrLf
                    FooterReportMenuLink = "<a href=""/Reports/Default.asp"">Report Menu</a>"
                    TempMenu = TempMenu & "<li><a href=""/Reports/Default.asp"">Report Menu</a></li>" & vbCrLf & vbCrLf
                Case "CustomMenu"
                    LoadMenu = "<li><a href=""/Management/CustomMenu.asp"">Custom Menu</a>" & vbCrLf & vbCrLf
                    LoadMenu = LoadMenu & "<ul>" & MenuItems & "</ul></li>" & vbCrLf & vbCrLf
                    FooterCustomMenuLink = "<a href=""/Management/CustomMenu.asp"">Custom Menu</a>"
                    TempMenu = TempMenu & "<li><a href=""/Management/CustomMenu.asp"">Custom Menu</a></li>" & vbCrLf & vbCrLf
            End Select         
            
        End If            
            
    End If
    
End Function

%>


<link rel="SHORTCUT ICON" href="/Images/FavIcon.ico" />
<link rel="stylesheet" href="/clients/tix/css/stylemanagement.css" type="text/css" />
<link href="/clients/tix/css/dcmegamenu.css" rel="stylesheet" type="text/css" />
<link href="/clients/tix/css/skins/tix.css" rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="/javascript/jquery-1.8.2.js"></script>
    <script type='text/javascript' src='/JavaScript/jquery.hoverIntent.minified.js'></script>
    <script type='text/javascript' src='/clients/tix/js/jquery.dcmegamenu.1.3.3.js'></script>
    <script type="text/javascript">
        $(document).ready(function ($) {
            var tixNav = document.getElementById('TixNav');
            tixNav.style.display = 'block';
            var tixNavTemp = document.getElementById('TixNavTemp');
            tixNavTemp.style.display = 'none';
            $('#menu').dcMegaMenu({
                rowItems: '4',
                speed: 'fast',
                effect: 'fade'
            });
        });
    </script>

    <script>
    // This adds 'placeholder' to the items listed in the jQuery .support object. 
    jQuery(function() {
      jQuery.support.placeholder = false;
      textBox = document.createElement('input');
      if('placeholder' in textBox) jQuery.support.placeholder = true;
    });
    // This adds placeholder support to browsers that wouldn't otherwise support it. 
    $(function() {
      if(!$.support.placeholder) { 
       var active = document.activeElement;
       $('.placeholder').focus(function () {
         if ($(this).attr('placeholder') != '' && $(this).val() == $(this).attr('placeholder')) {
          $(this).val('').removeClass('hasPlaceholder');
         }
       }).blur(function () {
         if ($(this).attr('placeholder') != '' && ($(this).val() == '' || $(this).val() == $(this).attr('placeholder'))) {
          $(this).val($(this).attr('placeholder')).addClass('hasPlaceholder');
         }
       });
       $('.placeholder').blur();
       $(active).focus();
       $('form:eq(0)').submit(function () {
         $('.placeholder.hasPlaceholder').val('');
       });
      }
    });
    </script>

    <!-- Google Tracking Code -->
    <script>
      (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
      (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
      m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
      })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

      ga('create', 'UA-63226316-1', 'auto');
      ga('send', 'pageview');

    </script>

    <style type="text/css">
    .hasPlaceholder {
      color: #777;
    }
    </style>
<center>

<br />
<div style="background: #e0e0e0 url('/clients/tix/images/bg-row-1.png') no-repeat; width: 990px; height: 117px;">
    <div style="position: relative; float: left; padding: 20px 0px 0px 70px;"><img src="/clients/tix/images/tixlogoitstheticket.gif" alt="Tix - It's the Ticket!" /></div>
	<div style="position: relative; float: right; padding: 30px 5px 0px 0px;"><%= ShoppingCartLink %></div>
    <div style="position: relative; float: right; padding: 0px 100px 0px 0px;"><%= Organization %>&nbsp;&nbsp;<%= OrderType %>&nbsp;&nbsp;<%= LogInName %></div>
</div>

<div class="white" style="display: none;" id="TixNav">
    <ul id="menu" class="mega-menu" style="width: 990px; list-style: none;" >
        <%= LoadMenu("ManagementMenu") %>
        <%= LoadMenu("TicketSalesMenu") %>
        <%= LoadMenu("ReportMenu") %>
        <%= LoadMenu("CRM") %>
        <%= LoadMenu("CustomMenu") %>
        <%= SearchForm %>
    </ul>
</div>

<div class="white" id="TixNavTemp">
    <ul class="mega-menu" style="width: 990px;background-color:white; list-style: none;">
        <%= TempMenu %>
        <%= SearchForm %>
    </ul>
</div>
    

<table style="width: 100%;" cellpadding="0" cellspacing="0">
    <tr>
        <td align="center">
            <table width="990px" style="background-color: White;">
                <tr>
                    <td align="center"><div class="TixManagementContent">                    


            