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

            }
        }

        [System.Web.Services.WebMethod]
        public static void RegisterButton_Clicked(string lastName, string firstName, string lastNameKana, string firstNameKana, string email, string birthdayStr, string genderStr, string prefecture)
        {
            string name = lastName + " " + firstName;
            string nameKana = lastNameKana + " " + firstNameKana;
            DateTime birthday = DateTime.Parse(birthdayStr);
            bool gender = false;

            if(genderStr == "1")
            {
                gender = true;
            }

            DateTime createdAt = DateTime.Now;

            string connectionString = ConfigurationManager.ConnectionStrings["MyConnectionString"].ConnectionString;

            int count = 0;

            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                string query = "SELECT COUNT(*) AS count FROM M_Customer";
                SqlCommand command = new SqlCommand(query, connection);

                connection.Open();

                SqlDataReader reader = command.ExecuteReader();

                if(reader.Read())
                {
                    string countStr = reader["count"].ToString();
                    count = Convert.ToInt32(countStr);
                }
            }

            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                try
                {
                    SqlCommand command = new SqlCommand();

                    StringBuilder sb = new StringBuilder();
                    sb.Append(@"INSERT INTO M_Customer (id, name, name_kana, mail, birthday, gender, prefecture_id, created_at)");
                    sb.Append(@"VALUES (@id, @name, @nameKana, @email, @birthday, @gender, @prefecture, @createdAt)");

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

                    using (SqlTransaction transaction = connection.BeginTransaction())
                    {
                        try
                        {
                            command.Transaction = transaction;
                            command.ExecuteNonQuery();

                            transaction.Commit();
                        } catch(Exception e)
                        {
                            transaction.Rollback();
                            Debug.WriteLine(e.ToString());
                        }
                    }
                } catch(Exception e)
                {
                    Debug.WriteLine(e.ToString());
                }   
                    
            }
            
            

                

//            INSERT INTO M_Customer(id, name, name_kana, mail, birthday, gender, prefecture_id, created_at, updated_at)
//VALUES(11, '田中 太郎', 'たなか たろう', 't.tanaka@solidseed.co.jp', '1900-01-01', 0, 4, '2023-06-13', NULL)


        }
    }
}