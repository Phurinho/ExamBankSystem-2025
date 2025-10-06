<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AddQuestion.aspx.cs" Inherits="ExamBankFrontend.AddQuestion" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Add Question | Exam Bank</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
</head>
<body class="bg-light">
    <form id="form1" runat="server" class="container mt-5">
        <div class="card p-4 shadow-sm">
            <h3 class="text-center mb-4">📝 Add New Question</h3>

            <div class="mb-3">
                <label for="txtQuestion" class="form-label">Question Text</label>
                <asp:TextBox ID="txtQuestion" runat="server" CssClass="form-control"></asp:TextBox>
            </div>

            <div class="row">
                <div class="col-md-6 mb-3">
                    <label>Choice A</label>
                    <asp:TextBox ID="txtA" runat="server" CssClass="form-control"></asp:TextBox>
                </div>
                <div class="col-md-6 mb-3">
                    <label>Choice B</label>
                    <asp:TextBox ID="txtB" runat="server" CssClass="form-control"></asp:TextBox>
                </div>
            </div>

            <div class="row">
                <div class="col-md-6 mb-3">
                    <label>Choice C</label>
                    <asp:TextBox ID="txtC" runat="server" CssClass="form-control"></asp:TextBox>
                </div>
                <div class="col-md-6 mb-3">
                    <label>Choice D</label>
                    <asp:TextBox ID="txtD" runat="server" CssClass="form-control"></asp:TextBox>
                </div>
            </div>

            <div class="mb-3">
                <label>Correct Answer</label>
                <asp:DropDownList ID="ddlAnswer" runat="server" CssClass="form-select">
                    <asp:ListItem>A</asp:ListItem>
                    <asp:ListItem>B</asp:ListItem>
                    <asp:ListItem>C</asp:ListItem>
                    <asp:ListItem>D</asp:ListItem>
                </asp:DropDownList>
            </div>

            <div class="text-center">
                <asp:Button ID="btnSave" runat="server" Text="Save Question" CssClass="btn btn-primary" OnClick="btnSave_Click" />
            </div>

            <div class="text-center mt-3">
                <asp:Label ID="lblStatus" runat="server" CssClass="fw-bold"></asp:Label>
            </div>
        </div>
    </form>
</body>
</html>
