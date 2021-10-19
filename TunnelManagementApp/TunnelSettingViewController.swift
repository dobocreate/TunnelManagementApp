//
//  UpdateTunSettingViewController.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2021/10/15.
//

import UIKit
import Firebase

class TunnelSettingViewController: UIViewController {


    @IBOutlet weak var tunnelNameTextField: UITextField!
    
    @IBOutlet weak var stationKTextField: UITextField!
    @IBOutlet weak var stationMTextField: UITextField!
    
    @IBOutlet weak var stationK2TextField: UITextField!
    @IBOutlet weak var stationM2TextField: UITextField!

    var tunnelData: TunnelData?
    
    var tunnelSpecData: TunnelDataDS?       // 画面遷移時のデータ渡し用
    var tunnelDataDS: TunnelDataDS?   // Firebaseからのデータ取得用

    // var tunnelId: String!
    
    
    // 表示項目名がタップされた時に実行される
    @IBAction func itemNameSettingButton(_ sender: Any) {
        
        self.performSegue(withIdentifier: "itemNameChangeSegue", sender: nil)
        
    }
    
    
    // 岩種名リストをタップされた時に実行される
    @IBAction func tunnelNameSettingButton(_ sender: Any) {
        
        self.performSegue(withIdentifier: "rockNameSegue", sender: nil)
    }
    
    // 画面遷移が行われる前に実行され、Segueを使用してデータを渡す
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "rockNameSegue" {
            
            let RockNameSettingVC = segue.destination as! RockNameSettingViewController
            
            if let tunnelDataDS = self.tunnelDataDS {
                
                RockNameSettingVC.tunnelSpecData = tunnelDataDS
            }
        } else if segue.identifier == "itemNameChangeSegue" {
            
            let ItemNameChangeVC = segue.destination as! ItemNameChangeViewController
            
            if let tunnelDataDS = self.tunnelDataDS {
                
                ItemNameChangeVC.tunnelSpecData = tunnelDataDS
            }
        }
    }
    
    
    // 画面遷移時に一度だけ実行される
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 遷移時のデータ受け渡しの確認
        print("TunnelSettingVC id: \(tunnelData?.id), tunnelId: \(tunnelData?.tunnelId)")
        
        // Firebaseからデータの取得
        if let tunnelId = self.tunnelData?.tunnelId, let id = tunnelData?.id {
            
            // 取得するドキュメントを設定
            let tunnelSpecDataRef = Firestore.firestore().collection("tunnelLists").document(id)
            
            // Firestoreのdocumentを取得する
            tunnelSpecDataRef.getDocument {(documentSnapshot, error) in
            
                if let error = error {
                    print("DEBUG_PRINT: documentSnapshotの取得に失敗しました。 \(error)")
                    return
                }
                
                guard let document = documentSnapshot else { return }
                
                // print("Firestore document.id \(document.documentID)")
                
                // print("Firestore documentData: \(document.data())")
                
                let tunnelDataDS = TunnelDataDS(document: document)
                
                self.tunnelDataDS = tunnelDataDS
                
                // print("FirestoreDS tunnelName: \(tunnelDataDS.tunnelName)")
                
                //　データを取得できた場合にテキストフィールドに代入する
                // トンネル名
                self.tunnelNameTextField.text = self.tunnelDataDS?.tunnelName
                
                // 始点位置
                if let stationNo1 = self.tunnelDataDS?.stationNo1 {
                    
                    let a = floor(stationNo1 / 1000)
                    let b = stationNo1 - a * 1000
                    let c: Int = Int(a)
                    
                    self.stationKTextField.text! = String(c)
                    self.stationMTextField.text! = String(b)
                }
                
                // 終点位置
                if let stationNo2 = self.tunnelDataDS?.stationNo2 {
                    
                    let a = floor(stationNo2 / 1000)
                    let b = stationNo2 - a * 1000
                    let c: Int = Int(a)
                    
                    self.stationK2TextField.text! = String(c)
                    self.stationM2TextField.text! = String(b)
                }
                
                /*
                // rockNameの出力確認
                if let rockName = self.tunnelDataDS?.rockName {
                    
                    print("rockName: \(self.tunnelDataDS?.rockName) -> \(rockName)")
                }
                */
            }
        }
    }
    
    // 更新ボタンがプッシュされた時に実行
    @IBAction func updateButton2(_ sender: Any) {
        
        print("更新ボタンがプッシュされました")
        
        // stationNoの計算
        let stationNo1: Float?
        let stationNo2: Float?
        
        stationNo1 = Float(self.stationKTextField.text!)! * 1000 + Float(self.stationMTextField.text!)!
        stationNo2 = Float(self.stationK2TextField.text!)! * 1000 + Float(self.stationM2TextField.text!)!
        
        print("stationNo1 \(stationNo1!)")
        
        // 保存するデータを辞書に格納する
        let tunnelDic = [
            "tunnelName": tunnelNameTextField.text!,
            "stationNo1": stationNo1!,
            "stationNo2": stationNo2!,
            "date": FieldValue.serverTimestamp()
        ] as [String: Any]
     
        // Firestoreにデータを上書き保存
        // トンネルデータの保存場所（更新する場合は、既存のdocumentIdを設定する）
        if let id = self.tunnelDataDS?.id {
            
            let tunnelListRef = Firestore.firestore().collection("tunnelLists").document(id)
            
            tunnelListRef.updateData(tunnelDic)
            
            print("変更を保存しました")
            
            /*
            // データを上書き保存する場合は、merge: trueとする
            tunnelListRef.setData(tunnelDic, merge: true) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
            */
        }
    }
    
    // テキストフィールド以外をタップした時に実行される
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
    }
}
