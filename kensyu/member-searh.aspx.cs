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
    public partial class membersearh : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            

            if (!IsPostBack)
            {

            }
        }

        protected void SearchButton_Click(object sender, EventArgs e)
        {
            ViewState.Clear();

            // 入力されたパラメータを取得する

            // 全件表示フラグ(性別や会員状態のチェックボックスに両方チェックが入った場合全件表示にする)
            bool dispAll = false;

            int id = -1; // 会員ID(初期値は-1)

            // ID検索欄に文字列が入力されているなら、int型に変換してidに代入する
            if (!String.IsNullOrEmpty(Request.QueryString["id"]))
            {
                id = Convert.ToInt32(Request.QueryString["id"]);
            }

            string email = Request.QueryString["email"]; // メールアドレス
            string name = Request.QueryString["name"]; // 名前(漢字)
            string nameKana = Request.QueryString["name_kana"]; // 名前(かな)

            // 誕生日検索
            DateTime birthStart = DateTime.Now; // 始めの日付(初期値は検索実行した時の時刻)
            DateTime birthEnd = DateTime.Now; // 終わりの日付(初期値は検索実行した時の時刻)

            // 誕生日検索欄(始めの日付)に入力がされていれば、DateTime型にParseしてbirthStartに代入する
            if(!String.IsNullOrEmpty(Request.QueryString["birth-start"]))
            {
                birthStart = DateTime.Parse(Request.QueryString["birth-start"]);
            }

            // 誕生日検索欄(終わりの日付)に入力がされていれば、DateTime型にParseしてbirthStartに代入する
            if (!String.IsNullOrEmpty(Request.QueryString["birth-end"]))
            {
                birthEnd = DateTime.Parse(Request.QueryString["birth-end"]);
            }

            // 性別(パラメータ: 1 = 男性, 2 = 女性)
            bool gender = false; // 性別(false = 男性, true = 女性)
            bool isEmptyGender = true; // 性別のパラメータの中身があるかを管理するフラグ(初期値はtrue)

            // 男性、女性どちらかのチェックボックスにチェックが入っていて、
            // 性別のパラメータに中身があるならフラグをfalseにする
            if(!String.IsNullOrEmpty(Request.QueryString["sex[]"]))
            {
                // パラメータに中身が入っていたので、フラグをfalseにする
                isEmptyGender = false;

                // 取得したパラメータ
                string parameter = Request.QueryString["sex[]"];

                // 男性、女性のどちらのチェックボックスにもチェックが入っていた場合、
                // 「1,2」のような形でparameterに代入されている
                // Splitメソッドでカンマ区切りで文字列を配列に分割してその長さが1より大きければ、
                // 2つのチェックボックスにチェックが入っているとみなして、全件表示フラグをtrueにする
                if (parameter.Split(',').Length > 1)
                {
                    dispAll = true;
                } else
                {
                    // 受け取ったパラメータをint型に変換する
                    int genderNumber = Convert.ToInt32(parameter);

                    // パラメータは1が男性、2が女性を表しているため、genderNumberが2だった場合は
                    // genderをtrueにする
                    if (genderNumber == 2)
                    {
                        gender = true;
                    }
                }
            }

            int prefecture_id = -1; // 都道府県(初期値は-1)
            
            // 都道府県が指定されていたなら、int型に変換してprefecture_idに代入する
            if (!String.IsNullOrEmpty(Request.QueryString["prefecture"]))
            {
                prefecture_id = Convert.ToInt32(Request.QueryString["prefecture"]);
            }

            // 会員状態(パラメータ: 1 = 有効, 2 = 無効)
            bool membershipStatus = false; // 会員状態(false = 無効, true = 有効)
            bool isEmptyMembershipStatus = true;

            // 有効、無効どちらかのチェックボックスにチェックが入っていて、
            // 会員状態のパラメータに中身があるならフラグをfalseにする
            if(!String.IsNullOrEmpty(Request.QueryString["member-status[]"]))
            {
                // パラメータに中身が入っていたので、フラグをfalseにする
                isEmptyMembershipStatus = false;

                // 取得したパラメータ
                string parameter = Request.QueryString["member-status[]"];

                // 有効、無効のどちらのチェックボックスにもチェックが入っていた場合、
                // 「1,2」のような形でparameterに代入されている
                // Splitメソッドでカンマ区切りで文字列を配列に分割してその長さが1より大きければ、
                // 2つのチェックボックスにチェックが入っているとみなして、全件表示フラグをtrueにする
                if(parameter.Split(',').Length > 1)
                {
                    dispAll = true;
                } else
                {
                    // 受け取ったパラメータをint型に変換する
                    int membershipStatusNumber = Convert.ToInt32(parameter);

                    // パラメータは1が有効、2が無効を表しているため、membershipStatusNumberが1だった場合は
                    // membershipStatusをtrueにする
                    if (membershipStatusNumber == 1)
                    {
                        membershipStatus = true;
                    }
                }
            }

            string connectionString = ConfigurationManager.ConnectionStrings["MyConnectionString"].ConnectionString;
            //string query = "SELECT * FROM V_Customer";

            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand();

                // SQL文を作成する
                StringBuilder sb = new StringBuilder();
                sb.Append(@"SELECT c.id, name, name_kana, mail, birthday, gender, p.prefecture, membership_status FROM V_Customer AS c");
                sb.Append(@"  JOIN M_Prefecture AS p");
                sb.Append(@"    ON c.prefecture_id = p.id");

                // 全件表示フラグがfalseの時だけ、検索条件を追加していく
                if (!dispAll)
                {
                    // 検索条件(id)
                    sb.Append(@" WHERE c.id = @id");
                    command.Parameters.Add(new SqlParameter("@id", id));

                    // nameの中身が空なら検索条件にnameを含めない
                    if (!String.IsNullOrEmpty(name))
                    {
                        // 検索条件(name)
                        sb.Append(@"    OR name LIKE @name");
                        command.Parameters.Add(new SqlParameter("@name", "%" + name + "%"));
                    }

                    // nameKanaの中身が空なら検索条件にname_kanaを含めない
                    if (!String.IsNullOrEmpty(nameKana))
                    {
                        // 検索条件(name_kana)
                        sb.Append(@"    OR name_kana LIKE @nameKana");
                        command.Parameters.Add(new SqlParameter("@nameKana", "%" + nameKana + "%"));
                    }

                    // 検索条件(mail)
                    sb.Append(@"    OR mail = @email");
                    command.Parameters.Add(new SqlParameter("@email", email));

                    // 検索条件(birthday)
                    sb.Append(@"    OR birthday BETWEEN @birthStart AND @birthEnd");
                    command.Parameters.Add(new SqlParameter("@birthStart", birthStart));
                    command.Parameters.Add(new SqlParameter("@birthEnd", birthEnd));

                    // 性別のパラメータが空なら検索条件にgenderを含めない
                    if (!isEmptyGender)
                    {
                        // 検索条件(gender)
                        sb.Append(@"    OR gender = @gender");
                        command.Parameters.Add(new SqlParameter("@gender", gender));
                    }

                    // 検索条件(prefecture_id)
                    sb.Append(@"    OR prefecture_id = @prefecture");
                    command.Parameters.Add(new SqlParameter("@prefecture", prefecture_id));

                    // 会員状態のパラメータが空なら検索条件にmembership_statusを含めない
                    if (!isEmptyMembershipStatus)
                    {
                        // 検索条件(membership_status)
                        sb.Append(@"    OR membership_status = @membershipStatus");
                        command.Parameters.Add(new SqlParameter("@membershipStatus", membershipStatus));
                    }
                }

                // 作成したsqlをstring型にする
                string query = sb.ToString();

                // クエリとコネクションを指定する
                command.CommandText = query;
                command.Connection = connection;

                connection.Open();

                SqlDataAdapter da = new SqlDataAdapter(command);
                DataTable dt = new DataTable();
                da.Fill(dt);

                DataRow[] rows = dt.Select();
                

                Repeater1.DataSource = dt;
                Repeater1.DataBind();
            }
        }

        [System.Web.Services.WebMethod]
        public static void SortTable(string columnName)
        {
            Debug.WriteLine(columnName);
        }
    }
}