using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace kensyu
{
    public class MemberResult
    {
        public string Result { get; set; }
        public List<string> ErrorMsgs { get; set; }
    }
}