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
        
        
        /*
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
        */
        
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
    
    // 新規作成ボタン「＋」をタップした時に実行されるメソッド
    @IBAction func newBarButton(_ sender: Any) {
        
        
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
            
            
        }
        else if segue.identifier == "kirihaSpec2Segue" {        // テーブルのセルをタップしたときの画面遷移
            
            let kirihaSpec2VC: KirihaSpec2ViewController = segue.destination as! KirihaSpec2ViewController
            
            kirihaSpec2VC.kirihaRecordData = self.kirihaRecordData
            kirihaSpec2VC.tunnelData = self.tunnelData
            
            // kirihaSpecVC.tunnelData = self.tunnelData
        }
    }
    
    /*
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
    */
    
    /*
    // 諸元の画面から戻る
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
        
        
    }
    */
    

}
