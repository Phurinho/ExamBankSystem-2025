<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ViewQuestion.aspx.cs" Inherits="ExamBankFrontend.ViewQuestion" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <asp:GridView ID="GridView1" runat="server" 
    AutoGenerateColumns="False" 
    DataKeyNames="QuestionID"
    CssClass="table table-bordered"
    HeaderStyle-BackColor="#007bff"
    HeaderStyle-ForeColor="White">
    
    <Columns>
        <asp:BoundField DataField="QuestionID" HeaderText="ID" />
        <asp:BoundField DataField="QuestionText" HeaderText="Question" />
        <asp:BoundField DataField="OptionA" HeaderText="A" />
        <asp:BoundField DataField="OptionB" HeaderText="B" />
        <asp:BoundField DataField="OptionC" HeaderText="C" />
        <asp:BoundField DataField="OptionD" HeaderText="D" />
        <asp:BoundField DataField="CorrectAnswer" HeaderText="Answer" />
    </Columns>
</asp:GridView>

    </form>
</body>
</html>
