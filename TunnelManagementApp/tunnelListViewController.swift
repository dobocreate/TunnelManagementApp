//
//  tunnelListViewController.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2021/10/08.
//

import UIKit

class tunnelListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let tunnelList:[String] = ["渡島トンネル", "内浦トンネル"]
    
    // デリゲートメソッド：データ数を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tunnelList.count
    }

    // デリゲートメソッド：セルの表示内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // 値を設定する.
        cell.textLabel!.text = tunnelList[indexPath.row]   // "Row \(indexPath.row)"

        return cell
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }

    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //
        performSegue(withIdentifier: "cellSegue",sender: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // デリゲートの指定。ここで、selfとはViewController
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
