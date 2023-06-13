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

namespace kensyu
{
    public partial class About : Page
    {
        public DataTable Results { get; set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                //GetSearchResults();
            }
        }
        [System.Web.Services.WebMethod]
        public static string GetSearchResultsForWebMethod()
        {
            string connectionString = ConfigurationManager.ConnectionStrings["MyConnectionString"].ConnectionString;
            string query = "SELECT * FROM Table_1";

            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand(query, connection);
                connection.Open();

                SqlDataAdapter da = new SqlDataAdapter(command);
                DataTable dt = new DataTable();
                da.Fill(dt);

                // As we cannot directly return a DataTable to the client-side, we will serialize the DataTable into a JSON string before returning.
                string JSONresult;
                JSONresult = JsonConvert.SerializeObject(dt);
                return JSONresult;
            }
        }

        
            //[System.Web.Services.WebMethod]
            //public static DataTable GetSearchResultsForWebMethod()
            //{
            //    About aboutPage = new About();
            //    aboutPage.GetSearchResults();
            //    return aboutPage.Results;
            //}

            //public void GetSearchResults()
            //{
            //    string connectionString = ConfigurationManager.ConnectionStrings["MyConnectionString"].ConnectionString;
            //    string query = "SELECT * FROM Table_1";

            //    using (SqlConnection connection = new SqlConnection(connectionString))
            //    {
            //        SqlCommand command = new SqlCommand(query, connection);
            //        connection.Open();

            //        SqlDataAdapter da = new SqlDataAdapter(command);
            //        DataTable dt = new DataTable();
            //        da.Fill(dt);

            //        Results = dt;
            //    }
            //}
    }
}