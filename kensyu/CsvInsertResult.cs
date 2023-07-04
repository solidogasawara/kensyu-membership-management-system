using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace kensyu
{
    public class CsvInsertResult
    {
        public List<string> errorMsgs { get; set; } = new List<string>();
        public string result { get; set; } = string.Empty;
        
    }
}