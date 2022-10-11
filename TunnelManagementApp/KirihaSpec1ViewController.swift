//
//  KirihaSpec1ViewController.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2022/10/11.
//

import UIKit
import Firebase
import SVProgressHUD
import SwiftUI

class KirihaSpec1ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

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
    var id1: String?                            // 切羽観察記録データのid
//    var tunnelId1: String?                      // トンネルid
//    var date1: Date?                            // 日付
    
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
        if let id = tunnelData?.id {
            
            print("KirihaSpecVC 1 tunnelData id \(String(describing: self.tunnelData?.id))")
            
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
        
        // 観察日
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        
        let date = Date()
        
        self.obsDateTextField.text! = formatter.string(from: date)
        
        print("Date: \(date)")
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
        
        let type1Index1 = cautionGeoAgeList.firstIndex(of: self.geoAgeTextField.text!)
        let type1Index2 = cautionRockNameList.firstIndex(of: self.rockNameTextField.text!)

        print("type1 index1: \(String(describing:type1Index1)), index2: \(String(describing:type1Index2))")
        
        if type1Index1 != nil && type1Index2 != nil {

            alert.addAction(alClose)
            present(alert, animated: true, completion: nil)
            
            // 2.5秒後に自動で閉じる
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
               
                // 秒後の処理内容をここに記載
                alert.dismiss(animated: true, completion: nil)           // アラートを閉じる
                self.saveFile(1)          // データの保存, 1：保存して前の画面に遷移、2：保存して分析画面に遷移
            }
        }
        else {
            self.saveFile(1)          // データの保存, 1：保存して前の画面に遷移、2：保存して分析画面に遷移
        }
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
        
//        var tunnelId:String? = nil
//        var id:String? = nil
//
//        if self.kirihaRecordData != nil {
//
//            tunnelId = self.kirihaRecordData?.tunnelId
//            id = self.kirihaRecordData?.id
//        }

        // Firebaseの操作
        if let tunnelId = self.kirihaRecordData?.tunnelId, let id = self.kirihaRecordData?.id {
            // 既にIDが発行されており、データを更新する場合
            
            print("save tunnelId: \(tunnelId), id: \(id)")
            
            // 保存するデータを辞書の型にまとめる
            let kirihaRecordDic = [
                "date":FieldValue.serverTimestamp(),
                "stationNo": stationNo,
                "obsDate": obsDate,
                "rockType": rockTypeTextField.text!,
                "rockName": rockNameTextField.text!,
                "geoAge": geoAgeTextField.text!,
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
        } else {        // 新規でデータを保存する場合
            
            let obsName = Auth.auth().currentUser?.displayName
            
            if let tunnelId = self.tunnelData?.tunnelId {
                
                // 画像と投稿データの保存場所を定義する
                // 自動生成されたIDを持つドキュメントリファレンスを作成する
                // この段階でDocumentIDが自動生成される
                let postRef = Firestore.firestore().collection(tunnelId).document()
                
                print("kirihaRecordVC postRef: \(postRef.documentID)")
                
                // 保存するデータを辞書の型にまとめる
                let postDic = [
                    "id": postRef.documentID,
                    "date": FieldValue.serverTimestamp(),
                    "tunnelId": tunnelId,
                    "obsName": obsName!,
                    "stationNo": stationNo,
                    "obsDate": obsDate,
                    "rockType": rockTypeTextField.text!,
                    "rockName": rockNameTextField.text!,
                    "geoAge": geoAgeTextField.text!,
                    "distance": distance,
                    "overburden": overburden,
                    "structurePattern":self.structurePattern,
                    "stationNo2":self.stationNo2
                ] as [String: Any]
                
                postRef.setData(postDic)
                
                self.id1 = postRef.documentID               // データの受け渡し用
                
                // 保存アラートを表示する処理
                let alert = UIAlertController(title: nil, message: "保存しました", preferredStyle: .alert)
                
                let alClose = UIAlertAction(title: "閉じる", style: .default, handler: {
                    (action:UIAlertAction!) -> Void in
                    
                    // 閉じるボタンがプッシュされた際の処理内容をここに記載
                    alert.dismiss(animated: true, completion: nil)                  // アラートを閉じる
                    // self.performSegue(withIdentifier: "KirihaRecordSegue", sender: nil)     // 切羽観察記録の画面に遷移
                })
                
                alert.addAction(alClose)
                
                self.present(alert, animated: true, completion: nil)
                
                // ２秒後に自動で閉じる
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    
                    // 秒後の処理内容をここに記載

                    alert.dismiss(animated: true, completion: nil)                  // アラートを閉じる
                    self.performSegue(withIdentifier: "KirihaRecordSegue", sender: nil)     // 切羽観察記録の画面に遷移
                }
                
                print("新規保存しました")
            }
        }
        
    }
    
    // 画面遷移前に実行される
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // 画面遷移時に値を渡すときはここで記載する
        if segue.identifier == "KirihaRecordSegue" {              // 切羽観察へ
            
            print("KirihaSpecVC prepare: KirihaRecordSegue")
            
            // データの受け渡し
            let KirihaRecordVC = segue.destination as! KirihaRecordViewController
            
            KirihaRecordVC.tunnelData = self.tunnelData
            KirihaRecordVC.kirihaRecordData = self.kirihaRecordData
            KirihaRecordVC.id1 = self.id1
        }
        
        if segue.identifier == "AnalysisSegue" {                        // 分析へ
            
            print("KirihaSpecVC prepare: AnalysisSegue")
            
            // データの受け渡し
            let AnalysisVC = segue.destination as! AnalysisViewController
            
            AnalysisVC.obsRecordArray = self.obsRecordArray
            AnalysisVC.waterValue = self.waterValue
            AnalysisVC.rockType = self.rockTypeTextField.text
            AnalysisVC.rockTypeSymbol = conv_rockName(self.rockNameTextField.text!)
            AnalysisVC.structurePattern = self.structurePattern
            
            AnalysisVC.tunnelData = self.tunnelData
            AnalysisVC.kirihaRecordData = self.kirihaRecordData
            
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
