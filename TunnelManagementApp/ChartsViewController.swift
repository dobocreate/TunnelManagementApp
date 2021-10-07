//
//  ChartsViewController.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2021/10/07.
//

import UIKit
import Charts

class ChartsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pieChart: PieChartView!
    
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
    
    let rate = [
        10.0,
        4.0,
        6.0,
        3.0,
        12.0,
        16.0,
        3.0,
        12.0,
        16.0
    ]
    
    // カラークラスを定義する
    class MyColor: UIColor {
        
        class var myPink: UIColor {
            
            return UIColor(red:255/255, green:204/255, blue:255/255,alpha:1.0)
        }
    }
    
    
    // 初めに１度だけ実行されるメソッド
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        setPieChart()
    }
    
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }

    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // 値を設定する.
        cell.textLabel!.text = supportPatterns[indexPath.row]!
        
        // 選択時に色を変える設定をオフにする
        cell.selectionStyle = .none
        
        // セルの背景色を白色に設定する
        cell.backgroundColor = .white

        return cell
    }
    
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // 選択したセルの背景色を変更する
        if tableView.cellForRow(at: indexPath)?.backgroundColor == .white {
            
            tableView.cellForRow(at: indexPath)?.backgroundColor = MyColor.myPink
        }
        else {
            
            tableView.cellForRow(at: indexPath)?.backgroundColor = .white
        }
        
    }

    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }

    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    
    
    func setPieChart() {
        
        // ChartDataEntry型の配列を定義
        var dataEntries: [ChartDataEntry] = []
        
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

}
