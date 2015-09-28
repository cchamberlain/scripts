<%@ Page MasterPageFile="~/TixInner.master" CodeFile="~/Secure/OrderConfirmation.aspx.vb" Inherits="OrderConfirmation" AutoEventWireup="false" title="Tix - Order Confirmation" %>
<%@ MasterType virtualPath="~/TixInner.master"%>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Web.Mail" %>

<script runat="server">
    'CHANGE LOG
    '9/24/15 TTT - Modified to include tooltip
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="TixInnerHead" Runat="Server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="TixInnerContent" Runat="Server">
    <!--#INCLUDE VIRTUAL="~/TooltipInclude.html" -->
    <asp:Panel ID="pnlOrderConfirmation" runat="server" />
</asp:Content>

