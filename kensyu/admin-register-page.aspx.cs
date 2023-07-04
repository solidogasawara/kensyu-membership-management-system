using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text;
using System.Data.SqlClient;
using System.Configuration;
using System.Diagnostics;

namespace kensyu
{
    public partial class admin_register_page : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [System.Web.Services.WebMethod]
        public static string AdminRegister(string loginId, string inputtedPassword)
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

                if (reader.Read())
                {
                    int loginIdCount = Convert.ToInt32(reader["count"]);

                    if (loginIdCount == 1)
                    {
                        isLoginIdExist = true;
                    }
                }
            }

            if (isLoginIdExist)
            {
                return "loginId exists";
            }

            int count = 0;

            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                string query = "SELECT COUNT(*) AS count FROM M_Customer";
                SqlCommand command = new SqlCommand(query, connection);

                connection.Open();

                SqlDataReader reader = command.ExecuteReader();

                if (reader.Read())
                {
                    string countStr = reader["count"].ToString();
                    count = Convert.ToInt32(countStr);
                }
            }

            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand();

                StringBuilder sb = new StringBuilder();
                sb.Append(@"INSERT INTO M_Admin (id, role_id, login_id, salt, password, created_at)");
                sb.Append(@"VALUES (@id, @roleId, @loginId, @salt, @password, @createdAt)");

                string query = sb.ToString();

                int id = count + 1;
                string salt = AuthenticationManager.GenerateSalt();
                string password = AuthenticationManager.HashPassword(inputtedPassword, salt);
                DateTime createdAt = DateTime.Now;

                command.Parameters.Add(new SqlParameter("@id", id));
                command.Parameters.Add(new SqlParameter("@roleId", 2));
                command.Parameters.Add(new SqlParameter("@loginId", loginId));
                command.Parameters.Add(new SqlParameter("@salt", salt));
                command.Parameters.Add(new SqlParameter("@password", password));
                command.Parameters.Add(new SqlParameter("@createdAt", createdAt));

                command.CommandText = query;
                command.Connection = connection;

                connection.Open();

                using (SqlTransaction transaction = connection.BeginTransaction())
                {
                    try
                    {
                        command.Transaction = transaction;
                        command.ExecuteNonQuery();

                        transaction.Commit();

                        // 登録に成功したら、セッションを削除する
                        HttpContext context = HttpContext.Current;
                        context.Session.Remove("loginId");
                        context.Session.Remove("roleId");

                        return "success";
                    }
                    catch (SqlException e)
                    {
                        transaction.Rollback();
                        Debug.WriteLine(e.ToString());

                        if(e.Number == 2627)
                        {
                            return "loginId exists";
                        } else
                        {
                            return "unexpected error";
                        }
                    }
                    catch (Exception e)
                    {
                        transaction.Rollback();
                        Debug.WriteLine(e.ToString());

                        return "unexpected error";
                    }
                }
               
            }
        }
    }
}