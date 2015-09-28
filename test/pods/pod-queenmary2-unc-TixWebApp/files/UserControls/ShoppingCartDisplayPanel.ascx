<%
    'CHANGE LOG
    'TTT 5/18/11 - Removed User Control ClassName since it's irrevelant and causes ambiguous reference
    'REE 12/8/11 - Suppressed Event Order Confirmation Notes unless order is complete.
    'TTT 7/16/12 - Added ability to suppress Date and/or Time
    'TTT 9/13/12 - Modified to share font styles among Tix2, Mobile, and Kiosk
    'JAI 10/26/12 - Cleaned up CSS.
    'TTT 11/13/14 - Modified to use isSmallScreen function instead of SubDomain for Mobile
    'TTT 9/24/15 - Modified to add completed order's events to calendar on Order Confirmation page
%>
<%@ Control Language="VB" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="GlobalClass" %>

<script runat="server">
    
    Private _OrderNumber As Integer
    Dim CurrentEventCode As Integer = 0
    Dim EventCounter As Integer = 0

    Public WriteOnly Property OrderNumber() As Integer
        Set(ByVal Value As Integer)
            _OrderNumber = Value
        End Set
    End Property

    Protected Sub Repeater1_ItemDataBound(ByVal sender As Object, ByVal e As RepeaterItemEventArgs) Handles Repeater1.ItemDataBound
        If e.Item.ItemType = ListItemType.Item Or e.Item.ItemType = ListItemType.AlternatingItem Then
            
            'Event Date/Time Display
            Dim lblEventDate As Label = CType(e.Item.FindControl("lblEventDate"), Label)
            If e.Item.DataItem("DateSuppress") = "N" Then
                lblEventDate.Text = " on " & WeekdayName(Weekday(e.Item.DataItem("EventDate")), False) & " " & String.Format("{0:d}", e.Item.DataItem("EventDate"))
            End If
            If e.Item.DataItem("TimeSuppress") = "N" Then
                lblEventDate.Text = lblEventDate.Text & " " & Resources.Resource.At & " " & String.Format("{0:t}", e.Item.DataItem("EventDate"))
            End If

            Dim DMLabel As Label = CType(e.Item.FindControl("DMLabel"), Label)
            Dim DeliveryMethod As String = e.Item.DataItem("ShipType")
            
            Dim DBTix As New SqlConnection
            Dim DBCmd As New SqlCommand
            DBOpen(DBTix)
            Dim DataReader As SqlDataReader

            If DeliveryMethod = "E-Ticket" Then 'Add the E-Ticket Link if there are current E-Tickets for this order (order is complete)

                Dim SQLETicket As String = "SELECT TicketNumber FROM OrderHeader WITH (NOLOCK) INNER JOIN Ticket WITH (NOLOCK) ON OrderHeader.OrderNumber = Ticket.OrderNumber WHERE OrderHeader.OrderNumber = @OrderNumber AND Ticket.StatusCode = 'A'"
                DBCmd = New SqlCommand(SQLETicket, DBTix)
                DBCmd.Parameters.AddWithValue("@OrderNumber", _OrderNumber)
                DataReader = DBCmd.ExecuteReader()
                DBCmd.Parameters.Clear()

                If DataReader.HasRows Then
                    DataReader.Read()
                    Dim TicketNumber As String = DataReader("TicketNumber")
                    DeliveryMethod = "<a href=""https://" & Request.ServerVariables("SERVER_NAME") & "/ETicket.aspx?ordernumber=" & _OrderNumber & "&ticketnumber=" & TicketNumber & """ TARGET=""ETicket"">" & DeliveryMethod & "</a> - <a href=""https://" & Request.ServerVariables("SERVER_NAME") & "/ETicket.aspx?ordernumber=" & _OrderNumber & "&ticketnumber=" & TicketNumber & """ TARGET=""ETicket"">Click here</a> to print your E-Tickets."
                End If

                DataReader.Close()
                DBCmd.Dispose()
                
            End If
            
            DMLabel.Text = "Delivery Method: " & DeliveryMethod

            Dim sdsTickets As SqlDataSource = CType(e.Item.FindControl("sdsTickets"), SqlDataSource)
            sdsTickets.SelectParameters("OrderNumber").DefaultValue = _OrderNumber
            sdsTickets.SelectParameters("EventCode").DefaultValue = e.Item.DataItem("EventCode")
            
            
            If Not IsDBNull(e.Item.DataItem("EventNotes")) And strOrderStatus(_OrderNumber) = "S" Then
                'Display Event Notes
                Dim pnlEventNotes As New Panel
                pnlEventNotes = CType(e.Item.FindControl("pnlEventNotes"), Panel)
                pnlEventNotes.Visible = True
            End If
            
            'Display Discount column if applicable
            Dim gvShoppingCart As GridView = CType(e.Item.FindControl("gvShoppingCart"), GridView)
            
            If isSmallScreen() Then 'It's Tix Mobile
                gvShoppingCart.Columns(0).HeaderText = "Section/<BR>Price"
                'gvShoppingCart.Columns(1).HeaderText = "Row"
                gvShoppingCart.Columns(2).HeaderText = "Seat/<BR>Fee"
                gvShoppingCart.Columns(3).HeaderText = "Type/<BR>Subtotal"
            End If
            
            Dim SQLDiscount As String = "SELECT OrderLine.Discount FROM OrderLine WITH (NOLOCK) INNER JOIN OrderHeader WITH (NOLOCK) ON OrderLine.OrderNumber = OrderHeader.OrderNumber WHERE OrderHeader.OrderNumber = @OrderNumber AND OrderLine.ItemType IN ('Seat', 'SubFixedEvent') AND OrderLine.Discount <> 0"
            DBCmd = New SqlCommand(SQLDiscount, DBTix)
            DBCmd.Parameters.AddWithValue("@OrderNumber", _OrderNumber)
            DataReader = DBCmd.ExecuteReader()
            DBCmd.Parameters.Clear()
            If DataReader.HasRows Then
                If isSmallScreen() Then 'It's Tix Mobile
                    gvShoppingCart.Columns(1).HeaderText = "Row/<BR>Discount"
                End If
                gvShoppingCart.Columns(5).Visible = True
            End If
            DataReader.Close()
            
            If isSmallScreen() Then 'It's Tix Mobile
                gvShoppingCart.Columns(4).Visible = False
                gvShoppingCart.Columns(5).Visible = False
                gvShoppingCart.Columns(6).Visible = False
                gvShoppingCart.Columns(7).Visible = False
                'Set new width for remaining four columns
                gvShoppingCart.Columns(0).ItemStyle.Width = Unit.Percentage(25)
                gvShoppingCart.Columns(1).ItemStyle.Width = Unit.Percentage(25)
                gvShoppingCart.Columns(2).ItemStyle.Width = Unit.Percentage(25)
                gvShoppingCart.Columns(3).ItemStyle.Width = Unit.Percentage(25)
            End If
            
            'Link to Seat Map
            If e.Item.DataItem("Map") <> "general" And InStr(Page.MasterPageFile.ToString.ToLower(), "kiosk.master") = False Then
                Dim pnlSeatMapLink As Panel = CType(e.Item.FindControl("pnlSeatMapLink"), Panel)
                pnlSeatMapLink.Visible = True
                pnlSeatMapLink.Attributes.CssStyle.Add("font-weight", "normal")
                pnlSeatMapLink.Attributes.CssStyle.Add("font-style", "italic")
                Dim lblSeatMap As New Label
                lblSeatMap.Text = "&nbsp;&nbsp;&nbsp;To view the seating chart "
                pnlSeatMapLink.Controls.Add(lblSeatMap)
                Dim hlSeatMap As New HyperLink
                hlSeatMap.NavigateUrl = "http://" & Request.ServerVariables("SERVER_NAME") & "/images/" & e.Item.DataItem("Map") & ".gif"
                hlSeatMap.Text = "click here"
                hlSeatMap.Target = "SeatMap"
                pnlSeatMapLink.Controls.Add(hlSeatMap)
                Dim lblSeatMapPeriod As New Label
                lblSeatMapPeriod.Text = "."
                pnlSeatMapLink.Controls.Add(lblSeatMapPeriod)
                
            End If
            
            DBCmd.Dispose()
            DBClose(DBTix)
            
        End If
    End Sub
    
    Protected Sub ShoppingCartRowCreated(ByVal sender As Object, ByVal e As GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim lblSectionPrice As Label = CType(e.Row.FindControl("lblSectionPrice"), Label)
            Dim SectionPrice As String = e.Row.DataItem("Section")
            If isSmallScreen() Then
                SectionPrice = SectionPrice & "<BR>" & FormatCurrency(e.Row.DataItem("Price"), 2)
            End If
            lblSectionPrice.Text = SectionPrice
            Dim lblRowDiscount As Label = CType(e.Row.FindControl("lblRowDiscount"), Label)
            Dim RowDiscount As String = e.Row.DataItem("Row")
            If isSmallScreen() Then
                If CDbl(e.Row.DataItem("Discount")) > 0 Then
                    RowDiscount = RowDiscount & "<BR>" & FormatCurrency(e.Row.DataItem("Discount"), 2)
                End If
            End If
            lblRowDiscount.Text = RowDiscount
            Dim lblSeatSurcharge As Label = CType(e.Row.FindControl("lblSeatSurcharge"), Label)
            Dim SeatSurcharge As String = e.Row.DataItem("Seat")
            If isSmallScreen() Then
                SeatSurcharge = SeatSurcharge & "<BR>" & FormatCurrency(e.Row.DataItem("Surcharge"), 2)
            End If
            lblSeatSurcharge.Text = SeatSurcharge
            Dim lblSeatTypeSubtotal As Label = CType(e.Row.FindControl("lblSeatTypeSubtotal"), Label)
            Dim SeatTypeSubtotal As String = e.Row.DataItem("SeatType")
            If isSmallScreen() Then
                SeatTypeSubtotal = SeatTypeSubtotal & "<BR>" & FormatCurrency(e.Row.DataItem("Subtotal"), 2)
            End If
            lblSeatTypeSubtotal.Text = SeatTypeSubtotal
            If isSmallScreen() Then
                'e.Row.Attributes.Add("style", "border-bottom:1px #AAAAAA solid")
                If CurrentEventCode <> e.Row.DataItem("EventCode") Then
                    EventCounter = EventCounter + 1
                    CurrentEventCode = e.Row.DataItem("EventCode")
                End If
                Dim gvShoppingCart As GridView = CType(Repeater1.Items(EventCounter - 1).FindControl("gvShoppingCart"), GridView)
                gvShoppingCart.GridLines = GridLines.Horizontal
            End If
        End If
    End Sub
    
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        
        Dim DBTix As New SqlConnection
        Dim DBCmd As New SqlCommand
        Dim DataReader As SqlDataReader
        DBOpen(DBTix)

        sdsDonations.SelectParameters("OrderNumber").DefaultValue = _OrderNumber
        sdsEvents.SelectParameters("OrderNumber").DefaultValue = _OrderNumber

        Dim SQLDonation As String = "SELECT OrderLine.LineNumber FROM OrderLine WITH (NOLOCK) INNER JOIN Donation WITH (NOLOCK) ON OrderLine.ItemNumber = Donation.ItemNumber INNER JOIN OrderHeader WITH (NOLOCK) ON OrderLine.OrderNumber = OrderHeader.OrderNumber WHERE OrderHeader.OrderNumber = @OrderNumber AND OrderLine.ItemType = 'Donation'"
        DBCmd = New SqlCommand(SQLDonation, DBTix)
        DBCmd.Parameters.AddWithValue("@OrderNumber", _OrderNumber)
        DataReader = DBCmd.ExecuteReader()
        DBCmd.Parameters.Clear()
        If DataReader.HasRows Then
            pnlDonationHeader.Visible = True
            pnlDonationContent.Visible = True
        End If
        DBCmd.Dispose()
        DataReader.Close()
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

<asp:Panel ID="ShoppingCartPanel" runat="server" Width="100%">
    <asp:SqlDataSource ID="sdsEvents" runat="server" 
        ConnectionString="<%$ ConnectionStrings:TixDB %>" 
        SelectCommand="SELECT Event.EventCode, Act.Act, Act.Comments AS ActComments, Venue.Venue, Venue.Address_1, Venue.City, Venue.State, Venue.Zip_Code, Event.EventDate, Event.Map, Shipping.ShipType, EventOptions.OptionValue AS EventNotes, ISNULL(DateSuppress.DateSuppress, 'N') AS DateSuppress, ISNULL(TimeSuppress.TimeSuppress, 'N') AS TimeSuppress FROM OrderHeader WITH (NOLOCK) INNER JOIN OrderLine WITH (NOLOCK) ON OrderHeader.OrderNumber = OrderLine.OrderNumber INNER JOIN Seat WITH (NOLOCK) ON OrderLine.ItemNumber = Seat.ItemNumber INNER JOIN Event WITH (NOLOCK) ON Seat.EventCode = Event.EventCode INNER JOIN Act WITH (NOLOCK) ON Event.ActCode = Act.ActCode INNER JOIN Venue WITH (NOLOCK) ON Event.VenueCode = Venue.VenueCode INNER JOIN Shipping WITH (NOLOCK) ON OrderLine.ShipCode = Shipping.ShipCode LEFT JOIN EventOptions WITH (NOLOCK) ON Event.EventCode = EventOptions.EventCode AND EventOptions.OptionName = 'EventOrderConfirmationNotes' LEFT OUTER JOIN (SELECT EventCode, OptionValue AS DateSuppress FROM EventOptions WITH (NOLOCK) WHERE OptionName = 'DateSuppress' AND OptionValue = 'Y') AS DateSuppress ON Event.EventCode = DateSuppress.EventCode LEFT OUTER JOIN (SELECT EventCode, OptionValue AS TimeSuppress FROM EventOptions AS EventOptions_2 WITH (NOLOCK) WHERE OptionName = 'TimeSuppress' AND OptionValue = 'Y') AS TimeSuppress ON Event.EventCode = TimeSuppress.EventCode WHERE OrderHeader.OrderNumber = @OrderNumber AND OrderLine.ItemType IN ('Seat', 'SubFixedEvent') GROUP BY Event.EventCode, Act.Act, Act.Comments, Venue.Venue, Venue.Address_1, Venue.City, Venue.State, Venue.Zip_Code, Event.EventDate, Event.Map, Shipping.ShipType, EventOptions.OptionValue, DateSuppress.DateSuppress, TimeSuppress.TimeSuppress ORDER BY Event.EventDate, Act.Act">
        <SelectParameters>
            <asp:Parameter Name="OrderNumber" DefaultValue="0" />
        </SelectParameters>
    </asp:SqlDataSource>    
    <asp:Repeater ID="Repeater1" runat="server" DataSourceID="sdsEvents">
        <ItemTemplate>

            <asp:HiddenField ID="EventCode" Value=<%# DataBinder.Eval(Container.DataItem, "EventCode") %> runat="server" />

            <asp:Panel ID="pnlShoppingCartHeader" runat="server" CssClass="PanelHeader" style="padding-left:0px;">&nbsp;&nbsp;<b>
                <span><%#DataBinder.Eval(Container.DataItem, "Act") %></span><asp:Label ID="lblEventDate" runat="server" />
                <asp:PlaceHolder ID="phEventCalendar" runat="server" Visible="false">
                    <div class="addthisevent" style="border:none;">
                        <img src="/images/icon-calendar-t1.png" title="Add to Calendar" />
                        <span class="start"><%#LocalDateTime(EventOwner(DataBinder.Eval(Container.DataItem, "EventCode")), CDate(DataBinder.Eval(Container.DataItem, "EventDate")))%></span>
                        <span class="end"><%#LocalDateTime(EventOwner(DataBinder.Eval(Container.DataItem, "EventCode")), CDate(DataBinder.Eval(Container.DataItem, "EventDate")))%></span>
                        <span class="timezone">America/Los_Angeles</span>
                        <span class="title"><%#DataBinder.Eval(Container.DataItem, "Act") & " At " & DataBinder.Eval(Container.DataItem, "Venue")%></span>
                        <span class="location"><%#DataBinder.Eval(Container.DataItem, "Address_1").ToString & ", " & DataBinder.Eval(Container.DataItem, "City").ToString & ", " & DataBinder.Eval(Container.DataItem, "State").ToString() & " " & DataBinder.Eval(Container.DataItem, "Zip_Code").ToString()%></span>
                        <span class="description"><%#If(DataBinder.Eval(Container.DataItem, "EventNotes").ToString() <> "", DataBinder.Eval(Container.DataItem, "EventNotes").ToString(), DataBinder.Eval(Container.DataItem, "ActComments").ToString()) & "<BR><BR>http://" & Request.ServerVariables("SERVER_NAME") & "/Event.aspx?EventCode=" & DataBinder.Eval(Container.DataItem, "EventCode")%></span>
                        <span class="all_day_event">false</span>
                        <span class="date_format">MM/DD/YYYY</span>
                    </div>
                </asp:PlaceHolder>
                <br />&nbsp;&nbsp;<span><%#DataBinder.Eval(Container.DataItem, "Venue")%></span></b><asp:Panel ID="pnlSeatMapLink" runat="server" visible="false" />
            </asp:Panel>

            <asp:Panel ID="pnlShoppingCartContent" runat="server">

                <asp:Panel ID="pnlDeliveryMethod" runat="server" CssClass="PanelContent" style="padding-left:0px;">&nbsp;
                    <asp:Label ID="DMLabel" runat="server" Font-Bold="True" />
                </asp:Panel>

                <asp:Panel ID="pnlEventNotes" runat="server" CssClass="PanelContent" Visible="False" style="padding-left:0px;">&nbsp;
                    <asp:Label ID="lblEventNotes" runat="server" Font-Size="11px" Text=<%#DataBinder.Eval(Container.DataItem, "EventNotes")%>></asp:Label>
                </asp:Panel>
                
                <asp:SqlDataSource ID="sdsTickets" runat="server" 
                    ConnectionString="<%$ ConnectionStrings:TixDB %>"
                    SelectCommand="SELECT OrderLine.OrderNumber, Seat.EventCode, Section.Section, Seat.SectionCode, Seat.Row, Seat.Seat, IsNull(SeatType.SeatTypeCode, 0) AS SeatTypeCode, SeatType.SeatType AS SeatType, Seat.ItemNumber, OrderLine.LineNumber, ISNULL(OrderLine.Price, 0) AS Price, ISNULL(OrderLine.Surcharge, 0) AS Surcharge, ISNULL(OrderLine.Discount, 0) AS Discount, ISNULL(OrderLine.Price, 0) + ISNULL(OrderLine.Surcharge, 0) - ISNULL(OrderLine.Discount, 0) AS Subtotal FROM OrderHeader WITH (NOLOCK) INNER JOIN OrderLine WITH (NOLOCK) ON OrderHeader.OrderNumber = OrderLine.OrderNumber INNER JOIN Seat WITH (NOLOCK) ON OrderLine.ItemNumber = Seat.ItemNumber INNER JOIN Section WITH (NOLOCK) ON Seat.EventCode = Section.EventCode AND Seat.SectionCode = Section.SectionCode LEFT JOIN SeatType WITH (NOLOCK) ON OrderLine.SeatTypeCode = SeatType.SeatTypeCode WHERE OrderHeader.OrderNumber = @OrderNumber AND Seat.EventCode = @EventCode AND OrderLine.ItemType IN ('SubFixedEvent', 'Seat') ORDER BY Seat.SectionCode, Seat.RowSort, Seat.SeatSort">                        
                    <SelectParameters>
                        <asp:Parameter Name="OrderNumber" DefaultValue="0" />
                        <asp:Parameter Name="EventCode" DefaultValue="0" />
                    </SelectParameters>
                </asp:SqlDataSource>

                <asp:GridView ID="gvShoppingCart" runat="server" DataSourceID="sdsTickets" AutoGenerateColumns="False" Width="95%" GridLines="None" HeaderStyle-Font-Underline="True" OnRowDataBound="ShoppingCartRowCreated" DataKeyNames="LineNumber" CssClass="PanelContent" Style="width:100%;padding:0px 10px 0px 10px;">
                    <Columns>
                        <asp:TemplateField HeaderText="Section" ItemStyle-HorizontalAlign="Left" ItemStyle-VerticalAlign="Top" HeaderStyle-VerticalAlign="Top" HeaderStyle-HorizontalAlign="Left"><ItemTemplate><asp:Label ID="lblSectionPrice" runat="server" /></ItemTemplate></asp:TemplateField>
                        <asp:TemplateField HeaderText="Row" ItemStyle-HorizontalAlign="Left" ItemStyle-VerticalAlign="Top" HeaderStyle-VerticalAlign="Top" HeaderStyle-HorizontalAlign="Left"><ItemTemplate><asp:Label ID="lblRowDiscount" runat="server" /></ItemTemplate></asp:TemplateField>
                        <asp:TemplateField HeaderText="Seat" ItemStyle-HorizontalAlign="Left" ItemStyle-VerticalAlign="Top" HeaderStyle-VerticalAlign="Top" HeaderStyle-HorizontalAlign="Left"><ItemTemplate><asp:Label ID="lblSeatSurcharge" runat="server" /></ItemTemplate></asp:TemplateField>
                        <asp:TemplateField HeaderText="Ticket Type" ItemStyle-HorizontalAlign="Left" ItemStyle-VerticalAlign="Top" HeaderStyle-VerticalAlign="Top" HeaderStyle-HorizontalAlign="Left"><ItemTemplate><asp:Label ID="lblSeatTypeSubtotal" runat="server" /></ItemTemplate></asp:TemplateField>
                        <asp:BoundField DataField="Price" ItemStyle-Wrap="false" HeaderStyle-Wrap="false" HeaderText="Price" ReadOnly="True" DataFormatString="{0:c}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" />
                        <asp:BoundField DataField="Discount" ItemStyle-Wrap="false" HeaderStyle-Wrap="false" HeaderText="Discount" ReadOnly="True" DataFormatString="{0:c}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" Visible="False" />
                        <asp:BoundField DataField="Surcharge" ItemStyle-Wrap="false" HeaderStyle-Wrap="false" HeaderText="Service Fee" ReadOnly="True" DataFormatString="{0:c}"  ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" />
                        <asp:BoundField DataField="Subtotal" ItemStyle-Wrap="false" HeaderStyle-Wrap="false" HeaderText="Subtotal" ReadOnly="True" DataFormatString="{0:c}" ItemStyle-HorizontalAlign="Right" HeaderStyle-HorizontalAlign="Right" />
                    </Columns>
                </asp:GridView>

            </asp:Panel>
        
        </ItemTemplate>

        <SeparatorTemplate>
            <asp:Panel ID="Panel5" Height="10" runat="server">&nbsp;</asp:Panel>                   
        </SeparatorTemplate>

    </asp:Repeater>
    
    <asp:Panel ID="Panel100" Height="10" runat="server">&nbsp;</asp:Panel>
        
    <asp:SqlDataSource ID="sdsDonations" runat="server" 
        ConnectionString="<%$ ConnectionStrings:TixDB %>"
        SelectCommand="SELECT Donation.Description, OrderLine.Price, OrderLine.LineNumber FROM OrderLine WITH (NOLOCK) INNER JOIN Donation WITH (NOLOCK) ON OrderLine.ItemNumber = Donation.ItemNumber WHERE OrderLine.OrderNumber = @OrderNumber AND OrderLine.ItemType = 'Donation' ORDER BY OrderLine.LineNumber">                        
        <SelectParameters>
            <asp:Parameter Name="OrderNumber" DefaultValue="0" />
        </SelectParameters>
    </asp:SqlDataSource>
    
    <asp:Panel ID="pnlDonationHeader" runat="server" Visible="false" CssClass="PanelHeader" style="padding-left:0px;">&nbsp;&nbsp;
        <asp:Label id="lblDonationHeader" runat="server" text="Donations/Memberships"></asp:Label>
    </asp:Panel>
    
    <asp:Panel ID="pnlDonationContent" runat="server" Visible="false" HorizontalAlign="Center">
    <table width="100%" border="0" class="PanelContent"><tr><td>
    <asp:GridView ID="gvDonations" runat="server" DataSourceID="sdsDonations" AutoGenerateColumns="False" Width="100%" BorderStyle="None" GridLines="None" HeaderStyle-Font-Underline="True" Font-Size="8" CssClass="PanelContent" Style="padding:0px 10px 0px 10px;">
        <Columns>
            <asp:BoundField DataField="Description" HeaderText="Description" ReadOnly="True" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" />
            <asp:BoundField DataField="Price" HeaderText="Amount" ReadOnly="True" DataFormatString="{0:c}" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" />
        </Columns>
    </asp:GridView>
    </td></tr></table>
    </asp:Panel>

</asp:Panel>
