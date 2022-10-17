//
//  KirihaListViewController.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2021/10/16.
//

import UIKit
import Firebase

// UIViewControllerを継承するとともに、UITableViewDelegateとUITableViewDataSourceのプロトコルに準拠する
class KirihaListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortButton: UIBarButtonItem!
    
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
    var kirihaRecordData2: KirihaRecordData?
    
    // フラグ
    var flagNew: Int? = nil
    
    // トンネルID
    var tunnelPath: String?
    
    // 画面遷移後に１度呼ばれる
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // デリゲートの指定。ここで、selfとはViewController
        tableView.delegate = self
        tableView.dataSource = self
        
        // カスタムセルを登録する
        let nib = UINib(nibName: "KirihaPostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
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
        
        // ソート（BarBottunItem）にドロップダウンメニューを設定
        let items = UIMenu(options: .displayInline, children: [
            UIAction(title: "測点順（降順）に並び替え", handler: { _ in
                print("メニュー測点が押されました")
                
                // ソート
                self.kirihaRecordDataArray.sort(by:{
                    // 坑口からの距離：降順、日付：降順にソート
                    ($0.stationNo ?? 0.0, $0.date!) > ($1.stationNo ?? 0.0, $1.date!)
                })
                
                // TableViewの表示を更新する
                self.tableView.reloadData()
            }),
            UIAction(title: "日付順（降順）に並び替え", handler: { _ in
                print("メニュー日付が押されました")
                
                // ソート
                self.kirihaRecordDataArray.sort(by:{
                    // 日付：降順, 坑口からの距離：降順にソート
                    ($0.date!, $0.distance ?? 0.0) > ($1.date!, $1.distance ?? 0.0)
                })
                
                // TableViewの表示を更新する
                self.tableView.reloadData()
            }),
        ])

        self.sortButton.menu = UIMenu(title: "並び替えメニュー", children: [items])
        // button.showsMenuAsPrimaryAction = true
        
        // フラグの初期化
        self.flagNew = 0
    }

    // 画面が消える前に実行される
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("DEBUG_PRINT: viewWillDisappear")
        
        // listenerを削除して監視を停止する
        listener?.remove()
    }
    
    // kirihaRecordSegue
    
    // デリゲートメソッド：データ数を返す関数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return kirihaRecordDataArray.count
        // return 5 // 5個のデータがあるという意味
    }

    // デリゲートメソッド：セルの表示内容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! KirihaPostTableViewCell
        
        // 日付のフォーマット
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        // 値を設定する
        if let stationNo = kirihaRecordDataArray[indexPath.row].stationNo, let date =  kirihaRecordDataArray[indexPath.row].date {
            
            // ダウンキャスト（より具体的な型に変換する）
            let a = floor(stationNo / 1000)
            var b = stationNo - a * 1000
            
            // 有効数字（小数点以下2位を四捨五入）
            b = round(b * 100)
            b = b / 100
            
            let c: Int = Int(a)
            
            if let sP = kirihaRecordDataArray[indexPath.row].structurePattern, let sPN = self.structurePatternsName[sP] {

                cell.stationLabel!.text = "測点 : " + String(format:"%4d", c) + "k " + String(format:"%5.1f", b) + "m"
                cell.patternLabel!.text = "地山等級 : " + String(sPN)
                cell.noteLabel!.text = "日付 : " + formatter.string(from: date)
            }
            else {          // 支保パターンが設定されていない場合
                cell.stationLabel!.text = "測点 : " + String(format:"%4d", c) + "k " + String(format:"%5.1f", b) + "m"
                cell.patternLabel!.text = "地山等級 : 未設定"
                cell.noteLabel!.text = "日付 : " + formatter.string(from: date)
            }
        }
        else if let date =  kirihaRecordDataArray[indexPath.row].date {     // 測点が設定されていない場合
            
            cell.stationLabel!.text = "測点 : 未設定"
            cell.patternLabel!.text = "地山等級 : 未設定"
            cell.noteLabel!.text = "日付 : " + formatter.string(from: date)
        }
        
        return cell
    }
    
    // スワイプした時に表示するアクションの定義
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        // 編集処理
        let editAction = UIContextualAction(style: .normal, title: "コピー") { (action, view, completionHandler) in
            
            print("Editがタップされた。indexPath.row: \(indexPath.row)")
            
            // kirihaRecordDataArray[indexPath.row]
            
            // 編集処理を記述
            // 自動生成されたIDを持つドキュメントリファレンスを作成する
            // この段階でDocumentIDが自動生成される
            if let tunnelId = self.tunnelData?.tunnelId {
                
                let postRef = Firestore.firestore().collection(tunnelId).document()
                
                // 保存するデータを辞書の型にまとめる
                let postDic = [
                    "id": postRef.documentID,
                    "date": FieldValue.serverTimestamp(),
                    "tunnelId": tunnelId,
                    "obsDate": self.kirihaRecordDataArray[indexPath.row].obsDate,
                    "obsName": self.kirihaRecordDataArray[indexPath.row].obsName,
                    "stationNo": self.kirihaRecordDataArray[indexPath.row].stationNo,
                    "distance": self.kirihaRecordDataArray[indexPath.row].distance,
                    "overburden": self.kirihaRecordDataArray[indexPath.row].overburden,
                    "rockType": self.kirihaRecordDataArray[indexPath.row].rockType,
                    "geoAge": self.kirihaRecordDataArray[indexPath.row].geoAge,
                    "geoStructure": self.kirihaRecordDataArray[indexPath.row].geoAge,
                    "obsRecordArray": self.kirihaRecordDataArray[indexPath.row].obsRecordArray,
                    "structurePattern": self.kirihaRecordDataArray[indexPath.row].structurePattern,
                    "patternRate": self.kirihaRecordDataArray[indexPath.row].patternRate,
                    "water": self.kirihaRecordDataArray[indexPath.row].water,
                    "stationNo2": self.kirihaRecordDataArray[indexPath.row].stationNo2,
                    
                    "obsRecord00": self.kirihaRecordDataArray[indexPath.row].obsRecord00,
                    "obsRecord01": self.kirihaRecordDataArray[indexPath.row].obsRecord01,
                    "obsRecord02": self.kirihaRecordDataArray[indexPath.row].obsRecord02,
                    "obsRecord03": self.kirihaRecordDataArray[indexPath.row].obsRecord03,
                    "obsRecord04": self.kirihaRecordDataArray[indexPath.row].obsRecord04,
                    "obsRecord05": self.kirihaRecordDataArray[indexPath.row].obsRecord05,
                    "obsRecord06": self.kirihaRecordDataArray[indexPath.row].obsRecord06,
                    "obsRecord07": self.kirihaRecordDataArray[indexPath.row].obsRecord07,
                    "obsRecord08": self.kirihaRecordDataArray[indexPath.row].obsRecord08,
                    "obsRecord09": self.kirihaRecordDataArray[indexPath.row].obsRecord09,
                    "obsRecord10": self.kirihaRecordDataArray[indexPath.row].obsRecord10,
                    "obsRecord11": self.kirihaRecordDataArray[indexPath.row].obsRecord11,
                    "obsRecord12": self.kirihaRecordDataArray[indexPath.row].obsRecord12,
                    
                    "specialTextArray": self.kirihaRecordDataArray[indexPath.row].specialTextArray,
                    
                    "rockNameSet1": self.kirihaRecordDataArray[indexPath.row].rockNameSet1,
                    "rockNameSet2": self.kirihaRecordDataArray[indexPath.row].rockNameSet2
                ] as [String: Any]
                
                postRef.setData(postDic)
            }
            
            // 実行結果に関わらず記述
            completionHandler(true)
        }
        
        // 編集ボタンの背景色を青色にする
        editAction.backgroundColor = UIColor.blue


        // 削除処理
        let deleteAction = UIContextualAction(style: .destructive, title: "削除") { (action, view, completionHandler) in
            
            //削除処理を記述
            print("Deleteがタップされた")
            
            // 保存するか確認するアラートを出して、保存ボタンがタップされたら保存して遷移する
            let alert = UIAlertController(title: nil,
                                          message: "本当に削除してもよろしいでしょうか？",
                                          preferredStyle: .alert)

            let alOk = UIAlertAction(title: "はい", style: .default, handler: {
                (action:UIAlertAction!) in
                
                // 切羽観察記録の削除
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
                
                tableView.reloadData()
            })

            let alCancel = UIAlertAction(title: "いいえ", style: .default) {
                (action) in
                
                // 処理の内容をここに記載
                
                self.dismiss(animated: true, completion: nil)           // ダイアログを閉じる
            }

            alert.addAction(alOk)
            alert.addAction(alCancel)

            self.present(alert, animated: true, completion: nil)
            
            // 実行結果に関わらず記述
            completionHandler(true)
        }

        // スワイプでの削除を無効化してセットする
        let swipeAction = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        
        swipeAction.performsFirstActionWithFullSwipe = false        // 左に完全にスワイプする削除を無効にする
        
        return swipeAction
    }
    
    
    /*
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
     
                let documentId = self.kirihaRecordDataArray[indexPath.row].id           // 削除するドキュメントのIDを取得する
                
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
     */
    
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("セルがタップされました")
        
        // 受け渡し用データを格納する
        self.kirihaRecordData = kirihaRecordDataArray[indexPath.row]
        
        // Segue IDを指定して画面遷移させる
        // performSegue(withIdentifier: "kirihaSpec2Segue",sender: nil)
        performSegue(withIdentifier: "kirihaSpec1Segue",sender: nil)
        
    }
    
    // 新規作成ボタン「＋」をタップした時に実行されるメソッド
    @IBAction func newBarButton(_ sender: Any) {
        
        self.flagNew = 1        // 新規作成フラグ
        
        // Segue IDを指定して画面遷移させる
        performSegue(withIdentifier: "kirihaSpec1Segue",sender: nil)
    }
    
    // 画面を閉じる前に実行される
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "kirihaSpec1Segue" {        // ナビゲーションバー「＋」をタップしたときの画面遷移
            
            // 切羽観察に遷移する場合の処理
            // let kirihaRecordVC:KirihaRecordViewController = segue.destination as! KirihaRecordViewController
            // kirihaRecordVC.tunnelData = self.tunnelData
            
            // 設定に遷移する場合の処理
            let kirihaSpec1VC: KirihaSpec1ViewController = segue.destination as! KirihaSpec1ViewController
            
            kirihaSpec1VC.tunnelData = self.tunnelData
            
            if flagNew != 1 {
                
                kirihaSpec1VC.kirihaRecordData = kirihaRecordData
            }
        }
        else if segue.identifier == "kirihaSpec2Segue" {        // テーブルのセルをタップしたときの画面遷移
            
            let kirihaSpec2VC: KirihaSpec2ViewController = segue.destination as! KirihaSpec2ViewController
            
            kirihaSpec2VC.kirihaRecordData = self.kirihaRecordData
            kirihaSpec2VC.tunnelData = self.tunnelData
            
            // kirihaSpecVC.tunnelData = self.tunnelData
        }
    }
    
}
