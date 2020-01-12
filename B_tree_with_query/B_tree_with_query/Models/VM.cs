using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace B_tree_with_query.Models
{
    public class VM
    {
        public List<Menu> GEtdb()
        {
            List<Menu> DBase = new List<Menu>();

            string connstring = ConfigurationManager.ConnectionStrings["dbx"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connstring))
            {
                SqlCommand cmd = new SqlCommand("select m.Menu_id d_id,u.Menu_id , m.menu_name , m.menu_parent_id , u.User_id from Menus m full outer join  User_Privilege u on m.Menu_id = u.Menu_id where u.User_id = 'sahal' or u.Menu_id is null union all select  u.Menu_id d_id,null Menu_id , m.Menu_name , m.Menu_Parent_id , null user_id from Menus m, User_Privilege u where u.User_id <> 'sahal' and m.Menu_id = u.Menu_id", conn);

                conn.Open();

                SqlDataReader reader = cmd.ExecuteReader();

                while (reader.Read())
                {
                    Menu emp = new Menu();
                    emp.d_id = Convert.ToInt16(reader["d_id"]);
                    emp.menu_id = reader["menu_id"] != DBNull.Value ? Convert.ToInt32(reader["menu_id"]) : (int?)null;
                    emp.menu_name = reader["menu_name"].ToString();

                    if(reader["menu_parent_id"] != DBNull.Value)
                    {
                        emp.menu_parent_id = Convert.ToInt32(reader["menu_parent_id"]) ;
                    }
                    

                    if (reader["User_id"] != DBNull.Value)
                    {
                        emp.User_id = reader["User_id"].ToString();
                    }


                    DBase.Add(emp);

                }
            }

            return DBase;
        }
    }
}