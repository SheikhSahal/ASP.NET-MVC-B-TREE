using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using B_tree_with_query.Models;

namespace B_tree_with_query.Controllers
{
    public class HomeController : Controller
    {
        VM db = new VM();
        Menu menu = new Menu();

        public ActionResult Index()
        {
            var Menulist = db.GEtdb();
            var menudisplay = menu.Menutree(Menulist, null);
            return View(menudisplay);
        }
    }
}