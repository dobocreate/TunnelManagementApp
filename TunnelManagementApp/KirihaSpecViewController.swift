//
//  KirihaSpecViewController.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2021/10/17.
//

import UIKit

class KirihaSpecViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    
    @IBOutlet weak var obsDateTextField: UITextField!       // 観察日ボタン
    @IBOutlet weak var rockTypeTextField: UITextField!      // 岩種ボタン
    @IBOutlet weak var rockNameTextField: UITextField!      // 岩石名ボタン
    @IBOutlet weak var geoAgeTextField: UITextField!        // 形成地質年代ボタン
    
    // datePickerViewのプロパティ
    var obsDatePickerView: UIDatePicker = UIDatePicker()

    // PickerViewのプロパティ
    var rockTypePickerView: UIPickerView = UIPickerView()
    var rockNamePickerView: UIPickerView = UIPickerView()
    var geoAgePickerView: UIPickerView = UIPickerView()
    
    
    // 岩種の選択リスト
    let rockTypeDataSource: [String] = ["A","B","C","D","E","F"]
    
    // 岩石名の選択リスト
    let rockNameDataSource: [String] = ["泥岩", "砂岩"]
    
    // 形成地質年代
    let geoAgeDataSource: [String] = ["新生代第三紀", "中生代ジュラ紀"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // rockTypePickerViewをキーボードにする設定
        rockTypePickerView.tag = 1
        rockTypePickerView.delegate = self
        
        rockTypeTextField.inputView = rockTypePickerView
        rockTypeTextField.delegate = self
        
        // rockNamePickerViewをキーボードにする設定
        rockNamePickerView.tag = 2
        rockNamePickerView.delegate = self
        
        rockNameTextField.inputView = rockNamePickerView
        rockNameTextField.delegate = self
        
        // geoAgePickerViewをキーボードにする設定
        geoAgePickerView.tag = 3
        geoAgePickerView.delegate = self
        
        geoAgeTextField.inputView = geoAgePickerView
        geoAgeTextField.delegate = self
        
    
        /*
        // 日付ピッカーをキーボードにする設定
        obsDatePickerView.datePickerMode = UIDatePicker.Mode.date   // UIDatePicker.Mode.dateAndTime
        obsDatePickerView.timeZone = NSTimeZone.local               // TimeZone(identifier: "Asia/Tokyo")
        obsDatePickerView.locale = Locale.current                   // Locale(identifier: "ja_JP")
        obsDatePickerView.addTarget(self, action: #selector(self.dateChange), for: .valueChanged)
        
        obsDateTextField.inputView = obsDatePickerView

        obsDateTextField.delegate = self
        */
        
    }
    
    
    // PickerViewの列数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    // PickerViewに表示する内容
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 1:
            return rockTypeDataSource[row]
        case 2:
            return rockNameDataSource[row]
        case 3:
            return geoAgeDataSource[row]
        default:
            return "error"
        }
    }
    
    // PickerViewの行数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1:
            return rockTypeDataSource.count
        case 2:
            return rockNameDataSource.count
        case 3:
            return geoAgeDataSource.count
        default:
            return 0
        }
    }

    // 各選択肢が選ばれた時の操作
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 1:
            return rockTypeTextField.text = rockTypeDataSource[row]
        case 2:
            return rockNameTextField.text =  rockNameDataSource[row]
        case 3:
            return geoAgeTextField.text =  geoAgeDataSource[row]
        default:
            return
        }
    }
    
    
    // datePickerが変化すると呼ばれる
    @objc func dateChange() {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        obsDateTextField.text = "\(formatter.string(from: obsDatePickerView.date))"
    }
    
}


