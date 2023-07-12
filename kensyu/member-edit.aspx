<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="member-edit.aspx.cs" Inherits="kensyu.memberedit" %>
<!DOCTYPE html>
<html>
<head>
    <title>会員編集 | 会員管理システム</title>
    <link rel="stylesheet" href="./css/common.css" />
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <script type="text/javascript">
        window.onload = setCustomerData();

        function setCustomerData() {
            // URLを取得
            var url = new URL(window.location.href);
            var params = url.searchParams;

            var idStr = params.get('id');

            $.ajax({
                type: "POST",
                url: '<%= ResolveUrl("/member-edit.aspx/GetCustomerInfoById") %>',
                contentType: "application/json",
                data: JSON.stringify({
                    "idStr": idStr,
                }),
                success: function (data) {
                    const result = data.d;

                    // データの取得中に例外が発生した場合、"failed"が返ってくる
                    // アラートでエラーメッセージを表示し、この後の処理を実行しない
                    if (result == "failed") {
                        alert('データのロードに失敗しました');

                        return false;
                    }

                    // 取得したJSON形式のデータを配列に変換する
                    const customerData = JSON.parse(result)[0];

                    // 取得したデータを変数に格納する
                    const name = customerData["name"];
                    const nameKana = customerData["nameKana"];

                    const splitedName = name.split(' ');
                    const splitedNameKana = nameKana.split(' ');

                    const lastNameStr = splitedName[0];
                    const firstNameStr = splitedName[1];

                    const lastNameKanaStr = splitedNameKana[0];
                    const firstNameKanaStr = splitedNameKana[1];

                    const emailStr = customerData["mail"];
                    const birthdayStr = customerData["birthday"];
                    const genderStr = customerData["gender"];
                    const prefectureStr = customerData["prefecture"];
                    const membershipStatusStr = customerData["membershipStatus"];

                    // idや入力欄の要素を取得する
                    const elements = getEditElements();

                    // 取得した要素を変数に代入する
                    const id = elements["id"]; // id
                    const email = elements["email"]; // メールアドレス
                    const lastName = elements["lastName"]; // 苗字(漢字)
                    const firstName = elements["firstName"]; // 名前(漢字)
                    const lastNameKana = elements["lastNameKana"]; // 苗字(かな)
                    const firstNameKana = elements["firstNameKana"]; // 名前(かな)
                    const birthday = elements["birthday"]; // 誕生日
                    const prefecture = elements["prefecture"]; // 都道府県
                    const gender = elements["gender"]; // 性別
                    const membershipStatus = elements["membershipStatus"]; // 会員状態

                    // 取得したデータを入力欄に入れる
                    id.innerHTML = idStr;

                    lastName.value = lastNameStr;
                    firstName.value = firstNameStr;

                    lastNameKana.value = lastNameKanaStr;
                    firstNameKana.value = firstNameKanaStr;

                    email.value = emailStr;
                    birthday.value = birthdayStr;

                    for (var i = 0; i < gender.length; i++) {
                        if (gender[i].value == genderStr) {
                            gender[i].checked = true;
                            break;
                        }
                    }

                    var prefectureOptions = prefecture.options;

                    for (var i = 0; i < prefectureOptions.length; i++) {
                        if (prefectureOptions[i].value == prefectureStr) {
                            prefectureOptions[i].selected = true;
                            break;
                        }
                    }

                    for (var i = 0; i < membershipStatus.length; i++) {
                        if (membershipStatus[i].value == membershipStatusStr) {
                            membershipStatus[i].checked = true;
                            break;
                        }
                    }
                },
                error: function () {
                    alert("データのロードに失敗しました");
                }
            });
        }

        // idや入力欄の要素を全て取得する
        // 連想配列が返される
        function getEditElements() {
            // 要素を取得
            const id = document.querySelector('#id');

            const lastName = document.querySelector('input[name="last_name"]');
            const firstName = document.querySelector('input[name="first_name"]');

            const lastNameKana = document.querySelector('input[name="last_name_kana"]');
            const firstNameKana = document.querySelector('input[name="first_name_kana"]');

            const email = document.querySelector('input[name="email"]');
            const birthday = document.querySelector('input[name="birthday"]');
            const gender = document.querySelectorAll('input[name="sex"]');
            const prefecture = document.querySelector('select[name="prefecture"]');
            const membershipStatus = document.querySelectorAll('input[name="member-status"]');

            // 要素を格納する連想配列
            const elements = {
                "id": id,
                "lastName": lastName,
                "firstName": firstName,
                "lastNameKana": lastNameKana,
                "firstNameKana": firstNameKana,
                "email": email,
                "birthday": birthday,
                "gender": gender,
                "prefecture": prefecture,
                "membershipStatus": membershipStatus
            };

            return elements;
        }

        function editBtnClicked() {
            // idなどの要素を取得する
            const elements = getEditElements();

            // 取得した要素を変数に格納する
            const id = elements["id"]; // id
            const email = elements["email"]; // メールアドレス
            const lastName = elements["lastName"]; // 苗字(漢字)
            const firstName = elements["firstName"]; // 名前(漢字)
            const lastNameKana = elements["lastNameKana"]; // 苗字(かな)
            const firstNameKana = elements["firstNameKana"]; // 名前(かな)
            const birthday = elements["birthday"]; // 誕生日
            const prefecture = elements["prefecture"]; // 都道府県
            const gender = elements["gender"]; // 性別
            const membershipStatus = elements["membershipStatus"]; // 会員状態

            // 入力された文字列を取得する
            const idStr = id.innerText;

            const lastNameStr = lastName.value;
            const firstNameStr = firstName.value;

            const lastNameKanaStr = lastNameKana.value;
            const firstNameKanaStr = firstNameKana.value;

            const emailStr = email.value;
            const birthdayStr = birthday.value;
            const prefectureStr = prefecture.value;

            var genderValue = "";
            var membershipStatusValue = "";

            for (var i = 0; i < gender.length; i++) {
                if (gender[i].checked) {
                    genderValue = gender[i].value;
                    break;
                }
            }

            for (var i = 0; i < membershipStatus.length; i++) {
                if (membershipStatus[i].checked) {
                    membershipStatusValue = membershipStatus[i].value;
                    break;
                }
            }

            // いずれかの不正な入力があったか
            let hasInvalidInput = false;

            // genderValueに1と2以外が入っていないかチェックする

            // genderValueが不正か
            let invalidGender = false;

            if (!(genderValue == "1" || genderValue == "2")) {
                invalidGender = true;
                hasInvalidInput = true;
            }

            // membershipStatusValueに1と2以外が入っていないかチェックする

            // membershipStatusValueが不正か
            let invalidMembershipStatus = false;

            if (!(membershipStatusValue == "1" || membershipStatusValue == "2")) {
                invalidMembershipStatus = true;
                hasInvalidInput = true;
            }

            // メッセージを表示するp要素
            const messageObj = document.querySelector('.message');

            // 入力チェック
            const inputtedData = [
                lastNameStr, firstNameStr, lastNameKanaStr, firstNameKanaStr,
                emailStr, birthdayStr, genderValue, prefectureStr, membershipStatusValue
            ];

            // 最大文字数
            const maxNameCharactor = 15; // 名前(漢字)
            const maxNameKanaCharactor = 50; // 名前(かな)
            const maxEmailCharactor = 50; // メールアドレス

            // 名前は苗字と名前を半角スペースで区切った形で登録されるため、
            // その形にして文字数チェックする
            const name = lastNameStr + " " + firstNameStr;
            const nameKana = lastNameKanaStr + " " + firstNameKanaStr;

            // 入力欄が空の所があったかどうかを管理するフラグ
            var isEmpty = false;

            // 最大文字数を超えた入力がされたかを管理するフラグ
            var exceedsMaxLength = {
                "name": false,
                "nameKana": false,
                "email": false
            };

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

            if (emailStr.length > maxEmailCharactor) {
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
            if (!kanjiCheckRegex.test(lastNameStr)) {
                nonKanjiDetected["lastName"] = true;
                hasInvalidInput = true;
            }

            if (!kanjiCheckRegex.test(firstNameStr)) {
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
            if (!hiraganaCheckRegex.test(lastNameKanaStr)) {
                nonHiraganaDetected["lastName"] = true;
                hasInvalidInput = true;
            }

            if (!hiraganaCheckRegex.test(firstNameKanaStr)) {
                nonHiraganaDetected["firstName"] = true;
                hasInvalidInput = true;
            }

            // メールアドレスの形式が正しいものかをチェックする
            const emailCheckRegex = /^[a-zA-Z0-9_+-]+(\.[a-zA-Z0-9_+-]+)*@([a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]*\.)+[a-zA-Z]{2,}$/;

            // メールアドレスの形式が正しくないか
            // 正しくないならtrueになる
            var invalidEmail = false;

            // チェック
            if (!emailCheckRegex.test(emailStr)) {
                invalidEmail = true;
                hasInvalidInput = true;
            }

            // 入力された誕生日が不正なものでないかチェックする

            // チェック用のDateオブジェクト
            const date = new Date(birthdayStr);

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

            const prefectureNum = Number(prefectureStr);

            // まず、数字であるか調べる
            if (isNaN(prefectureNum)) {
                invalidPrefecture = true;
                hasInvalidInput = true;
            } else {
                // 次に、1から47までの範囲内かを調べる
                if (!(prefectureNum >= 1 && prefectureNum <= 47)) {
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

                if (invalidGender) {
                    errorMsg += "性別が不正です。" + "\n";
                }

                if (invalidPrefecture) {
                    errorMsg += "都道府県に入力された値が不正です。" + "\n";
                }

                if (invalidMembershipStatus) {
                    errorMsg += "会員状態が不正です。" + "\n";
                }

                // エラーメッセージを表示
                messageObj.style.color = "red";
                messageObj.innerText = errorMsg;
            } else {
                $.ajax({
                    type: "POST",
                    url: '<%= ResolveUrl("/member-edit.aspx/UpdateCustomerInfo") %>',
                    contentType: "application/json",
                    data: JSON.stringify({
                        "idStr": idStr,
                        "lastNameStr": lastNameStr,
                        "firstNameStr": firstNameStr,
                        "lastNameKanaStr": lastNameKanaStr,
                        "firstNameKanaStr": firstNameKanaStr,
                        "emailStr": emailStr,
                        "birthdayStr": birthdayStr,
                        "genderStr": genderValue,
                        "prefectureStr": prefectureStr,
                        "membershipStatusStr": membershipStatusValue
                    }),
                    success: function (data) {
                        // 更新処理の結果が格納される
                        const parsedData = JSON.parse(data.d);

                        // 処理結果を取得
                        const result = parsedData["Result"];

                        // エラーメッセージを取得
                        const errorMsgs = parsedData["ErrorMsgs"];

                        console.log(errorMsgs);

                        // 複数のエラーメッセージを一つの文字列にする
                        var errorMsg = "";

                        for (let msg of errorMsgs) {
                            errorMsg += msg + "\n";
                        }

                        // 処理成功
                        if (result == "success") {
                            messageObj.style.color = "green";
                            messageObj.innerText = "会員情報の更新に成功しました";
                        // 処理失敗
                        } else if (result == "failed") {
                            messageObj.style.color = "red";
                            messageObj.innerText = errorMsg;
                        }
                    },
                    error: function () {
                        messageObj.style.color = "red";
                        messageObj.innerText = "サーバーとの接続に問題が発生しました";
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
        <h2>会員編集</h2>
        <div class="input-form">
            <table>
                <tr>
                    <th>ID</th>
                    <td id="id"></td>
                </tr>
                <tr>
                    <th>名前</th>
                    <td>
                        <div class="two-column">
                            <div>姓<input type="text" name="last_name" value="山田" /></div>
                            <div>名<input type="text" name="first_name" value="太郎" /></div>
                        </div>
                    </td>
                </tr>
                <tr>
                    <th>名前(かな)</th>
                    <td>
                        <div class="two-column">
                            <div>姓<input type="text" name="last_name_kana" value="やまだ" /></div>
                            <div>名<input type="text" name="first_name_kana" value="たろう" /></div>
                        </div>
                    </td>
                </tr>
                <tr>
                    <th>メールアドレス</th>
                    <td>
                        <input type="text" name="email" value="a@solidseed.co.jp" />
                    </td>
                </tr>
                <tr>
                    <th>生年月日</th>
                    <td>
                        <input type="date" name="birthday" value="1990-03-01" min="1950-01-01" max="2025-12-31">
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
                    <th>会員状態</th>
                    <td>
                        <div class="input-check-list">
                            <label><input type="radio" name="member-status" value="1">有効</label>
                            <label><input type="radio" name="member-status" value="2">退会</label>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td colspan="4">
                        <div class="button-box">
                            <input class="edit-button" type="submit" onclick="editBtnClicked()" value="編集" />
                        </div>
                    </td>
                </tr>
            </table>
            <p class="message"></p>
        </div>
    </main>
</body>
</html>