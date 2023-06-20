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

            }
        }

        [System.Web.Services.WebMethod]
        public static string GetCustomerInfoById(string idStr)
        {
            int id = Convert.ToInt32(idStr);

            

            string connectionString = ConfigurationManager.ConnectionStrings["MyConnectionString"].ConnectionString;
            //string query = "SELECT * FROM V_Customer";

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

                List<string> customerData = new List<string>();

                SqlDataReader reader = command.ExecuteReader();

                if (reader.Read())
                {
                    customerData.Add(reader["name"].ToString());
                    customerData.Add(reader["name_kana"].ToString());
                    customerData.Add(reader["mail"].ToString());

                    DateTime birthday = (DateTime)reader["birthday"];
                    customerData.Add(birthday.ToString("yyyy-MM-dd"));

                    customerData.Add((bool)reader["gender"] ? "2" : "1");
                    customerData.Add(reader["prefecture_id"].ToString());
                    customerData.Add((bool)reader["membership_status"] ? "1" : "2");
                }

                reader.Close();

                JavaScriptSerializer js = new JavaScriptSerializer();

                // Listをjsonの形にする
                string json = js.Serialize(customerData);

                return json;
            }
        }

        [System.Web.Services.WebMethod]
        public static void UpdateCustomerInfo(string idStr, string lastNameStr, string firstNameStr, string lastNameKanaStr, string firstNameKanaStr, string emailStr, string birthdayStr, string genderStr, string prefectureStr, string membershipStatusStr)
        {
            int id = Convert.ToInt32(idStr);
            string name = lastNameStr + " " + firstNameStr;
            string nameKana = lastNameKanaStr + " " + firstNameKanaStr;
            DateTime birthday = DateTime.Parse(birthdayStr);

            bool gender = false;
            if(genderStr == "2")
            {
                gender = true;
            }

            int prefectureId = Convert.ToInt32(prefectureStr);

            bool membershipStatus = false;
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

                    // UPDATE M_Customer
                    //    SET name = '桜井 千佳',
                    //        name_kana = 'さくらい ちか',
                    //        mail = 'c.sakurai@solidseed.co.jp',
                    //        birthday = '2000-10-31',
                    //        gender = 1,
                    //        prefecture_id = 26,
                    //        membership_status = 1,
                    //        updated_at = CURRENT_TIMESTAMP
                    //  WHERE id = 11;

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

                    using (SqlTransaction transaction = connection.BeginTransaction())
                    {
                        try
                        {
                            command.Transaction = transaction;
                            command.ExecuteNonQuery();

                            transaction.Commit();
                        }
                        catch (Exception e)
                        {
                            transaction.Rollback();
                            Debug.WriteLine(e.ToString());
                        }
                    }
                }
                catch (Exception e)
                {
                    Debug.WriteLine(e.ToString());
                }

            }
        }
    }
}