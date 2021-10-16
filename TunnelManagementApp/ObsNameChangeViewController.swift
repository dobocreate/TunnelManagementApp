//
//  ObsNameChangeViewController.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2021/10/16.
//

import UIKit
import Firebase
import SVProgressHUD

class ObsNameChangeViewController: UIViewController {

    
    @IBOutlet weak var obsNameTextField: UITextField!
    
    // 変更ボタンがタップされた時に実行
    @IBAction func changeButton(_ sender: Any) {
        
        if let displayName = obsNameTextField.text {
            
            // 観察者名が入力されてない場合は、何もしない
            if displayName.isEmpty {
                
                SVProgressHUD.show(withStatus: "表示名を入力してください")
                return
            }
            
            // 表示名を設定する
            let user = Auth.auth().currentUser
            
            if let user = user {
                
                let changeRequest = user.createProfileChangeRequest()
                
                changeRequest.displayName = displayName
                
                changeRequest.commitChanges { error in
                    if let error = error {
                        SVProgressHUD.showError(withStatus: "表示名の変更に失敗しました。")
                        print("DEBUG_PRINT: " + error.localizedDescription)
                        return
                    }
                    print("DEBUG_PRINT: [displayName = \(user.displayName!)]の設定に成功しました。")

                    // HUDで完了を知らせる
                    SVProgressHUD.showSuccess(withStatus: "表示名を変更しました")
                }
            }
        }
        
        // モーダルを閉じる
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let name = Auth.auth().currentUser?.displayName
        
        print("displayName: \(name!)")
        
        obsNameTextField.text! = name!
    }

}
