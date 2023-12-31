﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="member-searh.aspx.cs" Inherits="kensyu.membersearh" %>

<!DOCTYPE html>
<html>
<head>
    <title>会員一覧 | 会員管理システム</title>
    <link rel="stylesheet" href="./css/common.css" />
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/encoding-japanese/2.0.0/encoding.min.js" integrity="sha512-AhAMtLXTbhq+dyODjwnLcSlytykROxgUhR+gDZmRavVCNj6Gjta5l+8TqGAyLZiNsvJhh3J83ElyhU+5dS2OZw==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
    <!-- Select2.css -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.2/css/select2.min.css">
    <!-- Select2本体 -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.2/js/select2.min.js"></script>
     <!-- 追加：deleteConfirmOpen(id) 関数を定義 -->
    <script type="text/javascript">
        // ページがロードされた時に実行される
        window.onload = function () {
            // aタグにクリックイベントを設定する
            // 検索条件を保存するセッションを削除するためのもの
            $('a').click(function (e) {
                e.preventDefault();

                // このページの名前を取得する
                const thisPagePathName = location.pathname;

                // クリックされたaタグに設定されているURL
                const url = e.target.href;

                // 検索条件を保存するセッションと検索結果件数を保存するセッションの削除を行う
                // クリックしたリンクのURLに、このページ名が含まれていた場合は削除を行わない
                // (例えば、ページネーションの中のボタンをクリックした場合など)
                if (!url.includes(thisPagePathName)) {
                    sessionStorage.removeItem('searchQuery');
                    sessionStorage.removeItem('resultCount');
                }

                // ページ遷移を行う
                location.href = url;
            });

            if (sessionStorage.getItem('searchQuery') != null) {
                // 検索条件の状態を復元する
                restoreSearchQuery();
            }

            if (sessionStorage.getItem('resultCount') != null) {
                // 検索結果を表示する
                searchResultUpdate();

                // ページネーションを作成する
                createPagination();
            }

            // select2を適用する
            $('select[name="prefecture"]').select2();
        }

        function restoreSearchQuery() {
            // 保存されたSessionを元に、検索条件の状態を復元する
            const jsonQuerys = sessionStorage.getItem("searchQuery");

            // 初回読み込み時や、他ページに遷移して戻ってきたときなどはjsonQuerysがnullになる
            // もしjsonQuerysに中身があれば処理を実行する
            if (jsonQuerys != null) {
                // 保存されたデータを元に、検索条件の状態を復元する

                // JSON.parseを利用して、json形式のデータを連想配列にする
                const querys = JSON.parse(jsonQuerys);

                // 検索条件を入力する要素を取得する
                const queryElements = getSearchQueryElements();

                // 取得した要素を変数に代入する
                const id = queryElements["id"]; // id
                const email = queryElements["email"]; // メールアドレス
                const name = queryElements["name"]; // 名前
                const nameKana = queryElements["nameKana"]; // 名前(かな)
                const birthStart = queryElements["birthStart"]; // 誕生日(始め)
                const birthEnd = queryElements["birthEnd"]; // 誕生日(終わり)
                const prefecture = queryElements["prefecture"]; // 都道府県
                const gender = queryElements["gender"]; // 性別
                const memberStatus = queryElements["memberStatus"]; // 会員状態

                // セッションに保存されていた各要素のvalueプロパティを変数に代入する
                const idStr = querys["id"]; // id
                const emailStr = querys["email"]; // メールアドレス
                const nameStr = querys["name"]; // 名前
                const nameKanaStr = querys["nameKana"]; // 名前(かな)
                const birthStartStr = querys["birthStart"]; // 誕生日(始め)
                const birthEndStr = querys["birthEnd"]; // 誕生日(終わり)
                const prefectureStr = querys["prefecture"]; // 都道府県
                const genderStr = querys["gender"]; // 性別
                const memberStatusStr = querys["memberStatus"]; // 会員状態

                // 状態を復元する
                id.value = idStr;
                email.value = emailStr;
                name.value = nameStr;
                nameKana.value = nameKanaStr;
                birthStart.value = birthStartStr;
                birthEnd.value = birthEndStr;
                prefecture.value = prefectureStr;

                // 性別入力欄の状態を復元する
                // genderStrが空文字だった場合は復元処理を実行しない
                if (genderStr != "") {
                    // bothは2つのチェックボックスに両方チェックが入っていたことを表している
                    if (genderStr == "both") {
                        // 2つのチェックボックスにチェックを入れる
                        for (var i = 0; i < gender.length; i++) {
                            gender[i].checked = true;
                        }
                    } else {
                        // genderStrをNumber型に変換する
                        // 1: 男性, 2: 女性を表している
                        const value = Number(genderStr);

                        // valueから1を引いたものをインデックスとしてcheckedプロパティをtrueにする
                        gender[value - 1].checked = true;
                    }
                }

                // 会員状態入力欄の状態を復元する
                // memberStatusStrが空文字だった場合は復元処理を実行しない
                if (memberStatusStr != "") {
                    // bothは2つのチェックボックスに両方チェックが入っていたことを表している
                    if (memberStatusStr == "both") {
                        // 2つのチェックボックスにチェックを入れる
                        for (var i = 0; i < memberStatus.length; i++) {
                            memberStatus[i].checked = true;
                        }
                    } else {
                        // memberStatusStrをNumber型に変換する
                        // 1: 有効, 2: 退会を表している
                        const value = Number(memberStatusStr);

                        // valueから1を引いたものをインデックスとしてcheckedプロパティをtrueにする
                        memberStatus[value - 1].checked = true;
                    }
                }
            }
        }

        // 1ページに最大何件の会員情報を表示するか
        const maxResultsPerPage = 10;

        // 検索結果画面下部のページネーションを作成する
        function createPagination() {
            // ページネーションのイメージ
            // 最大ページ数が10ページの場合
            // 「⇓」は現在表示中のページ番号を表し、背景色を変える
            // 
            // 1ページ目を表示中の場合
            //   ⇓
            // < 1 2 3 4 5 … 10 >
            // 
            // 5ページ目を表示中の場合
            //            ⇓
            // < 1 … 3 4 5 6 7 … 10 >
            //
            // 7ページ目を表示中の場合
            //            ⇓
            // < 1 … 5 6 7 8 9 … 10 >
            //
            // 9ページ目を表示中の場合
            //              ⇓
            // < 1 … 6 7 8 9 10 >
            //
            // 1と最大ページ数の番号がページネーション内にない場合、…を表示してそれらのページに飛べるようにする
            // 現在のページ番号を表す目印の位置を、"1 2"、"9 10"は左から順番に移動させ、それ以外のページ番号の時は
            // ページネーションの中央に目印が来るようにする(5ページ目と7ページ目の例のイメージ)

            // 現在表示しているページのページ番号
            const pageNumber = getCurrentPageNumber();

            // ページネーションの長さ(奇数にすること)
            const paginationLength = 5;

            // セッションから検索結果の件数を取得する
            const resultCountStr = sessionStorage.getItem('resultCount');

            // Number型に変換する
            const resultCount = Number(resultCountStr);

            // 最大ページ数を計算する
            const maxPageNumber = Math.ceil(resultCount / maxResultsPerPage);

            // ページネーションの長さを2で割り、小数点以下を切り捨てする
            // この変数は後に条件式で使われる
            const halfPaginationLength = Math.floor(paginationLength / 2);

            const pagerUlObj = document.querySelector('.pager > ul');

            // ulの中身をリセットする
            pagerUlObj.innerHTML = '';

            // ページネーションを作成する
            // 最大ページ数が1ページ以下だった場合は、ボタンを一つだけ作って処理を終える
            if (maxPageNumber <= 1) {
                const li = document.createElement('li');
                const span = document.createElement('span');

                // span要素のクラス名と内容を「1」に設定
                span.className = 'content';
                span.innerText = '1';

                li.appendChild(span);

                pagerUlObj.appendChild(li);

                // この後の処理を実行しない
                return;
            }

            // ページボタンの一番最初に来るページ番号
            var firstPageNumber = pageNumber - halfPaginationLength; // ループカウンタの初期値

            console.log(firstPageNumber);

            // もし、firstPageNumberが0以下になったり、firstPageNumberにpaginationLengthを足した値がmaxPageNumberの値を超えるなら
            // 値を修正する

            // firstPageNumberとpaginationLengthを足した値がmaxPageNumberの値を超える場合
            if (firstPageNumber + paginationLength > maxPageNumber) {
                firstPageNumber = maxPageNumber + 1 - paginationLength;
            }

            // firstPageNumberが0以下の場合
            if (firstPageNumber <= 0) {
                firstPageNumber = 1;
            }

            // ページボタンの一番最後に来るページ番号
            var lastPageNumber = firstPageNumber - 1 + paginationLength; // ループ終了値

            console.log("lastPageNumber: " + lastPageNumber);

            // lastPageNumberが最大ページ数を超えている場合、値を修正する
            if (lastPageNumber > maxPageNumber) {
                lastPageNumber = maxPageNumber;
            }

            // 「<」ボタンを作成する
            // ただし、現在表示しているページのページ番号が1なら表示しない
            if (pageNumber != 1) {
                const li = document.createElement('li');
                // 「<」の部分
                const a = document.createElement('a');

                a.className = 'content';
                a.href = 'member-searh.aspx?p=' + (pageNumber - 1);
                a.innerText = '<';

                li.appendChild(a);

                // 「<」をulに追加
                pagerUlObj.appendChild(li);
            }

            // ページボタンの一番最初のボタンが「1」以外なら「1…」のボタンを表示する
            if (firstPageNumber != 1) {
                const li = document.createElement('li');
                // 「1」の部分
                const a = document.createElement('a');
                // 「…」の部分
                const p = document.createElement('p');

                a.className = 'content';
                a.href = 'member-searh.aspx';
                a.innerText = '1';

                li.appendChild(a);

                // 「1」をulに追加
                pagerUlObj.appendChild(li);

                p.className = 'content';
                p.innerText = '…';

                // 「…」をulに追加
                pagerUlObj.appendChild(p);
            }

            

            // ページボタンを作成する
            for (var page = firstPageNumber; page <= lastPageNumber; page++) {
                const li = document.createElement('li');

                // 現在表示中のページ番号の場合、背景色を変えてリンクではなくテキストにする
                if (page == pageNumber) {
                    const span = document.createElement('span');

                    span.className = 'content';
                    span.innerText = page;

                    li.appendChild(span);
                } else {
                    const a = document.createElement('a');

                    a.className = 'content';
                    a.href = 'member-searh.aspx?p=' + page;
                    a.innerText = page;

                    li.appendChild(a);
                }

                pagerUlObj.appendChild(li);
            }

            // 現在表示されているページボタンに最大ページ数のボタンがないなら、
            // 「(最大ページ数) …」これを表示して一番最後のページに飛べるようにする
            if (lastPageNumber != maxPageNumber) {
                const li = document.createElement('li');
                // 「…」の部分
                const p = document.createElement('p');
                // 「(最大ページ数)」の部分
                const a = document.createElement('a');

                p.className = 'content';
                p.innerText = '…';

                // 「…」をulに追加
                pagerUlObj.appendChild(p);

                a.className = 'content';
                a.href = 'member-searh.aspx?p=' + maxPageNumber;
                a.innerText = maxPageNumber;

                li.appendChild(a);

                // 「(最大ページ数)」をulに追加
                pagerUlObj.appendChild(li);
            }

            // 「>」ボタンを作成する
            // ただし、現在表示しているページのページ番号が最大ページ数なら表示しない
            if (pageNumber != maxPageNumber) {
                const li = document.createElement('li');
                // 「>」の部分
                const a = document.createElement('a');

                a.className = 'content';
                a.href = 'member-searh.aspx?p=' + (pageNumber + 1);
                a.innerText = '>';

                li.appendChild(a);

                // 「>」をulに追加
                pagerUlObj.appendChild(li);
            }
        }

        // 現在表示しているページのページ番号をURLから取得する
        function getCurrentPageNumber() {
            // URLを取得
            const url = new URL(window.location.href);
            // クエリパラメータを取得
            const params = url.searchParams;

            // クエリパラメータのpの中身は現在表示しているページ番号を表している
            var pageNumberStr = params.get('p');

            // もしpageNumberがnullなら1ページ目とみなす
            if (pageNumberStr == null) {
                pageNumberStr = "1";
            }

            // Number型に変換する
            const pageNumber = Number(pageNumberStr);

            return pageNumber;
        }

        // 削除画面
        function deleteConfirmOpen(rowNum) {
            var table = document.getElementById('search-result');

            var id = table.rows[rowNum].cells[0].innerText;

            const modalBackgroundObj = document.querySelector('.modal-background');
            modalBackgroundObj.style.display = 'block';
    
            const modalWindowObj = document.querySelector('#modal-delete-confirm-window');
            modalWindowObj.style.display = 'block';
    
            const modalMemberDeleteIdObj = document.querySelector('#modal-member-delete-id');
            modalMemberDeleteIdObj.value = id;

            const modalWindowYesBtn = document.querySelector('#modal-delete-confirm-window .yes');

            modalWindowYesBtn.addEventListener('click', deleteBtnClicked);

            const windowClicked = () => {
                modalMemberDeleteIdObj.value = '';
                modalBackgroundObj.style.display = 'none';
                modalWindowObj.style.display = 'none';

                modalWindowObj.removeEventListener('click', windowClicked);
                modalWindowYesBtn.removeEventListener('click', deleteBtnClicked);
            };

            modalWindowObj.addEventListener('click', windowClicked);
        }

        // csvアップロード画面
        function csvUploadWindowOpen() {
            const modalBackgroundObj = document.querySelector('.modal-background');
            modalBackgroundObj.style.display = 'block';
    
            const modalWindowObj = document.querySelector('#modal-csvupload-window');
            modalWindowObj.style.display = 'block';

            const modalWindowCloseBtn = document.querySelector('.modal-csvupload-close-button');

            const modalWindowUploadBtn = document.querySelector('.modal-csvupload-button');

            const modalTextarea = document.getElementById('modal-csvupload-textarea');

            const modalDoneObj = document.getElementById('modal-csvupload-done');

            const modalResultObj = document.querySelector('.modal-csvupload-result');

            const modalFileUploadObj = document.getElementById('modal-csvupload-file');
            var csvFile = null;

            const fileSelect = (e) => {
                // 表示をリセット
                modalTextarea.value = '';
                modalDoneObj.style.visibility = 'hidden';
                modalResultObj.innerHTML = '';
                modalResultObj.style.visibility = 'hidden';

                csvFile = e.target.files[0];
            };

            modalFileUploadObj.addEventListener('change', fileSelect);

            const uploadBtnClicked = () => {
                // まだファイルがアップロードされていないなら、ボタンを押しても何の処理も実行しない
                if (csvFile != null) {
                    console.log("upload");
                    csvUpload(csvFile);
                }
            };

            // アップロードボタンを押したとき、データ挿入処理を実行する
            modalWindowUploadBtn.addEventListener('click', uploadBtnClicked);

            const closeBtnClicked = () => {
                modalBackgroundObj.style.display = 'none';
                modalWindowObj.style.display = 'none';
                modalFileUploadObj.value = '';
                modalTextarea.value = '';
                modalDoneObj.style.visibility = 'hidden';
                modalResultObj.innerHTML = '';
                modalResultObj.style.visibility = 'hidden';
                csvFile = null;

                // イベントリスナーを削除
                modalFileUploadObj.removeEventListener('change', fileSelect);
                modalWindowUploadBtn.removeEventListener('click', uploadBtnClicked);
                modalWindowCloseBtn.removeEventListener('click', closeBtnClicked);
            };

            // 閉じるボタンを押したとき、ウィンドウの表示を隠す
            modalWindowCloseBtn.addEventListener('click', closeBtnClicked);
        }

        // 検索ヒント画面
        function searchHintWindowOpen() {
            const modalBackgroundObj = document.querySelector('.modal-background');
            modalBackgroundObj.style.display = 'block';
    
            const modalWindowObj = document.querySelector('#modal-searchhint-window');
            modalWindowObj.style.display = 'block';

            const modalWindowCloseBtn = document.querySelector('.modal-searchhint-close-button');

            const closeBtnClicked = () => {
                modalBackgroundObj.style.display = 'none';
                modalWindowObj.style.display = 'none';
            };

            modalWindowCloseBtn.addEventListener('click', closeBtnClicked);
        }

        function csvUpload(csvFile) {
            const modalTextarea = document.getElementById('modal-csvupload-textarea');

            // アップロードされたファイルの名前を取得する
            const fileName = csvFile.name;

            // もし拡張子がcsv以外のファイルがアップロードされた場合、エラーを表示する
            const pos = fileName.lastIndexOf('.');
            const extension = fileName.slice(pos + 1);

            if (extension != "csv") {
                modalTextarea.value = "エラー: csvファイル以外の種類のファイルがアップロードされました";
                return;
            }

            // ファイルのサイズ(バイト数)を取得する
            const fileSize = csvFile.size;

            // 最大サイズ(約33KB)
            const maxSize = 33000;

            // ファイルサイズが最大サイズを超えていた場合、エラーを表示する　
            if (fileSize > maxSize) {
                modalTextarea.value = "エラー: ファイルのサイズが大きすぎます。アップロードできるファイルのサイズは約33KBまでです。";
                return;
            }

            var reader = new FileReader();

            // FileReaderを使用して、csvファイルを読み込む
            // デフォルトではUTF-8で読み込もうとしてしまうので、Shift_JISを指定する
            reader.readAsText(csvFile, 'Shift_JIS');

            // ファイル読み込みに失敗した時
            reader.onerror = function () {
                modalTextarea.value = "エラー: ファイルの読み込みに失敗しました";
            }

            // ファイル読み込みに成功した時
            reader.onload = function () {
                // FileReaderで読み取った文字列を変数に格納する
                var csv = reader.result;

                const modalWindowCloseBtn = document.querySelector('.modal-csvupload-close-button');
                const modalWindowUploadBtn = document.querySelector('.modal-csvupload-button');

                // 挿入処理中はボタンを押せなくする
                modalWindowCloseBtn.disabled = true;
                modalWindowUploadBtn.disabled = true;

                // ajaxでC#のメソッドを呼び出す
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

                        if (errorMsgs.length == 0) {
                            modalDoneObj.innerText = "挿入処理が完了しました";
                        } else {
                            modalDoneObj.innerText = "挿入処理中にエラーが発生しました";
                        }
                        modalDoneObj.style.visibility = 'visible';

                        // 挿入処理が完了したら、再びボタンを押せるようにする
                        modalWindowCloseBtn.disabled = false;
                        modalWindowUploadBtn.disabled = false;

                        // 挿入処理が完了したら、検索結果を更新する
                        searchResultUpdate();
                    },
                    error: function (result) {
                        alert("失敗: " + result.status);

                        modalWindowCloseBtn.disabled = false;
                        modalWindowUploadBtn.disabled = false;
                    }
                });
            }

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

        function searchResultUpdate() {
            searchCustomer(
                "SearchButton_Click",
                function (data) {
                    const result = data.d;

                    // 処理中にエラーが発生した場合、"failed"が返される
                    // アラートでエラーメッセージを表示してこの後の処理を実行しない
                    if (result == "failed") {
                        alert("検索処理中にエラーが発生しました");
                        return false;
                    }

                    columnNamePrev = "id";
                    desc = false;
                    changeIdSortIndicatior();

                    const parsedData = JSON.parse(result);

                    // DBから取得した情報
                    var arrayData = parsedData["result"];

                    // テーブル要素
                    var table = document.getElementById('search-result');

                    var tableHeader = document.getElementById('search-table-header');
                    tableHeader.style.display = '';

                    // 既に表示されているテーブルを初期化する
                    // カラムの行は削除しないようにするので、引数に1を指定
                    while (table.rows.length > 1) {
                        table.deleteRow(1);
                    }

                    // 結果が0件なら、ヘッダーを非表示にしてテーブル作成処理を実行しない
                    if (arrayData.length == 0) {
                        tableHeader.style.display = 'none';
                    } else {
                        // 取得したデータを元にテーブルを作成する
                        for (var i = 0; i < arrayData.length; i++) {
                            // 取得したデータの1行
                            var arrayRow = arrayData[i];

                            console.log(JSON.stringify(arrayRow, null, '\t'));

                            // arrayRowに格納されている各データを変数に代入
                            const id = arrayRow["id"];
                            const name = arrayRow["name"];
                            const nameKana = arrayRow["nameKana"];
                            const mail = arrayRow["mail"];
                            const birthday = arrayRow["birthday"];
                            const gender = arrayRow["gender"];
                            const prefecture = arrayRow["prefecture"];
                            const membershipStatus = arrayRow["membershipStatus"];

                            // 取得したデータをtableに表示するために格納する配列
                            const tableRow = [
                                id, name, nameKana, mail, birthday, gender, prefecture, membershipStatus
                            ];

                            // tr要素の作成
                            const tr = document.createElement('tr');

                            // tableRowを元に、tr要素の中身の部分を作っていく
                            for (var j = 0; j < tableRow.length; j++) {
                                // td要素の作成
                                const td = document.createElement('td');

                                // td要素に取得した情報を追加する
                                td.appendChild(document.createTextNode(tableRow[j]));
                                // tr要素にtd要素を追加する
                                tr.appendChild(td);
                            }

                            const td = document.createElement('td');

                            const div = document.createElement('div');
                            div.className = "button-box";

                            // 編集、削除ボタンを作成する
                            // 編集ボタン
                            const editBtn = document.createElement('input');
                            editBtn.className = "link-button edit-button";
                            editBtn.type = "button";
                            editBtn.setAttribute('onclick', "editBtnClicked(" + (i + 1) + ")");
                            editBtn.value = "編集";

                            // 削除ボタン
                            const deleteBtn = document.createElement('input');
                            deleteBtn.className = "delete-button";
                            deleteBtn.type = "button";
                            deleteBtn.setAttribute('onclick', "deleteConfirmOpen(" + (i + 1) + ")");
                            deleteBtn.value = "削除";

                            // 編集、削除ボタンをtr要素に追加する
                            div.appendChild(editBtn);
                            div.appendChild(deleteBtn);

                            td.appendChild(div);

                            tr.appendChild(td);

                            // table要素にtr要素を追加する
                            table.appendChild(tr);
                        }
                    }

                    // セッションに検索結果の件数を保存する
                    // 返されたJsonから件数を取得する
                    const resultCount = parsedData["resultCount"];

                    // resultCountをsessionStorageに保存する
                    sessionStorage.setItem('resultCount', resultCount);

                    // セッションに検索条件を保存する
                    // 検索条件欄の内容を連想配列で取得する
                    const querys = getSearchQuery();

                    // querysは連想配列でそのままではsessionStorageに保存することができないため、
                    // JSON.stringifyを利用してquerysの中身をjson化する
                    const jsonQuerys = JSON.stringify(querys);

                    // json化したquerysをsessionStorageに保存する
                    sessionStorage.setItem('searchQuery', jsonQuerys);

                    // ページネーションの作成
                    createPagination();
                },
                function () {
                    alert("検索に失敗しました");
                },
                false
            );
        }

        function searchButtonClicked() {
            // ページ番号を1にする
            // URLを取得
            const url = new URL(window.location.href);
            // クエリパラメータを取得
            const params = url.searchParams;

            params.set('p', '1');
            history.replaceState("", "", `?${params.toString()}`)

            // 検索する
            searchResultUpdate();
        }

        // 検索条件を入力するテキストボックスやチェックボックスなどの要素を連想配列で取得する
        // id, メールアドレス, 名前, 名前(かな), 誕生日(始め), 誕生日(終わり), 都道府県, 性別, 会員状態
        function getSearchQueryElements() {
            const id = document.querySelector('.search-form input[name="id"]'); // id
            const email = document.querySelector('input[name="email"]'); // メールアドレス
            const name = document.querySelector('input[name="name"]'); // 名前
            const nameKana = document.querySelector('input[name="name_kana"]'); // 名前(かな)
            const birthStart = document.querySelector('input[name="birth-start"]'); // 誕生日(始め)
            const birthEnd = document.querySelector('input[name="birth-end"]'); // 誕生日(終わり)
            const prefecture = document.querySelector('select[name="prefecture"]'); // 都道府県
            const gender = document.querySelectorAll('input[name="sex[]"]'); // 性別
            const memberStatus = document.querySelectorAll('input[name="member-status[]"]'); // 会員状態

            // 検索入力欄の要素を連想配列で格納する
            const elements = {
                "id": id,
                "email": email,
                "name": name,
                "nameKana": nameKana,
                "birthStart": birthStart,
                "birthEnd": birthEnd,
                "prefecture": prefecture,
                "gender": gender,
                "memberStatus": memberStatus
            };

            // 連想配列を返す
            return elements;
        }

        // ユーザーが入力した検索条件を取得する
        function getSearchQuery() {
            // 検索条件入力欄の要素を取得する
            const queryElements = getSearchQueryElements();

            const id = queryElements["id"].value; // id
            const email = queryElements["email"].value; // メールアドレス
            const name = queryElements["name"].value; // 名前
            const nameKana = queryElements["nameKana"].value; // 名前(かな)
            const birthStart = queryElements["birthStart"].value; // 誕生日(始め)
            const birthEnd = queryElements["birthEnd"].value; // 誕生日(終わり)
            const prefecture = queryElements["prefecture"].value; // 都道府県
            const gender = queryElements["gender"]; // 性別
            const memberStatus = queryElements["memberStatus"]; // 会員状態

            // 2つあるチェックボックスでどちらにチェックが入っているかを示す変数
            // 両方のチェックボックスにチェックが入っていたら"both"が入る
            var genderValue = ""; // 1: 男性, 2: 女性
            var memberStatusValue = ""; // 1: 有効, 2: 退会

            // チェックボックスにチェックが入っているかを調べるための配列
            var genderCBoxChecked = [false, false];
            var memberStatusCBoxChecked = [false, false];

            // checkedを利用して、チェックが入っているチェックボックスを調べる
            for (var i = 0; i < gender.length; i++) {
                if (gender[i].checked) {
                    genderCBoxChecked[i] = true;
                }
            }

            // チェックが入っているチェックボックスを調べて、両方入っていたなら"both"を、
            // 片方ならそれぞれの数字を変数に格納する
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
            // checkedを利用して、チェックが入っているチェックボックスを調べる
            for (var i = 0; i < memberStatus.length; i++) {
                if (memberStatus[i].checked) {
                    memberStatusCBoxChecked[i] = true;
                }
            }

            // チェックが入っているチェックボックスを調べて、両方入っていたなら"both"を、
            // 片方ならそれぞれの数字を変数に格納する
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

            // 検索条件を格納する連想配列
            const querys = {
                "id": id,
                "email": email,
                "name": name,
                "nameKana": nameKana,
                "birthStart": birthStart,
                "birthEnd": birthEnd,
                "prefecture": prefecture,
                "gender": genderValue,
                "memberStatus": memberStatusValue
            };

            // 検索条件を返す
            return querys;
        }

        // 会員情報を取得する
        // 呼び出すC#メソッド名、取得成功時の処理、失敗時の処理、結果を全て取得するかのフラグを引数に取る
        // resultAllにtrueを渡すと、結果が10件など(1ページに表示させる件数)に制限されず全て返ってくる
        function searchCustomer(cSharpMethodName, success, failure, resultAll) {
            // ユーザーが入力した検索条件を取得する
            const querys = getSearchQuery();

            const id = querys["id"];
            const email = querys["email"];
            const name = querys["name"];
            const nameKana = querys["nameKana"];
            const birthStart = querys["birthStart"];
            const birthEnd = querys["birthEnd"];
            const prefecture = querys["prefecture"];
            const gender = querys["gender"];
            const memberStatus = querys["memberStatus"];

            const pageNumber = getCurrentPageNumber();

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
                    "genderStr": gender,
                    "memberStatusStr": memberStatus,
                    "pageNumber": pageNumber,
                    "resultAll": resultAll
                }),
                success: function (data) {
                    success(data);
                },
                error: function (result) {
                    failure(result);
                }
            });
        }

        // 編集ボタンクリック時
        function editBtnClicked(rowNum) {
            const table = document.getElementById('search-result');

            const id = table.rows[rowNum].cells[0].innerText;

            window.location.href = "member-edit.aspx?id=" + id;
        }

        // 削除ボタンクリック時
        function deleteBtnClicked() {
            const id = document.getElementById('modal-member-delete-id').value;

            $.ajax({
                type: "POST",
                url: '<%= ResolveUrl("/member-searh.aspx/DeleteButton_Click") %>',
                contentType: "application/json",
                data: JSON.stringify({
                    "idStr": id,
                }),
                success: function (data) {
                    const result = data.d;

                    if (result == "success") {
                        alert("削除しました");
                    } else if (result == "failed") {
                        alert("削除に失敗しました");
                    }

                    searchResultUpdate();
                },
                error: function () {
                    alert("削除に失敗しました");
                }
            });
        }

        // csvダウンロードボタンクリック時
        // resultAllがtrueなら全ページ分のデータをダウンロードする
        // falseなら現在表示しているページのデータだけダウンロードする
        function csvDownload(resultAll) {
            searchCustomer(
                "CSVDownloadButton_Click",
                function (data) {
                    const result = data.d;

                    // csvファイル生成中に例外が発生した場合、"failed"が返ってくる
                    // アラートでエラーメッセージを表示し、この後の処理を実行しない
                    if (result == "failed") {
                        alert('csvファイルの生成に失敗しました');
                        return false;
                    }

                    // csvデータを取得する(文字コードはUnicode)
                    const unicodeCsv = data.d;

                    // UnicodeだとExcelでcsvファイルを開いた時に文字化けしてしまうので、
                    // Shift_JISに変換する

                    var unicodeArray = [];
                    // unicodeCsvの内容を1文字ずつ文字コードの数値に変換して格納する
                    for (var i = 0; i < unicodeCsv.length; i++) {
                        unicodeArray.push(unicodeCsv.charCodeAt(i));
                    }

                    // Encodingライブラリを使用して、Shift_JISに変換する
                    const sjisArray = Encoding.convert(unicodeArray, {
                        to: 'SJIS',
                        from: 'UNICODE',
                    });

                    // Shift_JISに変換されたsjisArrayをUint8Arrayに変換する
                    // sjisArrayのままBlobコンストラクタに渡すと、文字ではなく文字コードの数字がそのまま出力されてしまう
                    const csv = new Uint8Array(sjisArray);

                    const blob = new Blob([csv], { type: "text/csv" });

                    // ファイル名の作成
                    // 現在日時が先頭に来るようになっている
                    const date = new Date();
                    const year = date.getFullYear();
                    const month = ("00" + (date.getMonth()+1)).slice(-2);
                    const day = ("00" + (date.getDate())).slice(-2);
                    const fileName = year + month + day + "_" + "会員検索結果.csv";

                    // ダウンロード処理
                    const link = document.createElement('a');
                    link.href = URL.createObjectURL(blob);
                    link.download = fileName;
                    link.click();
                },
                function (result) {
                    alert('csvファイルの生成に失敗しました');
                },
                resultAll
            );
        }
        
    </script>
    <script type="text/javascript" src="./js/common.js" defer></script>
</head>
  <body>
    <div id="modal-delete-confirm-window">
        <p>削除しますか？</p>
        <div class="button-box">
            <input class="yes" type="submit" value="はい"" />
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
            <button class="modal-csvupload-close-button">閉じる</button>
            <button class="modal-csvupload-button">アップロード</button>
        </div>
    </div>    
    <div class="modal-background"></div>

    <div id="modal-searchhint-window">
        <p>ヒント</p>
        <div class="modal-searchhint-result">
            <h2>あいまい検索</h2>
            <p>アスタリスク(*)を利用すると、前方一致、後方一致、部分一致で検索が行えます。</p>
            <ul>
                <li>前方一致</li>
                <p>田中*</p>
                <li>後方一致</li>
                <p>*太郎</p>
                <li>部分一致</li>
                <p>*中太*</p>
                <li>「田」で始まり、「郎」で終わる</li>
                <p>田*郎</p>
            </ul>
            <br>
            <h2>OR検索</h2>
            <p>カンマ(,)を利用すると、OR検索が行えます。</p>
            <ul>
                <li>「田中太郎」と「山田花子」の2名を検索結果に表示する</li>
                <p>田中太郎,山田花子</p>
                <li>あいまい検索との組み合わせ例</li>
                <p>田中*郎,山*子,佐藤*,*一郎</p>
            </ul>
            <br>
        </div>
        <div class="button-box">
            <input class="modal-searchhint-close-button" type="button" value="閉じる">
        </div>
    </div>
    <div class="modal-background"></div>

    <header>
        <h1>会員管理システム</h1>
        <nav>
            <ul>
                <li><a href="member-searh.aspx">会員一覧</a></li>
                <li><a href="member-register.aspx">会員登録</a></li>
                <li><a href="admin-register-page.aspx">システム管理者登録</a></li>
            </ul>
        </nav>
    </header>
    <main>
        <h2>会員一覧</h2>
        
            <table class="search-form">
                <tr>
                    <th>ID</th>
                    <td>
                        
                        <input type="text" name="id" value="" />
                    </td>
                    <th>メールアドレス</th>
                    <td>
                        
                        <input type="text" name="email" value="" />
                    </td>
                </tr>
                <tr>
                    <th>名前</th>
                    <td style="position: relative;">
                        <input type="text" name="name" value="" />
                        <button class="hint-button" onclick="searchHintWindowOpen()">
                            <img src="./img/01028.png" width="100">
                        </button>
                    </td>
                    <th>名前(かな)</th>
                    <td>
                        
                        <input type="text" name="name_kana" value="" />
                    </td>
                    
                </tr>
                <tr>
                    <th>生年月日</th>
                    <td>
                        <div class="search-input-date-select-input">
                            
                            <input type="date" name="birth-start" value="" min="1950-01-01" max="2025-12-31">
                            <div>～</div>
                            
                            <input type="date" name="birth-end" value="" min="1950-01-01" max="2025-12-31">
                        </div>
                    </td>
                    <th>性別</th>
                    <td>
                        <div class="input-check-list">
                            
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
                              
                            
                            <button class="search-button" onclick="searchButtonClicked();">検索</button>
                        </div>
                    </td>
                </tr>
            </table>
        
        <div class="csv-download-upload">
            <div class="button-box">
                <button class="csv-download-button" onclick="csvDownload(false)">検索結果をCSVダウンロード</button>
                <button class="csv-download-button" onclick="csvDownload(true)">全件CSVダウンロード</button>
                <button id="csv-upload-button" onclick="csvUploadWindowOpen()">CSVアップロード</button>
            </div>
        </div>
        <br />
        <div class="search-list">
          <table id="search-result">
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
        </table>
        </div>
        <div class="pager">
            <ul>
            </ul>
        </div>
    </main>
         
</body>
</html>