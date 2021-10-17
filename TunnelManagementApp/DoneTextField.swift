//
//  DoneTextField.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2021/10/17.
//

import Foundation
import UIKit

// MARK: - キーボードにと閉じるボタンを付ける
//storybordで該当テキストフィールドを選択し、identity Inspectorでclassを DoneTextFierdに切り替える
class DoneTextFierd: UITextField{

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        
        let tools = UIToolbar()
        
        tools.frame = CGRect(x: 0, y: 0, width: frame.width, height: 40)
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let closeButton = UIBarButtonItem(title: "閉じる", style: .done, target: self, action: #selector(self.closeButtonTapped))
        // let closeButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.closeButtonTapped))
        
        tools.items = [spacer, closeButton]
        self.inputAccessoryView = tools
    }

    @objc func closeButtonTapped() {
        
        self.endEditing(true)
        
        // ファーストレスポンダをやめる（その結果、キーボードが非表示になる）
        // 記載する意味がわからない
        // self.resignFirstResponder()
    }
}
