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
using System.Reflection;

namespace kensyu
{
    public partial class membersearh : Page
    {

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // まだログインしてないならログイン画面に飛ばす
                if(Session["loginId"] == null)
                {
                    Response.Redirect("~/admin-login-page.aspx");
                }
            }
        }

        [System.Web.Services.WebMethod]
        public static string SearchButton_Click(string idStr, string emailStr, string nameStr, string nameKanaStr, string birthStartStr, string birthEndStr, string prefectureStr, string genderStr, string memberStatusStr, string pageNumber, string resultAll)
        {
            // 検索結果を格納するList
            Dictionary<string, object> tableData = null;

            // 検索結果取得処理で例外が発生した場合、"failed"を返す
            try
            {
                // 検索結果を取得する
                tableData = SearchCustomer(idStr, emailStr, nameStr, nameKanaStr, birthStartStr, birthEndStr, prefectureStr, genderStr, memberStatusStr, pageNumber, resultAll);
            } catch(Exception e)
            {
                Debug.WriteLine(e.ToString());

                return "failed";
            }

            JavaScriptSerializer js = new JavaScriptSerializer();

            // Listをjsonの形にする
            string json = js.Serialize(tableData);

            return json;
        }

        private static Dictionary<string, object> SearchCustomer(string idStr, string emailStr, string nameStr, string nameKanaStr, string birthStartStr, string birthEndStr, string prefectureStr, string genderStr, string memberStatusStr, string pageNumber, string resultAll)
        {
            // 入力されたパラメータを取得する

            // 全件表示フラグ(性別や会員状態のチェックボックスに両方チェックが入った場合全件表示にする)
            bool dispAll = false;

            int id = -1; // 会員ID(初期値は-1)

            // ID検索欄に文字列が入力されているなら、int型に変換してidに代入する
            if (!String.IsNullOrEmpty(idStr))
            {
                id = Convert.ToInt32(idStr);
            }

            string email = emailStr; // メールアドレス
            string name = nameStr; // 名前(漢字)
            string nameKana = nameKanaStr; // 名前(かな)

            // 誕生日検索
            DateTime birthStart = DateTime.Now; // 始めの日付(初期値は検索実行した時の時刻)
            DateTime birthEnd = DateTime.Now; // 終わりの日付(初期値は検索実行した時の時刻)

            // 誕生日検索欄(始めの日付)に入力がされていれば、DateTime型にParseしてbirthStartに代入する
            if (!String.IsNullOrEmpty(birthStartStr))
            {
                birthStart = DateTime.Parse(birthStartStr);
            }

            // 誕生日検索欄(終わりの日付)に入力がされていれば、DateTime型にParseしてbirthStartに代入する
            if (!String.IsNullOrEmpty(birthEndStr))
            {
                birthEnd = DateTime.Parse(birthEndStr);
            }

            // 性別(パラメータ: 1 = 男性, 2 = 女性)
            bool gender = false; // 性別(false = 男性, true = 女性)
            bool isEmptyGender = true; // 性別のパラメータの中身があるかを管理するフラグ(初期値はtrue)

            // 男性、女性どちらかのチェックボックスにチェックが入っていて、
            // 性別のパラメータに中身があるならフラグをfalseにする
            if (!String.IsNullOrEmpty(genderStr))
            {
                // パラメータに中身が入っていたので、フラグをfalseにする
                isEmptyGender = false;

                // 男性、女性のどちらのチェックボックスにもチェックが入っていた場合、
                // 「both」が渡される
                if (genderStr == "both")
                {
                    dispAll = true;
                }
                else
                {
                    // 受け取ったパラメータをint型に変換する
                    int genderNumber = Convert.ToInt32(genderStr);

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
            if (!String.IsNullOrEmpty(prefectureStr))
            {
                prefecture_id = Convert.ToInt32(prefectureStr);
            }

            // 会員状態(パラメータ: 1 = 有効, 2 = 退会)
            bool membershipStatus = false; // 会員状態(false = 退会, true = 有効)
            bool isEmptyMembershipStatus = true;

            // 有効、無効どちらかのチェックボックスにチェックが入っていて、
            // 会員状態のパラメータに中身があるならフラグをfalseにする
            if (!String.IsNullOrEmpty(memberStatusStr))
            {
                // パラメータに中身が入っていたので、フラグをfalseにする
                isEmptyMembershipStatus = false;

                // 有効、無効のどちらのチェックボックスにもチェックが入っていた場合、
                // 「both」が渡される
                if (memberStatusStr == "both")
                {
                    dispAll = true;
                }
                else
                {
                    // 受け取ったパラメータをint型に変換する
                    int membershipStatusNumber = Convert.ToInt32(memberStatusStr);

                    // パラメータは1が有効、2が無効を表しているため、membershipStatusNumberが1だった場合は
                    // membershipStatusをtrueにする
                    if (membershipStatusNumber == 1)
                    {
                        membershipStatus = true;
                    }
                }
            }

            string connectionString = ConfigurationManager.ConnectionStrings["MyConnectionString"].ConnectionString;

            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand();

                // SQL文を作成するためのListを用意する
                List<string> sql = new List<string>();

                // 先に、検索結果が何件なのかを取得してその後、会員データを取得する
                sql.Add(@"SELECT COUNT(*) AS count FROM V_Customer AS c");
                sql.Add(@"  JOIN M_Prefecture AS p");
                sql.Add(@"    ON c.prefecture_id = p.id");
                sql.Add(@" WHERE delete_flag = 'FALSE'");

                // 全件表示フラグがfalseの時だけ、検索条件を追加していく
                if (!dispAll)
                {
                    // 検索条件(id)
                    sql.Add(@"   AND (c.id = @id");
                    command.Parameters.Add(new SqlParameter("@id", id));

                    // nameの中身が空なら検索条件にnameを含めない
                    if (!String.IsNullOrEmpty(name))
                    {
                        // 検索条件(name)
                        sql.Add(@"    OR name LIKE @name");
                        command.Parameters.Add(new SqlParameter("@name", "%" + name + "%"));
                    }

                    // nameKanaの中身が空なら検索条件にname_kanaを含めない
                    if (!String.IsNullOrEmpty(nameKana))
                    {
                        // 検索条件(name_kana)
                        sql.Add(@"    OR name_kana LIKE @nameKana");
                        command.Parameters.Add(new SqlParameter("@nameKana", "%" + nameKana + "%"));
                    }

                    // 検索条件(mail)
                    sql.Add(@"    OR mail = @email");
                    command.Parameters.Add(new SqlParameter("@email", email));

                    // 検索条件(birthday)
                    sql.Add(@"    OR birthday BETWEEN @birthStart AND @birthEnd");
                    command.Parameters.Add(new SqlParameter("@birthStart", birthStart));
                    command.Parameters.Add(new SqlParameter("@birthEnd", birthEnd));

                    // 性別のパラメータが空なら検索条件にgenderを含めない
                    if (!isEmptyGender)
                    {
                        // 検索条件(gender)
                        sql.Add(@"    OR gender = @gender");
                        command.Parameters.Add(new SqlParameter("@gender", gender));
                    }

                    // 検索条件(prefecture_id)
                    sql.Add(@"    OR prefecture_id = @prefecture");
                    command.Parameters.Add(new SqlParameter("@prefecture", prefecture_id));

                    // 会員状態のパラメータが空なら検索条件にmembership_statusを含めない
                    if (!isEmptyMembershipStatus)
                    {
                        // 検索条件(membership_status)
                        sql.Add(@"    OR membership_status = @membershipStatus");
                        command.Parameters.Add(new SqlParameter("@membershipStatus", membershipStatus));
                    }

                    sql.Add(@")");
                }

                //sql.Add(@"SELECT c.id, name, name_kana, mail, birthday, gender, p.prefecture, membership_status FROM V_Customer AS c");

                // ListにAddしたSQL文をStringBuilderを使用して一行の文字列にする
                StringBuilder sb = new StringBuilder();
                foreach(string line in sql)
                {
                    sb.Append(line);
                }

                // 作成したsqlをstring型にする
                string query = sb.ToString();

                // クエリとコネクションを指定する
                command.CommandText = query;
                command.Connection = connection;

                connection.Open();

                // SQL文を実行し、結果を得る
                // 今回は、検索結果が何件かを取得する
                SqlDataReader reader = command.ExecuteReader();

                // 検索結果の件数
                int count = -1;

                // 実行結果から、変数に検索結果の件数を代入
                if (reader.Read())
                {
                    count = Convert.ToInt32(reader["count"]);
                }



                reader.Close();

                // 検索結果の件数が取得出来たら、会員データの取得を行う
                // SELECT文を変更する
                sql[0] = @"SELECT c.id, name, name_kana, mail, birthday, gender, p.prefecture, membership_status FROM V_Customer AS c";

                // もしresultAllフラグがfalseなら、取得するデータ数に制限をかける
                // trueなら制限をかけない
                if(resultAll == "False")
                {
                    // OFFSET - FETCH文を使用して、取得するデータ数を制限する
                    // これにより検索結果画面でページ分けを行う
                    sql.Add(@"ORDER BY id ");
                    sql.Add(@"OFFSET @offset ROWS");
                    sql.Add(@" FETCH NEXT @nextCount ROWS ONLY");
                }

                // StringBuilderにAppendした文字列を全て削除する
                sb.Clear();

                // ListにAddした文字列をStringBuilderにAppendしていく
                foreach (string line in sql)
                {
                    sb.Append(line);
                }

                // 現在のページ数
                int page = Convert.ToInt32(pageNumber);

                // 1ページに何件の会員データを表示させるか
                // 今は、10件にしているが今後検索画面から表示させる件数の変更をできるようにするかもしれない
                int nextCount = 10;

                // offsetに指定する値は、現在表示しているのが何ページ目なのかで変化させたい
                // 1ページ目 -> offset = 0, 2ページ目 -> offset = 10
                // つまり、(ページ番号 - 1) * nextCountを計算してoffsetを出す
                int offset = (page - 1) * nextCount;

                // offsetとnextCountを設定する
                command.Parameters.Add(new SqlParameter("@offset", offset));
                command.Parameters.Add(new SqlParameter("@nextCount", nextCount));

                // クエリ変数の中身を更新し、CommandTextも更新する
                query = sb.ToString();
                command.CommandText = query;

                // 最終的に返す、会員データの集まり
                // CustomerクラスのListと、検索結果の件数が格納される
                Dictionary<string, object> customerData = new Dictionary<string, object>();

                // customerDataに格納するCustomerクラスのList
                List<Customer> customers = new List<Customer>();

                // SQL文を実行する
                // 今回は、結果から会員データを取得する
                reader = command.ExecuteReader();

                // 結果から会員データをクラスのフィールドに入れていく
                while (reader.Read())
                {
                    Customer customer = new Customer();

                    customer.id = reader["id"].ToString(); // id
                    customer.name = reader["name"].ToString(); // 名前
                    customer.nameKana = reader["name_kana"].ToString(); // 名前(かな)
                    customer.mail = reader["mail"].ToString(); // メールアドレス
                    customer.birthday = reader["birthday"].ToString(); // 誕生日
                    customer.gender = (bool)reader["gender"] ? "女性" : "男性"; // 性別
                    customer.prefecture = reader["prefecture"].ToString(); // 都道府県名
                    customer.membershipStatus = (bool)reader["membership_status"] ? "有効" : "退会"; // 会員状態

                    // インスタンスをListに追加する
                    customers.Add(customer);
                }

                reader.Close();

                // customerDataにCustomerクラスのListと、検索結果の件数を格納する
                customerData.Add("result", customers);
                customerData.Add("resultCount", count);

                return customerData;
            }
        }

        [System.Web.Services.WebMethod]
        public static string CSVDownloadButton_Click(string idStr, string emailStr, string nameStr, string nameKanaStr, string birthStartStr, string birthEndStr, string prefectureStr, string genderStr, string memberStatusStr, string pageNumber, string resultAll)
        {
            string csv = string.Empty;

            // CSVファイル生成中に例外が発生した場合、"failed"を返す
            try
            {
                // CSVファイルを生成する
                csv = GenerateCustomerDataCSV(idStr, emailStr, nameStr, nameKanaStr, birthStartStr, birthEndStr, prefectureStr, genderStr, memberStatusStr, pageNumber, resultAll);
            } catch (Exception e)
            {
                Debug.WriteLine(e.ToString());

                return "failed";
            }

            return csv;
        }

        private static string GenerateCustomerDataCSV(string idStr, string emailStr, string nameStr, string nameKanaStr, string birthStartStr, string birthEndStr, string prefectureStr, string genderStr, string memberStatusStr, string pageNumber, string resultAll)
        {
            // 検索結果を取得
            Dictionary<string, object> customerData = SearchCustomer(idStr, emailStr, nameStr, nameKanaStr, birthStartStr, birthEndStr, prefectureStr, genderStr, memberStatusStr, pageNumber, resultAll);

            // CSVファイルの内容を追加していくStringBuilder
            StringBuilder sb = new StringBuilder("id,名前,名前(かな),メールアドレス,生年月日,性別,都道府県,会員状態" + "\r\n");

            // 結果からCustomerクラスを1つずつ取得
            foreach (Customer customer in (List<Customer>) customerData["result"])
            {
                // Customerクラスのフィールド情報を取得
                // id, name, nameKana…のように順にFieldInfoが格納されている
                FieldInfo[] fields = customer.GetType().GetFields();
                // CSVファイルの1行分のデータを格納するList
                List<string> values = new List<string>();

                // fieldsを一つずつ取り出して処理をする
                // GetValueメソッドでフィールドに格納されている中身が取得できる
                foreach(FieldInfo info in fields)
                {
                    string value = (string) info.GetValue(customer);
                    values.Add(value);
                }

                // Listに保存したデータを要素ごとにカンマ区切りにして文字列にする
                string line = string.Join(",", values);

                // CSVファイルに追加する
                sb.Append(line + "\r\n");
            }

            // 出来上がったStringBuilderをstringにする
            string csv = sb.ToString();

            // csvを返す
            return csv;
        }

        [System.Web.Services.WebMethod]
        public static string CSVUploadButton_Click(string csv)
        {
            // エラーメッセージを格納するList
            List<string> errorMsgs = new List<string>();

            // csvファイルを1行ずつ配列に格納する
            string[] separator = new string[] { "\r\n", "\n" };
            // Splitメソッドを利用して改行文字ごとに区切って配列に格納する
            string[] csvRows = csv.Split(separator, StringSplitOptions.RemoveEmptyEntries);

            string connectionString = ConfigurationManager.ConnectionStrings["MyConnectionString"].ConnectionString;

            // ヘッダー
            string header = "id,名前,名前(かな),メールアドレス,生年月日,性別,都道府県,会員状態";

            // 何行目にエラーが発生したかを表現するために使用するカウンタ
            int rowCount = 0;

            // csvファイルを元に挿入処理を実行する
            // csvファイルの行分だけループする
            foreach (string row in csvRows)
            {
                rowCount++;

                // その行がヘッダーだったなら次のループにスキップする
                if (row == header)
                {
                    continue;
                }

                // カンマ区切りで配列に格納する
                string[] cols = row.Split(new string[] { "," }, StringSplitOptions.None);

                // 変数に配列の中身を格納していく
                string idStr = cols[0];
                int id = -1;

                // idStrに数字以外のものが入っていた場合、エラーメッセージを追加して次のループにスキップする
                if(!int.TryParse(idStr, out id))
                {
                    errorMsgs.Add(InsertError.GenerateErrorMsg(InsertError.E008_ID_ILLEGAL, rowCount));
                    continue;
                }

                string name = cols[1];
                string nameKana = cols[2];
                string email = cols[3];

                string birthdayStr = cols[4];
                DateTime birthday = DateTime.Now;

                // birthdayStrに不正な形式の日付が入っていた場合、エラーメッセージを追加して次のループにスキップする
                if(!DateTime.TryParse(birthdayStr, out birthday))
                {
                    errorMsgs.Add(InsertError.GenerateErrorMsg(InsertError.E004_DATETIME_ILLEGAL, rowCount));
                    continue;
                }

                string genderStr = cols[5];
                int gender = -1;

                if(genderStr == "男性")
                {
                    gender = 0;
                } else if (genderStr == "女性")
                {
                    gender = 1;
                } else
                {
                    // genderStrに"男性"、"女性"以外の文字列が入っていた場合、
                    // エラーメッセージを追加して次のループにスキップする
                    errorMsgs.Add(InsertError.GenerateErrorMsg(InsertError.E005_GENDER_ILLEGAL, rowCount));
                    continue;
                }

                string prefectureStr = cols[6];
                int prefectureId = -1;

                // prefectureStrを元に、都道府県Idを取得する
                // もし存在しない都道府県が入っていた場合、エラーメッセージを追加して次のループにスキップする
                using(SqlConnection connection = new SqlConnection(connectionString))
                {
                    try
                    {
                        SqlCommand command = new SqlCommand();

                        string query = "SELECT id FROM V_Prefecture WHERE prefecture = @prefecture";

                        command.Parameters.Add(new SqlParameter("@prefecture", prefectureStr));

                        command.CommandText = query;
                        command.Connection = connection;

                        connection.Open();

                        SqlDataReader reader = command.ExecuteReader();

                        if(reader.Read())
                        {
                            prefectureId = (int) reader["id"];
                        } else
                        {
                            errorMsgs.Add(InsertError.GenerateErrorMsg(InsertError.E006_PREFECTURE_NOT_EXIST, rowCount));
                            continue;
                        }
                    } catch(Exception e)
                    {
                        Debug.WriteLine(e.ToString());
                        // 不明なエラー
                        errorMsgs.Add(InsertError.GenerateErrorMsg(InsertError.E1000_UNEXPECTED_ERROR, rowCount));
                        continue;
                    }
                }

                string membershipStatusStr = cols[7];
                int membershipStatus = -1;

                if(membershipStatusStr == "退会")
                {
                    membershipStatus = 0;
                } else if (membershipStatusStr == "有効")
                {
                    membershipStatus = 1;
                } else
                {
                    // membershipStatusStrに"退会"、"有効"以外の文字列が入っていた場合、
                    // エラーメッセージを追加して次のループにスキップする
                    errorMsgs.Add(InsertError.GenerateErrorMsg(InsertError.E009_MEMBERSHIPSTATUS_ILLEGAL, rowCount));
                    continue;
                }

                // データ挿入日
                DateTime createdAt = DateTime.Now;

                // データ挿入開始
                // もし挿入処理中に何かの例外が発生した場合、RollBackして挿入をキャンセルする
                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    try
                    {
                        SqlCommand command = new SqlCommand();

                        StringBuilder sb = new StringBuilder();
                        sb.Append(@"INSERT INTO M_Customer (id, name, name_kana, mail, birthday, gender, prefecture_id, membership_status, created_at)");
                        sb.Append(@"VALUES (@id, @name, @nameKana, @email, @birthday, @gender, @prefectureId, @membershipStatus, @createdAt)");

                        command.Parameters.Add(new SqlParameter("@id", id));
                        command.Parameters.Add(new SqlParameter("@name", name));
                        command.Parameters.Add(new SqlParameter("@nameKana", nameKana));
                        command.Parameters.Add(new SqlParameter("@email", email));
                        command.Parameters.Add(new SqlParameter("@birthday", birthday));
                        command.Parameters.Add(new SqlParameter("@gender", gender));
                        command.Parameters.Add(new SqlParameter("@prefectureId", prefectureId));
                        command.Parameters.Add(new SqlParameter("@membershipStatus", membershipStatus));
                        command.Parameters.Add(new SqlParameter("@createdAt", createdAt));

                        command.CommandText = sb.ToString();
                        command.Connection = connection;

                        connection.Open();

                        using (SqlTransaction transaction = connection.BeginTransaction())
                        {
                            try
                            {
                                command.Transaction = transaction;
                                command.ExecuteNonQuery();

                                transaction.Commit();
                            }
                            catch (SqlException e)
                            {
                                transaction.Rollback();
                                Debug.WriteLine(e.ToString());

                                // エラー番号を元にエラーメッセージを追加する
                                switch(e.Number)
                                {
                                    case 8115:
                                        // idに指定できる最大文字数を超えた文字数のidを挿入しようとした
                                        errorMsgs.Add(InsertError.GenerateErrorMsg(InsertError.E001_ID_OVERFLOW, rowCount));
                                        continue;
                                    case 2628:
                                        // 何らかの文字列が挿入できる最大文字数を超えている
                                        errorMsgs.Add(InsertError.GenerateErrorMsg(InsertError.E002_STRING_TOOLONG, rowCount));
                                        continue;
                                    case 2627:
                                        // 既に登録されているidを登録しようとした
                                        errorMsgs.Add(InsertError.GenerateErrorMsg(InsertError.E003_ID_DUPLICATE, rowCount));
                                        continue;
                                    case 109:
                                        // 挿入に必要な値が不足している
                                        errorMsgs.Add(InsertError.GenerateErrorMsg(InsertError.E007_NOT_ENOUGH_VALUE, rowCount));
                                        continue;
                                    default:
                                        // 不明なエラー
                                        errorMsgs.Add(InsertError.GenerateErrorMsg(InsertError.E1000_UNEXPECTED_ERROR, rowCount));
                                        continue;
                                }
                            }
                            catch (Exception e)
                            {
                                transaction.Rollback();
                                Debug.WriteLine(e.ToString());

                                // 不明なエラー
                                errorMsgs.Add(InsertError.GenerateErrorMsg(InsertError.E1000_UNEXPECTED_ERROR, rowCount));
                                continue;
                            }
                        }
                    }
                    catch (Exception e)
                    {
                        Debug.WriteLine(e.ToString());

                        // 不明なエラー
                        errorMsgs.Add(InsertError.GenerateErrorMsg(InsertError.E1000_UNEXPECTED_ERROR, rowCount));
                        continue;
                    }

                }
            }

            // 挿入結果を記録するクラスをインスタンス化
            CsvInsertResult insertResult = new CsvInsertResult();
            insertResult.errorMsgs = errorMsgs;
            insertResult.result = rowCount + "行 エラー: " + errorMsgs.Count + "件";

            JavaScriptSerializer js = new JavaScriptSerializer();

            // Listをjsonの形にする
            string json = js.Serialize(insertResult);

            // jsonを返す
            return json;
        }

        [System.Web.Services.WebMethod]
        public static string DeleteButton_Click(string idStr)
        {
            int id = Convert.ToInt32(idStr);

            string connectionString = ConfigurationManager.ConnectionStrings["MyConnectionString"].ConnectionString;

            // 削除処理開始
            // DELETE文を使用せず、UPDATE文で削除フラグをTRUEにする
            // 途中で例外が発生した場合、"failed", 成功したなら"success"を返す
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                try
                {
                    SqlCommand command = new SqlCommand();

                    string query = @"UPDATE M_Customer SET delete_flag = 1 WHERE id = @id";

                    command.Parameters.Add(new SqlParameter("@id", id));

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

                            return "success";
                        }
                        catch (Exception e)
                        {
                            transaction.Rollback();
                            Debug.WriteLine(e.ToString());

                            return "failed";
                        }
                    }
                }
                catch (Exception e)
                {
                    Debug.WriteLine(e.ToString());

                    return "failed";
                }
            }
        }

        [System.Web.Services.WebMethod]
        public static string SortTable(List<List<string>> tableData, string columnName, string sortMethod)
        {
            Debug.WriteLine(columnName);

            // クリックされたカラムがidなら、idを基準に昇順、降順でソートする
            if(columnName == "id")
            {
                if (sortMethod == "asc")
                {
                    tableData.Sort((a, b) => Convert.ToInt32(a[0]).CompareTo(Convert.ToInt32(b[0])));
                } else if(sortMethod == "desc")
                {
                    tableData.Sort((a, b) => Convert.ToInt32(b[0]).CompareTo(Convert.ToInt32(a[0])));
                }
            }

            // クリックされたカラムが誕生日なら、誕生日を基準に昇順、降順でソートする
            if (columnName == "birthday")
            {
                if (sortMethod == "asc")
                {
                    tableData.Sort((a, b) => DateTime.Parse(a[4]).CompareTo(DateTime.Parse(b[4])));
                } else if(sortMethod == "desc")
                {
                    tableData.Sort((a, b) => DateTime.Parse(b[4]).CompareTo(DateTime.Parse(a[4])));
                }
            }

            JavaScriptSerializer js = new JavaScriptSerializer();

            // Listをjsonの形にする
            string json = js.Serialize(tableData);

            Debug.WriteLine(json);

            // jsonを返す
            return json;
        }
    }
}