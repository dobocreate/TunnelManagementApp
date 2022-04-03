//
//  OtherRecordViewController.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2022/04/01.
//

import UIKit

class OtherRecordViewController: UIViewController {

    
    @IBOutlet weak var SpecialTextView: UITextView!
    @IBOutlet weak var SpecialLabel: UILabel!
    
    // 遷移元とのデータ受け渡し用
    var titleLabel: String!
    var vcName: String!
    var secNo: Int!
    var specialText: String!
    
    // 画面遷移が行われた時に１度だけ実行される
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("遷移元vc: \(String(describing: self.vcName))")
        
        // 初期設定
        self.navigationItem.title = "特記事項"        // Navigation Barのタイトルの設定
        self.SpecialLabel.text = titleLabel         //　Labelのテキストの設定
        
        // TextViewの設定
        if self.specialText != nil {
            self.SpecialTextView.text = self.specialText
        }
        
        // TextViewの枠線の設定
        self.SpecialTextView.layer.borderColor = UIColor.systemGray6.cgColor
        self.SpecialTextView.layer.borderWidth = 1.0
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    // 保存ボタンをタップした時に実行される
    @IBAction func SavePush(_ sender: Any) {
        
        print("Saveボタンをプッシュ")
        
        // 遷移元へのデータを渡す
        let nc = self.navigationController as! UINavigationController
        let vcNum = nc.viewControllers.count
        
        print("vcNum: \(vcNum)")
        
        if vcName == "KirihaRecordVC" {
            
            let kirihaRecordvc = nc.viewControllers[vcNum - 2] as! KirihaRecordViewController
            
            kirihaRecordvc.specialSec = titleLabel

            kirihaRecordvc.specialSecNo = secNo
            kirihaRecordvc.specialRecordData[secNo] = SpecialTextView.text
            
            print("遷移先vc: \(kirihaRecordvc), text: \(String(describing: kirihaRecordvc.specialRecordData[secNo]))")
            
            self.navigationController?.popViewController(animated: true)
        }
        else if vcName == "KirihaRecordChangeVC" {
            
            let kirihaRecordChangevc = nc.viewControllers[vcNum - 2] as! KirihaRecordChangeViewController
            
            kirihaRecordChangevc.specialSec = titleLabel
            kirihaRecordChangevc.specialRecordData[secNo] = SpecialTextView.text
            
            print("遷移先vc: \(kirihaRecordChangevc), text: \(String(describing: kirihaRecordChangevc.specialRecordData[secNo]))")
            
            self.navigationController?.popViewController(animated: true)
        }
    }


    
    
    
    // キーボードを閉じるメソッド
    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }

}
