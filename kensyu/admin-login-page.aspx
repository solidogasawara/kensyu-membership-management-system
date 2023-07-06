<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="admin-login-page.aspx.cs" Inherits="kensyu.admin_login_page" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>ログイン画面 | 会員管理システム</title>
    <link rel="stylesheet" href="./css/loginPageStyle.css" />
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <script type="text/javascript">
        function loginProcess() {
            // 入力欄の要素を取得する
            const loginInputLoginId = document.getElementById('login-input-loginId');
            const loginInputPassword = document.getElementById('login-input-password');

            // 入力されたログインidとパスワードを取得する
            const inputtedLoginId = loginInputLoginId.value;
            const inputtedPassword = loginInputPassword.value;

            // エラーメッセージを表示する要素
            const loginErrorMsg = document.getElementById('login-error-msg');
            loginErrorMsg.style.visibility = 'visible';

            // 未入力チェック
            if (inputtedLoginId == "" || inputtedPassword == "") {
                loginErrorMsg.innerText = "ログインIDまたはパスワードが未入力です";
                return false;
            }

            // ログインidとパスワードをC#側に送信する
            $.ajax({
                type: "POST",
                url: '<%= ResolveUrl("/admin-login-page.aspx/LoginProcess") %>',
                contentType: "application/json",
                data: JSON.stringify({
                    "loginId": inputtedLoginId,
                    "inputtedPassword": inputtedPassword
                }),
                success: function (data) {
                    const result = data.d;

                    if (result == "correct") {
                        window.location.href = "member-searh.aspx";
                    } else if (result == "incorrect") {
                        loginErrorMsg.innerText = "ログインIDまたはパスワードが誤っています";
                    } else if (result == "error") {
                        loginErrorMsg.innerText = "処理中にエラーが発生しました";
                    }
                },
                error: function () {
                    loginErrorMsg.innerText = "何らかのエラーが発生しました";
                }
            });
        }
    </script>
</head>
<body>
    <header>
        <h1>会員管理システム</h1>
    </header>
        <main>
            <div class="login-form">
                <form>
                <table>
                    <tr>
                        <td colspan="2">
                            <h1>ログイン</h1>
                        </td>
                    </tr>
                    <tr>
                        <th>
                            ログインID
                        </th>
                        <td>
                            <input id="login-input-loginId" type="text" />
                        </td>
                    </tr>
                    <tr>
                        <td><br/></td>
                    </tr>
                    <tr>
                        <th>
                            パスワード
                        </th>
                        <td>
                            <input id="login-input-password" type="password" />
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <p id="login-error-msg"><br/></p>
                        </td>
                    </tr>
                    <tr>
                        <td><br/></td>
                    </tr>
                    <tr>
                        <td><br/></td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <div class="button-box">
                                <input type="submit" value="ログイン" onclick="loginProcess(); return false;"/>
                            </div>
                        </td>
                    </tr>
                </table>
                </form>
            </div>
        </main>
</body>
</html>
