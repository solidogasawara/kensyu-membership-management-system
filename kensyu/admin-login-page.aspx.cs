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
    public partial class admin_login_page : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if(!IsPostBack)
            {
                // ログイン済みなら、検索画面に飛ばす
                if (Session["loginId"] != null)
                {
                    Response.Redirect("~/member-searh.aspx");
                }
            }
        }

        // ログイン処理
        [System.Web.Services.WebMethod]
        public static string LoginProcess(string loginId, string inputtedPassword)
        {
            // 入力されたログインidが存在しているか
            bool isLoginIdExist = false;

            string connectionString = ConfigurationManager.ConnectionStrings["MyConnectionString"].ConnectionString;

            // ログインidの存在を確認する
            // もし登録されていないログインidが入力されたならその時点でログイン失敗となる
            using (SqlConnection connection = new SqlConnection(connectionString))
            using (SqlCommand command = new SqlCommand())
            {
                // 処理中に例外が発生した場合、"error"を返す
                try
                {
                    string query = @"SELECT COUNT(*) AS count FROM V_Admin WHERE login_id = @loginId AND delete_flag = 0";

                    command.Parameters.Add(new SqlParameter("@loginId", loginId));

                    command.CommandText = query;
                    command.Connection = connection;

                    connection.Open();

                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            int loginIdCount = Convert.ToInt32(reader["count"]);

                            // countが1ならログインidが存在することとみなし、フラグをtrueにする
                            if (loginIdCount == 1)
                            {
                                isLoginIdExist = true;
                            }
                        }
                    }
                }
                catch (Exception e)
                {
                    Debug.WriteLine(e.ToString());

                    return "error";
                }
            }

            // ログインidが存在しなかったなら、リザルトを返してこれ以降の処理を実行しない
            if(!isLoginIdExist)
            {
                return "incorrect";
            }

            // パスワードをチェックする
            using (SqlConnection connection = new SqlConnection(connectionString))
            using (SqlCommand command = new SqlCommand())
            {
                // パスワードチェック処理中に例外が発生した場合、"error"を返す
                try
                {
                    string query = @"SELECT role_id, salt, password FROM V_Admin WHERE login_id = @loginId AND delete_flag = 0";

                    command.Parameters.Add(new SqlParameter("@loginId", loginId));

                    command.CommandText = query;
                    command.Connection = connection;

                    connection.Open();

                    SqlDataReader reader = command.ExecuteReader();

                    if (reader.Read())
                    {
                        string salt = reader["salt"].ToString();
                        string password = reader["password"].ToString();

                        // 入力されたパスワードにDBに登録されているソルトを足してハッシュ化する
                        string hashedInputtedPassword = AuthenticationManager.HashPassword(inputtedPassword, salt);

                        // DBに登録されているハッシュ化されたパスワードとhashedInputtedPasswordを比較する
                        bool isMatch = AuthenticationManager.CheckPasswordMatch(hashedInputtedPassword, password);

                        // もし正しいパスワードだったなら、セッションを作成しリザルトを返す
                        if (isMatch)
                        {
                            int roleId = Convert.ToInt32(reader["role_id"]);

                            // ログインidとロールをセッションに登録する
                            HttpContext context = HttpContext.Current;
                            context.Session["loginId"] = loginId;
                            context.Session["roleId"] = roleId;

                            // ログイン成功
                            return "correct";
                        }
                    }
                }
                catch (Exception e)
                {
                    Debug.WriteLine(e.ToString());

                    return "error";
                }
            }

            // ログイン失敗
            return "incorrect";
        }
    }
}