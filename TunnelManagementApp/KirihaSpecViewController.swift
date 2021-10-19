//
//  KirihaSpecViewController.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2021/10/17.
//

import UIKit
import Firebase

class KirihaSpecViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var obsDateTextField: UITextField!       // 観察日ボタン
    @IBOutlet weak var rockTypeTextField: UITextField!      // 岩種ボタン
    @IBOutlet weak var rockNameTextField: UITextField!      // 岩石名ボタン
    @IBOutlet weak var geoAgeTextField: UITextField!        // 形成地質年代ボタン
    
    @IBOutlet weak var stationKTextField: DoneTextFierd!    // 測点K
    @IBOutlet weak var stationMTextField: DoneTextFierd!    // 測点M
    
    
    // データ受け渡し用
    var tunnelData: TunnelData?             // トンネルデータを格納する配列
    var kirihaRecordData: KirihaRecordData?     // 切羽観察記録データを格納する配列
    
    var kirihaRecordData2: KirihaRecordData?
    var dataArray2: [Int?] = []
    
    // datePickerViewのプロパティ
    var obsDatePickerView: UIDatePicker = UIDatePicker()

    // PickerViewのプロパティ
    var rockTypePickerView: UIPickerView = UIPickerView()
    var rockNamePickerView: UIPickerView = UIPickerView()
    var geoAgePickerView: UIPickerView = UIPickerView()
    
    // 岩種の選択リスト
    let rockTypeDataSource: [String] = ["A","B","C","D","E","F","G　表土、崩積土、崖錐など"]
    
    // 岩石名の選択リスト
    let rockNameDataSource: [String] = ["貫入岩玄武岩", "八雲層頁岩"]
    
    // 形成地質年代
    let geoAgeDataSource: [String] = ["新第三紀中新世", "その他"]
    
    // 分析ボタンがタップされた時に実行
    @IBAction func analysisButton(_ sender: Any) {
        
        self.performSegue(withIdentifier: "AnalysisSegue", sender: nil)
    }
    
    
    // 保存ボタンがタップされた時に実行
    @IBAction func saveButton(_ sender: Any) {
        
        // 測点を距離に換算する
        let stationNo = Float(stationKTextField.text!)! * 1000 + Float(stationMTextField.text!)!
        
        if let tunnelId = self.kirihaRecordData?.tunnelId, let id = kirihaRecordData?.id {
            
            // "dataArray[0] : \(dataArray[0])"
            
            // 観察者名
            let obsName = Auth.auth().currentUser?.displayName
            
            // 保存するデータを辞書の型にまとめる
            let kirihaRecordDic = [
                "date":FieldValue.serverTimestamp(),
                "tunnelId": tunnelId,
                "stationNo": stationNo,
                "obsDate": obsDateTextField.text!,
                "obsName": obsName!,
                "rockType": rockTypeTextField.text!,
                "rockName": rockNameTextField.text!,
                "geoAge": geoAgeTextField.text!,
                "obsRecordArray": dataArray2
            ] as [String: Any]
            
            // 既存のDocumentIDの保存場所を取得
            let kirihaRecordDataRef = Firestore.firestore().collection(tunnelId).document(id)
            
            // データを上書き保存する
            kirihaRecordDataRef.setData(kirihaRecordDic, merge: true) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
            print("上書きしました")
            
            // 画面遷移
            // navigationController?.popViewController(animated: true)      // 画面を閉じることで１つ前の画面に戻る
        }
    }
    
    // 画面遷移前に実行される
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // 画面遷移時に値を渡すときはここで記載する
        if segue.identifier == "kirihaRecordChangeSegue" {
            
            print("KirihaSpecVC prepare: kirihaRecordChangeSegue")
            
            let KirihaRecordChangeVC = segue.destination as! KirihaRecordChangeViewController
            
            print("KirihaRecordChangeVC tunnelId: \(self.kirihaRecordData?.tunnelId) ,id: \(self.kirihaRecordData?.id)")
            
            KirihaRecordChangeVC.kirihaRecordData = self.kirihaRecordData
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("KirihaSpecVC tunnelid: \(self.kirihaRecordData?.tunnelId)")
        print("kirihaSpecVC id: \(self.kirihaRecordData?.id)")
        
        // tunnelIdとidのnilでない時（データの受け渡しに成功した場合）
        if let tunnelId = self.kirihaRecordData?.tunnelId, let id = self.kirihaRecordData?.id {
            
            // データを取得するドキュメントを設定
            let kirihaRecordDataRef = Firestore.firestore().collection(tunnelId).document(id)
            
            // Firestoreのdocumentを取得する
            kirihaRecordDataRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    
                    // NSDictionary -> String
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    
                    // let rockType = document.data()?["rockType"] as? String
                    // let rockName = document.data()?["rockName"] as? String
                    // let geoAge = document.data()?["geoAge"] as? String
                    
                    
                    let dataArray:[Int?] = document.data()?["obsRecordArray"] as! [Int?]
                    self.dataArray2 = document.data()?["obsRecordArray"] as! [Int?]
                    
                    print("dataArray[0] : \(dataArray[0])")             // 関数内で定義、取得成功
                    print("dataArray2[0] : \(self.dataArray2[0])")      // クラス内で定義、取得成功
                    
                    self.kirihaRecordData2?.obsRecordArray = dataArray
                    
                    // 自分で定義したクラス内の配列には、値を代入することができない
                    print("obsRecordArray[0] : \(self.kirihaRecordData2?.obsRecordArray[0])")
                
                    // 距離を測点に変換する
                    // 始点位置
                    if let stationNo = document.data()?["stationNo"] {
                        
                        // Any -> Floatにダウンキャスト（より具体的な型に変換する）
                        let d = stationNo as? Float
                        
                        let a = floor(d! / 1000)
                        let b = d! - a * 1000
                        let c: Int = Int(a)
                        
                        self.stationKTextField.text! = String(c)
                        self.stationMTextField.text! = String(b)
                    }
                    
                    // テキストフィールドに値を代入する
                    if let obsDate = document.data()?["obsDate"] as? String {
                        
                        self.obsDateTextField.text! = obsDate
                    }
                    
                    
                    if let rockType = document.data()?["rockType"] as? String {
                        
                        self.rockTypeTextField.text! = rockType
                    }
                    
                    if let rockName = document.data()?["rockName"] as? String {
                        
                        self.rockNameTextField.text! = rockName
                    }
                    
                    if let geoAge = document.data()?["geoAge"] as? String {
                        
                        self.geoAgeTextField.text! = geoAge
                    }
                }
                else {
                    print("Document does not exist")
                }
            }
        }

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
        
        // 日付ピッカーをキーボードにする設定
        obsDatePickerView.datePickerMode = UIDatePicker.Mode.date
        obsDatePickerView.timeZone = TimeZone(identifier: "Asia/Tokyo")
        obsDatePickerView.locale = Locale(identifier: "ja_JP")
        
        // 日付ピッカーがスクロールにする。デフォルトはカレンダータイプ
        obsDatePickerView.preferredDatePickerStyle = .wheels
        
        obsDatePickerView.addTarget(self, action: #selector(self.dateChange), for: .valueChanged)
        
        obsDateTextField.inputView = obsDatePickerView

        obsDateTextField.delegate = self
    }
    
    // datePickerが変化すると呼ばれる
    @objc func dateChange() {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        obsDateTextField.text = "\(formatter.string(from: obsDatePickerView.date))"
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
    
    

    
}


