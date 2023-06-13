<%@ Page Title="About" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="About.aspx.cs" Inherits="kensyu.About" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <h2><%: Title %>.</h2>
    <h3>あなたのアプリケーションの説明ページ。</h3>
    <p>ここに追加情報を提供してください。</p>

    <button id="SearchButton">検索</button>

    <div id="ResultsArea">
        <!-- 検索結果はここにJavaScriptによって表示されます -->
    </div>

    <script src="About.js"></script>
</asp:Content>