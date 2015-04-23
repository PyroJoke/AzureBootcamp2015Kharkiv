using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Configuration;

namespace CustomerManager.E2ETests
{
    public static class Parameters
    {
        public static string SiteUrl { get { return ConfigurationManager.AppSettings["appUrl"]; }}
    }
}
