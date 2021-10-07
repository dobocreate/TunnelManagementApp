//
//  RemarksViewController.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2021/10/07.
//

import UIKit

class RemarksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    // 特記事項の項目
    var remarksArray: [RemarksData] = [
    
        RemarksData(title: "「地質構造」で「その他」を選択した場合", remarksText: "塊状、レンズ状、片理、鏡肌、空洞（中小・大）、未固結　他"),
        RemarksData(title: "「切羽の安定」に関する特記事項", remarksText: ""),
        RemarksData(title: "「素掘り面の状態」に関する特記事項", remarksText: ""),
        RemarksData(title: "「圧縮強度」に関する特記事項", remarksText: ""),
        RemarksData(title: "「風化変質」に関する特記事項", remarksText: ""),
        RemarksData(title: "「破砕部の切羽に占める割合」に関する特記事項", remarksText: ""),
        RemarksData(title: "「割れ目の頻度」に関する特記事項", remarksText: ""),
        RemarksData(title: "「割れ目の状態」に関する特記事項", remarksText: "")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        // カスタムセルを登録する
        let nib = UINib(nibName: "RemarksTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
        /*
        // キーボードの出現を検知
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        // キーボードの消失を検知
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        // タップを認識するためのインスタンスを作成
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        
        // Viewに追加
        view.addGestureRecognizer(tapGesture)
        */
    }
    
    /*
    // キーボードと閉じる際の処理
    @objc public func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            } else {
                let suggestionHeight = self.view.frame.origin.y + keyboardSize.height
                self.view.frame.origin.y -= suggestionHeight
            }
        }
    }
    
    @objc func keyboardWillHide() {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y = 0
            }
        }
    */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return remarksArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RemarksTableViewCell
        cell.setRemaksData(remarksArray[indexPath.row])
        
        return cell
    }
    

}
