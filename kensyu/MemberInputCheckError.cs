using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace kensyu
{
    public class MemberInputCheckError
    {
        public readonly static string E001_NON_KANJI_LASTNAME = "名前(漢字)の姓の入力欄に漢字以外の文字が入力されています。";
        public readonly static string E002_NON_KANJI_FIRSTNAME = "名前(漢字)の名の入力欄に漢字以外の文字が入力されています。";
        public readonly static string E003_NON_HIRAGANA_LASTNAME = "名前(かな)の姓の入力欄に漢字以外の文字が入力されています。";
        public readonly static string E004_NON_HIRAGANA_FIRSTNAME = "名前(かな)の名の入力欄に漢字以外の文字が入力されています。";
        public readonly static string E005_INVALID_EMAIL = "メールアドレスの形式が不正です。";
        public readonly static string E006_INVALID_BIRTHDAY = "生年月日に入力された値が不正です。";
        public readonly static string E007_INVALID_GENDER = "性別が不正です。";
        public readonly static string E008_INVALID_PREFECTURE = "都道府県に入力された値が不正です。";
        public readonly static string E009_INVALID_MEMBERSHIPSTATUS = "会員状態が不正です。";
        public readonly static string E010_EMPTY_INPUT = "いずれかの入力欄が空です。";
    }
}