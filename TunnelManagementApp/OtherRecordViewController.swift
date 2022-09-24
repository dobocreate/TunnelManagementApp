//
//  OtherRecordViewController.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2022/04/01.
//

import UIKit

class OtherRecordViewController: UIViewController, UITextViewDelegate {

    
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
        
        // プレースホルダーの設定
        SpecialTextView.delegate = self
        
        // TextViewの設定
        if self.specialText == "ここに、特記事項を記載する。" {
            
            self.SpecialTextView.text = self.specialText
            
            SpecialTextView.textColor = UIColor.lightGray
        }
        else if self.specialText == "" {
            
            self.SpecialTextView.text = "ここに、特記事項を記載する。"
            
            SpecialTextView.textColor = UIColor.lightGray
        }
        else if self.specialText != nil {
            self.SpecialTextView.text = self.specialText
        }
        
        // TextViewの枠線の設定
        self.SpecialTextView.layer.borderColor = UIColor.systemGray6.cgColor
        self.SpecialTextView.layer.borderWidth = 1.0
        

        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        // キーボードに閉じるボタンを追加
        //inputAccesoryViewに入れるtoolbar
        let toolbar = UIToolbar()

        //完了ボタンを右寄せにする為に、左側を埋めるスペース作成
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                    target: nil,
                                    action: nil)
        //完了ボタンを作成
        let done = UIBarButtonItem(title: "閉じる",
                                   style: .done,
                                   target: self,
                                   action: #selector(didTapDoneButton))

        //toolbarのitemsに作成したスペースと完了ボタンを入れる。実際にも左から順に表示されます。
        toolbar.items = [space, done]
        toolbar.sizeToFit()
        
        //作成したtoolbarをtextFieldのinputAccessoryViewに入れる
        self.SpecialTextView.inputAccessoryView = toolbar

        //キーボードタイプを指定
        self.SpecialTextView.keyboardType = .default
    }
    
    // SpecialTextViewがフォーカスされたら、プレースホルダーを非表示
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if SpecialTextView.textColor == UIColor.lightGray {
            
            SpecialTextView.text = nil
            SpecialTextView.textColor = UIColor.black
        }
    }
    
    // SpecialTextViewに文字列が入力されていない場合の処理
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if SpecialTextView.text.isEmpty {
            
            SpecialTextView.text = "ここに、特記事項を記載する。"
            SpecialTextView.textColor = UIColor.lightGray
        }
    }
    
    //完了ボタンを押した時の処理
    @objc func didTapDoneButton() {
        self.SpecialTextView.resignFirstResponder()
    }
    
    // 保存ボタンをタップした時に実行される
    @IBAction func SavePush(_ sender: Any) {
        
        print("Saveボタンをプッシュ")
        
        // 遷移元へのデータを渡す
        let nc = self.navigationController!
        let vcNum = nc.viewControllers.count
        
        print("vcNum: \(vcNum)")
        
        if vcName == "KirihaRecordVC" {
            
            let kirihaRecordvc = nc.viewControllers[vcNum - 2] as! KirihaRecordViewController
            
            kirihaRecordvc.specialSec = titleLabel

            kirihaRecordvc.specialSecNo = secNo
            
            if SpecialTextView.text == "ここに、特記事項を記載する。" {
                
                kirihaRecordvc.specialRecordData[secNo] = ""
            }
            else {
                kirihaRecordvc.specialRecordData[secNo] = SpecialTextView.text
            }
            
            print("遷移先vc: \(kirihaRecordvc), text: \(String(describing: kirihaRecordvc.specialRecordData[secNo]))")
            
            self.navigationController?.popViewController(animated: true)
        }
        else if vcName == "KirihaRecordChangeVC" {
            
            let kirihaRecordChangevc = nc.viewControllers[vcNum - 2] as! KirihaRecordChangeViewController
            
            kirihaRecordChangevc.specialSec = titleLabel
            
            if SpecialTextView.text == "ここに、特記事項を記載する。" {
                
                kirihaRecordChangevc.specialRecordData[secNo] = ""
            }
            else {
                kirihaRecordChangevc.specialRecordData[secNo] = SpecialTextView.text
            }
            
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
