//
//  LoginViewController.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2021/10/04.
//

import UIKit
import Firebase
import SVProgressHUD

class LoginViewController: UIViewController {
    
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var displayNameTextField: UITextField!
    
    // ログインボタンがタップされた時に実行される
    @IBAction func handleLoginButton(_ sender: Any) {
        
        
    }
    
    // アカウント作成ボタンがタップされた時に実行される
    @IBAction func handleCreateAccountButton(_ sender: Any) {
        
        // if let...は、mailAddressTextField.text != nil の時、mailAddressTextField.textをアンラップして、addressに代入する
        // ひとつでもnilがあればelseを実行する
        if let address = mailAddressTextField.text, let password = passwordTextField.text, let displayName = displayNameTextField.text {

            // アドレスとパスワードと表示名のいずれかでも入力されていない時は何もしない
            // 上のif分のelseで処理をすればいいのでは？
            if address.isEmpty || password.isEmpty || displayName.isEmpty {
                print("DEBUG_PRINT: 何かが空文字です。")
                return
            }
            
            // HUDで処理中を表示
            SVProgressHUD.show()

            // アドレスとパスワードでユーザー作成。ユーザー作成に成功すると、自動的にログインする
            Auth.auth().createUser(withEmail: address, password: password) { authResult, error in
                
                // if error != nil { let error = error! } ← なぜ変数名が同じでも問題ないのか？
                if let error = error {
                    // エラーがあったら原因をprintして、returnすることで以降の処理を実行せずに処理を終了する
                    print("DEBUG_PRINT: " + error.localizedDescription)
                    return
                }
                print("DEBUG_PRINT: ユーザー作成に成功しました。")
                
                // HUDを消す
                SVProgressHUD.dismiss()

                // 表示名を設定する
                let user = Auth.auth().currentUser
                
                // if u
                if let user = user {
                    
                    let changeRequest = user.createProfileChangeRequest()
                    
                    changeRequest.displayName = displayName
                    
                    changeRequest.commitChanges { error in
                        if let error = error {
                            // プロフィールの更新でエラーが発生
                            print("DEBUG_PRINT: " + error.localizedDescription)
                            return
                        }
                        print("DEBUG_PRINT: [displayName = \(user.displayName!)]の設定に成功しました。")

                        // 画面を閉じてタブ画面に戻る
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
