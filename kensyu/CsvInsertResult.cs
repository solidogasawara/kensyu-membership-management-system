using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace kensyu
{
    // CSVファイルから会員情報を登録処理の結果を記録するクラス
    public class CsvInsertResult
    {
        public List<string> errorMsgs { get; set; } = new List<string>();
        public string result { get; set; } = string.Empty;
        
    }
}