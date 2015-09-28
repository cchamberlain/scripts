<%
    'CHANGE LOG
    'TTT 5/16/11 - Removed User Control ClassName since it's irrevelant and causes ambiguous reference
    'TTT 9/28/15 - Modified to change usercontrol caching to a minute
%>
<%@ Control Language="VB" %>
<%@ Import Namespace="GlobalClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ OutputCache Duration="60" VaryByParam="*" %>

<script runat="server">
    
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        
        Dim EventCode As Long = CLng(CleanNumeric(Request("EventCode")))

        Dim DBTix As New SqlConnection
        Dim DBCmd As New SqlCommand
        Dim DataReader As SqlDataReader

        DBOpen(DBTix)

        Dim SQLEvent As String = "SELECT IsNull(Act.Comments, '') AS ActComments, IsNull(Event.Comments, '') As EventComments FROM Event WITH (NOLOCK) INNER JOIN Act WITH (NOLOCK) ON Event.ActCode = Act.ActCode WHERE Event.EventCode = @EventCode"
        DBCmd = New SqlCommand(SQLEvent, DBTix)
        DBCmd.Parameters.AddWithValue("@EventCode", EventCode)
        DataReader = DBCmd.ExecuteReader()
        
        Dim ActComments As String = ""
        Dim EventComments As String = ""
                
        If DataReader.HasRows Then
            DataReader.Read()
            ActComments = DataReader("ActComments")
            EventComments = DataReader("EventComments")
        End If
        
        Dim DescrSeparator As String = ""
        
        If ActComments <> "" And EventComments <> "" Then
            DescrSeparator = "<br /><br />"
        End If
        
        If ActComments <> "" Or EventComments <> "" Then
            DescriptionContentLabel.Text = EventComments & DescrSeparator & ActComments
            DescriptionContentLabel.Visible = True
            DescriptionHeaderPanel.Visible = True
            DescriptionContentPanel.Visible = True
        End If
        
        DBClose(DBTix)
        
    End Sub
</script>

<asp:Panel ID="DescriptionHeaderPanel" runat="server"  CssClass="PanelHeader TixClass2" Visible="False">
    <asp:Label ID="DescriptionHeaderLabel" runat="server" Text="Description" />
</asp:Panel>

<asp:Panel ID="DescriptionContentPanel" runat="server"  CssClass="PanelContent TixClass4" Visible="False">
    <asp:Label ID="DescriptionContentLabel" runat="server" Text="" Visible="false" />
</asp:Panel>
