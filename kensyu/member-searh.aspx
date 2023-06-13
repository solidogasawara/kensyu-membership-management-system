<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="member-searh.aspx.cs" Inherits="kensyu.membersearh" %>

<!DOCTYPE html>
<html>
<head>
    <title>会員一覧 | 会員管理システム</title>
    <link rel="stylesheet" href="./css/common.css" />
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
     <!-- 追加：deleteConfirmOpen(id) 関数を定義 -->
    <script type="text/javascript">
        function deleteConfirmOpen(id) {
            const modalBackgroundObj = document.querySelector('#modal-background');
            modalBackgroundObj.style.display = 'block';
    
            const modalWindowObj = document.querySelector('#modal-delete-confirm-window');
            modalWindowObj.style.display = 'block';
    
            const modalMemberDeleteIdObj = document.querySelector('#modal-member-delete-id');
            modalMemberDeleteIdObj.value = id;
    
            modalWindowObj.addEventListener('click', () => {
                modalMemberDeleteIdObj.value = '';
                modalBackgroundObj.style.display = 'none';
                modalWindowObj.style.display = 'none';
            });
        }

        function sortTable(columnName) {
            $.ajax({
                type: "POST",
                url: '/member-searh.aspx/SortTable',
                contentType: "application/json",
                data: JSON.stringify(columnName)
            })
        }
    </script>
    <script type="text/javascript" src="./js/common.js" defer></script>
</head>
  <body>
     <form method="get" action="member-searh.aspx" runat="server">
         

    <div id="modal-delete-confirm-window">
        <p>削除しますか？</p>
        <%--<form method="post" action="">
            <div class="button-box">
                <input class="yes" type="submit" value="はい" />
                <input class="no" type="button" value="いいえ" onclikc="deleteConfirmClose()" />
            </div>
            <input id="modal-member-delete-id" type="hidden" name="id" value="" />
        </form>--%>
    </div>
    <div id="modal-background"></div>
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
        <h2>会員一覧</h2>
        <%--<form class="search-form" method="get" action="member-searh.aspx">--%>
            <table class="search-form">
                <tr>
                    <th>ID</th>
                    <td>
                        <%--<asp:TextBox id="id" runat="server" />--%>
                        <input type="text" name="id" value="" />
                    </td>
                    <th>メールアドレス</th>
                    <td>
                        <%--<asp:TextBox id="email" runat="server" />--%>
                        <input type="text" name="email" value="" />
                    </td>
                </tr>
                <tr>
                    <th>名前</th>
                    <td>
                        <%--<asp:TextBox id="name" runat="server" />--%>
                        <input type="text" name="name" value="" />
                    </td>
                    <th>名前(かな)</th>
                    <td>
                        <%--<asp:TextBox id="name_kana" runat="server" />--%>
                        <input type="text" name="name_kana" value="" />
                    </td>
                    
                </tr>
                <tr>
                    <th>生年月日</th>
                    <td>
                        <div class="search-input-date-select-input">
                            <%--<asp:Calendar id="birth_start" runat="server" minimumValue="1950-01-01" maximumValue="2025-12-31"/>--%>
                            <input type="date" name="birth-start" value="" min="1950-01-01" max="2025-12-31">
                            <div>～</div>
                            <%--<asp:Calendar id="birth_end" runat="server" minimumValue="1950-01-01" maximumValue="2025-12-31"/>--%>
                            <input type="date" name="birth-end" value="" min="1950-01-01" max="2025-12-31">
                        </div>
                    </td>
                    <th>性別</th>
                    <td>
                        <div class="input-check-list">
                            <%--<label><asp:CheckBox id="sex[]" runat="server" /></label>--%>
                            <label><input type="checkbox" name="sex[]" value="1">男性</label>
                            <label><input type="checkbox" name="sex[]" value="2">女性</label>
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
                    <th>会員状態</th>
                    <td>
                        <div class="input-check-list">
                            <label><input type="checkbox" name="member-status[]" value="1">有効</label>
                            <label><input type="checkbox" name="member-status[]" value="2">退会</label>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td colspan="4">
                        <div class="button-box">
                             <%--<input class="search-button" type="submit" value="検索" />--%> 
                            <asp:Button ID="SearchButton" class="search-button" runat="server" Text="検索" OnClick="SearchButton_Click" />
                        </div>
                    </td>
                </tr>
            </table>
        <%--</form>--%>
        <div class="search-list">
          <table>
            <asp:Repeater id="Repeater1" runat="server">
                <HeaderTemplate>
                    <tr>
                        <th onclick="sortTable('id')">ID</th>
                        <th>名前</th>
                        <th>名前(かな)</th>
                        <th>メールアドレス</th>
                        <th>生年月日</th>
                        <th>性別</th>
                        <th>都道府県</th>
                        <th>会員状態</th>
                        <th>操作</th>
                    </tr>
                </HeaderTemplate>

                <ItemTemplate>
                    <tr>
                        <td><%# Eval("id") %></td>
                        <td><%# Eval("name") %></td>
                        <td><%# Eval("name_kana") %></td>
                        <td><%# Eval("mail") %></td>
                        <td><%# Eval("birthday") %></td>
                        <td><%# (bool) Eval("gender") ? "女性" : "男性" %></td>
                        <td><%# Eval("prefecture") %></td>
                        <td><%# (bool) Eval("membership_status") ? "有効" : "無効" %></td>
                        <td>
                            <div class="button-box">
                                <a class="link-button edit-button" href="member-edit.aspx?id=1">編集</a>
                                <input class="delete-button" type="button" onclick="deleteConfirmOpen(1)" value="削除" />
                            </div>
                        </td>
                    </tr>
                </ItemTemplate>
            </asp:Repeater>
        </table>
        </div>
        <div class="pager">
            <ul>
                <li>
                    <span class="content">1</span>
                </li>
                <li>
                    <a class="content" href="member-searh.aspx?p=2">2</a>
                </li>
            </ul>
        </div>
    </main>
         </form>
</body>
</html>