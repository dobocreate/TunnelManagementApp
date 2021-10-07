//
//  kirihaRecord2ViewController.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2021/10/06.
//

import UIKit

class kirihaRecord2ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
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
    // 地質構造
    let array0 = ["１．互層（層状含む）", "２．不整合", "３．岩脈貫入", "４．褶曲", "５．断層", "６．その他", "特記事項　"]
    // 切羽の安定
    let array1 = ["１．安定", "２．鏡面から岩塊が抜け落ちる", "３．鏡面の押出しを生じる", "４．鏡面は自立せず崩落あるいは流出", "特記事項　"]
    // 素掘り面の状態
    let array2 = ["１．自立", "２．時間が経つと緩み、肌落ちする", "３．自立困難。掘削後早期に支保する", "４．掘削に先行して山を受けておく必要有り", "特記事項　"]
    // 圧縮強度
    let array3 = ["１．ハンマー打撃で跳ね返る", "２．ハンマー打撃で砕ける", "３．ハンマーの軽い打撃で砕ける", "４．ハンマーの刃先がくい込む", "特記事項　"]
    // 風化変質
    let array4 = ["１．なし・健全", "２．岩目に沿って変色、強度やや低下", "３．全体に変色、強度相当に低下", "４．土砂状、粘土状、礫状、当初より未固結", "特記事項　"]
    // 破砕部の切羽に占める割合
    let array5 = ["１．破砕 < ５％", "２．５％ ≦ 破砕 < ２０％", "３．２０％ ≦ 破砕 < ５０％", "４．切羽面の大部分が破砕されている状態", "特記事項　"]
    // 割れ目の頻度
    let array6 = ["１．d ≧ 1m", "２．1m > d ≧ 20cm", "３．20cm > d ≧ 5cm", "４．5cm > d 破砕、当初より未固結", "特記事項　"]
    // 割れ目の状態
    let array7 = ["１．密着", "２．部分的に開口", "３．開口", "４．粘土を挟む、当初より未固結", "特記事項　"]
    // 割れ目の形態
    let array8 = ["１．ランダム方形", "２．柱状", "３．層状、片状、板状", "４．土砂状、細片状、当初より未固結", "特記事項　"]
    // 湧水
    let array9 = ["１．なし、滲水程度", "２．滴水程度", "３．集中湧水", "４．全面湧水", "湧水量の入力"]
    // 水による劣化
    let array10 = ["１．なし", "２．緩みを生ず", "３．軟弱化", "４．流出"]
    // 割れ目の方向：縦断方向
    let array11 = ["１．水平（0° < θ < １０°）", "２．さし目（１０° ≦ θ < ３０°、６０° ≦ θ < ８０°）", "３．さし目（３０° ≦ θ < ６０°）", "４．流れ目（６０° > θ ≧ ３０°）", "５．流れ目（３０° > θ ≧ １０°、８０° > θ ≧ ６０°）", "６．垂直（θ ≧ ８０°）"]
    // 割れ目の方向：横断方向
    let array12 = ["１．水平（0° < θ < １０°）", "２．右上からさし目（１０° ≦ θ < ３０°、６０° ≦ θ < ８０°）", "３．右上からさし目（３０° ≦ θ < ６０°）", "４．左上から流れ目（６０° > θ ≧ ３０°）", "５．左上から流れ目（３０° > θ ≧ １０°、８０° > θ ≧ ６０°）", "６．垂直（θ ≧ ８０°）"]
    
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
            return array0.count
        }
        else if section == 1 {
            return array1.count
        }
        else if section == 2 {
            return array2.count
        }
        else if section == 3 {
            return array3.count
        }
        else if section == 4 {
            return array4.count
        }
        else if section == 5 {
            return array5.count
        }
        else if section == 6 {
            return array6.count
        }
        else if section == 7 {
            return array7.count
        }
        else if section == 8 {
            return array8.count
        }
        else if section == 9 {
            return array9.count
        }
        else if section == 10 {
            return array10.count
        }
        else if section == 11 {
            return array11.count
        }
        else{
            return array12.count
        }
    }

    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 再利用可能な cell を得る、tableCellのIDでUITableViewCellのインスタンスを生成
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // 選択時に色を変える設定をオフにする
        cell.selectionStyle = .none
        
        // セルの背景色を白色に設定する
        cell.backgroundColor = .white
        
        // cellに値を設定する
        if indexPath.section == 0 {
            
            let cellTitle = array0[indexPath.row]
            cell.textLabel?.text = cellTitle
        }
        else if indexPath.section == 1 {
            
            let cellTitle = array1[indexPath.row]
            cell.textLabel?.text = cellTitle
        }
        else if indexPath.section == 2 {
            
            let cellTitle = array2[indexPath.row]
            cell.textLabel?.text = cellTitle
        }
        else if indexPath.section == 3 {
            
            let cellTitle = array3[indexPath.row]
            cell.textLabel?.text = cellTitle
        }
        else if indexPath.section == 4 {
            
            let cellTitle = array4[indexPath.row]
            cell.textLabel?.text = cellTitle
        }
        else if indexPath.section == 5 {
            
            let cellTitle = array5[indexPath.row]
            cell.textLabel?.text = cellTitle
        }
        else if indexPath.section == 6 {
            
            let cellTitle = array6[indexPath.row]
            cell.textLabel?.text = cellTitle
        }
        else if indexPath.section == 7 {
            
            let cellTitle = array7[indexPath.row]
            cell.textLabel?.text = cellTitle
        }
        else if indexPath.section == 8 {
            
            let cellTitle = array8[indexPath.row]
            cell.textLabel?.text = cellTitle
        }
        else if indexPath.section == 9 {
            
            let cellTitle = array9[indexPath.row]
            cell.textLabel?.text = cellTitle
        }
        else if indexPath.section == 10 {
            
            let cellTitle = array10[indexPath.row]
            cell.textLabel?.text = cellTitle
        }
        else if indexPath.section == 11 {
            
            let cellTitle = array11[indexPath.row]
            cell.textLabel?.text = cellTitle
        }
        else {
            
            let cellTitle = array12[indexPath.row]
            cell.textLabel?.text = cellTitle
        }

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
        
    }

    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }

    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
