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
                if (Session["loginId"] == null)
                {
                    Response.Redirect("~/admin-login-page.aspx");
                }
            }
        }

        [System.Web.Services.WebMethod]
        public static string GetCustomerInfoById(string idStr)
        {
            int id = Convert.ToInt32(idStr);

            string connectionString = ConfigurationManager.ConnectionStrings["MyConnectionString"].ConnectionString;

            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand();

                // SQL文
                string query = @"SELECT name, name_kana, mail, birthday, gender, prefecture_id, membership_status FROM V_Customer WHERE id = @id";

                command.Parameters.Add(new SqlParameter("@id", id));

                // クエリとコネクションを指定する
                command.CommandText = query;
                command.Connection = connection;

                connection.Open();

                // SQL文を実行して取得したデータを格納するList
                List<Customer> customerData = new List<Customer>();

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

                JavaScriptSerializer js = new JavaScriptSerializer();

                // Listをjsonの形にする
                string json = js.Serialize(customerData);

                return json;
            }
        }

        [System.Web.Services.WebMethod]
        public static string UpdateCustomerInfo(string idStr, string lastNameStr, string firstNameStr, string lastNameKanaStr, string firstNameKanaStr, string emailStr, string birthdayStr, string genderStr, string prefectureStr, string membershipStatusStr)
        {
            int id = Convert.ToInt32(idStr);
            string name = lastNameStr + " " + firstNameStr;
            string nameKana = lastNameKanaStr + " " + firstNameKanaStr;
            DateTime birthday = DateTime.Parse(birthdayStr);

            // 男性: false, 女性: true
            bool gender = false;
            // genderStrが2なら女性を表す
            if(genderStr == "2")
            {
                gender = true;
            }

            int prefectureId = Convert.ToInt32(prefectureStr);

            // 退会: false, 有効: true
            bool membershipStatus = false;
            // membershipStatusStrが1なら有効を表す
            if(membershipStatusStr == "1")
            {
                membershipStatus = true;
            }

            DateTime updatedAt = DateTime.Now;

            string connectionString = ConfigurationManager.ConnectionStrings["MyConnectionString"].ConnectionString;

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

                            return "success";
                        }
                        catch (Exception e)
                        {
                            transaction.Rollback();
                            Debug.WriteLine(e.ToString());

                            return "update failed";
                        }
                    }
                }
                catch (Exception e)
                {
                    Debug.WriteLine(e.ToString());

                    return "unexpected error";
                }

            }
        }
    }
}