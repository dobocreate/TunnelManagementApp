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
    
    var waterValue: Float?          // 湧水量の受け渡し
    
    @IBOutlet weak var waterTextField: UITextField!
    
    @IBAction func saveButton(_ sender: Any) {
        
        if waterTextField.text == "" {
            
            SVProgressHUD.showError(withStatus: "湧水量を入力してください")
            print("強制終了")
            
            return
        }
        
        saveFile()
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
