'CHANGE LOG
'9/26/11 - Added PastEventTime Flag for current Date/Time forward
'REE 10/11/11 - Added PageLoadComplete lblNoEvent.Visible True and False depending on GridView row count.
'TTT 11/2/11 - Separated schedule of event listing to its own user control
'TTT 11/22/11 - Showed no event listing if OrgNum in request variables is missing - due to separating event schedule in its own u.c.
'TTT 6/13/12 - Added the ability to display ScheduleSubCategory
'TTT 10/9/12 - Prevented setting Mobile's HomePage to just only Schedule.aspx
'TTT 3/20/13 - Revised to handle date formats with different culture languages
'TTT 9/23/13 - Include ability to pass MemberID
'TTT 10/15/13 - Added browser capabilities to fix issue for iPhone on Mobile
'TTT 3/24/14 - Modified to check for request variables' valid data types
'TTT 7/18/14 - Modified to consolidate schedule page to multiple types of schedule pages for Tix2 & Mobile
'TTT 10/15/14 - Modified to include display of Schedule SubCategory
'TTT 10/23/14 - Modified to add in no events message for SubCategory
'TTT 11/13/14 - Modified to use isSmallScreen function instead of SubDomain for Mobile
'TTT 1/8/15 - Modified to set session("DiscountCode") to apply on Pay page automatically if applicable
'TTT 1/12/15 - Modified to add ability to suppress tooltip for Schedule pages
'TTT 8/13/15 - Added check on Request("OrgNum") if missing then redirect to Tix Homepage
'TTT 9/22/15 - Modified to switch to OrgOption("NoEventsMessage") and add proper check for if events are on sale

Imports System.IO
Imports System.Data
Imports System.Data.SqlClient
Imports GlobalClass

Partial Class Schedule
	Inherits GlobalClass

	Private OrgNum As Integer

	Protected Sub Page_PreInit(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreInit
		If isSmallScreen() And Not Request.UserAgent Is Nothing AndAlso Request.UserAgent.Contains("iPhone") Then 'For Mobile and iPhone
			'In fullscreen mode Safari uses a different HTTP User Agent String, and ASP.NET doesn't anymore recognize the browser as Safari, 
			'instead it recognizes it as a generic browser with no capabilities and for example JavaScript and JQuery will stop working
			Me.ClientTarget = "uplevel" 'Specifies browser capabilities equivalent to Internet Explorer 6.0 to support Javascript
		End If
	End Sub

	Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
		If Request("DiscountCode") <> "" Then
			Session("DiscountCode") = Clean(Request("DiscountCode"))
		End If

		If Request("OrgNum") <> "" Then
			If Not IsNumeric(Request("OrgNum")) Then
				Response.Redirect(HomePage())
            End If
        Else
            Response.Redirect("http://www.tix.com")
        End If
		If Request("ActCode") <> "" And Not InStr(Request("ActCode"), ",") Then
			If Not IsNumeric(Request("ActCode")) Then
				If IsNumeric(Request("OrgNum")) Then
					Response.Redirect("/Schedule.aspx?Orgnum=" & Request("OrgNum"))
				End If
			End If
		End If
		If Request("VenueCode") <> "" And Not InStr(Request("VenueCode"), ",") Then
			If Not IsNumeric(Request("VenueCode")) Then
				If IsNumeric(Request("OrgNum")) Then
					Response.Redirect("/Schedule.aspx?Orgnum=" & Request("OrgNum"))
				End If
			End If
		End If
		If Request("EventCode") <> "" And Not InStr(Request("EventCode"), ",") Then
			If Not IsNumeric(Request("EventCode")) Then
				If IsNumeric(Request("OrgNum")) Then
					Response.Redirect("/Schedule.aspx?Orgnum=" & Request("OrgNum"))
				End If
			End If
		End If
		If Request("StartDate") <> "" And Not IsDate(Request("StartDate")) Then
			If IsNumeric(Request("OrgNum")) Then
				Response.Redirect("/Schedule.aspx?Orgnum=" & Request("OrgNum"))
			End If
		End If
		If Request("EndDate") <> "" And Not IsDate(Request("EndDate")) Then
			If IsNumeric(Request("OrgNum")) Then
				Response.Redirect("/Schedule.aspx?Orgnum=" & Request("OrgNum"))
			End If
		End If
		If Request("SaleStartDateBefore") <> "" And Not IsDate(Request("SaleStartDateBefore")) Then
			If IsNumeric(Request("OrgNum")) Then
				Response.Redirect("/Schedule.aspx?Orgnum=" & Request("OrgNum"))
			End If
		End If

		HTTPSPage(False)

		OrgNum = CInt(CleanNumeric(Request("OrgNum")))
		pnlPreSale.OrgNum = OrgNum

		If SubDomain() = "m" And Request("OrgNum") <> "" And Session("ReturnPage") Is Nothing Then
			Dim MobileReturnPage As String = "/m/Schedule.aspx?"
			If Request.ServerVariables("QUERY_STRING").ToString() <> "" Then
				MobileReturnPage &= Clean(Request.ServerVariables("QUERY_STRING").ToString())
			End If
			Session("ReturnPage") = MobileReturnPage
		End If

		'Set Browser Page Title
		If PL("Title") <> "" Then
			Page.Title = PL("Title")
		Else
			If IsNumeric(OrgNum) Then 'Get Organization Name for Page Title
				PageTitle(OrgNum)
			Else
				Page.Title = "Ticket Sales Schedule"
			End If
		End If

		'Set Body Page Title
		Master.PageTitle = "Tickets"
		If PL("ScheduleTitle") <> "" Then
			Master.PageTitle = PL("ScheduleTitle")
		End If

		'Set Data Source to GridView
		If Not Page.IsPostBack() Then
			'If Org has active presale available and it's passed but not logged in yet
			If Session("MemberType") Is Nothing And OrgPreSaleActive(OrgNum) And Request("MemberID") <> "" Then
				Dim btnPreSale As Button = CType(pnlPreSale.FindControl("btnPreSale"), Button)
				If Not btnPreSale Is Nothing Then
					Dim txtPreSale As TextBox = CType(pnlPreSale.FindControl("txtPreSale"), TextBox)
					If Not txtPreSale Is Nothing Then
						txtPreSale.Text = Clean(Request("MemberID"))
						pnlPreSale.btnPreSale_Click()
					End If
				End If
			Else
				BuildPage()
			End If
		Else
			Dim whichBtnClicked As Control = GetPostBackControl(Page)
			If whichBtnClicked Is Nothing Then 'BuyTix button is clicked
				BuildPage()	'Rebind grid to get eventcode for redirecting to Event Page
			Else
				If whichBtnClicked.ID = "btnAddToCart" Then 'Schedule Qty
					BuildPage()
				End If
			End If
		End If

		'Campaign Tracking
		CampaignTracking(Request("CampaignNumber"), Request("CustomerNumber"))

	End Sub

	Public Sub BuildPage()

		Dim ScriptFileName As String = "/UserControls/EventSchedule.ascx"	'Use for generic Schedule and SubCategory
		If Request("Disp") <> "" Then
			Select Case UCase(Request("Disp"))
				Case "ACT" 'Schedule Act Selection
					ScriptFileName = "/UserControls/EventScheduleAct.ascx"
				Case "QTY" 'Schedule Qty
					ScriptFileName = "/UserControls/EventScheduleQtyNew.ascx"
				Case "CAL" 'Schedule Calendar
					ScriptFileName = "/UserControls/EventScheduleCalendar.ascx"
			End Select
		End If
		Dim UCScript As UserControl
		Dim ucType As Type

		If UCase(Request("Disp")) <> "SUBCAT" Then 'For generic, qty, act, and cal
			UCScript = LoadControl(ScriptFileName)
			ucType = UCScript.GetType()

			'Pass all possible request variables as input parameters
			Dim OrgNumProperty As Reflection.PropertyInfo = ucType.GetProperty("OrgNum")
			OrgNumProperty.SetValue(UCScript, OrgNum, Nothing)
			Dim ActCodeProperty As Reflection.PropertyInfo = ucType.GetProperty("ActCode")
			ActCodeProperty.SetValue(UCScript, Request("ActCode"), Nothing)
			Dim ToolTipProperty As Reflection.PropertyInfo = ucType.GetProperty("ToolTip")
			ToolTipProperty.SetValue(UCScript, Request("Tooltip"), Nothing)
			If UCase(Request("Disp")) = "QTY" Then
				Dim BestQtyProperty As Reflection.PropertyInfo = ucType.GetProperty("BestQty")
				BestQtyProperty.SetValue(UCScript, Request("BestQty"), Nothing)
			ElseIf UCase(Request("Disp")) = "CAL" Then
				Dim CalMonthProperty As Reflection.PropertyInfo = ucType.GetProperty("CalendarMonth")
				CalMonthProperty.SetValue(UCScript, CInt(Request("CalendarMonth")), Nothing)
				Dim CalYearProperty As Reflection.PropertyInfo = ucType.GetProperty("CalendarYear")
				CalYearProperty.SetValue(UCScript, CInt(Request("CalendarYear")), Nothing)
				Dim CampaignNumberProperty As Reflection.PropertyInfo = ucType.GetProperty("CampaignNumber")
				CampaignNumberProperty.SetValue(UCScript, CInt(Request("CampaignNumber")), Nothing)
			End If
			If UCase(Request("Disp")) <> "CAL" Then
				Dim PastTimeProperty As Reflection.PropertyInfo = ucType.GetProperty("PastEventTime")
				PastTimeProperty.SetValue(UCScript, Request("PastEventTime"), Nothing)
				Dim StartDateProperty As Reflection.PropertyInfo = ucType.GetProperty("StartDate")
				StartDateProperty.SetValue(UCScript, Request("StartDate"), Nothing)
				Dim EndDateProperty As Reflection.PropertyInfo = ucType.GetProperty("EndDate")
				EndDateProperty.SetValue(UCScript, Request("EndDate"), Nothing)
				Dim VenueCodeProperty As Reflection.PropertyInfo = ucType.GetProperty("VenueCode")
				VenueCodeProperty.SetValue(UCScript, Request("VenueCode"), Nothing)
				Dim EventCodeProperty As Reflection.PropertyInfo = ucType.GetProperty("EventCode")
				EventCodeProperty.SetValue(UCScript, Request("EventCode"), Nothing)
				Dim CategoryProperty As Reflection.PropertyInfo = ucType.GetProperty("Category")
				CategoryProperty.SetValue(UCScript, Request("Category"), Nothing)
				Dim SubCategoryProperty As Reflection.PropertyInfo = ucType.GetProperty("SubCategory")
				SubCategoryProperty.SetValue(UCScript, Request("SubCategory"), Nothing)
				Dim SaleStartDateBeforeProperty As Reflection.PropertyInfo = ucType.GetProperty("SaleStartDateBefore")
				SaleStartDateBeforeProperty.SetValue(UCScript, Request("SaleStartDateBefore"), Nothing)
				Dim SortOrderProperty As Reflection.PropertyInfo = ucType.GetProperty("SortOrder")
				SortOrderProperty.SetValue(UCScript, Request("SortOrder"), Nothing)
			End If

			pnlGridView.Controls.Add(UCScript)
		Else
			Dim SubCategoryEvents(200, 1) As String
			Dim index As Integer = 0

			Dim DBTix As New SqlConnection
			Dim DBCmd As New SqlCommand
			Dim DataReader, DataReader2 As SqlDataReader

			DBOpen(DBTix)

            Dim SQLSubcategory As String = "SELECT DISTINCT SubCategory.SubCategoryCode, SubCategory.SubCategory FROM Event WITH (NOLOCK) INNER JOIN Act WITH (NOLOCK) ON Event.ActCode = Act.ActCode INNER JOIN SubCategory WITH (NOLOCK) ON Act.SubCategoryCode = SubCategory.SubCategoryCode INNER JOIN Venue WITH (NOLOCK) ON Event.VenueCode = Venue.VenueCode INNER JOIN OrganizationVenue WITH (NOLOCK) ON Event.VenueCode = OrganizationVenue.VenueCode INNER JOIN OrganizationAct WITH (NOLOCK) ON Act.ActCode = OrganizationAct.ActCode WHERE OrganizationAct.OrganizationNumber = @OrgNum AND OrganizationVenue.OrganizationNumber = @OrgNum AND Event.EventDate >= @StartDate AND Event.OnSale = 1 AND Event.SaleStartDate <= @SaleStartDate ORDER BY SubCategory.SubCategory, SubCategory.SubCategoryCode"
			DBCmd = New SqlCommand(SQLSubcategory, DBTix)
            DBCmd.Parameters.AddWithValue("@OrgNum", OrgNum)
            DBCmd.Parameters.AddWithValue("@StartDate", FormatDateTime(DateTime.Now, vbShortDate))
            DBCmd.Parameters("@StartDate").DbType = DbType.DateTime
            DBCmd.Parameters.AddWithValue("@SaleStartDate", Now())
            DBCmd.Parameters("@SaleStartDate").DbType = DbType.DateTime
			DataReader = DBCmd.ExecuteReader()
			DBCmd.Parameters.Clear()
			Do While DataReader.Read()
				SubCategoryEvents(index, 0) = DataReader("SubCategory")
				Dim EventCodes As String = ""
                Dim SQLEvents As String = "SELECT Event.EventCode FROM Event WITH (NOLOCK) INNER JOIN Act WITH (NOLOCK) ON Event.ActCode = Act.ActCode INNER JOIN OrganizationAct WITH (NOLOCK) ON Act.ActCode = OrganizationAct.ActCode INNER JOIN Venue WITH (NOLOCK) ON Event.VenueCode = Venue.VenueCode INNER JOIN OrganizationVenue WITH (NOLOCK) ON Venue.VenueCode = OrganizationVenue.VenueCode WHERE OrganizationAct.OrganizationNumber = @OrgNum AND OrganizationVenue.OrganizationNumber = @OrgNum AND Act.SubCategoryCode = @SubCategeoryCode AND Event.OnSale = 1 AND Event.EventDate >= @StartDate"
				DBCmd = New SqlCommand(SQLEvents, DBTix)
				DBCmd.Parameters.AddWithValue("@OrgNum", OrgNum)
				DBCmd.Parameters.AddWithValue("@SubCategeoryCode", DataReader("SubCategoryCode"))
				DBCmd.Parameters.AddWithValue("@StartDate", FormatDateTime(DateTime.Now, vbShortDate))
                DBCmd.Parameters("@StartDate").DbType = DbType.DateTime
                DataReader2 = DBCmd.ExecuteReader()
				Do While DataReader2.Read()
					EventCodes = EventCodes & DataReader2("EventCode") & ","
				Loop
				DataReader2.Close()
				If EventCodes <> "" Then
					EventCodes = Left(EventCodes, Len(EventCodes) - 1)
				End If
				SubCategoryEvents(index, 1) = EventCodes
				index = index + 1
			Loop
			DataReader.Close()

			DBCmd.Dispose()
			DBClose(DBTix)

			If index > 0 Then
				For i As Integer = 0 To index - 1
					If SubCategoryEvents(i, 1) <> "" Then
						UCScript = LoadControl(ScriptFileName)
						ucType = UCScript.GetType()
						Dim OrgNumProperty As Reflection.PropertyInfo = ucType.GetProperty("OrgNum")
						OrgNumProperty.SetValue(UCScript, OrgNum, Nothing)
						Dim PastTimeProperty As Reflection.PropertyInfo = ucType.GetProperty("PastEventTime")
						PastTimeProperty.SetValue(UCScript, Request("PastEventTime"), Nothing)
						Dim StartDateProperty As Reflection.PropertyInfo = ucType.GetProperty("StartDate")
						StartDateProperty.SetValue(UCScript, Request("StartDate"), Nothing)
						Dim EndDateProperty As Reflection.PropertyInfo = ucType.GetProperty("EndDate")
						EndDateProperty.SetValue(UCScript, Request("EndDate"), Nothing)
						Dim ActCodeProperty As Reflection.PropertyInfo = ucType.GetProperty("ActCode")
						ActCodeProperty.SetValue(UCScript, Request("ActCode"), Nothing)
						Dim VenueCodeProperty As Reflection.PropertyInfo = ucType.GetProperty("VenueCode")
						VenueCodeProperty.SetValue(UCScript, Request("VenueCode"), Nothing)
						Dim EventCodeProperty As Reflection.PropertyInfo = ucType.GetProperty("EventCode")
						EventCodeProperty.SetValue(UCScript, Request("EventCode"), Nothing)
						Dim CategoryProperty As Reflection.PropertyInfo = ucType.GetProperty("Category")
						CategoryProperty.SetValue(UCScript, Request("Category"), Nothing)
						Dim SubCategoryProperty As Reflection.PropertyInfo = ucType.GetProperty("SubCategory")
						SubCategoryProperty.SetValue(UCScript, Request("SubCategory"), Nothing)
						Dim SaleStartDateBeforeProperty As Reflection.PropertyInfo = ucType.GetProperty("SaleStartDateBefore")
						SaleStartDateBeforeProperty.SetValue(UCScript, Request("SaleStartDateBefore"), Nothing)
						Dim SortOrderProperty As Reflection.PropertyInfo = ucType.GetProperty("SortOrder")
						SortOrderProperty.SetValue(UCScript, Request("SortOrder"), Nothing)
						Dim ScheduleTitleProperty As Reflection.PropertyInfo = ucType.GetProperty("ScheduleTitle")
						ScheduleTitleProperty.SetValue(UCScript, SubCategoryEvents(i, 0), Nothing)
						Dim DisplayEventsProperty As Reflection.PropertyInfo = ucType.GetProperty("DisplayEvents")
						DisplayEventsProperty.SetValue(UCScript, SubCategoryEvents(i, 1), Nothing)
						Dim ToolTipProperty As Reflection.PropertyInfo = ucType.GetProperty("ToolTip")
						ToolTipProperty.SetValue(UCScript, Request("Tooltip"), Nothing)
						pnlGridView.Controls.Add(UCScript)
					End If
				Next
            Else
                Dim NoEventsMsg As String = OrgOption(OrgNum, "NoEventsMessage")
                If NoEventsMsg = "" Then
                    NoEventsMsg = "There are no events on sale at this time.  Please check back again."
                End If
                Dim lblNoEventsSubCat As New Label
                lblNoEventsSubCat.Text = NoEventsMsg
                phContent2.Controls.Add(lblNoEventsSubCat)
			End If

		End If

	End Sub

	Public Sub PageTitle(ByVal OrgNum As Integer)

		Dim DBTix As New SqlConnection
		Dim DBCmd As New SqlCommand

		DBOpen(DBTix)

		Dim SQLOrg As String = "SELECT Organization.Organization From Organization WITH (NOLOCK) WHERE Organization.OrganizationNumber = @OrgNum"
		DBCmd = New SqlCommand(SQLOrg, DBTix)
		DBCmd.Parameters.AddWithValue("@OrgNum", OrgNum)
		Dim drOrg As SqlDataReader
		drOrg = DBCmd.ExecuteReader()
		DBCmd.Parameters.Clear()

		If drOrg.HasRows Then
			drOrg.Read()
			Page.Title = drOrg("Organization") & " - Ticket Sales"
		End If

		drOrg.Close()
		DBCmd.Dispose()
		DBClose(DBTix)

	End Sub



End Class
