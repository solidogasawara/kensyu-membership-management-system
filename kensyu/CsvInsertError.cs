using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace kensyu
{
    public class CsvInsertError
    {
        public readonly static string E001_ID_OVERFLOW = "idに最大値を超えた値を挿入しようとしました";
        public readonly static string E002_STRING_TOOLONG = "名前やメールアドレスなどに最大文字数を超えた文字列を挿入しようとしました";
        public readonly static string E003_ID_DUPLICATE = "既に登録されているidを挿入しようとしました";
        public readonly static string E004_DATETIME_ILLEGAL = "日付の形式が不正です";
        public readonly static string E005_GENDER_ILLEGAL = "性別が不正です";
        public readonly static string E006_PREFECTURE_NOT_EXIST = "都道府県名が誤っています";
        public readonly static string E007_NOT_ENOUGH_VALUE = "データの挿入に必要な値が不足しています";
        public readonly static string E008_ID_ILLEGAL = "idは数字のみを使用しなくてはなりません";
        public readonly static string E009_MEMBERSHIPSTATUS_ILLEGAL = "会員状態の値が不正です";
        public readonly static string E010_NAME_ILLEGAL = "名前(漢字)の形式が不正です";
        public readonly static string E011_NAMEKANA_ILLEGAL = "名前(かな)の形式が不正です";
        public readonly static string E1000_UNEXPECTED_ERROR = "予期せぬエラーが発生しました";

        public static string GenerateErrorMsg(string errorMsg, int rowCount)
        {
            return rowCount + "行目: " + errorMsg;
        }
    }
}