//
//  LogoutViewController.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2021/10/09.
//

import UIKit
import Firebase

class LogoutViewController: UIViewController {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
