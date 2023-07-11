using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace kensyu
{
    public class AdminRegisterCheckError
    {
        public readonly static string E001_EMPTY_INPUT = "ログインIDまたはパスワードが未入力です";
        public readonly static string E002_LOGINID_MAX_INPUT_EXCEEDED = "ログインidに指定できる最大文字数を超えています";
        public readonly static string E003_PASSWORD_INVALID = "パスワードにアルファベット大文字、小文字、数字以外の文字を含めることはできません";
    }
}