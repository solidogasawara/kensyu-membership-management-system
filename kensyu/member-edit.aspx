<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="member-edit.aspx.cs" Inherits="kensyu.membersearh" %>
<!DOCTYPE html>
<html>
<head>
    <title>会員編集 | 会員管理システム</title>
    <link rel="stylesheet" href="./css/common.css" />
    <script type="text/javascript">
        //javascript
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
                    <td>1</td>
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
                        <input type="date" name="birth-start" value="1990-03-01" min="1950-01-01" max="2025-12-31">
                    </td>
                </tr>
                <tr>
                    <th>性別</th>
                    <td>
                        <div class="input-check-list">
                            <label><input type="radio" name="sex" value="1" checked>男性</label>
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
                            <option value="13" selected>東京都</option>
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
                            <label><input type="radio" name="member-status" value="1" checked>有効</label>
                            <label><input type="radio" name="member-status" value="2">退会</label>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td colspan="4">
                        <div class="button-box">
                            <input class="edit-button" type="submit" value="編集" />
                        </div>
                    </td>
                </tr>
            </table>
        </form>
    </main>
</body>
</html>