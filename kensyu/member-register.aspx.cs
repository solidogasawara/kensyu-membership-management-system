using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using Newtonsoft.Json;
using System.Text;
using System.Diagnostics;

namespace kensyu
{
    public partial class memberregister : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // まだログインしてないなら、ログイン画面に飛ばす
                if (Session["loginId"] == null)
                {
                    Response.Redirect("~/admin-login-page.aspx");
                }
            }
        }

        [System.Web.Services.WebMethod]
        public static string RegisterButton_Clicked(string lastName, string firstName, string lastNameKana, string firstNameKana, string email, string birthdayStr, string genderStr, string prefecture)
        {
            // 名前(漢字)
            string name = lastName + " " + firstName;
            // 名前(かな)
            string nameKana = lastNameKana + " " + firstNameKana;
            DateTime birthday = DateTime.Parse(birthdayStr);
            bool gender = false;

            if(genderStr == "1")
            {
                gender = true;
            }

            // 登録日
            DateTime createdAt = DateTime.Now;

            string connectionString = ConfigurationManager.ConnectionStrings["MyConnectionString"].ConnectionString;

            // idを連番にするために、データ数を取得する
            int count = 0;

            // データ数取得
            // 何らかの理由で取得に失敗した場合"failed"を返す
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                try
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
                } catch(Exception e)
                {
                    Debug.WriteLine(e.ToString());

                    return "failed";
                }
            }

            // 登録処理実行
            // 処理中に何らかの例外が発生した場合"failed"を、処理成功なら"success"を返す
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                try
                {
                    SqlCommand command = new SqlCommand();

                    StringBuilder sb = new StringBuilder();
                    sb.Append(@"INSERT INTO M_Customer (id, name, name_kana, mail, birthday, gender, prefecture_id, created_at)");
                    sb.Append(@"VALUES (@id, @name, @nameKana, @email, @birthday, @gender, @prefecture, @createdAt)");

                    // 連番にするためcountに1を足す
                    command.Parameters.Add(new SqlParameter("@id", count + 1));
                    command.Parameters.Add(new SqlParameter("@name", name));
                    command.Parameters.Add(new SqlParameter("@nameKana", nameKana));
                    command.Parameters.Add(new SqlParameter("@email", email));
                    command.Parameters.Add(new SqlParameter("@birthday", birthday));
                    command.Parameters.Add(new SqlParameter("@gender", gender));
                    command.Parameters.Add(new SqlParameter("@prefecture", prefecture));
                    command.Parameters.Add(new SqlParameter("@createdAt", createdAt));

                    command.CommandText = sb.ToString();
                    command.Connection = connection;

                    connection.Open();

                    // 例外発生時、登録処理をキャンセルする
                    using (SqlTransaction transaction = connection.BeginTransaction())
                    {
                        try
                        {
                            command.Transaction = transaction;
                            command.ExecuteNonQuery();

                            transaction.Commit();

                            return "success";
                        } catch(Exception e)
                        {
                            transaction.Rollback();
                            Debug.WriteLine(e.ToString());

                            return "failed";
                        }
                    }
                } catch(Exception e)
                {
                    Debug.WriteLine(e.ToString());

                    return "failed";
                }     
            }
        }
    }
}