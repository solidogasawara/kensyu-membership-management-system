<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="admin-register-page.aspx.cs" Inherits="kensyu.admin_register_page" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>システム管理者登録画面</title>
    <link rel="stylesheet" href="./css/registerPageStyle.css" />
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <script type="text/javascript">
        function adminRegister() {
            // 入力欄の要素を取得する
            const loginInputLoginId = document.getElementById('register-input-loginId');
            const loginInputPassword = document.getElementById('register-input-password');

            // 入力されたログインidとパスワードを取得する
            const inputtedLoginId = loginInputLoginId.value;
            const inputtedPassword = loginInputPassword.value;

            // エラーメッセージを表示する要素
            const registerErrorMsg = document.getElementById('register-error-msg');
            registerErrorMsg.style.visibility = 'visible';

            // 未入力チェック
            if (inputtedLoginId == "" || inputtedPassword == "") {
                registerErrorMsg.innerText = "ログインIDまたはパスワードが未入力です";
                return false;
            }

            // ログインidの文字数チェック

            // ログインidの最大文字数
            const maxLoginIdCharactor = 50;

            if (inputtedLoginId.length > maxLoginIdCharactor) {
                loginErrorMsg.innerText = "ログインidに指定できる最大文字数を超えています";
                return false;
            }

            // 登録処理
            $.ajax({
                type: "POST",
                url: '<%= ResolveUrl("/admin-register-page.aspx/AdminRegister") %>',
                contentType: "application/json",
                data: JSON.stringify({
                    "loginId": inputtedLoginId,
                    "inputtedPassword": inputtedPassword
                }),
                success: function (data) {
                    const result = data.d;

                    if (result == "success") {
                        registerErrorMsg.style.color = "green";
                        registerErrorMsg.innerText = "登録処理が完了しました。ログイン画面に移動します。";

                        // 2秒後にログイン画面に遷移する
                        setTimeout(function () {
                            window.location.href = "admin-login-page.aspx";
                        }, 2000);
                    } else if (result == "loginId exists") {
                        registerErrorMsg.innerText = "入力されたログインiDは既に登録されています";
                    } else if (result == "unexpected error") {
                        registerErrorMsg.innerText = "予期せぬエラーが発生しました";
                    }
                },
                error: function () {
                    registerErrorMsg.innerText = "予期せぬエラーが発生しました";
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
        </ul>
    </nav>
    </header>
    <main>
        <div class="register-form">
            <form>
            <table>
                <tr>
                    <td colspan="2">
                        <h1>管理者登録</h1>
                    </td>
                </tr>
                <tr>
                    <th>
                        ログインID
                    </th>
                    <td>
                        <input id="register-input-loginId" type="text" />
                    </td>
                </tr>
                <tr>
                    <td><br /></td>
                </tr>
                <tr>
                    <th>
                        パスワード
                    </th>
                    <td>
                        <input id="register-input-password" type="password" />
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <p id="register-error-msg"><br/></p>
                    </td>
                </tr>
                <tr>
                    <td><br /></td>
                </tr>
                <tr>
                    <td><br /></td>
                </tr>
                <tr>
                    <td colspan="2">
                        <div class="button-box">
                            <input type="submit" value="登録" onclick="adminRegister(); return false;"/>
                        </div>
                    </td>
                </tr>
            </table>
            </form>
        </div>
    </main>
</body>
</html>
