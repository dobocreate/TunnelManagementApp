//
//  AnalysisViewController.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2021/10/20.
//

import UIKit
import Charts
import Firebase
import SVProgressHUD
import CoreML

class AnalysisViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pieChartsView: PieChartView!
    
    var prob:[Double] = [0, 0, 0, 0, 0, 0, 0, 0, 0]
    
    var tunnelData: TunnelData?
    var kirihaRecordData: KirihaRecordData?
    
    // 受け渡しデータの格納用
    var obsRecordArray = [Float?](repeating: nil, count:13)
    var waterValue: Float?
    var rockType: String?
    var rockTypeSymbol: String?
    var structurePattern: Int?
    var patternRate:[Double?] = []
    var aiSelectedNumber: Int?
    
    // 地山等級のパターン
    let supportPatterns:[String?] = [
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
    
    // カラークラスを定義する
    class MyColor: UIColor {
        
        class var myPink: UIColor {
            
            return UIColor(red:255/255, green:204/255, blue:255/255,alpha:1.0)
        }
    }
    
    // 画面遷移時に１度だけ実行される
    override func viewDidLoad() {
        super.viewDidLoad()

        // デリゲート
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // 画面が表示される前に呼び出されるメソッド
    // 画面遷移後に１度呼ばれ、他の画面に遷移して戻ってきた時にも呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     
        // print("AnalysisVC tunnelId: \(kirihaRecordData?.tunnelId), id: \(kirihaRecordData?.id)")
        /*
        if let sp = self.kirihaRecordData?.structurePattern {
            
            self.structurePattern = sp
        }
        */
        
        // AIによる判定
        print("AnalysisVC A: \(self.obsRecordArray[0]), rockType: \(self.rockType)")
        
        
        // let model = KirihaDataTabularClassifier_1028()
        let model = KirihaDataTabularClassifier_2203()
        
        // guard let rockType = self.rockType else { return }
        // guard let obsRecordArray = self.obsRecordArray else { return }
        
        guard let output = try? model.prediction(
            rockType: self.rockType!,
            rockName: self.rockTypeSymbol!,
            rockGroup: Double(self.obsRecordArray[0]!),
            A: Double(self.obsRecordArray[1]!),
            B: Double(self.obsRecordArray[2]!),
            C: Double(self.obsRecordArray[3]!),
            D: Double(self.obsRecordArray[4]!),
            E: Double(self.obsRecordArray[5]!),
            F: Double(self.obsRecordArray[6]!),
            G: Double(self.obsRecordArray[7]!),
            H: Double(self.obsRecordArray[8]!),
            I_1: Double(self.obsRecordArray[9]!),
            I_2: Double(self.waterValue!),
            J: Double(self.obsRecordArray[10]!),
            K: Double(self.obsRecordArray[11]!),
            L: Double(self.obsRecordArray[12]!)
        )
        else {
            fatalError("Unexpected runtime error.")
        }
        
        print(output.patternProbability[4])
        
        let aiPattern = output.pattern
        aiSelectedNumber = Int(aiPattern)
        
        let bunnsuu = output.featureValue(for: "pattern")
        
        print("aiPattern: \(aiPattern), \(bunnsuu)")
        
        
        if let prob3 = output.patternProbability[3] {
         
            self.prob[3] = prob3
        }
        
        if let prob4 = output.patternProbability[4] {
         
            self.prob[4] = prob4
        }
        
        if let prob5 = output.patternProbability[5] {
         
            self.prob[5] = prob5
        }
        
        if let prob7 = output.patternProbability[7] {
         
            self.prob[7] = prob7
        }
        
        // グラフの表示
        let dataEntries = [
        
            PieChartDataEntry(value: self.prob[3], label: "Ⅱ N"),
            PieChartDataEntry(value: self.prob[4], label: "IN-2"),
            PieChartDataEntry(value: self.prob[5], label: "IN-1"),
            PieChartDataEntry(value: self.prob[7], label: "IS")
        ]
        
        let dataSet = PieChartDataSet(entries: dataEntries, label: "AI判定結果")
        
        // グラフの色
        dataSet.colors = ChartColorTemplates.vordiplom()
        // グラフのデータの値の色
        dataSet.valueTextColor = UIColor.black
        // グラフのデータのタイトルの色
        dataSet.entryLabelColor = UIColor.black
        
        self.pieChartsView.data = PieChartData(dataSet: dataSet)
        
        // データを％表示にする
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        formatter.multiplier = 1.0
        self.pieChartsView.data?.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        self.pieChartsView.usePercentValuesEnabled = true
        
        view.addSubview(self.pieChartsView)
    }
    

    
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }

    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // セルに表示する文字色を設定
        // cell.textLabel?.textColor = .black
        
        // print(indexPath)
        
        // 選択時に色を変える設定をオフにする
        cell.selectionStyle = .none
        
        // print("AnalysisVC aiSelectedNumber: \(self.aiSelectedNumber)")
        
        // Ai
        if let asn = self.aiSelectedNumber {
            
            // print("indexPath.row: \(indexPath.row), sp: \(sp)")
            
            if indexPath.row == asn {
                
                cell.backgroundColor = UIColor.systemTeal
            }
            else {
                cell.backgroundColor = .clear
            }
        } else {
            cell.backgroundColor = .clear
        }
        
        
        // user
        if let sp = self.structurePattern {
            
            // print("indexPath.row: \(indexPath.row), sp: \(sp)")
            if indexPath.row == sp {
                
                cell.backgroundColor = MyColor.myPink
            }
            else if indexPath.row == self.aiSelectedNumber {
                
                cell.backgroundColor = UIColor.systemTeal
            }
            else {
                cell.backgroundColor = .clear
            }
        }
        else if indexPath.row == self.aiSelectedNumber {
            
            cell.backgroundColor = UIColor.systemTeal
        }
        else {
            cell.backgroundColor = .clear
        }
        
        // 値を設定する
        cell.textLabel!.text = supportPatterns[indexPath.row]!
        
        return cell
    }
    
    
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.structurePattern = indexPath.row
        
        print("AnalysisVC structurePattern1 \(self.structurePattern)")
        
        tableView.reloadData()
        
        // tableView.cellForRow(at: indexPath)?.backgroundColor = MyColor.myPink
    }
    
    // 各セルの選択を解除したときに実行されるメソッド
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        // tableView.cellForRow(at: indexPath)?.backgroundColor = .white
    }
    
 
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }

    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    }
    


    // テキストフィールド以外をタップした時に実行される
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        SVProgressHUD.dismiss()
        
        self.view.endEditing(true)
    }
    
    
    // 保存ボタンをタップした時に実行される
    @IBAction func saveButton(_ sender: Any) {
        
        if self.structurePattern == nil {
            
            SVProgressHUD.showError(withStatus: "地山等級を選択してください")
            
            return
        }
        
        print(self.structurePattern!)
        
        // 遷移元へのデータを渡す
        let nc = self.navigationController!
        let vcNum = nc.viewControllers.count
        
        print("vcNum: \(vcNum)")
        
        let kirihaSpec2vc = nc.viewControllers[vcNum - 2] as! KirihaSpec2ViewController
        
        kirihaSpec2vc.structurePattern = self.structurePattern!
        
        print("遷移先vc: \(String(describing: kirihaSpec2vc)), 支保パターン: \(String(describing: kirihaSpec2vc))")
        
        // self.navigationController?.popViewController(animated: true)
        
        
        
        
        if let tunnelId = self.kirihaRecordData?.tunnelId, let id = self.kirihaRecordData?.id {
            
            // データを更新するドキュメントを設定
            let kirihaRecordDataRef = Firestore.firestore().collection(tunnelId).document(id)
            
            print("AnalysisVC postRef: \(kirihaRecordDataRef.documentID)")
            print(self.structurePattern!)
            print(self.patternRate)
            
            // 更新するデータを辞書の型にまとめて、必要な箇所のみ更新する
            let postDic = [
                "structurePattern": self.structurePattern!,
                "patternRate": self.patternRate
            ] as [String: Any]
            
            kirihaRecordDataRef.updateData(postDic)
            
            print("変更を保存しました")
            
            // 画面遷移
            navigationController?.popViewController(animated: true)     // 画面を閉じることで、１つ前の画面に戻る
        }
        
        
    }
    
    
    
}
