using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace kensyu
{
    public class AdminRegisterError
    {
        public readonly static string E001_LOGINID_EXISTS = "このログインidは既に登録されています";
        public readonly static string E002_PASSWORD_INVALID = "パスワードにアルファベット大文字、小文字、数字以外の文字を含めることはできません";
        public readonly static string E1000_UNEXPECTED_ERROR = "処理中にエラーが発生しました";
    }
}