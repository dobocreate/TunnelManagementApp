//
//  tunnelListViewController.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2021/10/08.
//

import UIKit
import Firebase

class tunnelListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var listener: ListenerRegistration?
    
    // トンネルデータを格納する配列
    var tunnelDataArray:[tunInitialData] = []
    
    /*
    // 画面遷移する際の処理 -> indexPathがうまく取得できない。なぜ？
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "updateTunSettingSegue" {
            
            let updateTunSettingViewController:UpdateTunSettingViewController = segue.destination as! UpdateTunSettingViewController
     
            // let indexPath = self.tableView.indexPathForSelectedRow
            
            //print("indexPath.row: \(indexPath.row!)")
            
            updateTunSettingViewController.tunnelData = tunnelDataArray[0]
        }
    }
    */
    
    // 画面が表示される前に呼び出され、他の画面から戻ってきた場合にも呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("DEBUG_PRINT: viewWillAppear")
        
        // ログイン済みか確認
        if Auth.auth().currentUser != nil {         // ログイン済みの場合
            
            // listenerを登録して投稿データの更新を監視する
            let postsRef = Firestore.firestore().collection(FirestorePathList.tunnelListPath).order(by: "date", descending: true)
            
            listener = postsRef.addSnapshotListener() { (querySnapshot, error) in
                if let error = error {
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                    
                    return
                }
                
                // 取得したdocumentをもとにPostDataを作成し、postArrayの配列にする。
                self.tunnelDataArray = querySnapshot!.documents.map { document in
                    print("DEBUG_PRINT: document取得 \(document.documentID)")
                    
                    let tunnelData = tunInitialData(document: document)
                    
                    return tunnelData
                }
                // TableViewの表示を更新する
                self.tableView.reloadData()
            }
        }
        
        print("tunnelDataArray.count : \(tunnelDataArray.count)")
    }
    
    // 画面が消える前に実行される
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("DEBUG_PRINT: viewWillDisappear")
        // listenerを削除して監視を停止する
        listener?.remove()
    }
    
    // 画面が表示された時に１度だけ実行される
    override func viewDidLoad() {
        super.viewDidLoad()

        // デリゲートの指定。ここで、selfとはViewController
        // デリゲートを指定することで、データ数を返すメソッドなどが使えるようになると考える
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    // デリゲートメソッド：データ数を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tunnelDataArray.count
    }

    // デリゲートメソッド：セルの表示内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // 値を設定する
        cell.textLabel!.text = tunnelDataArray[indexPath.row].tunnelName!

        return cell
    }
    
    // スワイプした時に表示するアクションの定義
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        // 編集処理
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, completionHandler) in
            
            // 編集処理を記述
            print("Editがタップされた")
            
            // 遷移先のViewControllerを取得
            let UpdateTunSettingViewController = self.storyboard?.instantiateViewController(withIdentifier: "updateTunSetting") as! UpdateTunSettingViewController
            
            print("indexPath.row: \(indexPath.row)")
            
            // 遷移先の変数に値を渡す
            UpdateTunSettingViewController.tunnelData = self.tunnelDataArray[indexPath.row]
        
            print("tunnelName: \(self.tunnelDataArray[indexPath.row].tunnelName!)")
            
            // Segueを指定して画面遷移する　-> Segueを指定してもデータの受け渡しがうまくいかない。なぜ？
            //self.performSegue(withIdentifier: "updateTunSettingSegue", sender: nil)
            
            // モーダル遷移
            self.present(UpdateTunSettingViewController, animated: true, completion: nil)

            // 実行結果に関わらず記述
            completionHandler(true)
        }
        
        // 編集ボタンの背景色を青色にする
        editAction.backgroundColor = UIColor.blue

        // 削除処理
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            
            //削除処理を記述
            print("Deleteがタップされた")
            
            // Firestore内に保存されているトンネルリストから、タップしたセルに対応するドキュメントデータを削除する
            Firestore.firestore().collection(FirestorePathList.tunnelListPath).document(self.tunnelDataArray[indexPath.row].id).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                }
                else {
                    print("Document successfully removed!")
                }
            }

            // 実行結果に関わらず記述
            completionHandler(true)
        }

        // 定義したアクションをセット
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }

    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("セルがタップされた")
        
        // 遷移先のViewControllerを取得
        let KirihaListViewController = self.storyboard?.instantiateViewController(withIdentifier: "kirihaList") as! KirihaListViewController
        
        print("indexPath.row: \(indexPath.row)")
        
        // 遷移先の変数に値を渡す
        KirihaListViewController.tunnelData = self.tunnelDataArray[indexPath.row]
    
        print("tunnelName: \(self.tunnelDataArray[indexPath.row].tunnelName!)")
        
        self.navigationController?.pushViewController(KirihaListViewController, animated: true)
        
        // Segueで画面遷移
        // performSegue(withIdentifier: "cellSegue",sender: nil)
    }
    
    /*
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }

    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    */
    

}
