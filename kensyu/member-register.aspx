<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="member-register.aspx.cs" Inherits="kensyu.memberregister" %>
<!DOCTYPE html>
<head>
    <title>会員登録 | 会員管理システム</title>
    <link rel="stylesheet" href="./css/common.css" />
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <!-- Select2.css -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.2/css/select2.min.css">
    <!-- Select2本体 -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.2/js/select2.min.js"></script>
    <script type="text/javascript">
        // select2を適用
        $(document).ready(() => {
            $('select').select2();
        });

        function registerButtonClicked() {
            // 入力欄の要素を取得する
            const firstNameObj = document.querySelector('input[name="first_name"]');
            const lastNameObj = document.querySelector('input[name="last_name"]');
            const firstNameKanaObj = document.querySelector('input[name="first_name_kana"]');
            const lastNameKanaObj = document.querySelector('input[name="last_name_kana"]');
            const emailObj = document.querySelector('input[name="email"]');
            const birthdayObj = document.querySelector('input[name="birthday"]');
            const genderObj = document.querySelectorAll('input[name="sex"]');
            const prefectureObj = document.querySelector('select[name="prefecture"]');

            // 要素から入力された文字列を取得する
            const firstName = firstNameObj.value;
            const lastName = lastNameObj.value;
            const firstNameKana = firstNameKanaObj.value;
            const lastNameKana = lastNameKanaObj.value;
            const email = emailObj.value;
            const birthday = birthdayObj.value;            

            var genderValue = "";

            var genderRBtnSelected = [false, false];

            // ラジオボタンの選択箇所を調べる
            for (var i = 0; i < genderObj.length; i++) {
                if (genderObj[i].checked) {
                    genderRBtnSelected[i] = true;
                    break;
                }
            }

            if (genderRBtnSelected[0]) {
                genderValue = genderObj[0].value;
            }

            if (genderRBtnSelected[1]) {
                genderValue = genderObj[1].value;
            }

            const prefecture = prefectureObj.value;

            // エラーメッセージや登録完了メッセージを表示するp要素
            const messageObj = document.querySelector('.message');

            // 入力チェック
            const inputtedData = [
                firstName, lastName, firstNameKana, lastNameKana,
                email, birthday, genderValue, prefecture
            ];

            // 最大文字数
            const maxNameCharactor = 15; // 名前(漢字)
            const maxNameKanaCharactor = 50; // 名前(かな)
            const maxEmailCharactor = 50; // メールアドレス

            // 名前は苗字と名前を半角スペースで区切った形で登録されるため、
            // その形にして文字数チェックする
            const name = lastName + " " + firstName;
            const nameKana = lastNameKana + " " + firstNameKana;

            // 入力欄が空の所があったかどうかを管理するフラグ
            var isEmpty = false;

            // 最大文字数を超えた入力がされたかを管理するフラグ
            var exceedsMaxLength = {
                "name": false,
                "nameKana": false,
                "email": false
            };

            // いずれかの不正な入力があったか
            var hasInvalidInput = false;

            for (var i = 0; i < inputtedData.length; i++) {
                // 空文字チェック
                if (inputtedData[i] == "") {
                    isEmpty = true;
                    hasInvalidInput = true;
                    break;
                }
            }

            // 最大文字数チェック
            if (name.length > maxNameCharactor) {
                exceedsMaxLength["name"] = true;
                hasInvalidInput = true;
            }

            if (nameKana.length > maxNameKanaCharactor) {
                exceedsMaxLength["nameKana"] = true;
                hasInvalidInput = true;
            }

            if (email.length > maxEmailCharactor) {
                exceedsMaxLength["email"] = true;
                hasInvalidInput = true;
            }

            // 名前(漢字)の入力欄に漢字以外の文字が入っていないかチェックする
            const kanjiCheckRegex = /^[一-龠]+$/;

            // 漢字以外の文字が入っているかのフラグ
            var nonKanjiDetected = {
                "lastName": false,
                "firstName": false
            };

            // チェック
            if (!kanjiCheckRegex.test(lastName)) {
                nonKanjiDetected["lastName"] = true;
                hasInvalidInput = true;
            } else if (!kanjiCheckRegex.test(firstName)) {
                nonKanjiDetected["firstName"] = true;
                hasInvalidInput = true;
            }

            // 名前(かな)の入力欄にひらがな以外の文字が入っていないかチェックする
            const hiraganaCheckRegex = /^[ぁ-んー]+$/;

            // ひらがな以外の文字が入っているかのフラグ
            var nonHiraganaDetected = {
                "lastName": false,
                "firstName": false
            };

            // チェック
            if (!hiraganaCheckRegex.test(lastName)) {
                nonHiraganaDetected["lastName"] = true;
                hasInvalidInput = true;
            } else if (!hiraganaCheckRegex.test(firstName)) {
                nonHiraganaDetected["firstName"] = true;
                hasInvalidInput = true;
            }

            // メールアドレスの形式が正しいものかをチェックする
            const emailCheckRegex = /^[a-zA-Z0-9_+-]+(\.[a-zA-Z0-9_+-]+)*@([a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]*\.)+[a-zA-Z]{2,}$/;

            // メールアドレスの形式が正しくないか
            // 正しくないならtrueになる
            var invalidEmail = false;

            // チェック
            if (!emailCheckRegex.test(email)) {
                invalidEmail = true;
                hasInvalidInput = true;
            }

            // 入力された誕生日が不正なものでないかチェックする

            // チェック用のDateオブジェクト
            const date = new Date(birthday);

            // 誕生日が不正か
            var invalidBirthday = false;

            // 不正ならgetDate()メソッドの返り値がNaNになる
            if (isNaN(date.getDate())) {
                invalidBirthday = true;
                hasInvalidInput = true;
            }

            // 都道府県コードが不正でないか調べる

            // 都道府県コードが不正か
            var invalidPrefecture = false;

            // まず、数字であるか調べる
            if (!isNaN(prefecture)) {
                invalidPrefecture = true;
                hasInvalidInput = true;
            } else {
                // 次に、1から47までの範囲内かを調べる
                if (!(prefecture >= 1 && prefecture <= 47)) {
                    invalidPrefecture = true;
                    hasInvalidInput = true;
                }
            }

            // 不正な入力がされたなら、登録処理を中断しエラーメッセージを表示する
            if (hasInvalidInput) {
                // エラーメッセージの作成
                var errorMsg = "";

                if (isEmpty) {
                    errorMsg += "いずれかの入力欄が空です。" + "\n";
                }

                if (exceedsMaxLength["name"]) {
                    errorMsg += "名前(漢字)に入力する事のできる最大文字数を超えています。" + "\n";
                }

                if (exceedsMaxLength["nameKana"]) {
                    errorMsg += "名前(かな)に入力する事のできる最大文字数を超えています。" + "\n";
                }

                if (exceedsMaxLength["email"]) {
                    errorMsg += "メールアドレスに入力する事のできる最大文字数を超えています。" + "\n";
                }

                if (nonKanjiDetected["lastName"]) {
                    errorMsg += "名前(漢字)の姓の入力欄に漢字以外の文字が入力されています。" + "\n";
                }

                if (nonKanjiDetected["firstName"]) {
                    errorMsg += "名前(漢字)の名の入力欄に漢字以外の文字が入力されています。" + "\n";
                }

                if (nonHiraganaDetected["lastName"]) {
                    errorMsg += "名前(かな)の姓の入力欄にひらがな以外の文字が入力されています。" + "\n";
                }

                if (nonHiraganaDetected["firstName"]) {
                    errorMsg += "名前(かな)の名の入力欄にひらがな以外の文字が入力されています。" + "\n";
                }

                if (invalidEmail) {
                    errorMsg += "メールアドレスの形式が不正です。" + "\n";
                }

                if (invalidBirthday) {
                    errorMsg += "生年月日に入力された値が不正です。" + "\n";
                }

                if (invalidPrefecture) {
                    errorMsg += "都道府県に入力された値が不正です。" + "\n";
                }

                // エラーメッセージを表示
                messageObj.style.color = "red";
                messageObj.innerText = errorMsg;
            } else {
                $.ajax({
                    type: "POST",
                    url: '<%= ResolveUrl("/member-register.aspx/RegisterButton_Clicked") %>',
                    contentType: "application/json",
                    data: JSON.stringify({
                        "lastName": lastName,
                        "firstName": firstName,
                        "lastNameKana": lastNameKana,
                        "firstNameKana": firstNameKana,
                        "email": email,
                        "birthdayStr": birthday,
                        "genderStr": genderValue,
                        "prefecture": prefecture
                    }),
                    success: function (data) {
                        const parsedData = JSON.parse(data.d);

                        // 処理結果を取得する
                        const result = parsedData["Result"];

                        // エラーメッセージを取得する
                        const errorMsgs = parsedData["ErrorMsgs"];

                        // 複数のエラーメッセージを一つの文字列にする
                        const errorMsg = "";

                        for (let msg in errorMsgs) {
                            errorMsg += msg + "\n";
                        }

                        if (result == "success") {
                            messageObj.style.color = "green";
                            messageObj.innerText = "登録に成功しました";
                        } else if (result == "failed") {
                            messageObj.style.color = "red";
                            messageObj.innerText = errorMsg;
                        }
                    },
                    error: function () {
                        messageObj.style.color = "red";
                        messageObj.innerText = "登録処理に失敗しました";
                    }
                });
            }
        }
    </script>
</head>
<body>
    <header>
        <h1>会員管理システム</h1>
        <nav>
            <ul>
                <li><a href="member-searh.aspx">会員一覧</a></li>
                <li><a href="member-register.aspx">会員登録</a></li>
            </ul>
        </nav>
    </header>
    <main>
        <h2>会員登録</h2>
        <div class="input-form">
            <table>
                <tr>
                    <th>名前</th>
                    <td>
                        <div class="two-column">
                            <div>姓<input type="text" name="last_name" value="" /></div>
                            <div>名<input type="text" name="first_name" value="" /></div>
                        </div>
                    </td>
                </tr>
                <tr>
                    <th>名前(かな)</th>
                    <td>
                        <div class="two-column">
                            <div>姓<input type="text" name="last_name_kana" value="" /></div>
                            <div>名<input type="text" name="first_name_kana" value="" /></div>
                        </div>
                    </td>
                </tr>
                <tr>
                    <th>メールアドレス</th>
                    <td>
                        <input type="text" name="email" value="" />
                    </td>
                </tr>
                <tr>
                    <th>生年月日</th>
                    <td>
                        <input type="date" name="birthday" value="" min="1950-01-01" max="2025-12-31">
                    </td>
                </tr>
                <tr>
                    <th>性別</th>
                    <td>
                        <div class="input-check-list">
                            <label><input type="radio" name="sex" value="1">男性</label>
                            <label><input type="radio" name="sex" value="2">女性</label>
                        </div>
                    </td>
                </tr>
                <tr>
                    <th>都道府県</th>
                    <td>
                        <select name="prefecture">
                            <option value=""></option>
                            <option value="1">北海道</option>
                            <option value="2">青森県</option>
                            <option value="3">岩手県</option>
                            <option value="4">宮城県</option>
                            <option value="5">秋田県</option>
                            <option value="6">山形県</option>
                            <option value="7">福島県</option>
                            <option value="8">茨城県</option>
                            <option value="9">栃木県</option>
                            <option value="10">群馬県</option>
                            <option value="11">埼玉県</option>
                            <option value="12">千葉県</option>
                            <option value="13">東京都</option>
                            <option value="14">神奈川県</option>
                            <option value="15">新潟県</option>
                            <option value="16">富山県</option>
                            <option value="17">石川県</option>
                            <option value="18">福井県</option>
                            <option value="19">山梨県</option>
                            <option value="20">長野県</option>
                            <option value="21">岐阜県</option>
                            <option value="22">静岡県</option>
                            <option value="23">愛知県</option>
                            <option value="24">三重県</option>
                            <option value="25">滋賀県</option>
                            <option value="26">京都府</option>
                            <option value="27">大阪府</option>
                            <option value="28">兵庫県</option>
                            <option value="29">奈良県</option>
                            <option value="30">和歌山県</option>
                            <option value="31">鳥取県</option>
                            <option value="32">島根県</option>
                            <option value="33">岡山県</option>
                            <option value="34">広島県</option>
                            <option value="35">山口県</option>
                            <option value="36">徳島県</option>
                            <option value="37">香川県</option>
                            <option value="38">愛媛県</option>
                            <option value="39">高知県</option>
                            <option value="40">福岡県</option>
                            <option value="41">佐賀県</option>
                            <option value="42">長崎県</option>
                            <option value="43">熊本県</option>
                            <option value="44">大分県</option>
                            <option value="45">宮崎県</option>
                            <option value="46">鹿児島県</option>
                            <option value="47">沖縄県</option>
                        </select>
                    </td>
                </tr>
                <tr>
                    <td colspan="4">
                        <div class="button-box">
                            <button class="register-button" onclick="registerButtonClicked()">登録</button>
                        </div>
                    </td>
                </tr>
            </table>
            <p class="message"></p>
            </div>
    </main>
</body>