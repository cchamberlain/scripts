Imports System.IO
Imports System.Data
Imports System.Data.SqlClient
Imports System.Net.Mail
Imports clsTicketNumber
Imports clsCampaignTracking


Partial Class OrderConfirmation
    Inherits GlobalClass

    'CHANGE LOG
    'TTT 10/5/11 - Changed redirect to homepage using function HomePage() in GlobalClass
    'TTT 10/6/11 - Added code to make sure logged them out when the loginstatus is clicked for logout
    'TTT 1/24/12 - Added check to make sure EmailAddress is valid before sending
    'TTT 1/25/12 - Changed the sub of sending email to "SaveStateComplete" in order to update sent email message along with rendering all user controls
    'JAI 10/26/12 - Added TixCommon style to email   
    'REE 3/18/13 - Clear Session OrderNumber in Page Init and assign to page variable to prevent Session OrderNumber variable from being available while confirmation displays or if confirmation fails.
    'REE 3/19/13 - Moved ETicketAdd & Campaign Tracking to Order Confirmation from Pay.
    'REE 4/2/13 - Removed Membership and unused fields from SendEmail function.
    'TTT 7/1/13 - Rendered payment information on order confirmation page and email being sent
    'TTT 7/2/13 - Added ETicket page pop-up for auto print if applicable
    'REE 10/9/13 - Removed unused email sending code.  Added Customer Service Email Address as Reply To address in email confirmation.
    'TTT 11/13/14 - Modified to use isSmallScreen function instead of SubDomain for Mobile
    'TTT 1/8/15 - Modified to clear session("DiscountCode") once the order is completed
    'TTT 5/20/15 - Modified to update tender balance due and total paid
    'TTT 9/24/15 - Modified to add completed order's events to calendar on Order Confirmation page

    Protected _orderNumber As Int32


    Protected Sub Page_Init(sender As Object, e As EventArgs) Handles Me.Init
        If Session("OrderNumber") Is Nothing Then
            Response.Redirect(HomePage())
        Else
            _orderNumber = Session("OrderNumber")
            Session.Contents.Remove("OrderNumber")
            Session.Contents.Remove("DiscountCode")

            'REE 3/19/13 - Moved ETicketAdd to beginning of Order Confirmation from Pay.
            ETicketAdd(_orderNumber)
        End If

    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Page.IsPostback() Then
            Session.Contents.Remove("CustomerNumber")
            FormsAuthentication.SignOut()
        Else
            If Not isSmallScreen() Then 'ETicket pop-up for Tix2 only not Mobile
                Dim DBTix As New SqlConnection
                Dim DBCmd As New SqlCommand
                Dim dr As SqlDataReader
                DBOpen(DBTix)
                Dim SQLETicket As String = "SELECT Ticket.OrderNumber, TicketNumber FROM OrderLine (NOLOCK) INNER JOIN Ticket (NOLOCK) ON OrderLine.ItemNumber = Ticket.ItemNumber AND OrderLine.OrderNumber = Ticket.OrderNumber WHERE OrderLine.OrderNumber = @OrderNumber AND OrderLine.ShipCode = 13 AND OrderLine.StatusCode = 'S' AND Ticket.StatusCode = 'A'"
                DBCmd = New SqlCommand(SQLETicket, DBTix)
                DBCmd.Parameters.AddWithValue("@OrderNumber", _orderNumber)
                dr = DBCmd.ExecuteReader()
                DBCmd.Parameters.Clear()
                If dr.HasRows() Then 'Order has ETicket
                    If OrderOrg(_orderNumber, True) <> 3175 Or GetOrderTotal(_orderNumber) <> 0 Then 'Show pop-up auto print for ETicket if not GPLB or order is not free
                        dr.Read()
                        Dim sbScript As New StringBuilder()
                        sbScript.Append("window.open('http://" & Request.ServerVariables("SERVER_NAME") & "/ETicket.aspx?OrderNumber=" & _orderNumber & "&TicketNumber=" & dr("TicketNumber") & "', 'ETicket')" & vbCrLf)
                        Dim objScript As New HtmlGenericControl("script")
                        objScript.Attributes.Add("type", "text/javascript")
                        objScript.InnerHtml = sbScript.ToString()
                        pnlOrderConfirmation.Controls.Add(objScript)
                    End If
                End If
                dr.Close()
                DBCmd.Dispose()
                DBClose(DBTix)
            End If
        End If

        'Dynamically load Order Confirmation UserControl based upon OrgOption.  If none exists, use Default Confirmation UserControl.
        Dim ucOrderConfirmation As UserControl

        If OrgOption(OrderOwnerOrgNum(_orderNumber), "OrderConfirmation") <> "" Then 'Use Custom Confirmation
            ucOrderConfirmation = LoadControl(OrgOption(OrderOwnerOrgNum(_orderNumber), "OrderConfirmation"))
        Else 'Use Default
            If isSmallScreen() Then
                ucOrderConfirmation = LoadControl("~/UserControls/mOrderConfirmation.ascx")
            Else
                ucOrderConfirmation = LoadControl("~/UserControls/OrderConfirmation.ascx")
            End If
        End If

        Dim ucType As Type = ucOrderConfirmation.GetType()
        Dim ucOrderConfirmationProperty = ucType.GetProperty("OrderNumber")
        ucOrderConfirmationProperty.SetValue(ucOrderConfirmation, _orderNumber, Nothing)
        pnlOrderConfirmation.Controls.Add(ucOrderConfirmation)

    End Sub

    Public Overrides Sub VerifyRenderingInServerForm(ByVal control As System.Web.UI.Control)
        'DO NOTHING
    End Sub

    Public Sub SendEMail(ByVal strFromAddress As String, ByVal strFromName As String, ByVal strToAddress As String, ByVal strToName As String, ByVal strReplyToAddress As String, ByVal strSubject As String, ByVal strBody As String)

        'Get BCC if client wants copy of order confirmations
        Dim DBTix As New SqlConnection
        Dim DBCmd As New SqlCommand
        Dim BCC As String = ""

        DBOpen(DBTix)

        Dim SQLOrdNum As String = "SELECT EmailAddress FROM OrganizationEmail WITH (NOLOCK) WHERE OrganizationNumber = @OrgNum AND ReportName = 'OrderConfirmation'"
        DBCmd = New SqlCommand(SQLOrdNum, DBTix)
        DBCmd.Parameters.AddWithValue("@OrgNum", OrderOrg(_orderNumber, True))

        Dim drEMail As SqlDataReader
        drEMail = DBCmd.ExecuteReader()
        If drEMail.HasRows Then
            Do While drEMail.Read()
                BCC += drEMail("EMailAddress") & ","
            Loop

            'Remove last comma
            BCC = Left(BCC, Len(BCC) - 1)
        End If

        drEMail.Close()
        DBCmd.Parameters.Clear()
        DBCmd.Dispose()

        Dim msgMail = New MailMessage()

        Dim msgClient = New SmtpClient()

        msgMail.To.Add(strToAddress)

        If BCC <> "" Then
            msgMail.Bcc.Add(BCC)
        End If

        If strReplyToAddress <> "" Then
            msgMail.ReplyToList.Add(strReplyToAddress)
        End If

        msgMail.From = New MailAddress(strFromAddress)

        msgMail.Subject = strSubject

        msgMail.IsBodyHtml = True

        msgMail.Body = strBody

        msgClient.Send(msgMail)

    End Sub

    Protected Sub Page_SaveStateComplete(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.SaveStateComplete

        Dim DBTix As New SqlConnection
        Dim DBCmd As New SqlCommand
        Dim dr As SqlDataReader
        Dim CustomerEmail As String = ""
        Dim lblEmailConfirm As Label = CType(FindControlRecursive(pnlOrderConfirmation, "lblEmailConfirm"), Label)

        DBOpen(DBTix)

        'Display payment info if order is completed
        If strOrderStatus(_orderNumber) = "S" Then
            Dim lblBalanceDue As Label = CType(FindControlRecursive(pnlOrderConfirmation, "lblBalanceDue"), Label)
            If Not lblBalanceDue Is Nothing Then
                lblBalanceDue.Text = "Total Paid: "
            End If
            Dim lblBalanceDueAmount As Label = CType(FindControlRecursive(pnlOrderConfirmation, "lblBalanceDueAmount"), Label)
            If Not lblBalanceDueAmount Is Nothing Then
                lblBalanceDueAmount.Text = FormatCurrency(GetOrderTenderTotal(_orderNumber), 2)
            End If
        End If

        Try
            Dim SQLCustomerEmail As String = "SELECT FirstName, LastName, EMailAddress FROM Customer WITH (NOLOCK) WHERE CustomerNumber = @CustomerNumber"
            DBCmd = New SqlCommand(SQLCustomerEmail, DBTix)
            DBCmd.Parameters.AddWithValue("@CustomerNumber", Session("CustomerNumber"))
            dr = DBCmd.ExecuteReader()
            DBCmd.Parameters.Clear()
            If dr.HasRows() Then
                dr.Read()
                CustomerEmail = dr("EMailAddress")
                If ValidEmailAddressCheck(CustomerEmail) Then
                    Dim SB As New StringBuilder()
                    Dim SW As New StringWriter(SB)
                    Dim htmlTW As New HtmlTextWriter(SW)

                    Page.VerifyRenderingInServerForm(Me)

                    pnlOrderConfirmation.RenderControl(htmlTW)

                    Dim PageHTML As String = SB.ToString()

                    'Need to pull in PL style dynamically.
                    'Dim Style As String = "<style type=""text/css"">.PanelHeader {border-width: 1px;border-color: #AAAAAA;border-style: solid;font-weight: bold;text-align: left;padding: 5px 10px 5px 10px;font-size: x-small;color: #000000;background-color: #E8C63E; }.PanelContent {border-width: 1px;border-color: #AAAAAA;border-style: none solid solid solid;text-align: left;padding: 5px 10px 5px 10px;color: #000000;background-color: #F1F1F1; }</style>"
                    Dim Style As String = Master.GetPLStyle()
                    'Add a space before lines starting with a period to prevent SMTP error stripping periods when they are the first character on a line.
                    Style = " " & Replace(Style, vbCrLf & ".", vbCrLf & " .")
                    Style += "<style type=""text/css"">" & vbCrLf & TixCommonStyle() & vbCrLf & "</style>"

                    Dim EMailHeader As String
                    EMailHeader = "<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.0 Transitional//EN"" ""http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd""><html xmlns=""http://www.w3.org/1084880/xhtml"" >" & vbCrLf
                    EMailHeader = EMailHeader & "<head><title>Tix - Order Confirmation</title>" & vbCrLf
                    EMailHeader = EMailHeader & "</head>" & vbCrLf
                    EMailHeader = EMailHeader & "<body bgcolor=""#ffffff"" topmargin=""0"" bottommargin=""0"" leftmargin=""0"" rightmargin=""0"" marginwidth=""0"" marginheight=""0"" text=""#000000"" vlink=""#000000"" alink=""#333333"" link=""#000000"">" & vbCrLf

                    PageHTML = EMailHeader & Style & PageHTML & "</body></html>"

                    'Call SendEMail("orders@tix.com", "Tix Order Confirmation", "trung@tix.com", "Robert Edmison", "robert.edmison@tix.com", "Robert Edmison", "Tix - Order Confirmation", PageHTML, "info@tix.com", "")

                    Dim strCustomerServiceEMailAddress = OrgOption(OrderOrg(_orderNumber, True), "CustomerServiceEMailAddress")
                    Call SendEMail("orders@tix.com", "Tix Order Confirmation", CustomerEmail, dr("FirstName") & " " & dr("LastName"), strCustomerServiceEMailAddress, "Tix - Order Confirmation", PageHTML)
                    lblEmailConfirm.Text = "You may wish to print this page for reference.<br />An Order Confirmation E-Mail has been sent to " & CustomerEmail & ".<br /><br />"
                Else
                    ErrorLog("Tix2 Order Confirmation - Invalid Email Address: " & CustomerEmail & " - OrderNumber: " & _orderNumber)
                    lblEmailConfirm.Text = "You may wish to print this page for reference.<br />Unfortunately, we were unable to send an Order Confirmation E-Mail to " & CustomerEmail & ", as this is not a valid e-mail address.<br /><br />"
                End If
            End If
        Catch ex As Exception
            ErrorLog("Tix2 Order Confirmation - Error Sending Email Address: " & CustomerEmail & " - OrderNumber: " & _orderNumber)
            lblEmailConfirm.Text = "You may wish to print this page for reference.<br />Unfortunately, we were unable to send an Order Confirmation E-Mail to " & CustomerEmail & ", as this is not a valid e-mail address.<br /><br />"
        Finally
            dr.Close()
            DBCmd.Dispose()
            DBClose(DBTix)
        End Try

        Dim ShoppingCartPanel As Panel = CType(FindControlRecursive(pnlOrderConfirmation, "ShoppingCartPanel"), Panel)
        If Not ShoppingCartPanel Is Nothing Then
            Dim ShoppingCartEventCount As Integer = 0
            For Each c As Control In ShoppingCartPanel.Controls
                If TypeOf (c) Is Repeater Then
                    ShoppingCartEventCount = DirectCast(c, Repeater).Items.Count
                End If
            Next
            For EventNum As Integer = 1 To ShoppingCartEventCount
                Dim ShoppingCartRepeater As Repeater = CType(FindControlRecursive(pnlOrderConfirmation, "Repeater1"), Repeater)
                If Not ShoppingCartRepeater Is Nothing Then
                    Dim phEventCalendar As PlaceHolder = CType(ShoppingCartRepeater.Items(EventNum - 1).FindControl("phEventCalendar"), PlaceHolder)
                    If Not phEventCalendar Is Nothing Then
                        phEventCalendar.Visible = True
                    End If
                End If
            Next
        End If

        'REE 3/19/13 - Moved Campaign Tracking to end of Order Confirmation from Pay.
        If IsNumeric(Session("CampaignNumber")) Then
            Dim _campaignNumber, _customerNumber As Int32
            _campaignNumber = Convert.ToInt32(Session("CampaignNumber"))

            If Not IsNumeric(Session("CustomerNumber")) Then
                _customerNumber = 1
            Else
                _customerNumber = Convert.ToInt32(Session("CustomerNumber"))
            End If
            UpdateCampaignLog(_campaignNumber, _customerNumber, Convert.ToInt32(_orderNumber))
        End If

    End Sub

End Class