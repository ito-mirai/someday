function finish (){

  // 全てのチェックボックスを要素として取得
  const finish_checkboxs = document.getElementsByClassName("finish_checkbox")
  
  // ループを使用して、各チェックボックスにイベントリスナーを追加
  for (let finish_checkbox of finish_checkboxs) {
    finish_checkbox.addEventListener('change', change);
  }

  // チェックボックスのchangeイベントが発火したとき 
  function change() {
    const taskId = this.dataset.taskId;   // data: { task_id: task.id }}のtask_id:を取得
    let finishId = this.dataset.finishId;   // data: { finish_id: task.finish&.id }}のfinish_id:を取得
    const checked = this.checked;         // チェックボックスの状態を取得

    const XHR = new XMLHttpRequest();
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content;

    if (checked) {
      // チェックボックスをチェックしたとき
      XHR.open("POST", `/tasks/${taskId}/finishes`, true);
      // リクエストが完了された後の処理
      XHR.onload = () => {
        if (XHR.status === 201) { // レコードを正常に作成したとき（201はHTTPステータスコード）
          const response = XHR.response; // レスポンスの内容を取得
          this.dataset.finishId = response.id; // finish.idをデータ属性に設定
        }
      };
      // チェックボックスのチェックを外したとき
    } else {
      if (finishId) { // finishレコードが存在するとき
        XHR.open("DELETE", `/tasks/${taskId}/finishes/${finishId}`, true);
      } else {
        console.error("Finish ID is not available for deletion.");
        return;
      }
    }

    XHR.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
    XHR.setRequestHeader("X-CSRF-Token", csrfToken);

    XHR.responseType = "json";

    XHR.send(JSON.stringify({ task_id: taskId }));
  }
 };
 
 window.addEventListener('turbo:load', finish);