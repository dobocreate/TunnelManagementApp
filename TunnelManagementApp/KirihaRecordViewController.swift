//
//  kirihaRecord2ViewController.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2021/10/06.
//

import UIKit
import Firebase

class KirihaRecordViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var tunnelData: TunnelData?     // データ受け渡し用(トンネル設定データ)
    // var tunnelPath: String?     // トンネルID
    
    var kirihaRecordData: KirihaRecordData?
    
    var obsRecordArray  = [Float?](repeating: nil, count:13)

    
    // 遷移先のLabelテキストを格納
    var secTitle: String?
    
    // 遷移先から戻る際のデータの受け渡し用
    // var specialText: String = ""
    var specialSec: String = ""
    var specialSecNo: Int?
    var waterValue: Float = 0.0
    
    // 切羽観察項目および特記事項を格納
    var obsRecordArray2d = [[Int?]](repeating: [Int?](repeating:nil, count:7), count:13)
    
    var specialRecordData = [String?](repeating: nil, count:10)         // 特記事項をセクションごとに格納
    
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
        ["１．なし、滲水程度", "２．滴水程度", "３．集中湧水", "４．全面湧水", "特記事項　", "湧水量の入力"],
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
        
        // 選択された項目をピンク色にする（湧水量の項目以外）
        if cellSection != 9 && cellRow != 5 {           // 湧水量以外（湧水量の項目はピンク色にしない）
            
            if obsRecordArray2d[cellSection][cellRow] == 1 {
                
                cell.backgroundColor = MyColor.myPink
            } else {
                cell.backgroundColor = .clear
            }
        }
        
        // cellに値(各観察項目の内容)を設定する
        cell.textLabel?.text = obsArray[indexPath.section][indexPath.row]

        return cell
    }

    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cellSection = indexPath.section
        let cellRow = indexPath.row
        
        // 湧水量の入力をタップされた時
        // 色を変えずに、obsArrayに保存もしない
        if cellSection == 9 && cellRow == 5 {
            
            print("\(cellSection), \(cellRow) をタップ")
            
            // SegueIDを指定して、湧水量の記録画面に遷移
            performSegue(withIdentifier: "waterRecordSegue", sender: nil)
            
            return
        }
        
        // 特記事項をタップされた時
        // 色を変えずに、obsArrayに保存もしない
        if cellSection == 0 && cellRow == 6 || cellSection == 1 && cellRow == 4 ||
            cellSection == 2 && cellRow == 4 || cellSection == 3 && cellRow == 4 ||
            cellSection == 4 && cellRow == 4 || cellSection == 5 && cellRow == 4 ||
            cellSection == 6 && cellRow == 4 || cellSection == 7 && cellRow == 4 ||
            cellSection == 8 && cellRow == 4 || cellSection == 9 && cellRow == 4
        {
            secTitle = sectionTitle[cellSection] as? String
            
            print("\(sectionTitle[cellSection]), \(cellSection), \(cellRow) をタップ")
            
            self.specialSecNo = cellSection         // セクションNoを代入
            
            // SegueIDを指定して、特記事項の記録画面に遷移
            performSegue(withIdentifier: "otherRecordSegue", sender: nil)
            
            return
        }
        
        
        //
        // 選択済みあれば選択解除、選択されてなければ選択する
        // 選択数の許容値を設定し、許容値未満の場合に選択する
        if obsRecordArray2d[cellSection][cellRow] == 0 {
            
            var t = 0
            for r in 0..<obsRecordArray2d[cellSection].count {
                
                t = t + obsRecordArray2d[cellSection][r]!
            }

            if t < 2 {                     // 許容する選択数未満の場合に1とする
                obsRecordArray2d[cellSection][cellRow] = 1
            }
            
        } else {
            obsRecordArray2d[cellSection][cellRow] = 0
        }
        
        // 選択したセルのセクションにおいて、同セクションのセルの数だけ繰り返して、
        // 選択したセルの色だけピンクに変更する
        // var r = 0
        for r in 0..<obsRecordArray2d[cellSection].count {
            
            // print(obsArray[cellSection][r])
            
            if obsRecordArray2d[cellSection][r] == 1 {       // タップしたセル
                
                // セルの色を変更する
                tableView.cellForRow(at: [cellSection, r])?.backgroundColor = MyColor.myPink
                
                // print("section: \(cellSection), row: \(cellRow)")
            }
            else {
                // セルの色を変更する
                tableView.cellForRow(at: [cellSection, r])?.backgroundColor = .white
            }
        }
        
        
        
        /*
        // 選択したセルの文字色を変更する
        if tableView.cellForRow(at: indexPath)?.textLabel?.textColor ==  UIColor.black{
            
            // セルの文字色を変更
            tableView.cellForRow(at: indexPath)?.textLabel?.textColor = UIColor.red
        }
        else {
            // セルの文字色を変更
            tableView.cellForRow(at: indexPath)?.textLabel?.textColor = UIColor.black
        }
        */
        
        // print("indexPath.row = \(indexPath.row)")
        // print("indexPath.section = \(indexPath.section)")
        
        // Type2の判定
        if cellSection == 4 {
            if cellRow == 2 || cellRow == 3 {
                
                alert_cautionJiyama()
            }
        }
    }
    
    func alert_cautionJiyama() {
        
        let alert = UIAlertController(title: "注意が必要な地山",
                      message: "「風化や熱水変質および破砕の進行した岩石」に該当します",
                      preferredStyle: .alert)
        //ここから追加
        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        
        // Type２の判定
        print("風化変質: \(String(describing:obsRecordArray2d[4][2])), \(String(describing:obsRecordArray2d[4][3]))")
        
        if obsRecordArray2d[4][2] == 1 || obsRecordArray2d[4][3] == 1 {

            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }

    // Segueでの画面遷移時に呼ばれる。画面を閉じる前に実行される
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // 湧水量の記入画面への遷移時に実行される
        if segue.identifier == "waterRecordSegue" {
            
            let waterRecordVC:WaterRecordViewController = segue.destination as! WaterRecordViewController
            
            waterRecordVC.kirihaRecordData = self.kirihaRecordData
            waterRecordVC.waterValue = self.waterValue
            
            waterRecordVC.vcName = "KirihaRecordVC"
        }
        
        // 特記事項の記入画面への遷移時に実行される
        if segue.identifier == "otherRecordSegue" {
            
            let otherRecordVC:OtherRecordViewController = segue.destination as! OtherRecordViewController
            
            otherRecordVC.titleLabel = self.secTitle
            otherRecordVC.vcName = "KirihaRecordVC"
            otherRecordVC.secNo = self.specialSecNo
            
            if self.specialRecordData[self.specialSecNo!] == nil {          //　初めて特記事項を記載する場合
                
                otherRecordVC.specialText = "ここに、特記事項を記載する。"
            } else {
                
                otherRecordVC.specialText = self.specialRecordData[self.specialSecNo!]
            }
            
            print("otherRecordSegueへ遷移")
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
        
        // view.backgroundColor = .systemGray6
        
        print("kirihaRecord2VC tunnelPath: \(String(describing: self.tunnelData?.tunnelId))")
        
        // 配列の初期化
        obsRecordArray2d[0] = Array(repeating: 0, count: 7)    // 地質構造
        obsRecordArray2d[1] = Array(repeating: 0, count: 5)    // 切羽の安定
        obsRecordArray2d[2] = Array(repeating: 0, count: 5)    // 素掘面の状態
        obsRecordArray2d[3] = Array(repeating: 0, count: 5)    // 圧縮強度
        obsRecordArray2d[4] = Array(repeating: 0, count: 5)    // 風化変質
        obsRecordArray2d[5] = Array(repeating: 0, count: 5)    // 破砕部の切羽に占める割合
        obsRecordArray2d[6] = Array(repeating: 0, count: 5)    // 割れ目の頻度
        obsRecordArray2d[7] = Array(repeating: 0, count: 5)    // 割れ目の状態
        obsRecordArray2d[8] = Array(repeating: 0, count: 5)    // 割れ目の形態
        obsRecordArray2d[9] = Array(repeating: 0, count: 6)    // 湧水：目視での量
        obsRecordArray2d[10] = Array(repeating: 0, count: 4)    // 水による劣化
        obsRecordArray2d[11] = Array(repeating: 0, count: 7)    // 割れ目の方向性：縦断方向
        obsRecordArray2d[12] = Array(repeating: 0, count: 7)    // 割れ目の方向性：横断方向
        
        // print(obsRecordArray2d[0])
    }
    
    //　画面遷移が行われ、表示される前に実行される。遷移先から戻ってきたときにも毎回実行される
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
 
        if self.specialSecNo != nil &&
            self.specialRecordData[self.specialSecNo!] != nil {       // セクションNoおよび特記事項が初期値から変更がない場合
            
            // 遷移先から受け渡されたデータを表示
            print("special sec: \(self.specialSec), Text: \(String(describing: self.specialRecordData[self.specialSecNo!]!))")
            
            let specialText = self.specialRecordData[self.specialSecNo!]!
            
            if self.specialSecNo == 0 {
            
                obsArray[self.specialSecNo!][6] = "特記事項：　\(String(describing: specialText))"
            }
            else {
                obsArray[self.specialSecNo!][4] = "特記事項：　\(String(describing: specialText))"
            }
        }

        print("湧水量: \(self.waterValue)")
        
        // 湧水量を格納
        obsArray[9][5] = "湧水量：　\(self.waterValue)　L"        // TableViewの要素を更新
        
        tableView.reloadData()          // TableViewを更新
    }

    // 保存ボタンがプッシュされたときに実行されるメソッド
    @IBAction func saveButton(_ sender: Any) {
        
        let obsName = Auth.auth().currentUser?.displayName
        
        if let tunnelId = self.tunnelData?.tunnelId {
            
            // 画像と投稿データの保存場所を定義する
            // 自動生成されたIDを持つドキュメントリファレンスを作成する
            // この段階でDocumentIDが自動生成される
            let postRef = Firestore.firestore().collection(tunnelId).document()
            
            print("kirihaRecord2VC postRef: \(postRef.documentID)")
            
            // 保存するデータを辞書の型にまとめる
            let postDic = [
                "id": postRef.documentID,
                "date": FieldValue.serverTimestamp(),
                "tunnelId": tunnelId,
                "obsName": obsName!,
                "obsRecordArray": self.obsRecordArray,
                "obsRecord00": self.obsRecordArray2d[0],
                "obsRecord01": self.obsRecordArray2d[1],
                "obsRecord02": self.obsRecordArray2d[2],
                "obsRecord03": self.obsRecordArray2d[3],
                "obsRecord04": self.obsRecordArray2d[4],
                "obsRecord05": self.obsRecordArray2d[5],
                "obsRecord06": self.obsRecordArray2d[6],
                "obsRecord07": self.obsRecordArray2d[7],
                "obsRecord08": self.obsRecordArray2d[8],
                "obsRecord09": self.obsRecordArray2d[9],
                "obsRecord10": self.obsRecordArray2d[10],
                "obsRecord11": self.obsRecordArray2d[11],
                "obsRecord12": self.obsRecordArray2d[12],
                "specialTextArray": self.specialRecordData,
                "water": self.waterValue
            ] as [String: Any]
            
            postRef.setData(postDic)
            
            print("新規保存しました")
            
            // 画面遷移
            navigationController?.popViewController(animated: true)
        }
    }
    
    
}
