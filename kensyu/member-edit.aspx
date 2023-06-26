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
                    var customerData = JSON.parse(data.d);

                    var name = customerData[0];
                    var nameKana = customerData[1];

                    var splitedName = name.split(' ');
                    var splitedNameKana = nameKana.split(' ');

                    var lastNameStr = splitedName[0];
                    var firstNameStr = splitedName[1];

                    var lastNameKanaStr = splitedNameKana[0];
                    var firstNameKanaStr = splitedNameKana[1];

                    var emailStr = customerData[2];
                    var birthdayStr = customerData[3];
                    var genderStr = customerData[4];
                    var prefectureStr = customerData[5];
                    var membershipStatusStr = customerData[6];

                    var id = document.getElementById('id');

                    var lastName = document.getElementsByName('last_name')[0];
                    var firstName = document.getElementsByName('first_name')[0];

                    var lastNameKana = document.getElementsByName('last_name_kana')[0];
                    var firstNameKana = document.getElementsByName('first_name_kana')[0];

                    var email = document.getElementsByName('email')[0];
                    var birthday = document.getElementsByName('birthday')[0];
                    var gender = document.getElementsByName('sex');
                    var prefecture = document.getElementsByName('prefecture')[0];
                    var membershipStatus = document.getElementsByName('member-status');

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
                error: function (result) {
                    alert("データのロードに失敗しました");
                }
            });
        }

        function editBtnClicked() {
            var id = document.getElementById('id').innerText;

            var lastName = document.getElementsByName('last_name')[0].value;
            var firstName = document.getElementsByName('first_name')[0].value;

            var lastNameKana = document.getElementsByName('last_name_kana')[0].value;
            var firstNameKana = document.getElementsByName('first_name_kana')[0].value;

            var email = document.getElementsByName('email')[0].value;
            var birthday = document.getElementsByName('birthday')[0].value;
            var gender = document.getElementsByName('sex');
            var prefecture = document.getElementsByName('prefecture')[0].value;
            var membershipStatus = document.getElementsByName('member-status');

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

            $.ajax({
                type: "POST",
                url: '<%= ResolveUrl("/member-edit.aspx/UpdateCustomerInfo") %>',
                contentType: "application/json",
                data: JSON.stringify({
                    "idStr": id,
                    "lastNameStr": lastName,
                    "firstNameStr": firstName,
                    "lastNameKanaStr": lastNameKana,
                    "firstNameKanaStr": firstNameKana,
                    "emailStr": email,
                    "birthdayStr": birthday,
                    "genderStr": genderValue,
                    "prefectureStr": prefecture,
                    "membershipStatusStr": membershipStatusValue
                }),
                success: function (data) {
                    if (!alert("更新成功")) {
                        window.history.back();
                    }
                },
                error: function (result) {
                    alert("更新失敗");
                }
            });
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
        <form class="input-form" method="post" action="member-edit.aspx">
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
        </form>
    </main>
</body>
</html>