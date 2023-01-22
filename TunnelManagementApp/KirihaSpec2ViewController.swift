//
//  KirihaSpec2ViewController.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2021/11/04.
//

import UIKit
import Firebase
import SVProgressHUD
import SwiftUI

class KirihaSpec2ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {


    @IBOutlet weak var obsDateTextField: UITextField!       // 観察日
    @IBOutlet weak var rockTypeTextField: UITextField!      // 岩種

    @IBOutlet weak var rockName1TextField: UITextField!     // 岩石名１
    @IBOutlet weak var rockName2TextField: UITextField!     // 岩石名２
        
    @IBOutlet weak var stationKTextField: DoneTextFierd!    // 測点K
    @IBOutlet weak var stationMTextField: DoneTextFierd!    // 測点M
    
    @IBOutlet weak var distanceLabel: UILabel!              // 坑口からの距離
    @IBOutlet weak var distanceTextField: UITextField!      // 坑口からの距離
    
    @IBOutlet weak var overburdenTextField: UITextField!    // 土被り高さ
    
    // データ受け渡し用
    var tunnelData: TunnelData?                 // トンネルデータを格納する配列
    var kirihaRecordData: KirihaRecordData?     // 切羽観察記録データを格納する配列
    var id2: String?                            // 切羽観察記録データのid
    var rockListRow: Int?                       // 選択された岩石名の番号
    var rockNum: Int?                           // 岩石名１か２のどちらのケースか示す
    
    // var tunnelId2: String?                       // トンネルid
    
    var rockNameSet1: [String?] = ["", "", ""]            // 0: 地層名、1: 岩石名、2: 形成地質年代
    var rockNameSet2: [String?] = ["", "", ""]
    
    var kirihaRecordData2: KirihaRecordData?
    var dataArray2: [Float?] = []
    
    var tunnelDataDS: TunnelDataDS?                 // Firestoreデータの格納用
    var kirihaRecordDataDS: KirihaRecordDataDS?     // Firestoreデータの格納用
    
    // Firestoreから取得したデータを格納
    var obsRecordArray  = [Float?](repeating: nil, count:13)            // 切羽評価点を格納
    var waterValue: Float?
    var structurePattern: Int?
    
    var stationNo2: [Float?] = Array(repeating: nil, count: 2)
    
    // datePickerViewのプロパティ
    var obsDatePickerView: UIDatePicker = UIDatePicker()
    
    // PickerViewのプロパティ
    var rockTypePickerView: UIPickerView = UIPickerView()
    // var rockNamePickerView: UIPickerView = UIPickerView()
    // var geoAgePickerView: UIPickerView = UIPickerView()
    
    // 岩種の選択リスト
    let rockTypeDataSource: [String] = ["A","B","C","D","E","F","G　表土、崩積土、崖錐など"]
    
    // 岩種記号
    var rockTypeSymbol: String?
    
    // 岩石名の選択リスト（初期値）
    var rockNameDataSource: [String?] = []
//    var rockNameDataSource: [String?] = ["玄武岩", "石灰岩", "頁岩", "凝灰角礫岩", "安山岩", "安山岩・自破砕溶岩"]
    
    // 形成地質年代（初期値）
    var geoAgeDataSource: [String?] = []
//    var geoAgeDataSource: [String?] = ["新生代第四紀完新世", "新生代第四紀更新世", "新生代新第三紀鮮新世", "新生代新第三紀中新世", "新生代古第三紀漸新世", "新生代古第三紀始新世", "新生代古第三紀暁新世", "中生代白亜紀", "中生代ジュラ紀", "中生代三畳紀", "古生代二畳紀", "古生代石炭紀", "古生代デボン紀", "古生代シルリア紀", "古生代オルドビス紀", "古生代カンブリア紀", "先カンブリア代原生代", "先カンブリア代始生代"]
    
    // ダイアログのフラグ
    // var showAlert = false
    
    // 画面遷移が行われた時に１度だけ実行される
    override func viewDidLoad() {
        super.viewDidLoad()

        // 入力設定などの初期設定
        // rockTypePickerViewをキーボードにする設定
        rockTypePickerView.tag = 1
        rockTypePickerView.delegate = self
        
        rockTypeTextField.inputView = rockTypePickerView
        rockTypeTextField.delegate = self
        
        //rockName1TextField.minimumFontSize = 1
        //rockName1TextField.adjustsFontSizeToFitWidth = true
        
//        // rockNamePickerViewをキーボードにする設定
//        rockNamePickerView.tag = 2
//        rockNamePickerView.delegate = self
//
//        rockNameTextField.inputView = rockNamePickerView
//        rockNameTextField.delegate = self
//
//        // geoAgePickerViewをキーボードにする設定
//        geoAgePickerView.tag = 3
//        geoAgePickerView.delegate = self
//
//        geoAgeTextField.inputView = geoAgePickerView
//        geoAgeTextField.delegate = self
        
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
        if let id = tunnelData?.id {
            
            print("KirihaSpec2VC 1 tunnelData id \(String(describing: self.tunnelData?.id))")
            
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
                
//                //　データを取得できた場合にテキストフィールドに代入する
//                // 岩石名
//                if let rockName = self.tunnelDataDS?.rockName {
//
//                    // ドラムロールの設定
//                    self.rockNameDataSource = rockName
//
//                    // 初期値の設定
//                    // self.rockNameTextField.text = rockName[0]
//                }
//
//                // 形成地質年代
//                if let geoAge = self.tunnelDataDS?.geoAge {
//
//                    // ドラムロールの設定
//                    self.geoAgeDataSource = geoAge
//
//                    // 初期値の設定
//                    // self.geoAgeTextField.text = geoAge[0]
//                }
                
                // 坑口からの距離
                if let itemName = self.tunnelDataDS?.itemName {
                    
                    self.distanceLabel.text = itemName[0]
                }
            }
        }
        
        // Firestoreから切羽観察記録データの取得
        // tunnelIdとidのnilでない時（データの受け渡しに成功した場合）
        if let tunnelId = self.kirihaRecordData?.tunnelId, let id = self.kirihaRecordData?.id {
            
            print("KirihaSpec2VC tunnleId \(tunnelId), id \(id)")
            
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
                    // print("切羽位置：\(self.kirihaRecordDataDS?.stationNo2[0])")
                    
                    if self.kirihaRecordDataDS?.stationNo2.isEmpty == false {           // 測点が一度は設定され、配列が空でない場合
                        
                        let stationNo20 = self.kirihaRecordDataDS?.stationNo2[0]
                        let stationNo21 = self.kirihaRecordDataDS?.stationNo2[1]
                        
                        self.stationKTextField.text! = String(Int(stationNo20!))
                        self.stationMTextField.text! = String(stationNo21!)
                    }
                    else if let stationNo = self.kirihaRecordDataDS?.stationNo {        // 更新されておらず、測点の配列が空の場合
                        
                        // Any -> Floatにダウンキャスト（より具体的な型に変換する）
                        let d = stationNo
                        
                        // 有効数字（小数点以下2位を四捨五入）
                        let a = floor(d / 1000)
                        var b = d - a * 1000
                        b = round(b * 100)
                        b = b / 100
                        
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
                    
                    // 岩石名１
                    if self.rockNum == 1 {          // 岩石名１をタップして岩石名を選択されて戻ってきた場合
                        if let rockName = self.tunnelDataDS?.rockName, let layerName = self.tunnelDataDS?.layerName, let geoAge = self.tunnelDataDS?.geoAge {
                            
                            if let rockListRow = self.rockListRow {
                                
                                if self.rockListRow != nil {
                                    
                                    self.rockNameSet1[0] = layerName[rockListRow]!
                                    self.rockNameSet1[1] = rockName[rockListRow]!
                                    self.rockNameSet1[2] = geoAge[rockListRow]!
                                    
                                    self.rockName1TextField.text = layerName[rockListRow]!
                                        + " " + rockName[rockListRow]!
                                        + " (" + geoAge[rockListRow]! + ")"
                                }
                            }
                        }
                    } else if let rockNameSet1 = self.kirihaRecordDataDS?.rockNameSet1 {
                        // FirebaseにrockNameSet1が記録されている場合
                        
                        let rockNameStr = rockNameSet1[0]! + rockNameSet1[1]!
                                        + "(\(rockNameSet1[2]!))"
                        
                        self.rockName1TextField.text! = rockNameStr
                        
                        self.rockNameSet1 = rockNameSet1
                    }
                    else if let rockName = self.kirihaRecordDataDS?.rockName {
                        // Firebaseに古いデータしかない場合
                        
                        self.rockName1TextField.text! = rockName
                    }
                    
                    // 岩石名２
                    if self.rockNum == 2 {          // 岩石名２をタップして岩石名を選択されて戻ってきた場合
                        if let rockName = self.tunnelDataDS?.rockName, let layerName = self.tunnelDataDS?.layerName, let geoAge = self.tunnelDataDS?.geoAge {
                            
                            if let rockListRow = self.rockListRow {
                                
                                if self.rockListRow != nil {
                                    
                                    self.rockNameSet2[0] = layerName[rockListRow]!
                                    self.rockNameSet2[1] = rockName[rockListRow]!
                                    self.rockNameSet2[2] = geoAge[rockListRow]!
                                    
                                    self.rockName2TextField.text = layerName[rockListRow]!
                                        + " " + rockName[rockListRow]!
                                        + " (" + geoAge[rockListRow]! + ")"
                                }
                            }
                        }
                    } else if let rockNameSet2 = self.kirihaRecordDataDS?.rockNameSet2 {
                        // FirebaseにrockNameSet2が記録されている場合
                        
                        let rockNameStr = rockNameSet2[0]! + rockNameSet2[1]!
                                        + " (\(rockNameSet2[2]!))"
                        
                        self.rockName2TextField.text! = rockNameStr
                        
                        self.rockNameSet2 = rockNameSet2
                    }
                    
                    // 地山等級
                    if let structurePattern = self.kirihaRecordDataDS?.structurePattern {
                        
                        self.kirihaRecordData?.structurePattern = structurePattern
                        self.structurePattern = structurePattern
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
        } else {            // 諸元を新規作成する場合
            // 観察日
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy年MM月dd日"
            
            let date = Date()
            
            self.obsDateTextField.text! = formatter.string(from: date)
            
            print("Date: \(date)")
            
            // 岩石名１
            if self.rockNum == 1 {          // 岩石名１をタップして岩石名を選択されて戻ってきた場合
                if let rockName = self.tunnelDataDS?.rockName, let layerName = self.tunnelDataDS?.layerName, let geoAge = self.tunnelDataDS?.geoAge {
                    
                    if let rockListRow = self.rockListRow {
                        
                        if self.rockListRow != nil {
                            
                            self.rockNameSet1[0] = layerName[rockListRow]!
                            self.rockNameSet1[1] = rockName[rockListRow]!
                            self.rockNameSet1[2] = geoAge[rockListRow]!
                            
                            self.rockName1TextField.text = layerName[rockListRow]!
                                + " " + rockName[rockListRow]!
                                + " (" + geoAge[rockListRow]! + ")"
                        }
                    }
                }
            }
            print("rockNum: \(self.rockNum)")
            // 岩石名１　ここまで
            
            // 岩石名２
            if self.rockNum == 2 {          // 岩石名２をタップして岩石名を選択されて戻ってきた場合
                if let rockName = self.tunnelDataDS?.rockName, let layerName = self.tunnelDataDS?.layerName, let geoAge = self.tunnelDataDS?.geoAge {
                    
                    if let rockListRow = self.rockListRow {
                        
                        if self.rockListRow != nil {
                            
                            self.rockNameSet2[0] = layerName[rockListRow]!
                            self.rockNameSet2[1] = rockName[rockListRow]!
                            self.rockNameSet2[2] = geoAge[rockListRow]!
                            
                            self.rockName2TextField.text = layerName[rockListRow]!
                                + " " + rockName[rockListRow]!
                                + " (" + geoAge[rockListRow]! + ")"
                        }
                    }
                }
            }
            print("rockNum: \(self.rockNum)")
            // 岩石名２　ここまで
            
        }
        
        print("StructurePattern: \(String(describing: self.structurePattern))")
    }
    
    // 坑口からの距離の自動計算
    @IBAction func autoCalc_kirihaDistance(_ sender: Any) {
        
        // 切羽位置の入力漏れチェック
        if stationKTextField.text == "" || stationMTextField.text == "" {
            
            print("記載漏れチェック：切羽位置")
            
            // 記載漏れアラートを表示する処理
            let alert = UIAlertController(title: nil, message: "切羽位置を記載してください", preferredStyle: .alert)

            let alClose = UIAlertAction(title: "閉じる", style: .default, handler: {
                (action:UIAlertAction!) -> Void in

                // 閉じるボタンがプッシュされた際の処理内容をここに記載
                alert.dismiss(animated: true, completion: nil)          // アラートを閉じる
            })
            
            alert.addAction(alClose)
            
            self.present(alert, animated: true, completion: nil)

            // 秒後に自動で閉じる
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                
                // 秒後の処理内容をここに記載
                alert.dismiss(animated: true, completion: nil)          // アラートを閉じる
            }
            
            return
        }
        
        // 測点を距離に換算する
        let stationNo = Float(stationKTextField.text!)! * 1000 + Float(stationMTextField.text!)!
        
        // 開始測点の取得
        let stationNo1 = self.tunnelDataDS?.stationNo1
        
        var kirihaDistance = stationNo - Float(stationNo1!)
        
        self.distanceTextField.text! = String(kirihaDistance)
        
        print("autoCal_Distance: \(String(describing:kirihaDistance))")
        
    }
    
    
    // 切羽観察ボタンがタップされた時に実行
    @IBAction func kirihaRecordButton(_ sender: Any) {
        
        // 保存するか確認するアラートを出して、保存ボタンがタップされたら保存して遷移する
        let alert = UIAlertController(title: nil,
                                      message: "諸元の保存を行いますか？",
                                      preferredStyle: .alert)

        let alOk = UIAlertAction(title: "保存", style: .default, handler: {
            (action:UIAlertAction!) in
            
            // 未入力項目のチェック
            // 切羽位置
            if self.stationKTextField.text == "" || self.stationMTextField.text == "" {
                
                print("記載漏れチェック：切羽位置")
                
                // 記載漏れアラートを表示する処理
                let alert = UIAlertController(title: nil, message: "切羽位置を記載してください", preferredStyle: .alert)

                let alClose = UIAlertAction(title: "閉じる", style: .default, handler: {
                    (action:UIAlertAction!) -> Void in

                    // 閉じるボタンがプッシュされた際の処理内容をここに記載
                    alert.dismiss(animated: true, completion: nil)          // アラートを閉じる
                })
                
                alert.addAction(alClose)
                
                self.present(alert, animated: true, completion: nil)

                // 秒後に自動で閉じる
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    
                    // 秒後の処理内容をここに記載
                    alert.dismiss(animated: true, completion: nil)          // アラートを閉じる
                }
                
                return
            }
            
            // 坑口からの距離
            if self.distanceTextField.text == "" {
                
                print("記載漏れチェック：坑口からの距離")
                
                // 記載漏れアラートを表示する処理
                let alert = UIAlertController(title: nil, message: "坑口からの距離を記載してください", preferredStyle: .alert)

                let alClose = UIAlertAction(title: "閉じる", style: .default, handler: {
                    (action:UIAlertAction!) -> Void in

                    // 閉じるボタンがプッシュされた際の処理内容をここに記載
                    alert.dismiss(animated: true, completion: nil)          // アラートを閉じる
                })
                
                alert.addAction(alClose)
                
                self.present(alert, animated: true, completion: nil)

                // 秒後に自動で閉じる
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    
                    // 秒後の処理内容をここに記載
                    alert.dismiss(animated: true, completion: nil)          // アラートを閉じる
                }
                
                return
            }
            // 土被り高さ
            if self.overburdenTextField.text == "" {
                
                print("記載漏れチェック：土被り高さ")
                
                // 記載漏れアラートを表示する処理
                let alert = UIAlertController(title: nil, message: "土被り高さを記載してください", preferredStyle: .alert)

                let alClose = UIAlertAction(title: "閉じる", style: .default, handler: {
                    (action:UIAlertAction!) -> Void in

                    // 閉じるボタンがプッシュされた際の処理内容をここに記載
                    alert.dismiss(animated: true, completion: nil)          // アラートを閉じる
                })
                
                alert.addAction(alClose)
                
                self.present(alert, animated: true, completion: nil)

                // 秒後に自動で閉じる
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    
                    // 秒後の処理内容をここに記載
                    alert.dismiss(animated: true, completion: nil)          // アラートを閉じる
                }
                
                return
            }

            self.saveFile(3)
        })

        let alCancel = UIAlertAction(title: "キャンセル", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)

            self.performSegue(withIdentifier: "KirihaRecordChangeSegue", sender: nil)     // 切羽観察記録の画面に遷移
        }

        alert.addAction(alOk)
        alert.addAction(alCancel)

        present(alert, animated: true, completion: nil)
    }
    
    
    // 分析ボタンがタップされた時に実行
    @IBAction func analysisButton(_ sender: Any) {
        
        // 切羽観察項目の有無
        let checkZero = self.kirihaRecordDataDS?.obsRecordArray.firstIndex(of: 0)
        
        print("check nil: \(checkZero)")
        
        if checkZero == 0 {         // obsRecordArrayの要素内に、0がある場合
            
            print("記載漏れチェック：切羽観察記録")
            
            // 記載漏れアラートを表示する処理
            let alert = UIAlertController(title: nil, message: "切羽観察記録にチェック漏れがあります", preferredStyle: .alert)

            let alClose = UIAlertAction(title: "閉じる", style: .default, handler: {
                (action:UIAlertAction!) -> Void in

                // 閉じるボタンがプッシュされた際の処理内容をここに記載
                alert.dismiss(animated: true, completion: nil)          // アラートを閉じる
            })
            
            alert.addAction(alClose)
            
            self.present(alert, animated: true, completion: nil)

            // 秒後に自動で閉じる
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                
                // 秒後の処理内容をここに記載
                alert.dismiss(animated: true, completion: nil)          // アラートを閉じる
            }
            
            return
        }
        
        // 湧水量のチェック
        if self.waterValue == nil {         // obsRecordArrayの要素内に、0がある場合
            
            print("記載漏れチェック：湧水量")
            
            // 記載漏れアラートを表示する処理
            let alert = UIAlertController(title: nil, message: "湧水量が記載されていません", preferredStyle: .alert)

            let alClose = UIAlertAction(title: "閉じる", style: .default, handler: {
                (action:UIAlertAction!) -> Void in

                // 閉じるボタンがプッシュされた際の処理内容をここに記載
                alert.dismiss(animated: true, completion: nil)          // アラートを閉じる
            })
            
            alert.addAction(alClose)
            
            self.present(alert, animated: true, completion: nil)

            // 秒後に自動で閉じる
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                
                // 秒後の処理内容をここに記載
                alert.dismiss(animated: true, completion: nil)          // アラートを閉じる
            }
            
            return
        }
        
        self.saveFile(2)         // データの保存, 1：保存して前の画面に遷移、2：保存して分析画面に遷移
    }
    
    // 保存ボタンがタップされた時に実行
    @IBAction func saveButton(_ sender: Any) {
        
        // 未入力項目のチェック
        // 切羽位置
        if stationKTextField.text == "" || stationMTextField.text == "" {
            
            print("記載漏れチェック：切羽位置")
            
            // 記載漏れアラートを表示する処理
            let alert = UIAlertController(title: nil, message: "切羽位置を記載してください", preferredStyle: .alert)

            let alClose = UIAlertAction(title: "閉じる", style: .default, handler: {
                (action:UIAlertAction!) -> Void in

                // 閉じるボタンがプッシュされた際の処理内容をここに記載
                alert.dismiss(animated: true, completion: nil)          // アラートを閉じる
            })
            
            alert.addAction(alClose)
            
            self.present(alert, animated: true, completion: nil)

            // 秒後に自動で閉じる
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                
                // 秒後の処理内容をここに記載
                alert.dismiss(animated: true, completion: nil)          // アラートを閉じる
            }
            
            return
        }
        // 坑口からの距離
        if distanceTextField.text == "" {
            
            print("記載漏れチェック：坑口からの距離")
            
            // 記載漏れアラートを表示する処理
            let alert = UIAlertController(title: nil, message: "坑口からの距離を記載してください", preferredStyle: .alert)

            let alClose = UIAlertAction(title: "閉じる", style: .default, handler: {
                (action:UIAlertAction!) -> Void in

                // 閉じるボタンがプッシュされた際の処理内容をここに記載
                alert.dismiss(animated: true, completion: nil)          // アラートを閉じる
            })
            
            alert.addAction(alClose)
            
            self.present(alert, animated: true, completion: nil)

            // 秒後に自動で閉じる
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                
                // 秒後の処理内容をここに記載
                alert.dismiss(animated: true, completion: nil)          // アラートを閉じる
            }
            
            return
        }
        // 土被り高さ
        if overburdenTextField.text == "" {
            
            print("記載漏れチェック：土被り高さ")
            
            // 記載漏れアラートを表示する処理
            let alert = UIAlertController(title: nil, message: "土被り高さを記載してください", preferredStyle: .alert)

            let alClose = UIAlertAction(title: "閉じる", style: .default, handler: {
                (action:UIAlertAction!) -> Void in

                // 閉じるボタンがプッシュされた際の処理内容をここに記載
                alert.dismiss(animated: true, completion: nil)          // アラートを閉じる
            })
            
            alert.addAction(alClose)
            
            self.present(alert, animated: true, completion: nil)

            // 秒後に自動で閉じる
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                
                // 秒後の処理内容をここに記載
                alert.dismiss(animated: true, completion: nil)          // アラートを閉じる
            }
            
            return
        }
        
        // 要注意地山の該当チェック
        alert_cautionJiyama()
    }
    
    func alert_cautionJiyama() {
        
        let alert = UIAlertController(title: "注意が必要な地山",
                      message: "「新生代（古第三紀以降）の泥岩類の細流砕屑岩類、同時代の凝灰岩や凝灰角礫岩等の火山砕屑岩類」に該当します",
                      preferredStyle: .alert)
        //ここから追加
        let alClose = UIAlertAction(title: "閉じる", style: .default, handler: {
                        (action:UIAlertAction!) -> Void in

            // 閉じるボタンがプッシュされた際の処理内容をここに記載
            alert.dismiss(animated: true, completion: nil)          // アラートを閉じる
            // self.saveFile(1)          // データの保存, 1：保存して前の画面に遷移、2：保存して分析画面に遷移
        })
        
        // Type１の判定
        let cautionGeoAgeList:[String] = ["新生代第四紀完新世", "新生代第四紀更新世", "新生代新第三紀鮮新世", "新生代新第三紀中新世", "新生代古第三紀漸新世", "新生代古第三紀始新世", "新生代古第三紀暁新世"]
        
        let cautionRockNameList:[String] = ["泥岩", "凝灰岩", "凝灰角礫岩"]
        
        print("rockNameSet1: \(self.rockNameSet1)")

        // 岩石名１についてチェックする
        if self.rockNameSet1[0] != "" {

            if let type1Index1 = cautionGeoAgeList.firstIndex(of: rockNameSet1[2]!),
               let type1Index2 = cautionRockNameList.firstIndex(of: rockNameSet1[1]!) {

                print("type1 index1: \(String(describing:type1Index1)), index2: \(String(describing:type1Index2))")
                
                if type1Index1 != nil && type1Index2 != nil {

                    alert.addAction(alClose)
                    present(alert, animated: true, completion: nil)
                    
                    // 2.5秒後に自動で閉じる
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                       
                        // 秒後の処理内容をここに記載
                        alert.dismiss(animated: true, completion: nil)           // アラートを閉じる
                        self.saveFile(0)          // データの保存, 0：保存して遷移しない、1：保存して前の画面に遷移
                    }
                }
                else {
                    self.saveFile(0)          // データの保存, 1：保存して前の画面に遷移、2：保存して分析画面に遷移
                }
            }
        }
        // 岩石１ここまで
        
        // 岩石名２についてチェックする
        if self.rockNameSet2[0] != "" {

            if let type1Index1 = cautionGeoAgeList.firstIndex(of: rockNameSet2[2]!),
               let type1Index2 = cautionRockNameList.firstIndex(of: rockNameSet2[1]!) {

                print("type1 index1: \(String(describing:type1Index1)), index2: \(String(describing:type1Index2))")
                
                if type1Index1 != nil && type1Index2 != nil {

                    alert.addAction(alClose)
                    present(alert, animated: true, completion: nil)
                    
                    // 2.5秒後に自動で閉じる
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                       
                        // 秒後の処理内容をここに記載
                        alert.dismiss(animated: true, completion: nil)           // アラートを閉じる
                        self.saveFile(0)          // データの保存, 0：保存して遷移しない、1：保存して前の画面に遷移
                    }
                }
                else {
                    self.saveFile(0)          // データの保存, 1：保存して前の画面に遷移、2：保存して分析画面に遷移
                }
                
            }
        }
        // 岩石２ここまで
    }
    
    func saveFile(_ i:Int) {

        // 観察日を文字列から日付に変換する
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        
        let obsDate = dateFormatter.date(from: obsDateTextField.text!)
        
        print("obsDate : \(String(describing: obsDate))")
        
        // 測点を距離に換算する
        let stationNo = Float(stationKTextField.text!)! * 1000 + Float(stationMTextField.text!)!
        
        // 測点を配列に格納する
        self.stationNo2[0] = Float(stationKTextField.text!)
        self.stationNo2[1] = Float(stationMTextField.text!)
        
        // 坑口からの距離
        // Float()はオプショナル型のFloat型に変換するので、アンラップしてFloat型に代入する
        let distance = Float(distanceTextField.text!)!
        
        // 土被り高さ
        let overburden = Float(overburdenTextField.text!)!
        
        // tunnelIdの取得
        var tunnelid2: String? = nil
        
        if self.kirihaRecordData?.tunnelId != nil {
            tunnelid2 = self.kirihaRecordData?.tunnelId
        }
        else if self.tunnelData?.tunnelId != nil {
            
            tunnelid2 = self.tunnelData?.tunnelId
        }
    
        // idの取得
        var id2: String? = nil
        
        if self.kirihaRecordData?.id != nil {
            id2 = self.kirihaRecordData?.id
        }
        else if self.id2 != nil {
            
            id2 = self.id2
        }
        
        // Firebaseの操作
        if let tunnelId = tunnelid2, let id = id2 {
            // 既にIDが発行されており、データを更新する場合
            
            print("save tunnelId: \(tunnelId), id: \(id)")
            
            // 保存するデータを辞書の型にまとめる
            let kirihaRecordDic = [
                "date":FieldValue.serverTimestamp(),
                "stationNo": stationNo,
                "obsDate": obsDate,
                "rockType": rockTypeTextField.text!,
                "rockNameSet1": self.rockNameSet1,
                "rockNameSet2": self.rockNameSet2,
                "distance": distance,
                "overburden": overburden,
                "structurePattern":self.structurePattern,
                "stationNo2":self.stationNo2
            ] as [String: Any]
            
            // 既存のDocumentIDの保存場所を取得
            let kirihaRecordDataRef = Firestore.firestore().collection(tunnelId).document(id)
            
            // データを更新する
            kirihaRecordDataRef.updateData(kirihaRecordDic)
            
            print("更新しました")
            
            // 保存アラートを表示する処理
            let alert = UIAlertController(title: nil, message: "保存しました", preferredStyle: .alert)

            let alClose = UIAlertAction(title: "閉じる", style: .default, handler: {
                (action:UIAlertAction!) -> Void in

                // 閉じるボタンがプッシュされた際の処理内容をここに記載
                alert.dismiss(animated: true, completion: nil)                  // アラートを閉じる
                
            })
            
            alert.addAction(alClose)
            
            self.present(alert, animated: true, completion: nil)

            // 秒後に自動で閉じる
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                
                // 秒後の処理内容をここに記載
                alert.dismiss(animated: true, completion: nil)                  // アラートを閉じる
                
                if i == 1 {
                    self.navigationController?.popViewController(animated: true)        // 画面を閉じることで、１つ前の画面に戻る
                }
                else if i == 2 {
                    self.performSegue(withIdentifier: "AnalysisSegue", sender: nil)     // 分析画面に遷移
                }
                else if i == 3 {
                    self.performSegue(withIdentifier: "KirihaRecordChangeSegue", sender: nil)     // 切羽観察記録の画面に遷移
                }
            }
        }
    }
    
    
    @IBAction func rockName1TFAction(_ sender: Any) {
        
        self.rockNum = 1    // 岩石名１が選択されたことを示す
        
        print("KirihaSpec1VC TFA rockNum: \(self.rockNum)")
        
        self.performSegue(withIdentifier: "RockListSegue", sender: nil)     // 岩石名を選択する画面に遷移
        
        self.rockName1TextField.resignFirstResponder()          // キーボードを閉じる
    }
    
    
    @IBAction func rockName2TFAction(_ sender: Any) {
        
        self.rockNum = 2
        
        // 保存するか確認するアラートを出して、保存ボタンがタップされたら保存して遷移する
        let alert = UIAlertController(title: nil,
                                      message: "岩石名の選択 or クリア",
                                      preferredStyle: .alert)

        let alSelect = UIAlertAction(title: "選択", style: .default, handler: {
            (action:UIAlertAction!) in
            
            self.performSegue(withIdentifier: "RockListSegue", sender: nil)     // 岩石名を選択する画面に遷移
        })

        let alClear = UIAlertAction(title: "クリア", style: .default, handler: {
            (action: UIAlertAction!) in
            
            self.rockName2TextField.text = ""
            
            self.rockNameSet2 = ["", "", ""]
            
            // self.dismiss(animated: true, completion: nil)
        })


        alert.addAction(alSelect)
        alert.addAction(alClear)

        present(alert, animated: true, completion: nil)
        
        self.rockName2TextField.resignFirstResponder()          // キーボードを閉じる
    }
    
    
    
    // 画面遷移前に実行される
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // 画面遷移時に値を渡すときはここで記載する
        if segue.identifier == "KirihaRecordChangeSegue" {              // 切羽観察へ
            
            print("KirihaSpecVC prepare: KirihaRecordChangeSegue")
            
            let KirihaRecordChangeVC = segue.destination as! KirihaRecordChangeViewController
            
            // データの受け渡し
            KirihaRecordChangeVC.kirihaRecordData = self.kirihaRecordData
        }
        
        if segue.identifier == "AnalysisSegue" {                        // 分析へ
            
            print("KirihaSpecVC prepare: AnalysisSegue")
            
            let AnalysisVC = segue.destination as! AnalysisViewController
            
            // データの受け渡し
            AnalysisVC.obsRecordArray = self.obsRecordArray
            AnalysisVC.waterValue = self.waterValue
            AnalysisVC.rockType = self.rockTypeTextField.text
            AnalysisVC.rockType1Symbol = conv_rockName(self.rockName1TextField.text!)
            AnalysisVC.structurePattern = self.structurePattern
            
            AnalysisVC.tunnelData = self.tunnelData
            AnalysisVC.kirihaRecordData = self.kirihaRecordData
            
            // self.kirihaRecordData?.rockType = rockTypeTextField.text
            
            print("KirihaSpec2VC rockType:\(String(describing: self.kirihaRecordData?.rockType))")
        }
        
        if segue.identifier == "RockListSegue" {
            
            print("KirihaSpec1VC prepare: RockListSegue")
            
            // データの受け渡し
            let RockListVC = segue.destination as! RockListViewController
            
            RockListVC.tunnelDataDS = self.tunnelDataDS
            RockListVC.vcName = "KirihaSpec2VC"
            RockListVC.rockNum = self.rockNum
            
            print("KirihaSpec1VC prepare rockNum: \(self.rockNum)")
            
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
//        case 2:
//            return rockNameDataSource[row]
//        case 3:
//            return geoAgeDataSource[row]
        default:
            return "error"
        }
    }
    
    // PickerViewの行数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1:
            return rockTypeDataSource.count
//        case 2:
//            return rockNameDataSource.count
//        case 3:
//            return geoAgeDataSource.count
        default:
            return 0
        }
    }

    // 各選択肢が選ばれた時の操作
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 1:
            return rockTypeTextField.text = rockTypeDataSource[row]
//        case 2:
//            return rockNameTextField.text =  rockNameDataSource[row]
//        case 3:
//            return geoAgeTextField.text =  geoAgeDataSource[row]
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




