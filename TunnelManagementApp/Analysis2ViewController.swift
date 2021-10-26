//
//  Analysis2ViewController.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2021/10/25.
//

/*

import UIKit
import Charts
import Firebase
import SVProgressHUD
import CoreML

class Analysis2ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
        @IBOutlet weak var tableView: UITableView!
        @IBOutlet weak var pieChart: PieChartView!
        
        var tunnelData: TunnelData?
        var kirihaRecordData: KirihaRecordData?
        
        var obsRecordArray = [Int?](repeating: nil, count:13)
        
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
        
        // 円グラフの割合
        let rate = [10.0, 4.0, 6.0, 3.0, 12.0, 16.0, 3.0, 12.0, 16.0]
        
        var patternRate:[Double?] = []
        var structurePattern: Int?
        
        // カラークラスを定義する
        class MyColor: UIColor {
            
            class var myPink: UIColor {
                
                return UIColor(red:255/255, green:204/255, blue:255/255,alpha:1.0)
            }
        }
        
        // 保存ボタンをタップした時に実行される
        @IBAction func saveButton(_ sender: Any) {
            
            if self.structurePattern == nil {
                
                SVProgressHUD.showError(withStatus: "地山等級を選択してください")
                
                return
            }
            
            if let tunnelId = self.kirihaRecordData?.tunnelId, let id = self.kirihaRecordData?.id {
                
                // データを更新するドキュメントを設定
                let kirihaRecordDataRef = Firestore.firestore().collection(tunnelId).document(id)
                
                print("AnalysisVC postRef: \(kirihaRecordDataRef.documentID)")
                print(self.structurePattern)
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
        
        // 画面遷移時に１度だけ実行される
        override func viewDidLoad() {
            super.viewDidLoad()

            tableView.delegate = self
            tableView.dataSource = self
            
            print("AnalysisVC tunnelId: \(kirihaRecordData?.tunnelId), id: \(kirihaRecordData?.id)")
            
            if let sp = self.kirihaRecordData?.structurePattern {
                
                self.structurePattern = sp
            }
            
            // patternRateをFirebaseから取得する。取得できない場合は、あらかじめ定義されているデータを使う
            if let prate = self.kirihaRecordData?.patternRate {
                if prate.count != 0 {
                    
                    self.patternRate = prate
                    print("rate1: \(self.patternRate)")
                }
                else {
                    self.patternRate = self.rate
                    print("rate2: \(self.patternRate)")
                }
            } else {
                self.patternRate = self.rate
                print("rate3: \(self.patternRate)")
            }
            
            // AIによる判定結果
            print("AnalysisVC A: \(kirihaRecordData?.obsRecordArray[0]), rockType: \(kirihaRecordData?.rockType)")
            
            let model = MyTabularClassifier_kiriha()
            
            guard let rockType = kirihaRecordData?.rockType else { return }
            guard let obsRecordArray = kirihaRecordData?.obsRecordArray else { return }
            
            guard let output = try? model.prediction(
                rockType: rockType,
                    A: Double(obsRecordArray[0]!),
                    B: Double(obsRecordArray[1]!),
                    C: Double(obsRecordArray[2]!),
                    D: Double(obsRecordArray[3]!),
                    E: Double(obsRecordArray[4]!),
                    F: Double(obsRecordArray[5]!),
                    G: Double(obsRecordArray[6]!),
                    H: Double(obsRecordArray[7]!),
                    I: Double(obsRecordArray[8]!),
                    I_1: Double(obsRecordArray[9]!),
                    J: Double(obsRecordArray[10]!),
                    K: Double(obsRecordArray[11]!),
                    L: Double(obsRecordArray[12]!)
            ) else {
                
                fatalError("Unexpected runtime error.")
            }
            
            let aiPattern = output.pattern
            let bunnsuu = output.featureValue(for: "pattern")
            
            print("aiPattern: \(aiPattern), \(bunnsuu)")
            
            print(self.patternRate)
            
            // setPieChart(self.patternRate)
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
            
            // 選択時に色を変える設定をオフにする
            cell.selectionStyle = .none
            
            // print("AnalysisVC structurePattern \(self.kirihaRecordData?.structurePattern)")
            
            if let sp = self.structurePattern {
                
                // print("indexPath.row: \(indexPath.row), sp: \(sp)")
                
                if indexPath.row == sp {
                    
                    cell.backgroundColor = MyColor.myPink
                }
                else {
                    cell.backgroundColor = .clear
                }
            } else {
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
        
        func setPieChart(_ sender:[Double?]) {
            
            // ChartDataEntry型の配列を定義
            var dataEntries: [ChartDataEntry] = []
            
            // Float -> Double
            // let rate:[Double] = Double(sender)
            
            for i in 0..<supportPatterns.count {
                
                dataEntries.append( PieChartDataEntry(value:rate[i], label:supportPatterns[i], data:rate[i]))
            }
            let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: "支保の採用確率グラフ")
            
            pieChart.data = PieChartData(dataSet: pieChartDataSet)
            
            // グラフのカラー設定
            var colors: [UIColor] = []

            for _ in 0..<supportPatterns.count {     // 変数を指定せずに繰り返す
                let red = Double(arc4random_uniform(256))
                let green = Double(arc4random_uniform(256))
                let blue = Double(arc4random_uniform(256))

                let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
                colors.append(color)
            }

            pieChartDataSet.colors = colors
            
            // 凡例を非表示
            pieChart.legend.enabled = false
        }

        // テキストフィールド以外をタップした時に実行される
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            
            SVProgressHUD.dismiss()
            
            self.view.endEditing(true)
        }

}

*/
