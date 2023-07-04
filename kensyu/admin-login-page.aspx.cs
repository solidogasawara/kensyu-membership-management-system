using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text;
using System.Data.SqlClient;
using System.Configuration;

namespace kensyu
{
    public partial class admin_login_page : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if(!IsPostBack)
            {
                if (Session["loginId"] != null)
                {
                    Response.Redirect("~/member-searh.aspx");
                }
            }
        }

        [System.Web.Services.WebMethod]
        public static string LoginProcess(string loginId, string inputtedPassword)
        {
            bool isLoginIdExist = false;

            string connectionString = ConfigurationManager.ConnectionStrings["MyConnectionString"].ConnectionString;

            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand();

                string query = @"SELECT COUNT(*) AS count FROM V_Admin WHERE login_id = @loginId AND delete_flag = 0";

                command.Parameters.Add(new SqlParameter("@loginId", loginId));

                command.CommandText = query;
                command.Connection = connection;

                connection.Open();

                SqlDataReader reader = command.ExecuteReader();

                if(reader.Read())
                {
                    int loginIdCount = Convert.ToInt32(reader["count"]);

                    if(loginIdCount == 1)
                    {
                        isLoginIdExist = true;
                    }
                }
            }

            if(!isLoginIdExist)
            {
                return "incorrect";
            }

            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand();

                string query = @"SELECT role_id, salt, password FROM V_Admin WHERE login_id = @loginId AND delete_flag = 0";

                command.Parameters.Add(new SqlParameter("@loginId", loginId));

                command.CommandText = query;
                command.Connection = connection;

                connection.Open();

                SqlDataReader reader = command.ExecuteReader();

                if(reader.Read())
                {
                    string salt = reader["salt"].ToString();
                    string password = reader["password"].ToString();

                    string hashedInputtedPassword = AuthenticationManager.HashPassword(inputtedPassword, salt);

                    bool isMatch = AuthenticationManager.CheckPasswordMatch(hashedInputtedPassword, password);

                    if(isMatch)
                    {
                        int roleId = Convert.ToInt32(reader["role_id"]);

                        HttpContext context = HttpContext.Current;
                        context.Session["loginId"] = loginId;
                        context.Session["roleId"] = roleId;

                        return "correct";
                    }
                }
            }
                return "incorrect";
        }
    }
}