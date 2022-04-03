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
    
    @IBOutlet weak var overburdenTextField: UITextField!    // 土被り高さ
    
    
    // データ受け渡し用
    var tunnelData: TunnelData?                 // トンネルデータを格納する配列
    var kirihaRecordData: KirihaRecordData?     // 切羽観察記録データを格納する配列
    
    var kirihaRecordData2: KirihaRecordData?
    var dataArray2: [Float?] = []
    
    var tunnelDataDS: TunnelDataDS?                 // Firestoreデータの格納用
    var kirihaRecordDataDS: KirihaRecordDataDS?     // Firestoreデータの格納用
    
    // Firestoreから取得したデータを格納
    var obsRecordArray  = [Float?](repeating: nil, count:13)            // 切羽評価点を格納
    var waterValue: Float?
    var structurePattern: String?
    
    // datePickerViewのプロパティ
    var obsDatePickerView: UIDatePicker = UIDatePicker()

    // PickerViewのプロパティ
    var rockTypePickerView: UIPickerView = UIPickerView()
    var rockNamePickerView: UIPickerView = UIPickerView()
    var geoAgePickerView: UIPickerView = UIPickerView()
    
    // 岩種の選択リスト
    let rockTypeDataSource: [String] = ["A","B","C","D","E","F","G　表土、崩積土、崖錐など"]
    
    // 岩種記号
    var rockTypeSymbol: String?
    
    // 岩石名の選択リスト（初期値）
    var rockNameDataSource: [String?] = ["玄武岩", "石灰岩", "頁岩", "凝灰角礫岩", "安山岩", "安山岩・自破砕溶岩"]
    
    // 形成地質年代（初期値）
    var geoAgeDataSource: [String?] = ["新生代第四紀完新世", "新生代第四紀更新世", "新生代新第三紀鮮新世", "新生代新第三紀中新世", "新生代古第三紀漸新世", "新生代古第三紀始新世", "新生代古第三紀暁新世", "中生代白亜紀", "中生代ジュラ紀", "中生代三畳紀", "古生代二畳紀", "古生代石炭紀", "古生代デボン紀", "古生代シルリア紀", "古生代オルドビス紀", "古生代カンブリア紀", "先カンブリア代原生代", "先カンブリア代始生代"]
    
    
    // 画面遷移が行われた時に１度だけ実行される
    override func viewDidLoad() {
        super.viewDidLoad()

        // 入力設定などの初期設定
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
    
    // 画面遷移前に実行され、画面が戻ってくるたびに実行される
    override func viewWillAppear(_ animated: Bool) {
        
        // Firestoreからデータの取得
        if let tunnelId = self.tunnelData?.tunnelId, let id = tunnelData?.id {
            
            print("KirihaSpecVC 1 tunnelData tunnleId \(self.tunnelData?.tunnelId), id \(self.tunnelData?.id)")
            
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
            
            print("KirihaSpecVC 2 kirihaRecordData tunnleId \(tunnelId), id \(id)")
            
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
                    
                    // Firestoreから取得したデータを格納する
                    // 切羽評価点
                    if let array = self.kirihaRecordDataDS?.obsRecordArray {
                        
                        self.obsRecordArray = array
                        
                        print("obsRecordArray: \(self.obsRecordArray)")
                    }
                    // 湧水量
                    if let w = self.kirihaRecordDataDS?.water {
                        
                        self.waterValue = w
                        
                        print("waterValue: \(String(describing: self.waterValue))")
                    }
                    
                    
                    /*
                    let dataArray:[Float?] = document.data()?["obsRecordArray"] as! [Float?]
                    
                    self.dataArray2 = document.data()?["obsRecordArray"] as! [Float?]
                    
                    self.kirihaRecordData2?.obsRecordArray = dataArray
                    */
                    
                    // 自分で定義したクラス内の配列には、値を代入することができない
                    // print("obsRecordArray[0] : \(self.kirihaRecordData2?.obsRecordArray[0])")
                
                    // テキストフィールドに値を代入する
                    // 観察日
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy年MM月dd日"
                    
                    print("obsDate: \(String(describing: kirihaRecordDataDS.obsDate))")
                    
                    if let obsDate = kirihaRecordDataDS.obsDate {
                        
                        self.obsDateTextField.text! = formatter.string(from: obsDate)
                        
                        print("obsDate input: \(obsDate)")
                    }
                    else if let date = kirihaRecordDataDS.date {
                        
                        self.obsDateTextField.text! = formatter.string(from: date)
                        
                        print("Date input")
                    }
                    
                    // 切羽位置
                    if let stationNo = self.kirihaRecordDataDS?.stationNo {
                        
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
                    
                    // 土被り高さ
                    if let overburden = self.kirihaRecordDataDS?.overburden {
                        
                        self.overburdenTextField.text! = String(overburden)
                    }
                    
                    // 岩種
                    if let rockType = self.kirihaRecordDataDS?.rockType {
                        
                        self.rockTypeTextField.text! = rockType
                    }
                    else {
                        self.rockTypeTextField.text! = self.rockTypeDataSource[0]
                    }
                    
                    // 岩石名
                    if let rockName = self.kirihaRecordDataDS?.rockName {
                        
                        self.rockNameTextField.text! = rockName
                    }
                    else {
                        self.rockNameTextField.text! = self.rockNameDataSource[0]!
                    }
                    
                    // 形成地質年代
                    if let geoAge = self.kirihaRecordDataDS?.geoAge {
                        
                        self.geoAgeTextField.text! = geoAge
                    }
                    else {
                        self.geoAgeTextField.text! = self.geoAgeDataSource[0]!
                    }
                    
                    // 地山等級
                    if let structurePattern = self.kirihaRecordDataDS?.structurePattern {
                        
                        self.kirihaRecordData?.structurePattern = structurePattern
                    }
                    
                    /*
                    // 切羽観察記録
                    self.kirihaRecordData?.obsRecordArray = kirihaRecordDataDS.obsRecordArray
                    
                    /*
                    if let obsRecordArray:[Int?] = kirihaRecordDataDS.obsRecordArray {
                        
                        self.kirihaRecordData?.obsRecordArray = obsRecordArray
                    }
                    */
                    
                    // 湧水量の取得
                    self.kirihaRecordData?.water = kirihaRecordDataDS.water
                    */
                    
                    print("KirihaSpec2VC water \(String(describing: self.waterValue))")
                }
                else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    
    // 分析ボタンがタップされた時に実行
    @IBAction func analysisButton(_ sender: Any) {
        
        
//        if stationKTextField.text == "" || stationMTextField.text == "" {
//
//            SVProgressHUD.showError(withStatus: "切羽位置を入力してください")
//            print("強制終了")
//
//            return
//        }
//
//        if distanceTextField.text == "" {
//
//            SVProgressHUD.showError(withStatus: "\(self.distanceLabel.text!)を入力してください")
//            print("強制終了")
//
//            return
//        }
        
        // 切羽観察項目の有無
        if self.kirihaRecordDataDS?.obsRecordArray.firstIndex(of: nil) != nil {
            
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
        
        // 未入力項目のチェック
        // 切羽位置
        if stationKTextField.text == "" || stationMTextField.text == "" {
            
            SVProgressHUD.showError(withStatus: "切羽位置を入力してください")
            print("強制終了")
            
            return
        }
        // 坑口からの距離
        if distanceTextField.text == "" {
            
            SVProgressHUD.showError(withStatus: "\(self.distanceLabel.text!)を入力してください")
            print("強制終了")
            
            return
        }
        // 土被り高さ
        if overburdenTextField.text == "" {
            
            SVProgressHUD.showError(withStatus: "土被り高さを入力してください")
            print("強制終了")
            
            return
        }
        
        saveFile()
    }
    
    func saveFile() {

        // 観察日を文字列から日付に変換する
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        
        let obsDate = dateFormatter.date(from: obsDateTextField.text!)
        
        print("obsDate : \(String(describing: obsDate))")
        
        // 測点を距離に換算する
        let stationNo = Float(stationKTextField.text!)! * 1000 + Float(stationMTextField.text!)!
        
        // 坑口からの距離
        // Float()はオプショナル型のFloat型に変換するので、アンラップしてFloat型に代入する
        let distance = Float(distanceTextField.text!)!
        
        // 土被り高さ
        let overburden = Float(overburdenTextField.text!)!
        
        if let tunnelId = self.kirihaRecordData?.tunnelId, let id = kirihaRecordData?.id {
            
            // 保存するデータを辞書の型にまとめる
            let kirihaRecordDic = [
                "date":FieldValue.serverTimestamp(),
                "stationNo": stationNo,
                "obsDate": obsDate,
                "rockType": rockTypeTextField.text!,
                "rockName": rockNameTextField.text!,
                "geoAge": geoAgeTextField.text!,
                "distance": distance,
                "overburden": overburden
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
        if segue.identifier == "kirihaRecordChangeSegue" {              // 切羽観察へ
            
            print("KirihaSpecVC prepare: kirihaRecordChangeSegue")
            
            let KirihaRecordChangeVC = segue.destination as! KirihaRecordChangeViewController
            
            KirihaRecordChangeVC.kirihaRecordData = self.kirihaRecordData
        }
        
        if segue.identifier == "AnalysisSegue" {                        // 分析へ
            
            print("KirihaSpecVC prepare: AnalysisSegue")
            
            let AnalysisVC = segue.destination as! AnalysisViewController
            
            AnalysisVC.obsRecordArray = self.obsRecordArray
            AnalysisVC.waterValue = self.waterValue
            AnalysisVC.rockType = self.rockTypeTextField.text
            AnalysisVC.rockTypeSymbol = conv_rockName(self.rockNameTextField.text!)
            
            // self.kirihaRecordData?.rockType = rockTypeTextField.text
            
            print("KirihaSpecVC rockType:\(String(describing: self.kirihaRecordData?.rockType))")
        }
    }
    
    // 岩石名を岩石記号に変換する関数
    func conv_rockName (_ name: String) -> String {
        
        var nameSymbol:String = "Ls"
        // var result: Int?
        
        let nameList:[[String]] = [["玄武岩", "石灰岩", "頁岩", "凝灰角礫岩", "安山岩", "安山岩・自破砕溶岩"], ["Ba", "Ls", "Sh", "Tb", "An", "An3Abl"]]
        
        print("nameList: \(nameList[0])")
        
        let firstIndex = nameList[0].firstIndex(of: name)
        
        print("firstIndex: \(String(describing: firstIndex))")
        
        if firstIndex != nil {
            nameSymbol = nameList[1][firstIndex!]
        }
        
        print("name: \(name), nameSymbol: \(nameSymbol)")
        
        return nameSymbol
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

        print("touchesBegan!")

        SVProgressHUD.dismiss()

        self.view.endEditing(true)
    }
}




