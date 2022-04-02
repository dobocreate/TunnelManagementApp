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
    
    // 遷移元からのデータ受け渡し用
    var titleLabel: String!
    var vcName: String!
    
    @IBAction func SavePush(_ sender: Any) {
        
        print("Saveボタンをプッシュ")
        
        let nc = self.navigationController as! UINavigationController
        let vcNum = nc.viewControllers.count
        
        print("vcNum: \(vcNum)")
        
        let vc = nc.viewControllers[vcNum - 2] as! KirihaRecordViewController
        
        vc.specialSec = titleLabel
        vc.specialText = SpecialTextView.text
        
        print("遷移先vc: \(vc), text: \(vc.specialText)")
        
        self.navigationController?.popViewController(animated: true)
    }

    
    // 画面遷移が行われた時に１度だけ実行される
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("遷移元vc: \(self.vcName)")
        
        // 初期設定
        self.navigationItem.title = "特記事項"        // Navigation Barのタイトルの設定
        self.SpecialLabel.text = titleLabel         //　Labelのテキストの設定
        
        // 枠線の設定
        self.SpecialTextView.layer.borderColor = UIColor.systemGray6.cgColor
        self.SpecialTextView.layer.borderWidth = 1.0
        
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    
    
    // キーボードを閉じるメソッド
    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }

}
