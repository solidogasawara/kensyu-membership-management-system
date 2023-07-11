using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web;

namespace kensyu
{
    public class AdminRegisterInputChecker
    {
        // ログインidの最大文字数
        private readonly int maxLoginIdCharactor = 50;

        public bool LoginIdLengthCheck(string loginId)
        {
            // 入力されたログインidが最大文字数を超えていないかをチェックする

            // 入力されたログインidの文字数
            int loginIdCharactor = loginId.Length;

            // 最大文字数を超えていればfalse、超えていなければtrueが返る
            return loginIdCharactor < maxLoginIdCharactor;
        }

        public bool PasswordValidationCheck(string password)
        {
            // パスワードはアルファベットの大文字、小文字、数字の組み合わせ以外認めない
            // 正規表現でそれをチェックする
            string passwordCheckRegex = @"^[A-Za-z0-9]+$";

            // アルファベットの大文字、小文字、数字以外の文字が含まれていた場合、falseを返す
            if (!Regex.IsMatch(password, passwordCheckRegex)) {
                return false;
            }

            // パスワードが正しい形式ならtrueを返す
            return true;
        }
    }
}