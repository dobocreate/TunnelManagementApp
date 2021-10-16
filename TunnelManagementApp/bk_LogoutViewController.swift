//
//  LogoutViewController.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2021/10/09.
//

import UIKit
import Firebase

class LogoutViewController: UIViewController,  UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    // セッションタイトル
    let sectionTitle: NSArray = ["基本情報", "切羽観察記録の関連"]
    
    // セッションごとのセル
    let array0 = ["観察者名の変更"]    // 基本情報
    let array1 = ["項目名の変更"]     // 切羽観察記録の関連
    // let array2 = [""]               // 岩種判定の関連
    
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!     // tableViewの高さ
    
    let cellHeight: CGFloat = 45        // セル１つの高さ
    let sectionHeight: CGFloat = 30     // セクション１つの高さ
    

    // 遷移してきたときに１度だけ実行される
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // 高さの調整
    // tableViewの高さ
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let cellCount = array0.count + array1.count
        let sectionCount = sectionTitle.count
        
        tableViewHeight.constant = CGFloat(cellCount) * cellHeight + CGFloat(sectionCount) * sectionHeight
    }
    
    // セクションの高さ
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
      return sectionHeight
    }
    // フッターの高さ
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
      return 0
    }
    
    // セルの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return self.cellHeight
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
        else {
            return array1.count
        }
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 再生可能なセルを取得
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // セルの値を設定
        if indexPath.section == 0 {
            
            let cellTitle = array0[indexPath.row]
            cell.textLabel?.text = cellTitle
        }
        else {
            
            let cellTitle = array1[indexPath.row]
            cell.textLabel?.text = cellTitle
        }
        
        return cell
    }

    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("セルがタップされた")
        
        print("indexPath section: \(indexPath.section), row: \(indexPath.row)")
        
        /*
        // 遷移先のViewControllerを取得
        let KirihaListViewController = self.storyboard?.instantiateViewController(withIdentifier: "kirihaList") as! KirihaListViewController
        
        self.navigationController?.pushViewController(KirihaListViewController, animated: true)
        
        */
        // Segueで画面遷移
        // performSegue(withIdentifier: "cellSegue",sender: nil)
    }
    
    // ログアウトボタンをタップしたときに呼ばれるメソッド
    @IBAction func handleLogoutButton(_ sender: Any) {
        
        // ログアウトする
        try! Auth.auth().signOut()
        
        // ログイン画面を表示する
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
        
        // 第一引数：遷移先のUIViewController、第二引数：アニメーションの指定、第三引数：コールバック関数
        self.present(loginViewController!, animated: true, completion: nil)
        
        // ログイン画面から戻ってきた時のためにホーム画面（index = 0）を選択している状態にしておく
        tabBarController?.selectedIndex = 0
    }
}
