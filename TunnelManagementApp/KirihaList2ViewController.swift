//
//  KirihaList2ViewController.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2022/09/25.
//

import UIKit
import Firebase

class KirihaList2ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    // 地山等級のパターン
    let structurePatternsName:[String?] = [
        "Ⅴ N",
        "Ⅳ N",
        "Ⅲ N",
        "Ⅱ N",
        "Ⅰ N-2",
        "Ⅰ N-1",
        "Ⅰ L",
        "Ⅰ S",
        "特L、特S"
    ]
    
    var listener: ListenerRegistration?
    
    // 遷移時に受け取ったトンネルデータを格納する配列
    var tunnelData: TunnelData?
    
    // 切羽観察記録を格納する配列
    var kirihaRecordDataArray: [KirihaRecordData] = []
    
    // データ受け渡し用の切羽観察記録
    var kirihaRecordData: KirihaRecordData?
    
    // トンネルID
    var tunnelPath: String?
    
    // 画面遷移後に１度呼ばれる
    override func viewDidLoad() {
        super.viewDidLoad()

        // デリゲートの指定。ここで、selfとはViewController
        tableView.delegate = self
        tableView.dataSource = self
        
        print("KirihaListVC tunnelPath: \(tunnelData?.tunnelId)")
    }
    

    // 画面が表示される前に呼び出され、他の画面から戻ってきた場合にも呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("DEBUG_PRINT: viewWillAppear")
        
        // ログイン済みか確認
        if Auth.auth().currentUser != nil {         // ログイン済みの場合
                        
            
            if let tunnelId = self.tunnelData?.tunnelId {
                
                // listenerを登録して投稿データの更新を監視する
                let postsRef = Firestore.firestore().collection(tunnelId).order(by: "date", descending: true)
            
                // listenerを登録して投稿データの更新を監視する
                listener = postsRef.addSnapshotListener() { (querySnapshot, error) in
                    if let error = error {
                        print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                        
                        return
                    }
                    
                    // 取得したdocumentをもとにKirihaRecordDataを作成し、kirihaRecordDataArrayの配列にする。
                    self.kirihaRecordDataArray = querySnapshot!.documents.map { document in
                        print("DEBUG_PRINT: document取得 \(document.documentID)")
                        
                        let kirihaRecordData = KirihaRecordData(document: document)
                        
                        return kirihaRecordData
                    }
                    // TableViewの表示を更新する
                    self.tableView.reloadData()
                }
            }
        }
        
        print("kirihaRecordDataArray.count : \(kirihaRecordDataArray.count)")
    }
    
    // 画面が消える前に実行される
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("DEBUG_PRINT: viewWillDisappear")
        
        // listenerを削除して監視を停止する
        listener?.remove()
    }
    
    // デリゲートメソッド：データ数を返す関数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return kirihaRecordDataArray.count
        // return 5 // 5個のデータがあるという意味
    }

    // デリゲートメソッド：セルの表示内容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // 値を設定する
        if let stationNo = kirihaRecordDataArray[indexPath.row].stationNo {
            
            // ダウンキャスト（より具体的な型に変換する）
            let a = floor(stationNo / 1000)
            var b = stationNo - a * 1000
            
            // 有効数字（小数点以下2位を四捨五入）
            b = round(b * 100)
            b = b / 100
            
            let c: Int = Int(a)
            
            if let sP = kirihaRecordDataArray[indexPath.row].structurePattern, let sPN = self.structurePatternsName[sP] {

                cell.textLabel!.text = "測点 " + String(c) + "k " + String(b) + "m" + " : 地山等級 " + String(sPN)
            }
            else {
                cell.textLabel!.text = "測点 " + String(c) + "k " + String(b) + "m"
            }
        }
        else if let date =  kirihaRecordDataArray[indexPath.row].date {
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            
            let dateString:String = formatter.string(from: date)
            cell.textLabel!.text = String("測点未設定　") + dateString
        }

        return cell
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }

    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        // 保存するか確認するアラートを出して、保存ボタンがタップされたら保存して遷移する
        let alert = UIAlertController(title: nil,
                                      message: "本当に削除してもよろしいでしょうか？",
                                      preferredStyle: .alert)

        let alOk = UIAlertAction(title: "はい", style: .default, handler: {
            (action:UIAlertAction!) in
            
            // 切羽観察記録の削除
            if editingStyle == .delete {
                
                // let removed = self.kirihaRecordDataArray.remove(at: indexPath.row)
                
                // print("\(removed)が削除されました, \(indexPath.row)")
                
                let documentId = self.kirihaRecordDataArray[indexPath.row].id           // 削除するドキュメントのIDを取得する
                
                print("ドキュメントID \(documentId)")
                
                if let tunnelId = self.tunnelData?.tunnelId {
                    
                    Firestore.firestore().collection(tunnelId).document(documentId).delete() { err in
                        if let err = err {
                            print("Error removing document: \(err)")
                        } else {
                            print("Document successfully removed")
                        }
                        
                    }
                }
            }
            
            tableView.reloadData()
        })

        let alCancel = UIAlertAction(title: "いいえ", style: .default) {
            (action) in
            
            // 処理の内容をここに記載
            
            self.dismiss(animated: true, completion: nil)           // ダイアログを閉じる
        }

        alert.addAction(alOk)
        alert.addAction(alCancel)

        present(alert, animated: true, completion: nil)
    }
    
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("セルがタップされました")
        
        // 受け渡し用データを格納する
        kirihaRecordData = kirihaRecordDataArray[indexPath.row]
        
        // Segue IDを指定して画面遷移させる
        performSegue(withIdentifier: "kirihaSpec2Segue",sender: nil)
    }
    
    // 画面を閉じる前に実行される
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "kirihaRecordSegue" {
            
            let kirihaRecordVC:KirihaRecordViewController = segue.destination as! KirihaRecordViewController
            
            kirihaRecordVC.tunnelData = self.tunnelData
        }
        else if segue.identifier == "kirihaSpec2Segue" {
            
            let kirihaSpecVC: KirihaSpec2ViewController = segue.destination as! KirihaSpec2ViewController
            
            kirihaSpecVC.kirihaRecordData = self.kirihaRecordData
            kirihaSpecVC.tunnelData = self.tunnelData
            
            // kirihaSpecVC.tunnelData = self.tunnelData
        }
    }
    
    // ソートする
    @IBAction func sortKirihaRecord(_ sender: Any) {
        
        // ソート
        self.kirihaRecordDataArray.sort(by:{
            // 坑口からの距離：降順、日付：降順にソート
            ($0.distance ?? 0.0, $0.date!) > ($1.distance ?? 0.0, $1.date!)
        })
        
        // TableViewの表示を更新する
        self.tableView.reloadData()
    }
    
}
