//
//  InputKirihaViewController.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2021/10/05.
//

import UIKit
import Firebase

class InputKirihaViewController: UIViewController {
    
    @IBOutlet weak var tunnelIdTextField: UITextField!
    
    @IBOutlet weak var tunnelNameTextField: UITextField!
    
    @IBOutlet weak var stationKTextField: UITextField!
    @IBOutlet weak var stationMTextField: UITextField!
    
    @IBOutlet weak var stationK2TextField: UITextField!
    @IBOutlet weak var stationM2TextField: UITextField!
    
    @IBOutlet weak var tunnelTypeSegmentedControl2: UISegmentedControl!
    
    var tunnelType: Int = 2      // 様式タイプ名
    
    // 観察記録の様式タイプを選択する
    @IBAction func tunnelTypeSegmentedControl(_ sender: UISegmentedControl) {
        
        // 選択されたボタンのタイトルを取得する
        self.tunnelType = sender.selectedSegmentIndex
        
        print(sender.titleForSegment(at: sender.selectedSegmentIndex)!)
    }
    
    // Saveボタンがプッシュされた時に
    @IBAction func saveButton(_ sender: Any) {
        
        print("Save Button Push!")
        
        // トンネルデータの保存場所
        let tunnelListRef = Firestore.firestore().collection(FirestorePathList.tunnelListPath).document()
        
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
            "tunnelType": tunnelType,
            "date": FieldValue.serverTimestamp()
        ] as [String: Any]
     
        // Firestoreにデータを保存
        tunnelListRef.setData(tunnelDic)
        
        // StoryboardIDを指定して画面遷移する
        let tunnelListViewController = self.storyboard?.instantiateViewController(withIdentifier: "tunnelList") as! tunnelListViewController
        
        navigationController?.pushViewController(tunnelListViewController, animated: true)      // プッシュ画面遷移
        // self.present(tunnelListViewController, animated: true, completion: nil)              // モーダル画面遷移
    }
    
    // 画面遷移時に一度だけ実行される
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // tunnelTypeの初期値の設定
        let tunnelTypeIndex = 2         // 様式A：0、様式B：1、様式C：2
        tunnelTypeSegmentedControl2.selectedSegmentIndex = tunnelTypeIndex
        
        print("tunnelType: \(tunnelTypeIndex)")
        // self.tunnelType = tunnelTypeSegmentedControl2.titleForSegment(at: tunnelTypeIndex)
        
    }
    

}
