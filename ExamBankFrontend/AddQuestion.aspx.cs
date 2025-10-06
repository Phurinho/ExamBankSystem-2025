using System;
using System.Data.SqlClient;
using System.Configuration;

namespace ExamBankFrontend
{
    public partial class AddQuestion : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                string connStr = ConfigurationManager.ConnectionStrings["ExamConn"].ConnectionString;
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    string sql = @"INSERT INTO Question 
                                   (QuestionText, ChoiceA, ChoiceB, ChoiceC, ChoiceD, CorrectAnswer)
                                   VALUES (@q, @a, @b, @c, @d, @ans)";
                    SqlCommand cmd = new SqlCommand(sql, con);
                    cmd.Parameters.AddWithValue("@q", txtQuestion.Text);
                    cmd.Parameters.AddWithValue("@a", txtA.Text);
                    cmd.Parameters.AddWithValue("@b", txtB.Text);
                    cmd.Parameters.AddWithValue("@c", txtC.Text);
                    cmd.Parameters.AddWithValue("@d", txtD.Text);
                    cmd.Parameters.AddWithValue("@ans", ddlAnswer.SelectedValue);

                    con.Open();
                    cmd.ExecuteNonQuery();
                }

                lblStatus.Text = "✅ Question saved successfully!";
                lblStatus.CssClass = "text-success fw-bold";
            }
            catch (Exception ex)
            {
                lblStatus.Text = "❌ Error: " + ex.Message;
                lblStatus.CssClass = "text-danger fw-bold";
            }
        }
    }
}
