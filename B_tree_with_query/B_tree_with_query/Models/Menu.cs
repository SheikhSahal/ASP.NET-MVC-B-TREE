using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace B_tree_with_query.Models
{
    public class Menu
    {
        public int d_id { get; set; }
        public string User_id { get; set; }

        public int? menu_id { get; set; }
        public int menu_parent_id { get; set; }
        public string menu_name { get; set; }

        public List<Menu> List { get; set; }


        public List<Menu> Menutree(List<Menu> menulist, int? parentid)
        {
            return menulist.Where(x => x.menu_parent_id == parentid).Select(
                x => new Menu
                {
                    menu_id = x.menu_id,
                    menu_name = x.menu_name,
                    menu_parent_id = x.menu_parent_id,
                    d_id = x.d_id,
                    User_id = x.User_id,
                    List = Menutree(menulist, x.menu_id)
                }).ToList();
        }
    }
}