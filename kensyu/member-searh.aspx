<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="member-searh.aspx.cs" Inherits="kensyu.membersearh" %>

<!DOCTYPE html>
<html>
<head>
    <title>会員一覧 | 会員管理システム</title>
    <link rel="stylesheet" href="./css/common.css" />
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/encoding-japanese/2.0.0/encoding.min.js" integrity="sha512-AhAMtLXTbhq+dyODjwnLcSlytykROxgUhR+gDZmRavVCNj6Gjta5l+8TqGAyLZiNsvJhh3J83ElyhU+5dS2OZw==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
     <!-- 追加：deleteConfirmOpen(id) 関数を定義 -->
    <script type="text/javascript">
        function deleteConfirmOpen(rowNum) {
            var table = document.getElementById('search-result');

            var id = table.rows[rowNum].cells[0].innerText;

            const modalBackgroundObj = document.querySelector('.modal-background');
            modalBackgroundObj.style.display = 'block';
    
            const modalWindowObj = document.querySelector('#modal-delete-confirm-window');
            modalWindowObj.style.display = 'block';
    
            const modalMemberDeleteIdObj = document.querySelector('#modal-member-delete-id');
            modalMemberDeleteIdObj.value = id;
    
            modalWindowObj.addEventListener('click', () => {
                modalMemberDeleteIdObj.value = '';
                modalBackgroundObj.style.display = 'none';
                modalWindowObj.style.display = 'none';

                searchButtonClicked();
            });
        }

        function csvUploadWindowOpen() {
            const modalBackgroundObj = document.querySelector('.modal-background');
            modalBackgroundObj.style.display = 'block';
    
            const modalWindowObj = document.querySelector('#modal-csvupload-window');
            modalWindowObj.style.display = 'block';

            const modalWindowCloseBtn = document.querySelector('.modal-csvupload-close-button');
            modalWindowCloseBtn.style.display = 'block';

            const modalFileUploadObj = document.getElementById('modal-csvupload-file');
            modalFileUploadObj.addEventListener('change', onfileUploaded);

            const modalTextarea = document.getElementById('modal-csvupload-textarea');

            const modalDoneObj = document.getElementById('modal-csvupload-done');

            const modalResultObj = document.querySelector('.modal-csvupload-result');

            modalWindowCloseBtn.addEventListener('click', () => {
                modalBackgroundObj.style.display = 'none';
                modalWindowObj.style.display = 'none';
                modalFileUploadObj.value = '';
                modalTextarea.value = '';
                modalDoneObj.style.visibility = 'hidden';
                modalResultObj.innerHTML = '';
                modalResultObj.style.visibility = 'hidden';

                searchButtonClicked();
            });
        }

        function onfileUploaded(e) {
            const modalTextarea = document.getElementById('modal-csvupload-textarea');

            console.log(e.target.files.length);
            var fileData = e.target.files[0];


            var reader = new FileReader();

            reader.onerror = function () {
                modalTextarea.value = "エラー: ファイルの読み込みに失敗しました";
            }

            reader.onload = function () {
                var csv = reader.result;

                $.ajax({
                    type: "POST",
                    url: '<%= ResolveUrl("/member-searh.aspx/CSVUploadButton_Click") %>',
                    contentType: "application/json",
                    data: JSON.stringify({
                        "csv": csv
                    }),
                    success: function (data) {
                        var results = JSON.parse(data.d);
                        var errorMsgs = results["errorMsgs"];
                        var resultText = results["result"];

                        var errorMsg = "";
                        for (var i = 0; i < errorMsgs.length; i++) {
                            errorMsg += errorMsgs[i] + "\n";
                        }

                        modalTextarea.value = errorMsg;

                        const modalResultObj = document.querySelector('.modal-csvupload-result');
                        modalResultObj.innerText = resultText;
                        modalResultObj.style.visibility = 'visible';

                        const modalDoneObj = document.getElementById('modal-csvupload-done');
                        modalDoneObj.style.visibility = 'visible';
                    },
                    error: function (result) {
                        alert("失敗: " + result.status);
                    }
                });
            }

            reader.readAsText(fileData, 'Shift_JIS');
        }

        // 前にクリックされたテーブルのカラム
        // 始めはidがソートされた状態で表示されるため、初期値は"id"
        var columnNamePrev = "id";

        // 降順でソートするか
        var desc = false;

        // テーブル情報をC#側に送り、C#側でソートしたのちその結果を受け取る
        // その結果をもとにテーブルを更新する
        function sortTable(columnName) {

            // 前にクリックしたカラムと同じカラムがクリックされたなら、昇順、降順を入れ替える
            // もし違うカラムだったなら必ず昇順でソートする
            if (columnNamePrev == columnName) {
                desc = !desc;
            } else {
                desc = false;
            }

            // クリックされたカラムがidなら、idのソートインジケーターを表示して、
            // 誕生日のソートインジケーターを非表示にする
            // birthdayの場合はその逆
            // 昇順、降順で三角の向きを切り替える
            if (columnName == "id") {
                changeIdSortIndicatior();
            } else if (columnName == "birthday") {
                changeBdSortIndicator();
            }

            // 今回押されたカラムを変数に保存する
            columnNamePrev = columnName;

            // テーブルの取得
            var table = document.getElementById('search-result');

            // テーブル情報を格納する配列
            var tableData = [];

            // テーブル情報を配列に格納する
            // 1行目はテーブルのカラム名が入っている(["id", "名前", "名前(かな)"..."操作"])
            // テーブルの1行目は不要なため、iは1からスタート
            for (var i = 1; i < table.rows.length; i++) {
                var rowData = [];
                var row = table.rows[i];
                for (var j = 0; j < row.cells.length; j++) {
                    rowData.push(row.cells[j].innerText);
                }
                tableData.push(rowData);
            }

            // テーブル情報と、並び替えの基準となるカラム名、並び替え順をC#側に渡して
            // C#側でソートしたものを受け取る
            // 受け取ったものをテーブルに入れて画面上での並び替えを完了させる
            $.ajax({
                type: "POST",
                url: '<%= ResolveUrl("/member-searh.aspx/SortTable") %>',
                contentType: "application/json",
                data: JSON.stringify({
                    "tableData": tableData,
                    "columnName": columnName,
                    "sortMethod": desc ? "desc" : "asc"
                }),
                success: function (data) {
                    // alert("成功: " + data.d);

                    // ソートされたテーブル情報
                    var arrayData = JSON.parse(data.d);

                    // ソートされたテーブル情報を元にテーブルを更新する
                    // 実際にデータが入っている行は2行目からなので、iは1
                    for (var i = 1; i < table.rows.length; i++) {
                        var dataRow = arrayData[i - 1];
                        var tableRow = table.rows[i];
                        for (var j = 0; j < tableRow.cells.length - 1; j++) {
                            tableRow.cells[j].innerText = dataRow[j];
                        }
                    }
                },
                error: function (result) {
                    alert("失敗: " + result.status);
                }
            });
        }

        function changeIdSortIndicatior() {
            // ソートの昇順、降順を表すソートインジケーター
            // 昇順 = 「▲」、降順 = 「▼」
            var idSortToggle = document.getElementById("idSortToggle"); // id
            var bdSortToggle = document.getElementById("bdSortToggle"); // 誕生日

            idSortToggle.style.visibility = "visible";
            bdSortToggle.style.visibility = "hidden";

            if (!desc) {
                idSortToggle.innerText = "▲";
            } else {
                idSortToggle.innerText = "▼";
            }
        }

        function changeBdSortIndicator() {
            // ソートの昇順、降順を表すソートインジケーター
            // 昇順 = 「▲」、降順 = 「▼」
            var idSortToggle = document.getElementById("idSortToggle"); // id
            var bdSortToggle = document.getElementById("bdSortToggle"); // 誕生日

            idSortToggle.style.visibility = "hidden";
            bdSortToggle.style.visibility = "visible";

            if (!desc) {
                bdSortToggle.innerText = "▲";
            } else {
                bdSortToggle.innerText = "▼";
            }
        }

        function searchButtonClicked() {
            searchCustomer(
                "SearchButton_Click",
                function (data) {
                    columnNamePrev = "id";
                    desc = false;
                    changeIdSortIndicatior();

                    // DBから取得した情報
                    var arrayData = JSON.parse(data.d);


                    // テーブル要素
                    var table = document.getElementById('search-result');

                    var tableHeader = document.getElementById('search-table-header');
                    tableHeader.style.display = '';

                    // 既に表示されているテーブルを初期化する
                    // カラムの行は削除しないようにするので、iは1から
                    while (table.rows.length > 1) {
                        table.deleteRow(1);
                    }

                    if (arrayData.length == 0) {
                        tableHeader.style.display = 'none';
                        return;
                    }

                    // 取得した情報を元にテーブルを作成する
                    for (var i = 0; i < arrayData.length; i++) {
                        var arrayRow = arrayData[i];
                        // tr要素の作成
                        var tr = document.createElement('tr');
                        for (var j = 0; j < arrayRow.length; j++) {
                            // td要素の作成
                            var td = document.createElement('td');

                            // td要素に取得した情報を追加する
                            td.appendChild(document.createTextNode(arrayRow[j]));
                            // tr要素にtd要素を追加する
                            tr.appendChild(td);
                        }

                        var td = document.createElement('td');

                        var div = document.createElement('div');
                        div.className = "button-box";

                        // 編集、削除ボタンを作成する
                        // 編集ボタン
                        var editBtn = document.createElement('input');
                        editBtn.className = "link-button edit-button";
                        editBtn.type = "button";
                        //editBtn.href = "member-edit.aspx?id=" + arrayRow[0];
                        editBtn.setAttribute('onclick', "editBtnClicked(" + (i + 1) + ")");
                        //editBtn.onclick = "editBtnClicked(" + i + ")";
                        editBtn.value = "編集";

                        // 削除ボタン
                        var deleteBtn = document.createElement('input');
                        deleteBtn.className = "delete-button";
                        deleteBtn.type = "button";
                        deleteBtn.setAttribute('onclick', "deleteConfirmOpen(" + (i + 1) + ")");
                        //deleteBtn.onclick = "deleteConfirmOpen(1)";
                        deleteBtn.value = "削除";

                        // 編集、削除ボタンをtr要素に追加する
                        div.appendChild(editBtn);
                        div.appendChild(deleteBtn);

                        td.appendChild(div);

                        tr.appendChild(td);

                        // table要素にtr要素を追加する
                        table.appendChild(tr);
                    }
                },
                function (result) {
                    alert("失敗: " + result.status);

                }
            );
        }

        function searchCustomer(cSharpMethodName, success, failure) {
            // 入力された情報を取得する
            var id = document.getElementsByName('id')[0].value; // id
            var email = document.getElementsByName('email')[0].value; // メールアドレス
            var name = document.getElementsByName('name')[0].value; // 名前(漢字)
            var nameKana = document.getElementsByName('name_kana')[0].value; // 名前(かな)
            var birthStart = document.getElementsByName('birth-start')[0].value; // 誕生日(始め)
            var birthEnd = document.getElementsByName('birth-end')[0].value; // 誕生日(終わり)
            var prefecture = document.getElementsByName('prefecture')[0].value; // 都道府県
            var gender = document.getElementsByName('sex[]'); // 性別
            var memberStatus = document.getElementsByName('member-status[]'); // 会員状態

            var genderValue = "";
            var memberStatusValue = "";

            var genderCBoxChecked = [false, false];
            var memberStatusCBoxChecked = [false, false];

            for (var i = 0; i < gender.length; i++) {
                if (gender[i].checked) {
                    genderCBoxChecked[i] = true;
                }
            }

            if (genderCBoxChecked[0] && genderCBoxChecked[1]) {
                genderValue = "both";
            } else {
                if (genderCBoxChecked[0]) {
                    genderValue = gender[0].value;
                }
                if (genderCBoxChecked[1]) {
                    genderValue = gender[1].value;
                }
            }

            for (var i = 0; i < memberStatus.length; i++) {
                if (memberStatus[i].checked) {
                    memberStatusCBoxChecked[i] = true;
                }
            }

            if (memberStatusCBoxChecked[0] && memberStatusCBoxChecked[1]) {
                memberStatusValue = "both";
            } else {
                if (memberStatusCBoxChecked[0]) {
                    memberStatusValue = gender[0].value;
                }
                if (memberStatusCBoxChecked[1]) {
                    memberStatusValue = gender[1].value;
                }
            }

            $.ajax({
                type: "POST",
                url: '<%= ResolveUrl("/member-searh.aspx/") %>' + cSharpMethodName,
                contentType: "application/json",
                data: JSON.stringify({
                    "idStr": id,
                    "emailStr": email,
                    "nameStr": name,
                    "nameKanaStr": nameKana,
                    "birthStartStr": birthStart,
                    "birthEndStr": birthEnd,
                    "prefectureStr": prefecture,
                    "genderStr": genderValue,
                    "memberStatusStr": memberStatusValue
                }),
                success: function (data) {
                    success(data);
                },
                error: function (result) {
                    failure(result);
                }
            });
        }

        function editBtnClicked(rowNum) {
            var table = document.getElementById('search-result');

            var id = table.rows[rowNum].cells[0].innerText;

            window.location.href = "member-edit.aspx?id=" + id;
        }

        function deleteBtnClicked() {
            var id = document.getElementById('modal-member-delete-id').value;

            $.ajax({
                type: "POST",
                url: '<%= ResolveUrl("/member-searh.aspx/DeleteButton_Click") %>',
                contentType: "application/json",
                data: JSON.stringify({
                    "idStr": id,
                }),
                success: function (data) {
                    alert("削除しました");
                },
                error: function (result) {
                    alert("失敗: " + result.status);
                }
            });

        }

        function csvDownload() {
            searchCustomer(
                "CSVDownloadButton_Click",
                function (data) {
                    var unicodeCsv = data.d;

                    var unicodeArray = [];
                    for (var i = 0; i < unicodeCsv.length; i++) {
                        unicodeArray.push(unicodeCsv.charCodeAt(i));
                    }

                    var sjisArray = Encoding.convert(unicodeArray, {
                        to: 'SJIS',
                        from: 'UNICODE',
                    });

                    var csv = new Uint8Array(sjisArray);

                    var blob = new Blob([csv], { type: "text/csv" });

                    var date = new Date();
                    var year = date.getFullYear();
                    var month = ("00" + (date.getMonth()+1)).slice(-2);
                    var day = ("00" + (date.getDate())).slice(-2);
                    var fileName = year + month + day + "_" + "会員検索結果.csv";

                    var link = document.createElement('a');
                    link.href = URL.createObjectURL(blob);
                    link.download = fileName;
                    link.click();
                },
                function (result) {
                    alert('csvファイルの生成に失敗しました');
                }
            );
        }

        
    </script>
    <script type="text/javascript" src="./js/common.js" defer></script>
</head>
  <body>
     <%--<form method="get" action="member-searh.aspx" runat="server">
     <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>--%>
    <div id="modal-delete-confirm-window">
        <p>削除しますか？</p>
        <div class="button-box">
            <input class="yes" type="submit" value="はい" onclick="deleteBtnClicked();" />
            <input class="no" type="button" value="いいえ" />
        </div>
        <input id="modal-member-delete-id" type="hidden" name="id" value="" />
    </div>
    <div class="modal-background"></div>

    <div id="modal-csvupload-window">
        <p>CSVアップロード</p>
        <div class="button-box">
            <input type="file" id="modal-csvupload-file" accept=".csv">
        </div>
        <br>
        <textarea id="modal-csvupload-textarea"></textarea>
        <h2 id="modal-csvupload-done">挿入処理が完了しました</h2>
        <p class="modal-csvupload-result">行 エラー: 件</p>
        <div class="button-box">
            <input class="modal-csvupload-close-button" type="button" value="閉じる">
        </div>
    </div>
    
    <div class="modal-background"></div>
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
                            <%--<asp:Button ID="SearchButton" class="search-button" runat="server" Text="検索" OnClick="SearchButton_Click" />--%>
                            <button class="search-button" onclick="searchButtonClicked();">検索</button>
                        </div>
                    </td>
                </tr>
            </table>
        <%--</form>--%>
        <div class="csv-download-upload">
            <div class="button-box">
                <button id="csv-download-button" onclick="csvDownload()">検索結果をCSV形式でダウンロード</button>
                <button id="csv-upload-button" onclick="csvUploadWindowOpen()">CSVファイルをアップロード</button>
            </div>
        </div>
        <br />
        <div class="search-list">
          <table id="search-result">
           <%-- <asp:Repeater id="Repeater1" runat="server">
                <HeaderTemplate>--%>
                    <tr id="search-table-header" style="display: none;">
                        <th onclick="sortTable('id')">
                            ID 
                            <div id="idSortToggle" style="color: gray; display: inline-block; _display: inline; visibility: visible;">▲</div>
                        </th>
                        <th>名前</th>
                        <th>名前(かな)</th>
                        <th>メールアドレス</th>
                        <th onclick="sortTable('birthday')">
                            生年月日 
                            <div id="bdSortToggle" style="color: gray; display: inline-block; _display: inline; visibility: hidden;">▲</div>
                        </th>
                        <th>性別</th>
                        <th>都道府県</th>
                        <th>会員状態</th>
                        <th>操作</th>
                    </tr>
                <%--</HeaderTemplate>--%>

                <%--<ItemTemplate>
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
            </asp:Repeater>--%>
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
         <%--</form>--%>
</body>
</html>