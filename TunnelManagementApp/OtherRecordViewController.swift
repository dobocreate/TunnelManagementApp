//
//  OtherRecordViewController.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2022/04/01.
//

import UIKit

class OtherRecordViewController: UIViewController {

    
    @IBOutlet weak var SpecialTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.title = "title"
        
        
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
