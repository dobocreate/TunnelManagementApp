//
//  KirihaSpec2ViewController.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2021/11/04.
//

import UIKit
import Firebase
import SVProgressHUD

class KirihaSpec2ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {


    @IBOutlet weak var obsDateTextField: UITextField!       // 観察日ボタン
    @IBOutlet weak var rockTypeTextField: UITextField!      // 岩種ボタン
    @IBOutlet weak var rockNameTextField: UITextField!      // 岩石名ボタン
    @IBOutlet weak var geoAgeTextField: UITextField!        // 形成地質年代ボタン
    
    @IBOutlet weak var stationKTextField: DoneTextFierd!    // 測点K
    @IBOutlet weak var stationMTextField: DoneTextFierd!    // 測点M
    
    @IBOutlet weak var distanceLabel: UILabel!              // 坑口からの距離
    @IBOutlet weak var distanceTextField: UITextField!      // 坑口からの距離
    
    // データ受け渡し用
    var tunnelData: TunnelData?             // トンネルデータを格納する配列
    var kirihaRecordData: KirihaRecordData?     // 切羽観察記録データを格納する配列
    
    var kirihaRecordData2: KirihaRecordData?
    var dataArray2: [Int?] = []
    
    var tunnelDataDS: TunnelDataDS?                 // Firestoreデータの格納用
    var kirihaRecordDataDS: KirihaRecordDataDS?     // Firestoreデータの格納用
    
    // datePickerViewのプロパティ
    var obsDatePickerView: UIDatePicker = UIDatePicker()

    // PickerViewのプロパティ
    var rockTypePickerView: UIPickerView = UIPickerView()
    var rockNamePickerView: UIPickerView = UIPickerView()
    var geoAgePickerView: UIPickerView = UIPickerView()
    
    // 岩種の選択リスト
    let rockTypeDataSource: [String] = ["A","B","C","D","E","F","G　表土、崩積土、崖錐など"]
    
    // 岩石名の選択リスト
    var rockNameDataSource: [String?] = []
    
    // 形成地質年代
    var geoAgeDataSource: [String?] = []
    
    // 分析ボタンがタップされた時に実行
    @IBAction func analysisButton(_ sender: Any) {
        
        
        if stationKTextField.text == "" || stationMTextField.text == "" {
            
            SVProgressHUD.showError(withStatus: "切羽位置を入力してください")
            print("強制終了")
            
            return
        }
        
        if distanceTextField.text == "" {
            
            SVProgressHUD.showError(withStatus: "\(self.distanceLabel.text!)を入力してください")
            print("強制終了")
            
            return
        }
        
        // 切羽観察項目の有無
        if self.kirihaRecordData?.obsRecordArray.firstIndex(of: nil) != nil {
            
            SVProgressHUD.showError(withStatus: "切羽観察記録の入力を確認してください")
            print("強制終了")
            
            return
        }
        
        // print("obs[2] \(self.kirihaRecordData?.obsRecordArray[2])")
        
        saveFile()
        
        self.performSegue(withIdentifier: "AnalysisSegue", sender: nil)
    }
    
    // 保存ボタンがタップされた時に実行
    @IBAction func saveButton(_ sender: Any) {
        
        if stationKTextField.text == "" || stationMTextField.text == "" {
            
            SVProgressHUD.showError(withStatus: "切羽位置を入力してください")
            print("強制終了")
            
            return
        }
        
        if distanceTextField.text == "" {
            
            SVProgressHUD.showError(withStatus: "\(self.distanceLabel.text!)を入力してください")
            print("強制終了")
            
            return
        }
        
        saveFile()
    }
    
    func saveFile() {

        // 測点を距離に換算する
        let stationNo = Float(stationKTextField.text!)! * 1000 + Float(stationMTextField.text!)!
        
        // 坑口からの距離
        // Float()はオプショナル型のFloat型に変換するので、アンラップしてFloat型に代入する
        let distance = Float(distanceTextField.text!)!
        
        if let tunnelId = self.kirihaRecordData?.tunnelId, let id = kirihaRecordData?.id {
            
            // 保存するデータを辞書の型にまとめる
            let kirihaRecordDic = [
                "date":FieldValue.serverTimestamp(),
                "stationNo": stationNo,
                "obsDate": obsDateTextField.text!,
                "rockType": rockTypeTextField.text!,
                "rockName": rockNameTextField.text!,
                "geoAge": geoAgeTextField.text!,
                "distance": distance
            ] as [String: Any]
            
            // 既存のDocumentIDの保存場所を取得
            let kirihaRecordDataRef = Firestore.firestore().collection(tunnelId).document(id)
            
            // データを更新する
            kirihaRecordDataRef.updateData(kirihaRecordDic)
            
            print("更新しました")
            
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
        else if segue.identifier == "AnalysisSegue" {
            
            let AnalysisVC = segue.destination as! AnalysisViewController
            
            AnalysisVC.kirihaRecordData = self.kirihaRecordData
        }
    }
    
    // 画面遷移前に実行され、画面が戻ってくるたびに実行される
    override func viewWillAppear(_ animated: Bool) {
        
        // Firestoreからデータの取得
        if let tunnelId = self.tunnelData?.tunnelId, let id = tunnelData?.id {
            
            print("KirihaSpecVC tunnelData tunnleId \(self.tunnelData?.tunnelId), id \(self.tunnelData?.id)")
            
            // 取得するドキュメントを設定
            let tunnelSpecDataRef = Firestore.firestore().collection("tunnelLists").document(id)
            
            // Firestoreのdocumentを取得する
            tunnelSpecDataRef.getDocument { (documentSnapshot, error) in
            
                if let error = error {
                    print("DEBUG_PRINT: documentSnapshotの取得に失敗しました。 \(error)")
                    return
                }
                
                guard let document = documentSnapshot else { return }
                
                let tunnelDataDS = TunnelDataDS(document: document)
                
                self.tunnelDataDS = tunnelDataDS
                
                // print("FirestoreDS tunnelName: \(tunnelDataDS.tunnelName)")
                
                //　データを取得できた場合にテキストフィールドに代入する
                // 岩石名
                if let rockName = self.tunnelDataDS?.rockName {
                    
                    // ドラムロールの設定
                    self.rockNameDataSource = rockName
                    
                    // 初期値の設定
                    // self.rockNameTextField.text = rockName[0]
                }
                
                // 形成地質年代
                if let geoAge = self.tunnelDataDS?.geoAge {
                    
                    // ドラムロールの設定
                    self.geoAgeDataSource = geoAge
                    
                    // 初期値の設定
                    // self.geoAgeTextField.text = geoAge[0]
                }
                
                // 坑口からの距離
                if let itemName = self.tunnelDataDS?.itemName {
                    
                    self.distanceLabel.text = itemName[0]
                }
            }
        }
        
        // Firestoreから切羽観察記録データの取得
        // tunnelIdとidのnilでない時（データの受け渡しに成功した場合）
        if let tunnelId = self.kirihaRecordData?.tunnelId, let id = self.kirihaRecordData?.id {
            
            print("KirihaSpecVC kirihaRecordData tunnleId \(tunnelId), id \(id)")
            
            // データを取得するドキュメントを設定
            let kirihaRecordDataRef = Firestore.firestore().collection(tunnelId).document(id)
            
            // Firestoreのdocumentを取得する
            kirihaRecordDataRef.getDocument { (documentSnapshot, error) in
                if let document = documentSnapshot, document.exists {
                    
                    if let error = error {
                        print("DEBUG_PRINT: documentSnapshotの取得に失敗しました。 \(error)")
                        return
                    }
                    
                    guard let document = documentSnapshot else { return }
                    
                    let kirihaRecordDataDS = KirihaRecordDataDS(document: document)
                    
                    self.kirihaRecordDataDS = kirihaRecordDataDS
                    
                    let dataArray:[Int?] = document.data()?["obsRecordArray"] as! [Int?]
                    self.dataArray2 = document.data()?["obsRecordArray"] as! [Int?]
                    
                    self.kirihaRecordData2?.obsRecordArray = dataArray
                    
                    // 自分で定義したクラス内の配列には、値を代入することができない
                    // print("obsRecordArray[0] : \(self.kirihaRecordData2?.obsRecordArray[0])")
                
                    // テキストフィールドに値を代入する
                    // 観察日
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy年MM月dd日"
                    
                    if let obsDate = kirihaRecordDataDS.obsDate {
                        
                        self.obsDateTextField.text! = formatter.string(from: obsDate)
                    }
                    else if let date = kirihaRecordDataDS.date {
                        
                        self.obsDateTextField.text! = formatter.string(from: date)
                    }
                    
                    // 切羽位置
                    if let stationNo = kirihaRecordDataDS.stationNo {
                        
                        // Any -> Floatにダウンキャスト（より具体的な型に変換する）
                        let d = stationNo
                        
                        let a = floor(d / 1000)
                        let b = d - a * 1000
                        let c: Int = Int(a)
                        
                        self.stationKTextField.text! = String(c)
                        self.stationMTextField.text! = String(b)
                    }
                    
                    // 坑口からの距離
                    if let distance = self.kirihaRecordDataDS?.distance {
                        
                        self.distanceTextField.text! = String(distance)
                    }
                    
                    // 岩種
                    if let rockType = kirihaRecordDataDS.rockType {
                        
                        self.rockTypeTextField.text! = rockType
                    }
                    else {
                        
                        self.rockTypeTextField.text! = self.rockTypeDataSource[0]
                    }
                    
                    // 岩石名
                    if let rockName = kirihaRecordDataDS.rockName {
                        
                        self.rockNameTextField.text! = rockName
                    }
                    else {
                        
                        // self.rockNameTextField.text! = self.rockNameDataSource[0]!
                    }
                    
                    // 形成地質年代
                    if let geoAge = kirihaRecordDataDS.geoAge {
                        
                        self.geoAgeTextField.text! = geoAge
                    }
                    else {
                        
                        // self.geoAgeTextField.text! = self.geoAgeDataSource[0]!
                    }
                    
                    // 地山等級
                    if let structurePattern = kirihaRecordDataDS.structurePattern {
                        
                        self.kirihaRecordData?.structurePattern = structurePattern
                    }
                    
                    // 切羽観察記録
                    self.kirihaRecordData?.obsRecordArray = kirihaRecordDataDS.obsRecordArray
                    
                    /*
                    if let obsRecordArray:[Int?] = kirihaRecordDataDS.obsRecordArray {
                        
                        self.kirihaRecordData?.obsRecordArray = obsRecordArray
                    }
                    */
                    
                    // 湧水量の取得
                    self.kirihaRecordData?.water = kirihaRecordDataDS.water
                    
                    print("KirihaSpec2VC water \(self.kirihaRecordData?.water)")

                }
                else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    
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
    
    // テキストフィールド以外をタップした時に実行される
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        SVProgressHUD.dismiss()
        
        self.view.endEditing(true)
    }
    
    
    
    

}
