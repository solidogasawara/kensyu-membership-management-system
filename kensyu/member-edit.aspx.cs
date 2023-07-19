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
using System.Web.Script.Serialization;
using System.Diagnostics;

namespace kensyu
{
    public partial class memberedit : Page
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

        // idを元に会員情報を返す
        [System.Web.Services.WebMethod]
        public static string GetCustomerInfoById(string idStr)
        {
            int id = Convert.ToInt32(idStr);

            string connectionString = ConfigurationManager.ConnectionStrings["MyConnectionString"].ConnectionString;

            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                // SQL文を実行して取得したデータを格納するList
                List<Customer> customerData = new List<Customer>();

                // 会員情報取得中に例外が発生した場合"failed"を返す
                try
                {
                    SqlCommand command = new SqlCommand();

                    // SQL文
                    string query = @"SELECT name, name_kana, mail, birthday, gender, prefecture_id, membership_status FROM V_Customer WHERE id = @id";

                    command.Parameters.Add(new SqlParameter("@id", id));

                    // クエリとコネクションを指定する
                    command.CommandText = query;
                    command.Connection = connection;

                    connection.Open();

                    SqlDataReader reader = command.ExecuteReader();

                    if (reader.Read())
                    {
                        Customer customer = new Customer();

                        customer.name = reader["name"].ToString();
                        customer.nameKana = reader["name_kana"].ToString();
                        customer.mail = reader["mail"].ToString();

                        DateTime birthday = (DateTime)reader["birthday"];
                        customer.birthday = birthday.ToString("yyyy-MM-dd");

                        customer.gender = (bool)reader["gender"] ? "2" : "1";
                        customer.prefecture = reader["prefecture_id"].ToString();
                        customer.membershipStatus = (bool)reader["membership_status"] ? "1" : "2";

                        customerData.Add(customer);
                    }
                    reader.Close();
                } catch(Exception e)
                {
                    Debug.WriteLine(e.ToString());

                    return "failed";
                }

                JavaScriptSerializer js = new JavaScriptSerializer();

                // Listをjsonの形にする
                string json = js.Serialize(customerData);

                return json;
            }
        }

        // 会員情報を更新する処理
        [System.Web.Services.WebMethod]
        public static string UpdateCustomerInfo(string idStr, string lastNameStr, string firstNameStr, string lastNameKanaStr, string firstNameKanaStr, string emailStr, string birthdayStr, string genderStr, string prefectureStr, string membershipStatusStr)
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

            // lastNameKanaとfirstNameKanaがひらがなのみの文字列かチェックする
            if (!checker.NameHiraganaCheck(lastNameKanaStr))
            {
                errorMsgs.Add(MemberInputCheckError.E003_NON_HIRAGANA_LASTNAME);
                invalidInput = true;
            }

            if (!checker.NameHiraganaCheck(firstNameKanaStr))
            {
                errorMsgs.Add(MemberInputCheckError.E004_NON_HIRAGANA_FIRSTNAME);
                invalidInput = true;
            }

            // メールアドレスの形式をチェックする
            if (!checker.EmailValidationCheck(emailStr))
            {
                errorMsgs.Add(MemberInputCheckError.E005_INVALID_EMAIL);
                invalidInput = true;
            }

            // 生年月日が不正でないかチェックする
            if (!checker.BirthdayValidationCheck(birthdayStr))
            {
                errorMsgs.Add(MemberInputCheckError.E006_INVALID_BIRTHDAY);
                invalidInput = true;
            }

            // 性別が不正でないかチェックする
            if(!checker.GenderValidationCheck(genderStr))
            {
                errorMsgs.Add(MemberInputCheckError.E007_INVALID_GENDER);
                invalidInput = true;
            }

            // 都道府県が不正でないかチェックする
            if (!checker.PrefectureValidationCheck(prefectureStr))
            {
                errorMsgs.Add(MemberInputCheckError.E008_INVALID_PREFECTURE);
                invalidInput = true;
            }

            // 会員状態が不正でないかチェックする
            if(!checker.MembershipStatusValidationCheck(membershipStatusStr))
            {
                errorMsgs.Add(MemberInputCheckError.E009_INVALID_MEMBERSHIPSTATUS);
                invalidInput = true;
            } 

            // 空文字チェックを行う
            string[] datas =
            {
                lastNameStr, firstNameStr, lastNameKanaStr, firstNameKanaStr, emailStr, birthdayStr, genderStr, prefectureStr
            };

            foreach (string data in datas)
            {
                if (string.IsNullOrEmpty(data))
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
                int id = Convert.ToInt32(idStr);
                string name = lastNameStr + " " + firstNameStr;
                string nameKana = lastNameKanaStr + " " + firstNameKanaStr;
                DateTime birthday = DateTime.Parse(birthdayStr);

                // 男性: false, 女性: true
                bool gender = false;
                // genderStrが2なら女性を表す
                if (genderStr == "2")
                {
                    gender = true;
                }

                int prefectureId = Convert.ToInt32(prefectureStr);

                // 退会: false, 有効: true
                bool membershipStatus = false;
                // membershipStatusStrが1なら有効を表す
                if (membershipStatusStr == "1")
                {
                    membershipStatus = true;
                }

                DateTime updatedAt = DateTime.Now;

                string connectionString = ConfigurationManager.ConnectionStrings["MyConnectionString"].ConnectionString;

                // 更新処理開始
                // 更新時に例外が発生した場合、"failed"を、
                // 成功したなら"success"を返す
                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    try
                    {
                        SqlCommand command = new SqlCommand();

                        StringBuilder sb = new StringBuilder();

                        // SQL文を作成する
                        sb.Append(@"UPDATE M_Customer");
                        sb.Append(@"   SET name = @name,");
                        sb.Append(@"       name_kana = @nameKana,");
                        sb.Append(@"       mail = @email,");
                        sb.Append(@"       birthday = @birthday,");
                        sb.Append(@"       gender = @gender,");
                        sb.Append(@"       prefecture_id = @prefectureId,");
                        sb.Append(@"       membership_status = @membershipStatus,");
                        sb.Append(@"       updated_at = @updatedAt");
                        sb.Append(@" WHERE id = @id");

                        command.Parameters.Add(new SqlParameter("@name", name));
                        command.Parameters.Add(new SqlParameter("@nameKana", nameKana));
                        command.Parameters.Add(new SqlParameter("@email", emailStr));
                        command.Parameters.Add(new SqlParameter("@birthday", birthday));
                        command.Parameters.Add(new SqlParameter("@gender", gender));
                        command.Parameters.Add(new SqlParameter("@prefectureId", prefectureId));
                        command.Parameters.Add(new SqlParameter("@membershipStatus", membershipStatus));
                        command.Parameters.Add(new SqlParameter("@updatedAt", updatedAt));
                        command.Parameters.Add(new SqlParameter("@id", id));

                        command.CommandText = sb.ToString();
                        command.Connection = connection;

                        connection.Open();

                        // SqlTransactionを利用して、例外が発生した時は更新処理を中断するようにしている
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

                                result.Result = "failed";
                                errorMsgs.Add(MemberError.E001_EXCEPTION);
                            }
                        }
                    }
                    catch (Exception e)
                    {
                        Debug.WriteLine(e.ToString());

                        result.Result = "failed";
                        errorMsgs.Add(MemberError.E001_EXCEPTION);
                    }
                }
            }

            // エラーメッセージを格納する
            result.ErrorMsgs = errorMsgs;

            JavaScriptSerializer js = new JavaScriptSerializer();

            // Listをjsonの形にする
            string json = js.Serialize(result);

            // jsonを返す
            return json;
        }
    }
}