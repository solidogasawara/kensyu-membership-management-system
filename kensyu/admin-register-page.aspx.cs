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
using System.Web.Script.Serialization;

namespace kensyu
{
    public partial class admin_register_page : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // まだログインしてないなら、ログイン画面に飛ばす
            if (Session["loginId"] == null)
            {
                Response.Redirect("~/admin-login-page.aspx");
            }
        }

        // 管理者登録
        [System.Web.Services.WebMethod]
        public static string AdminRegister(string loginId, string inputtedPassword)
        {
            // エラーメッセージを格納する変数
            string errorMsg = "";

            // 処理結果を格納するインスタンス
            AdminRegisterResult result = new AdminRegisterResult();

            // ログインidとパスワードの入力チェック
            AdminRegisterInputChecker checker = new AdminRegisterInputChecker();

            // 入力されたログインidかパスワードが不正か
            bool invalidinput = false;

            // 未入力チェック
            string[] datas = { loginId, inputtedPassword };

            foreach(string data in datas)
            {
                if(data == "")
                {
                    errorMsg = AdminRegisterCheckError.E001_EMPTY_INPUT;
                    invalidinput = true;
                    break;
                }
            }

            // ログインidの長さをチェック
            if(!checker.LoginIdLengthCheck(loginId))
            {
                errorMsg = AdminRegisterCheckError.E002_LOGINID_MAX_INPUT_EXCEEDED;
                invalidinput = true;
            }

            // パスワードの文字列をチェック
            // アルファベットの大文字、小文字、数字の組み合わせ以外は認めない
            if(!checker.PasswordValidationCheck(inputtedPassword))
            {
                errorMsg = AdminRegisterCheckError.E003_PASSWORD_INVALID;
                invalidinput = true;
            }

            // 不正な入力があったなら、Resultに"failed"を格納し、登録処理を実行しない
            if (invalidinput)
            {
                result.Result = "failed";
            }
            else
            {
                // 登録しようとしているログインidが既に登録されているidじゃないかを管理するフラグ
                // 登録済みだったならtrueになる
                bool isLoginIdExist = false;

                string connectionString = ConfigurationManager.ConnectionStrings["MyConnectionString"].ConnectionString;

                // ログインidの重複確認開始
                // 処理中に例外が発生した場合、Resultに"failed"を格納する
                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    SqlCommand command = null;
                    SqlDataReader reader = null;
                    try
                    {
                        command = new SqlCommand();

                        // ログインidの重複を調べるためのSQL文
                        string query = @"SELECT COUNT(*) AS count FROM V_Admin WHERE login_id = @loginId AND delete_flag = 0";

                        command.Parameters.Add(new SqlParameter("@loginId", loginId));

                        command.CommandText = query;
                        command.Connection = connection;

                        connection.Open();

                        reader = command.ExecuteReader();

                        // もしcountが1以上なら重複ありとみなす
                        if (reader.Read())
                        {
                            int loginIdCount = Convert.ToInt32(reader["count"]);

                            if (loginIdCount >= 1)
                            {
                                isLoginIdExist = true;
                            }
                        }

                        reader.Close();
                        command.Parameters.Clear();

                        // 重複ありだったならResultに"failed"を格納し、登録処理を実行しない
                        if (isLoginIdExist)
                        {
                            result.Result = "failed";
                            errorMsg = AdminRegisterError.E001_LOGINID_EXISTS;
                        }
                        else
                        {
                            // idを連番にするためにデータ数を調べる
                            int count = 0;

                            // データ数を調べる
                            query = "SELECT COUNT(*) AS count FROM M_Admin";
                            command.CommandText = query;

                            reader = command.ExecuteReader();

                            if (reader.Read())
                            {
                                string countStr = reader["count"].ToString();
                                count = Convert.ToInt32(countStr);
                            }

                            reader.Close();

                            // 登録処理開始
                            // パスワードはハッシュ化して保存する
                            // 登録処理中に例外が発生した場合、Resultに"failed"を格納する

                            StringBuilder sb = new StringBuilder();
                            sb.Append(@"INSERT INTO M_Admin (id, role_id, login_id, salt, password, created_at)");
                            sb.Append(@"VALUES (@id, @roleId, @loginId, @salt, @password, @createdAt)");

                            query = sb.ToString();

                            // 連番にするため、データ数に1を足す
                            int id = count + 1;

                            // ソルトを取得する
                            string salt = AuthenticationManager.GenerateSalt();
                            // 入力されたパスワードにソルトを足したものをハッシュ化する
                            string password = AuthenticationManager.HashPassword(inputtedPassword, salt);

                            // 登録日
                            DateTime createdAt = DateTime.Now;

                            command.Parameters.Add(new SqlParameter("@id", id));
                            command.Parameters.Add(new SqlParameter("@roleId", 2));
                            command.Parameters.Add(new SqlParameter("@loginId", loginId));
                            command.Parameters.Add(new SqlParameter("@salt", salt));
                            command.Parameters.Add(new SqlParameter("@password", password));
                            command.Parameters.Add(new SqlParameter("@createdAt", createdAt));

                            command.CommandText = query;
                            command.Connection = connection;

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

                                    // 成功
                                    result.Result = "success";
                                }
                                catch (SqlException e)
                                {
                                    transaction.Rollback();
                                    Debug.WriteLine(e.ToString());

                                    if (e.Number == 2627)
                                    {
                                        // 既に登録されているログインidを登録しようとした
                                        result.Result = "failed";
                                        errorMsg = AdminRegisterError.E001_LOGINID_EXISTS;
                                    }
                                    else
                                    {
                                        // 不明なエラー
                                        result.Result = "failed";
                                        errorMsg = AdminRegisterError.E1000_UNEXPECTED_ERROR;
                                    }
                                }
                                catch (Exception e)
                                {
                                    transaction.Rollback();
                                    Debug.WriteLine(e.ToString());

                                    // 不明なエラー
                                    result.Result = "failed";
                                    errorMsg = AdminRegisterError.E1000_UNEXPECTED_ERROR;
                                }
                            }
                        }
                    }
                    catch (Exception e)
                    {
                        Debug.WriteLine(e.ToString());

                        // 不明なエラー
                        result.Result = "failed";
                        errorMsg = AdminRegisterError.E1000_UNEXPECTED_ERROR;
                    } finally
                    {
                        if (command != null)
                        {
                            command.Dispose();
                        }
                        if (reader != null)
                        {
                            reader.Dispose();
                        }
                    }
                }
            }

            // エラーメッセージを格納する
            result.ErrorMsg = errorMsg;

            JavaScriptSerializer js = new JavaScriptSerializer();

            // Listをjsonの形にする
            string json = js.Serialize(result);

            // jsonを返す
            return json;
        }
    }
}