//
//  WaterRecordViewController.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2021/11/04.
//

import UIKit
import SVProgressHUD
import Firebase

class WaterRecordViewController: UIViewController {

    var tunnelData: TunnelData?     // データ受け渡し用(トンネル設定データ)
    var kirihaRecordData: KirihaRecordData?
    var kirihaRecordDataDS: KirihaRecordDataDS?
    
    // 遷移元とのデータ受け渡し用
    var vcName: String!             // 遷移元のViewController名
    var waterValue: Float?          // 湧水量
    
    @IBOutlet weak var waterTextField: UITextField!
    
    // 保存ボタンをタップした時に実行される
    @IBAction func SavePush(_ sender: Any) {
        
        if self.waterTextField.text == "" {
            
            SVProgressHUD.showError(withStatus: "湧水量を入力してください")
            print("強制終了")
            
            return
        } else {
          
            self.waterValue = Float(self.waterTextField.text!)
            
            print("waterValue: \(String(describing: self.waterValue))")
        }
        
        // 遷移元へのデータを渡す
        let nc = self.navigationController as! UINavigationController
        let vcNum = nc.viewControllers.count
        
        print("vcNum: \(vcNum)")
        
        if self.vcName == "KirihaRecordVC" {
            
            let kirihaRecordvc = nc.viewControllers[vcNum - 2] as! KirihaRecordViewController
            
            kirihaRecordvc.waterValue = self.waterValue!
            
            print("遷移先vc: \(kirihaRecordvc), 湧水量: \(kirihaRecordvc.waterValue)")
            
            self.navigationController?.popViewController(animated: true)
        }
        else if self.vcName == "KirihaRecordChangeVC" {
            
            let kirihaRecordChangevc = nc.viewControllers[vcNum - 2] as! KirihaRecordChangeViewController
            
            kirihaRecordChangevc.waterValue = self.waterValue!
            
            print("遷移先vc: \(kirihaRecordChangevc), 湧水量: \(kirihaRecordChangevc.waterValue)")
            
            self.navigationController?.popViewController(animated: true)
        }
        
        // saveFile()
    }
    
    
    func saveFile() {
        
        if let tunnelId = self.kirihaRecordData?.tunnelId, let id = kirihaRecordData?.id {
            
            // 保存するデータを辞書の型にまとめる
            let kirihaRecordDic = [
                "water": Float(waterTextField.text!)
            ] as [String: Any]
            
            // 既存のDocumentIDの保存場所を取得
            let kirihaRecordDataRef = Firestore.firestore().collection(tunnelId).document(id)
            
            // データを更新する
            kirihaRecordDataRef.updateData(kirihaRecordDic)
            
            print("更新しました")
            
            SVProgressHUD.showSuccess(withStatus: "湧水量を保存しました")
            
            // 画面遷移
            navigationController?.popViewController(animated: true)     // 画面を閉じることで、１つ前の画面に戻る
            
        }
    }
    
    // 画面遷移後に１度呼ばれます。他の画面に遷移して戻ってきた時には呼ばれない
    override func viewDidLoad() {
        super.viewDidLoad()

        if let waterValue = self.waterValue {
            
            self.waterTextField.text = String(waterValue)
        }
        
    }
    
    //
    
    // 画面が消えた後に呼び出されるメソッド
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        SVProgressHUD.dismiss()
    }

    // テキストフィールド以外をタップした時に実行される
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
    }
    
    
}
