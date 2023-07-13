using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web;

namespace kensyu
{
    public class MemberInputChecker
    {
        public bool NameKanjiCheck(string name)
        {
            // nameが漢字、ひらがな、カタカナのみの文字列か調べる
            string nameCheckRegex = @"^[ぁ-んァ-ヶ一-龠ー]+$";

            // nameに漢字、ひらがな、カタカナ以外が入力されていたならfalseを返す
            if (!Regex.IsMatch(name, nameCheckRegex))
            {
                return false;
            }

            // 漢字のみならtrueを返す
            return true;
        }

        public bool NameHiraganaCheck(string name)
        {
            string nameKanaCheckRegex = @"^[ぁ-んー]+$";

            // nameにひらがな以外が入力されていたならfalseを返す
            if (!Regex.IsMatch(name, nameKanaCheckRegex))
            {
                return false;
            }

            // ひらがなのみならtrueを返す
            return true;
        }

        public bool EmailValidationCheck(string email)
        {
            string emailCheckRegex = @"^[a-zA-Z0-9_+-]+(\.[a-zA-Z0-9_+-]+)*@([a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]*\.)+[a-zA-Z]{2,}$";

            // emailの形式が正しくないならfalseを返す
            if(!Regex.IsMatch(email, emailCheckRegex))
            {
                return false;
            }

            // 形式が正しいならtrueを返す
            return true;
        }

        public bool BirthdayValidationCheck(string birthday)
        {
            DateTime dt = new DateTime();

            // birthdayがDateTime型に変換することができるかでチェックを行う
            // 変換する事が出来なかった場合falseを返す
            if(!DateTime.TryParse(birthday, out dt))
            {
                return false;
            }

            // 変換できたならtrueを返す
            return true;
        }

        public bool GenderValidationCheck(string gender)
        {
            int genderNum = 0;

            // genderは1か2の数字で渡される
            // 1: 男性、2: 女性
            // まずgenderが数字なのかを調べる
            // 数字でないならfalseを返す
            if(!int.TryParse(gender, out genderNum))
            {
                return false;
            }

            // 次に、3などの不正な数字が送られていないかチェックする
            // 1と2以外の数字が渡されていた場合、falseを返す
            if(!(genderNum == 1 || genderNum == 2))
            {
                return false;
            }

            // genderに問題が無い場合trueを返す
            return true;
        }

        public bool PrefectureValidationCheck(string prefecture)
        {
            int preNum = 0;

            // prefectureは1から47までの都道府県コードである
            // まず、prefectureが数字なのかを調べる
            // 数字でないならfalseを返す
            if(!int.TryParse(prefecture, out preNum))
            {
                return false;
            }

            // 次に、1から47の間であるかを調べる
            // 範囲外の数値ならfalseを返す
            if(!(preNum >= 1 && preNum <= 47))
            {
                return false;
            }

            // 正常な数値ならtrueを返す
            return true;
        }

        public bool MembershipStatusValidationCheck(string membershipStatus)
        {
            // チェックする項目はgenderと一緒なので、genderをチェックするメソッドを呼び出す
            bool result = GenderValidationCheck(membershipStatus);

            return result;
        }
    }
}