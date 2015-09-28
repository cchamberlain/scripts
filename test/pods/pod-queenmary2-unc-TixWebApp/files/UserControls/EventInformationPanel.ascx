<%
    'CHANGE LOG
    'TTT 5/16/11 - Removed User Control ClassName since it's irrevelant and causes ambiguous reference
    'TTT 12/12/11 - Added Date/Time Suppress and Act Suffix
    'TTT 1/8/13 - Modified to fix issue with DBNull for event info
    'TTT 11/13/14 - Modified to use isSmallScreen function instead of SubDomain for Mobile
    'TTT 9/23/15 - Modified to add ability to add to Calendar and change usercontrol caching to a minute
%>
<%@ Control Language="VB" %>
<%@ Import Namespace="GlobalClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ OutputCache Duration="60" VaryByParam="*" %>

<script runat="server">
    Protected EventDate As DateTime
    Protected EventTitle, EventDescription, EventLocation As String
    
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        
        Dim EventCode As Long = CLng(CleanNumeric(Request("EventCode")))

        Dim DBTix As New SqlConnection
        Dim DBCmd As New SqlCommand
        Dim DataReader As SqlDataReader

        DBOpen(DBTix)

        Dim SQLEvent As String = "SELECT Act, IsNull(Act.Comments, '') AS ActComments, DATENAME(dw, Event.EventDate) AS WeekdayName, Event.EventDate, IsNull(Event.Comments, '') As EventComments, Event.Phone, Event.EMailAddress, Event.URL, Venue.Venue, Venue.Address_1, Venue.Address_2, Venue.City, Venue.State, Venue.Zip_Code, Venue.Country, Event.Map, SelectTicketsButton, BestAvailableButton, SaleDates.SaleStartDate AS SaleStartDate, SaleDates.SaleEndDate AS SaleEndDate, Event.OnSale, IsNull(TicketCount.TicketCount,0) AS TicketCount, OrganizationNumber, DateSuppress.DateSuppress, TimeSuppress.TimeSuppress, ActSuffix.ActSuffix, COALESCE (Act.Act + ActSuffix.ActSuffix, Act.Act) AS Act2 FROM Act WITH (NOLOCK) INNER JOIN Event WITH (NOLOCK) ON Act.ActCode = Event.ActCode INNER JOIN Venue WITH (NOLOCK) ON Event.VenueCode = Venue.VenueCode LEFT JOIN (SELECT EventCode, COUNT(ItemNumber) AS TicketCount FROM Seat WITH (NOLOCK) WHERE Seat.EventCode = @EventCode AND Seat.StatusCode = 'A' GROUP BY EventCode) AS TicketCount ON Event.EventCode = TicketCount.EventCode INNER JOIN vOrgEvent WITH (NOLOCK) ON Event.EventCode = vOrgEvent.EventCode INNER JOIN (SELECT EventCode, MIN(SaleStartDate) AS SaleStartDate, MAX(SaleEndDate) AS SaleEndDate FROM (SELECT Event.EventCode, Event.SaleStartDate, Event.SaleEndDate From Event WITH (NOLOCK) WHERE EventCode = @EventCode UNION SELECT MemberSaleStartDate.EventCode, MemberSaleStartDate.MemberSaleStartDate AS SaleStartDate, MemberSaleStartDate.MemberSaleEndDate AS SaleEndDate FROM MemberSaleStartDate WITH (NOLOCK) WHERE MemberSaleStartDate.EventCode = @EventCode AND MemberSaleStartDate.MemberType = @MemberType) AS SaleDateUnion GROUP BY SaleDateUnion.EventCode) AS SaleDates ON Event.EventCode = SaleDates.EventCode LEFT OUTER JOIN (SELECT EventCode, OptionValue AS DateSuppress FROM EventOptions WITH (NOLOCK) WHERE (OptionName = 'DateSuppress')) AS DateSuppress ON Event.EventCode = DateSuppress.EventCode LEFT OUTER JOIN (SELECT EventCode, OptionValue AS TimeSuppress FROM EventOptions AS EventOptions_2 WITH (NOLOCK) WHERE (OptionName = 'TimeSuppress')) AS TimeSuppress ON Event.EventCode = TimeSuppress.EventCode LEFT OUTER JOIN (SELECT EventCode, COALESCE (' - ' + OptionValue, '') AS ActSuffix FROM EventOptions AS EventOptions_1 WITH (NOLOCK) WHERE (OptionName = 'ActSuffix')) AS ActSuffix ON Event.EventCode = ActSuffix.EventCode WHERE Event.EventCode = @EventCode AND vOrgEvent.Owner = 1"
        DBCmd = New SqlCommand(SQLEvent, DBTix)
        DBCmd.Parameters.AddWithValue("@EventCode", EventCode)

        Dim MemberType As String = ""
        If Session("MemberType") <> "" Then
            MemberType = Session("MemberType")
        End If
        DBCmd.Parameters.AddWithValue("@MemberType", MemberType)

        DataReader = DBCmd.ExecuteReader()

        If DataReader.HasRows Then
            DataReader.Read()
            
            EventDate = LocalDateTime(EventOwner(EventCode), CDate(DataReader("EventDate")))
            EventTitle = DataReader("Act").ToString() & " At " & DataReader("Venue").ToString()
            EventLocation = DataReader("Address_1").ToString & ", " & DataReader("City").ToString & ", " & DataReader("State").ToString() & " " & DataReader("Zip_Code").ToString()
            EventDescription = If(DataReader("ActComments").ToString() <> "", DataReader("ActComments").ToString(), DataReader("EventComments").ToString())
            EventDescription &= "<BR><BR>http://" & Request.ServerVariables("SERVER_NAME") & "/Event.aspx?EventCode=" & EventCode
            
            EventHeaderLabel.Text = "Information"
            EventHeaderLabel.Visible = True
            'EventHeaderLabel.Font.Size = "10"
            EventHeaderLabel.Font.Bold = "True"
            EventContentLabel.Text = "<b>" & DataReader("Act2") & "</b><br /><br />"
            
            If DataReader("DateSuppress").ToString() <> "Y" Then
                EventContentLabel.Text &= "Date: " & String.Format("{0:D}", DataReader("EventDate")) & "<br />"
            End If
            If DataReader("TimeSuppress").ToString() <> "Y" Then
                EventContentLabel.Text &= "Time: " & String.Format("{0:t}", DataReader("EventDate")) & "<br />"
            End If
            
            EventContentLabel.Text &= "<br />" & DataReader("Venue") & "<br />"
            If Not String.IsNullOrEmpty(DataReader("Address_1").ToString()) Then
                EventContentLabel.Text &= DataReader("Address_1") & "<br />"
            End If
            If Not String.IsNullOrEmpty(DataReader("Address_2").ToString()) Then
                EventContentLabel.Text &= DataReader("Address_2") & "<br />"
            End If
            If Not String.IsNullOrEmpty(DataReader("City").ToString()) Then
                EventContentLabel.Text &= DataReader("City") & ", "
            End If
            If Not String.IsNullOrEmpty(DataReader("State").ToString()) Then
                EventContentLabel.Text &= DataReader("State") & " "
            End If
            If Not String.IsNullOrEmpty(DataReader("Zip_Code").ToString()) Then
                EventContentLabel.Text &= DataReader("Zip_Code") & "<br />"
            End If
            If Not IsDBNull(DataReader("Address_1")) And Not IsDBNull(DataReader("Zip_Code")) Then
                Dim MapAddress As String
                MapAddress = Replace(DataReader("Address_1") & " " & DataReader("City") & " " & DataReader("State") & " " & DataReader("Zip_Code"), " ", "+")
                EventContentLabel.Text &= "<a href=""http://maps.google.com/maps?f=q&source=s_q&hl=en&geocode=&q=" & MapAddress & """ target=""GoogleMaps"">Map & Directions</a><br /><br />"
            End If
            If Not String.IsNullOrEmpty(DataReader("Phone").ToString()) Then
                EventContentLabel.Text &= "Phone: " & FormatPhone(DataReader("Phone"), DataReader("Country")) & "<br />"
            End If
            If Not String.IsNullOrEmpty(DataReader("EMailAddress").ToString()) Then
                If Not isSmallScreen() Then
                    EventContentLabel.Text &= "Email: <a href=mailto:" & DataReader("EMailAddress") & ">" & DataReader("EMailAddress") & "</a><br />"
                Else
                    EventContentLabel.Text &= "<a href=mailto:" & DataReader("EMailAddress") & ">Email</a><br />"
                End If
            End If
            
            If Not String.IsNullOrEmpty(DataReader("URL").ToString()) Then
                Dim EventURL As String = DataReader("URL")
                If Not InStr(LCase(EventURL), "http") Then
                    EventURL = "http://" & EventURL
                End If
                If Not isSmallScreen() Then
                    EventContentLabel.Text &= "Website: <a href=""" & EventURL & """>" & EventURL & "</a><br />"
                Else
                    EventContentLabel.Text &= "<a href=""" & EventURL & """>Website</a><br />"
                End If
                EventContentLabel.Visible = True
            End If
        End If
        DataReader.Close()
        DBCmd.Dispose()
        DBClose(DBTix)

    End Sub
</script>

<!-- AddThisEvent theme css -->
<link rel="stylesheet" href="/css/addthisevent.theme8.css" type="text/css" media="screen" />
<!-- AddThisEvent -->
<script type="text/javascript" src="https://addthisevent.com/libs/ate-latest.min.js"></script>
<!-- AddThisEvent Settings -->
<script type="text/javascript">
	addthisevent.settings({
		license: "replace-with-your-licensekey",
		css: false,
		outlook: { show: true, text: "Outlook" },
		google: { show: true, text: "Google <em>(online)</em>" },
		yahoo: { show: true, text: "Yahoo <em>(online)</em>" },
		outlookcom: { show: true, text: "Outlook.com <em>(online)</em>" },
		appleical: { show: true, text: "Apple Calendar" },
		dropdown: { order: "appleical,google,outlook,outlookcom,yahoo" }
	});
</script>

<asp:Panel ID="EventHeaderPanel" runat="server"  CssClass="PanelHeader" Style="height:17px;">
    <div style="float:left;vertical-align:middle;"><asp:Label ID="EventHeaderLabel" runat="server" Text="" /></div>
    <div class="addthisevent" style="float:right;border:none;top:-4px;">
        <img src="/images/icon-calendar-t1.png" title="Add to Calendar" />
        <span class="start"><%=EventDate%></span>
        <span class="end"><%=EventDate%></span>
        <span class="timezone">America/Los_Angeles</span>
        <span class="title"><%=EventTitle%></span>
        <span class="location"><%=EventLocation%></span>
        <span class="description"><%=EventDescription%></span>
        <span class="all_day_event">false</span>
        <span class="date_format">MM/DD/YYYY</span>
    </div>
    <div style="clear:both"></div>
</asp:Panel>

<asp:Panel ID="EventContentPanel" runat="server"  CssClass="PanelContent">
    <asp:Label ID="EventContentLabel" runat="server" Text="" />
</asp:Panel>
