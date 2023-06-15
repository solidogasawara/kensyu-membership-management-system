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
    public partial class memberregister : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {

            }
        }

        protected void SubmitButton_Click(object sender, EventArgs e)
        {
//            INSERT INTO M_Customer(id, name, name_kana, mail, birthday, gender, prefecture_id, created_at, updated_at)
//VALUES(11, '田中 太郎', 'たなか たろう', 't.tanaka@solidseed.co.jp', '1900-01-01', 0, 4, '2023-06-13', NULL)


        }
    }
}