//
//  TabBarController.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2021/10/08.
//

import UIKit
import Firebase

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // currentUserがnilならログインしていない
        if Auth.auth().currentUser == nil {
            // ログインしていない時の処理
            let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
            
            // 第一引数：遷移先のUIViewController、第二引数：アニメーションの指定、第三引数：コールバック関数
            self.present(loginViewController!, animated: true, completion: nil)
        }
        
    }


}
