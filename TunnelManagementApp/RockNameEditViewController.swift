//
//  RockNameEditViewController.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2022/10/14.
//

import UIKit
import Firebase

class RockNameEditViewController: UIViewController {

    @IBOutlet weak var layerNameTextField: UITextField!     // 地層名
    @IBOutlet weak var rockNameTextField: UITextField!      // 岩石名
    @IBOutlet weak var dispRockNameTextField: UITextField!  // 判定に使用する岩石名
    @IBOutlet weak var geoAgeTextField: UITextField!        // 形成地質年代
    
    // データ受け渡し用
    var tunnelDataDS: TunnelDataDS?         // トンネルデータを格納する配列
    var row: Int?                           // 行番号を格納
    
    
    
    // 画面遷移が行われた時に１度だけ実行される
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("RockNameEditVC 1 tunnelData id \(self.tunnelDataDS?.id))")   // データの受け渡しチェック
        print("RockNameEditVC 1 row \(self.row))")
        
        print("RockNameEditVC 1 岩石名 \(self.tunnelDataDS?.rockName[self.row!]))")
        
        self.layerNameTextField.text = self.tunnelDataDS?.layerName[self.row!]
        self.rockNameTextField.text = self.tunnelDataDS?.rockName[self.row!]
        self.dispRockNameTextField.text = self.tunnelDataDS?.dispRockName[self.row!]
        self.geoAgeTextField.text = self.tunnelDataDS?.geoAge[self.row!]

    }
    
    // 画面遷移前に実行され、戻ってくるたびに実行される
    override func viewWillAppear(_ animated: Bool) {
        
        
        
    }
    
    // 追加ボタンをタップしたときに実行される
    @IBAction func addButton(_ sender: Any) {
        
        self.tunnelDataDS?.layerName[self.row!] = self.layerNameTextField.text
        self.tunnelDataDS?.rockName[self.row!] = self.rockNameTextField.text
        self.tunnelDataDS?.dispRockName[self.row!] = self.dispRockNameTextField.text
        self.tunnelDataDS?.geoAge[self.row!] = self.geoAgeTextField.text
        
        // 保存するデータを辞書に格納する
        let tunnelDic = [
            "layerName": self.tunnelDataDS?.layerName,
            "rockName": self.tunnelDataDS?.rockName,
            "dispRockName": self.tunnelDataDS?.dispRockName,
            "geoAge": self.tunnelDataDS?.geoAge
        ] as [String: Any]
        
        // Firestoreのデータを上書き保存
        if let id = self.tunnelDataDS?.id {
            
            let tunnelListRef = Firestore.firestore().collection("tunnelLists").document(id)
            
            tunnelListRef.updateData(tunnelDic)
            
            print("変更を保存しました")
        }
        
        // データの受け渡し
        let RockNameSetting2NC = self.navigationController as! UINavigationController
        let RockNameSetting2VC = RockNameSetting2NC.viewControllers[RockNameSetting2NC.viewControllers.count - 2] as! RockNameSetting2ViewController
        RockNameSetting2VC.tunnelDataDS = self.tunnelDataDS  //ここで値渡し
        
        // 保存アラートを表示する処理
        let alert = UIAlertController(title: nil, message: "保存しました", preferredStyle: .alert)

        let alClose = UIAlertAction(title: "閉じる", style: .default, handler: {
            (action:UIAlertAction!) -> Void in

            // 閉じるボタンがプッシュされた際の処理内容をここに記載
            alert.dismiss(animated: true, completion: nil)                  // アラートを閉じる
            // self.navigationController?.popViewController(animated: true)    // 画面を閉じることで、１つ前の画面に戻る
        })
        
        alert.addAction(alClose)
        
        self.present(alert, animated: true, completion: nil)

        // 1秒後に自動で閉じる
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            
            // 秒後の処理内容をここに記載
            alert.dismiss(animated: true, completion: nil)                  // アラートを閉じる
            self.navigationController?.popViewController(animated: true)    // 画面を閉じることで、１つ前の画面に戻る
        }

        print("RockNameEditVC 2 保存しました")
    }
    
    // テキストフィールド以外をタップした時に実行される
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
    }
    
}
