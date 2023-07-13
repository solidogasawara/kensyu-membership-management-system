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
using System.Web.Script.Serialization;

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
            // エラーメッセージを格納するList
            List<string> errorMsgs = new List<string>();

            // 処理結果を格納するインスタンス
            MemberResult result = new MemberResult();

            // 不正な入力がされたか
            bool invalidInput = false;

            // 入力チェックを行う
            // それぞれの値が不正ならエラーメッセージを追加していく
            MemberInputChecker checker = new MemberInputChecker();

            // lastNameとfirstNameが漢字、ひらがな、カタカナのみの文字列かチェックする
            if(!checker.NameKanjiCheck(lastName))
            {
                errorMsgs.Add(MemberInputCheckError.E001_NON_KANJI_LASTNAME);
                invalidInput = true;
            }

            if(!checker.NameKanjiCheck(firstName))
            {
                errorMsgs.Add(MemberInputCheckError.E002_NON_KANJI_FIRSTNAME);
                invalidInput = true;
            }

            // lastNameKanaとfirstNameKanaがひらがなのみの文字列かチェックする
            if(!checker.NameHiraganaCheck(lastNameKana))
            {
                errorMsgs.Add(MemberInputCheckError.E003_NON_HIRAGANA_LASTNAME);
                invalidInput = true;
            }

            if(!checker.NameHiraganaCheck(firstNameKana))
            {
                errorMsgs.Add(MemberInputCheckError.E004_NON_HIRAGANA_FIRSTNAME);
                invalidInput = true;
            }

            // メールアドレスの形式をチェックする
            if(!checker.EmailValidationCheck(email))
            {
                errorMsgs.Add(MemberInputCheckError.E005_INVALID_EMAIL);
                invalidInput = true;
            }

            // 生年月日が不正でないかチェックする
            if(!checker.BirthdayValidationCheck(birthdayStr))
            {
                errorMsgs.Add(MemberInputCheckError.E006_INVALID_BIRTHDAY);
                invalidInput = true;
            }

            // 性別が不正でないかチェックする
            if (!checker.GenderValidationCheck(genderStr))
            {
                errorMsgs.Add(MemberInputCheckError.E007_INVALID_GENDER);
                invalidInput = true;
            }

            // 都道府県が不正でないかチェックする
            if (!checker.PrefectureValidationCheck(prefecture))
            {
                errorMsgs.Add(MemberInputCheckError.E008_INVALID_PREFECTURE);
                invalidInput = true;
            }

            // 空文字チェックを行う
            string[] datas =
            {
                lastName, firstName, lastNameKana, firstNameKana, email, birthdayStr, genderStr, prefecture
            };

            foreach(string data in datas)
            {
                if(string.IsNullOrEmpty(data))
                {
                    errorMsgs.Add(MemberInputCheckError.E010_EMPTY_INPUT);
                    invalidInput = true;
                    break;
                }
            }

            if(invalidInput)
            {
                // 処理が失敗したことをクライアント側に伝える
                result.Result = "failed";
                // エラーメッセージを返す
                result.ErrorMsgs = errorMsgs;
            } else
            {
                // 名前
                string name = lastName + " " + firstName;
                // 名前(かな)
                string nameKana = lastNameKana + " " + firstNameKana;
                DateTime birthday = DateTime.Parse(birthdayStr);
                bool gender = false;

                if (genderStr == "1")
                {
                    gender = true;
                }

                // 登録日
                DateTime createdAt = DateTime.Now;

                string connectionString = ConfigurationManager.ConnectionStrings["MyConnectionString"].ConnectionString;

                // idを連番にするために、データ数を取得する
                int count = 0;

                
                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    try
                    {
                        // データ数取得
                        // 何らかの理由で取得に失敗した場合"failed"を返す

                        string query = "SELECT COUNT(*) AS count FROM M_Customer";
                        SqlCommand command = new SqlCommand(query, connection);

                        connection.Open();

                        SqlDataReader reader = command.ExecuteReader();

                        if (reader.Read())
                        {
                            string countStr = reader["count"].ToString();
                            count = Convert.ToInt32(countStr);
                        }

                        reader.Close();

                        // 登録処理実行
                        // 処理中に何らかの例外が発生した場合"failed"を、処理成功なら"success"を返す

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

                        // 例外発生時、登録処理をキャンセルする
                        using (SqlTransaction transaction = connection.BeginTransaction())
                        {
                            try
                            {
                                command.Transaction = transaction;
                                command.ExecuteNonQuery();

                                transaction.Commit();

                                result.Result = "success";
                            }
                            catch (Exception e)
                            {
                                transaction.Rollback();
                                Debug.WriteLine(e.ToString());

                                errorMsgs.Add(MemberError.E001_EXCEPTION);
                                result.Result = "failed";
                            }
                        }
                    }
                    catch (Exception e)
                    {
                        Debug.WriteLine(e.ToString());

                        errorMsgs.Add(MemberError.E001_EXCEPTION);
                        result.Result = "failed";
                    }
                }
            }

            // エラーメッセージを格納
            result.ErrorMsgs = errorMsgs;

            JavaScriptSerializer js = new JavaScriptSerializer();

            // Listをjsonの形にする
            string json = js.Serialize(result);

            // jsonを返す
            return json;
        }
    }
}