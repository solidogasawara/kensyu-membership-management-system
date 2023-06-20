<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="member-register.aspx.cs" Inherits="kensyu.memberregister" %>
<!DOCTYPE html>
<head>
    <title>会員登録 | 会員管理システム</title>
    <link rel="stylesheet" href="./css/common.css" />
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <script type="text/javascript">
        function registerButtonClicked() {
            var firstName = document.getElementsByName('first_name')[0].value;
            var lastName = document.getElementsByName('last_name')[0].value;
            var firstNameKana = document.getElementsByName('first_name_kana')[0].value;
            var lastNameKana = document.getElementsByName('last_name_kana')[0].value;
            var email = document.getElementsByName('email')[0].value;
            var birthday = document.getElementsByName('birthday')[0].value;
            var gender = document.getElementsByName('sex');
            var prefecture = document.getElementsByName('prefecture')[0].value;

            var genderValue = "";

            var genderRBtnSelected = [false, false];
            for (var i = 0; i < gender.length; i++) {
                genderRBtnSelected[i] = true;
                break;
            }

            if (genderRBtnSelected[0]) {
                genderValue = gender[0].value;
            }

            if (genderRBtnSelected[1]) {
                genderValue = gender[1].value;
            }

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
                    alert("登録が完了しました");
                },
                error: function (result) {
                    alert("登録に失敗しました");
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
        <h2>会員登録</h2>
        <div class="input-form">
<%--        <form class="input-form" method="post" action="member-register.aspx" runat="server">--%>
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
                            <%--<asp:Button ID="SubmitButton" class="submit-button" runat="server" Text="登録" OnClick="SubmitButton_Click" />--%>
                            <%--<input type="submit" value="登録" />--%>
                        </div>
                    </td>
                </tr>
            </table>
            </div>
<%--        </form>--%>
    </main>
</body>