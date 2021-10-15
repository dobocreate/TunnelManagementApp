//
//  UpdateTunSettingViewController.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2021/10/15.
//

import UIKit
import Firebase

class UpdateTunSettingViewController: UIViewController {

    @IBOutlet weak var tunnelIdTextField: UITextField!
    @IBOutlet weak var tunnelNameTextField: UITextField!
    
    @IBOutlet weak var stationKTextField: UITextField!
    @IBOutlet weak var stationMTextField: UITextField!
    
    @IBOutlet weak var stationK2TextField: UITextField!
    @IBOutlet weak var stationM2TextField: UITextField!
    
    @IBOutlet weak var tunnelTypeSegmentedControl2: UISegmentedControl!
    
    var tunnelType:Int?      // 様式タイプ名
    
    var tunnelData: tunInitialData?   // データの受け渡し用
    
    // 画面遷移時に一度だけ実行される
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tunnelTypeの初期値の設定
        var tunnelTypeIndex = 2         // 様式A：0、様式B：1、様式C：2
        
        tunnelTypeSegmentedControl2.selectedSegmentIndex = tunnelTypeIndex
        
        self.tunnelType = tunnelTypeIndex
        
        // 初期値の入力
        
        if tunnelData != nil {
            // トンネルID
            if let tunnelId = tunnelData?.tunnelId {
                
                tunnelIdTextField.text! = tunnelId
            }
            
            // トンネル名
            if let tunnelName = tunnelData?.tunnelName {
                
                tunnelNameTextField.text! = tunnelName
            }

            // 始点位置
            if let stationNo1 = tunnelData?.stationNo1 {
                
                let a = floor(stationNo1 / 1000)
                let b = stationNo1 - a * 1000
                
                stationKTextField.text! = String(a)
                stationMTextField.text! = String(b)
            }
            
            // 終点位置
            if let stationNo2 = tunnelData?.stationNo2 {
                
                let a = floor(stationNo2 / 1000)
                let b = stationNo2 - a * 1000
                
                stationK2TextField.text! = String(a)
                stationM2TextField.text! = String(b)
            }
            
            // 様式タイプ（様式A：0、様式B：1、様式C：2）
            if let type = tunnelData?.tunnelType {
                
                tunnelTypeIndex = type
                
                tunnelTypeSegmentedControl2.selectedSegmentIndex = tunnelTypeIndex
            }
        }
    }
    
    
    // 観察記録の様式タイプを選択する
    @IBAction func tunnelTypeSegmentedControl(_ sender: UISegmentedControl) {
        
        // 選択されたボタンのタイトルを取得する
        self.tunnelType = sender.selectedSegmentIndex
        
        print(sender.titleForSegment(at: sender.selectedSegmentIndex)!)
    }
    
    // 更新ボタンがプッシュされた時に実行
    @IBAction func updateButton2(_ sender: Any) {
        
        print("更新ボタンがプッシュされました")
        
        // トンネルデータの保存場所
        let tunnelListRef = Firestore.firestore().collection(FirestorePathList.tunnelListPath).document("sgmYhd9wDqX2r5tGEnvz")
        
        // stationNoの計算
        let stationNo1: Float?
        let stationNo2: Float?
        
        stationNo1 = Float(stationKTextField.text!)! * 1000 + Float(stationMTextField.text!)!
        stationNo2 = Float(stationK2TextField.text!)! * 1000 + Float(stationM2TextField.text!)!
        
        print("stationNo1 \(stationNo1!)")
        
        // 保存するデータを辞書に格納する
        let tunnelDic = [
            "tunnelId": tunnelIdTextField.text!,
            "tunnelName": tunnelNameTextField.text!,
            "stationNo1": stationNo1!,
            "stationNo2": stationNo2!,
            "tunnelType": tunnelType!,
            "date": FieldValue.serverTimestamp()
        ] as [String: Any]
     
        // Firestoreにデータを保存
        tunnelListRef.updateData(tunnelDic) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
        
        // モーダルを閉じる
        self.dismiss(animated:true, completion: nil)
    }
    

}
