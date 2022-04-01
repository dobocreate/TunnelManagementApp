//
//  KirihaRecordChangeViewController.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2021/10/17.
//

import UIKit
import Firebase

class KirihaRecordChangeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var kirihaImageView: UIImageView!
    
    // var tunnelData: tunInitialData?     // データ受け渡し用(トンネル設定データ)
    // var tunnelPath: String?     // トンネルID
    
    var kirihaRecordData: KirihaRecordData?         // 遷移前のVCからデータを受け取る配列
    // var kirihaRecordFireData: KirihaRecordData2?     // Firestoreからデータを受け取る配列
    
    var kirihaRecordFireDataDS: KirihaRecordDataDS?     // Firestoreからデータを受け取る配列
    
    // 切羽観察記録の選択された情報を格納する
    var obsRecordArray  = [Int?](repeating: nil, count:13)
    
    // セクションタイトル
    let sectionTitle: NSArray = [
        "地質構造",
        "切羽の安定",
        "素掘面の状態",
        "圧縮強度",
        "風化変質",
        "破砕部の切羽に占める割合",
        "割れ目の頻度",
        "割れ目の状態",
        "割れ目の形態",
        "湧水：目視での量",
        "水による劣化",
        "割れ目の方向性：縦断方向",
        "割れ目の方向性：横断方向"
    ]
    
    // セクションごとのセル
    var obsArray: [[String]] = [
        ["１．互層（層状含む）", "２．不整合", "３．岩脈貫入", "４．褶曲", "５．断層", "６．その他", "特記事項　"],
        ["１．安定", "２．鏡面から岩塊が抜け落ちる", "３．鏡面の押出しを生じる", "４．鏡面は自立せず崩落あるいは流出", "特記事項　"],
        ["１．自立", "２．時間が経つと緩み、肌落ちする", "３．自立困難。掘削後早期に支保する", "４．掘削に先行して山を受けておく必要有り", "特記事項　"],
        ["１．ハンマー打撃で跳ね返る, 100MPa以上", "２．ハンマー打撃で砕ける, 100〜20MPa", "３．ハンマーの軽い打撃で砕ける, 20〜5MPa", "４．ハンマーの刃先がくい込む, 5MPa以下", "特記事項　"],
        ["１．なし・健全", "２．岩目に沿って変色、強度やや低下", "３．全体に変色、強度相当に低下", "４．土砂状、粘土状、礫状、当初より未固結", "特記事項　"],
        ["１．破砕 < ５％", "２．５％ ≦ 破砕 < ２０％", "３．２０％ ≦ 破砕 < ５０％", "４．切羽面の大部分が破砕されている状態", "特記事項　"],
        ["１．d ≧ 1m", "２．1m > d ≧ 20cm", "３．20cm > d ≧ 5cm", "４．5cm > d 破砕、当初より未固結", "特記事項　"],
        ["１．密着", "２．部分的に開口", "３．開口", "４．粘土を挟む、当初より未固結", "特記事項　"],
        ["１．ランダム方形", "２．柱状", "３．層状、片状、板状", "４．土砂状、細片状、当初より未固結", "特記事項　"],
        ["１．なし、滲水程度", "２．滴水程度", "３．集中湧水", "４．全面湧水", "湧水量の入力"],
        ["１．なし", "２．緩みを生ず", "３．軟弱化", "４．流出"],
        ["１．水平（0° < θ < １０°）", "２．さし目（１０° ≦ θ < ３０°、６０° ≦ θ < ８０°）", "３．さし目（３０° ≦ θ < ６０°）", "４．流れ目（６０° > θ ≧ ３０°）", "５．流れ目（３０° > θ ≧ １０°、８０° > θ ≧ ６０°）", "６．垂直（θ ≧ ８０°）", "７．なし。あるいは判断が難しい"],
        ["１．水平（0° < θ < １０°）", "２．右から左（１０° ≦ θ < ３０°、６０° ≦ θ < ８０°）", "３．右から左（３０° ≦ θ < ６０°）", "４．左から右（６０° > θ ≧ ３０°）", "５．左から右（３０° > θ ≧ １０°、８０° > θ ≧ ６０°）", "６．垂直（θ ≧ ８０°）", "７．なし。あるいは判断が難しい"]
    ]
    
    // カラークラスを定義する
    class MyColor: UIColor {
        
        class var myPink: UIColor {
            
            return UIColor(red:255/255, green:204/255, blue:255/255,alpha:1.0)
        }
    }
    
    // 画面が表示される前に実行される
    // 他の画面から遷移して戻ってきた時にも呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        
        // Firestoreからデータの取得
        if let tunnelId = self.kirihaRecordData?.tunnelId, let id = self.kirihaRecordData?.id {
            
            print("kirihaRecordChangeVC tunnelId: \(tunnelId), id: \(id)")
            
            // データを取得するドキュメントを設定
            let kirihaRecordDataRef = Firestore.firestore().collection(tunnelId).document(id)
            
            // データを取得する
            kirihaRecordDataRef.getDocument { (documentSnapshot, error) in
                if let error = error {
                    print("DEBUG_PRINT: documentSnapshotの取得に失敗しました。 \(error)")
                    return
                }
                
                guard let document = documentSnapshot, let dic = documentSnapshot?.data() else { return }
                
                print("Firestore document.id \(document.documentID)")
                
                let kirihaRecordDataDS = KirihaRecordDataDS(document: document)
                
                // print("Firestore document.data \(document.data())")
                
                self.kirihaRecordFireDataDS = kirihaRecordDataDS
                
                // print("FirestoreDS obsRecordArray \(self.kirihaRecordFireDataDS?.obsRecordArray)")
                
                // Firestoreから取得したデータを代入する
                if let array = self.kirihaRecordFireDataDS?.obsRecordArray {
                    
                    self.obsRecordArray = array
                }
                
                print("FirestoreDS データを取得しました \(self.kirihaRecordFireDataDS?.water)")
                
                // tableViewのデータをリロードする
                self.tableView.reloadData()
            }
        }
        
    }

    
    // 保存ボタンがタップされた時に実行される
    @IBAction func saveButton(_ sender: Any) {
        
        // let obsName = Auth.auth().currentUser?.displayName
        
        if let tunnelId = self.kirihaRecordData?.tunnelId, let id = self.kirihaRecordData?.id {
            
            // データを更新するドキュメントを設定
            let kirihaRecordDataRef = Firestore.firestore().collection(tunnelId).document(id)
            
            print("kirihaRecord2VC postRef: \(kirihaRecordDataRef.documentID)")
            
            // 更新するデータを辞書の型にまとめて、必要な箇所のみ更新する
            let postDic = [
                "obsRecordArray": self.obsRecordArray
            ] as [String: Any]
            
            kirihaRecordDataRef.updateData(postDic)
            
            print("変更を保存しました")
            
            // 画面遷移
            navigationController?.popViewController(animated: true)     // 画面を閉じることで、１つ前の画面に戻る
        }
    }
    
    // セクション数
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return sectionTitle.count
    }
    
    // セクションタイトル
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return sectionTitle[section] as? String
    }
    
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return obsArray[0].count
        }
        else if section == 1 {
            return obsArray[1].count
        }
        else if section == 2 {
            return obsArray[2].count
        }
        else if section == 3 {
            return obsArray[3].count
        }
        else if section == 4 {
            return obsArray[4].count
        }
        else if section == 5 {
            return obsArray[5].count
        }
        else if section == 6 {
            return obsArray[6].count
        }
        else if section == 7 {
            return obsArray[7].count
        }
        else if section == 8 {
            return obsArray[8].count
        }
        else if section == 9 {
            return obsArray[9].count
        }
        else if section == 10 {
            return obsArray[10].count
        }
        else if section == 11 {
            return obsArray[11].count
        }
        else{
            return obsArray[12].count
        }
    }

    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 再利用可能な cell を得る、tableCellのIDでUITableViewCellのインスタンスを生成
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // 選択時に色を変える設定をオフにする
        cell.selectionStyle = .none
        
        // セルの背景色を白色に設定する
        // cell.backgroundColor = .white
        
        let cellSection = indexPath.section
        let cellRow = indexPath.row
        
        // print("再利用、pinkCellRow[\(cellSection)]: \(obsRecordArray[cellSection])")
        
        if let pinkCellRow = obsRecordArray[cellSection] {
            
            print("pinkCellRow \(pinkCellRow)")
            
            if cellRow == pinkCellRow {
                
                cell.backgroundColor = MyColor.myPink
            }
            else {
                cell.backgroundColor = .clear
            }
        }
        else {
            cell.backgroundColor = .clear
        }
        
        // cellに値を設定する
        if indexPath.section == 0 {

            let cellTitle = obsArray[0][indexPath.row]
            cell.textLabel?.text = cellTitle
        }
        else if indexPath.section == 1 {
            
            let cellTitle = obsArray[1][indexPath.row]
            cell.textLabel?.text = cellTitle
        }
        else if indexPath.section == 2 {
            
            let cellTitle = obsArray[2][indexPath.row]
            cell.textLabel?.text = cellTitle
        }
        else if indexPath.section == 3 {
            
            let cellTitle = obsArray[3][indexPath.row]
            cell.textLabel?.text = cellTitle
        }
        else if indexPath.section == 4 {
            
            let cellTitle = obsArray[4][indexPath.row]
            cell.textLabel?.text = cellTitle
        }
        else if indexPath.section == 5 {
            
            let cellTitle = obsArray[5][indexPath.row]
            cell.textLabel?.text = cellTitle
        }
        else if indexPath.section == 6 {
            
            let cellTitle = obsArray[6][indexPath.row]
            cell.textLabel?.text = cellTitle
        }
        else if indexPath.section == 7 {
            
            let cellTitle = obsArray[7][indexPath.row]
            cell.textLabel?.text = cellTitle
        }
        else if indexPath.section == 8 {
            
            let cellTitle = obsArray[8][indexPath.row]
            cell.textLabel?.text = cellTitle
        }
        else if indexPath.section == 9 {
            
            let cellTitle = obsArray[9][indexPath.row]
            cell.textLabel?.text = cellTitle
        }
        else if indexPath.section == 10 {
            
            let cellTitle = obsArray[10][indexPath.row]
            cell.textLabel?.text = cellTitle
        }
        else if indexPath.section == 11 {
            
            let cellTitle = obsArray[11][indexPath.row]
            cell.textLabel?.text = cellTitle
        }
        else {
            
            let cellTitle = obsArray[12][indexPath.row]
            cell.textLabel?.text = cellTitle
        }

        return cell
    }

    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cellSection = indexPath.section
        let cellRow = indexPath.row
        
        // 湧水量の入力をタップされた時
        // 色を変えずに、obsArrayに保存もしない
        if cellSection == 9 && cellRow == 4 {
            
            // SegueIDを指定して、湧水量の記録画面に遷移
            performSegue(withIdentifier: "waterRecordSegue", sender: nil)
            
            return
        }
        
        
        // セクションごとに選択されたセルのデータを格納する
        obsRecordArray[cellSection] = cellRow
        
        // 選択したセルのセクションにおいて、同セクションのセルの数だけ繰り返して、
        // 選択したセルの色だけピンクに変更する
        for r in 0..<obsArray[cellSection].count {
            
            // print(obsArray[cellSection][r])
            
            if r == cellRow {       // タップしたセル
                
                // セルの色を変更する
                tableView.cellForRow(at: [cellSection, r])?.backgroundColor = MyColor.myPink
                
                // print("section: \(cellSection), row: \(cellRow)")
            }
            else {
                // セルの色を変更する
                tableView.cellForRow(at: [cellSection, r])?.backgroundColor = .clear
            }
        }
        

    }
    
    // 画面を閉じる前に実行される
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "waterRecordSegue" {
            
            let waterRecordVC:WaterRecordViewController = segue.destination as! WaterRecordViewController
            
            waterRecordVC.kirihaRecordData = self.kirihaRecordData
            waterRecordVC.waterValue = self.kirihaRecordFireDataDS?.water
        }
        
    }
    

    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }

    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    // 画面遷移が行われた時に１度だけ実行される
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        // 画像を設定
        let kirihaImage = UIImage(named: "tunnelImage.jpeg")
        kirihaImageView.image = kirihaImage
        
    }

}
