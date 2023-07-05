using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Security.Cryptography;
using System.Text;

namespace kensyu
{
    // パスワード関連のメソッド群
    public class AuthenticationManager
    {
        // パスワードをハッシュ化するメソッド
        public static string HashPassword(string password, string salt)
        {
            using (SHA256 sha256 = SHA256.Create())
            {
                // パスワードにソルトを足したものをbyte型の配列にする
                byte[] passwordBytes = Encoding.UTF8.GetBytes(password + salt);
                // SHA256を使用してハッシュ化する
                byte[] hashBytes = sha256.ComputeHash(passwordBytes);

                // byte型の配列をstring型に変換して返す
                return Convert.ToBase64String(hashBytes);
            }
        }

        // ソルトを生成するメソッド
        public static string GenerateSalt()
        {
            byte[] saltBytes = new byte[16];

            using (RNGCryptoServiceProvider rng = new RNGCryptoServiceProvider())
            {
                rng.GetBytes(saltBytes);
            }

            return Convert.ToBase64String(saltBytes);
        }

        // パスワードが一致するかチェックする
        public static bool CheckPasswordMatch(string inputtedPassword, string userPassword)
        {
            return inputtedPassword == userPassword;
        }
    }
}