//
//  TunnelCreate2ViewController.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2021/11/04.
//

import UIKit
import Firebase

class TunnelCreate2ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var tunnelIdTextField: UITextField!          // トンネルID
    @IBOutlet weak var tunnelNameTextField: UITextField!        // トンネル名
    
    @IBOutlet weak var stationKTextField: UITextField!          // 始点位置 k
    @IBOutlet weak var stationMTextField: UITextField!          // 始点位置 m
    
    @IBOutlet weak var stationK2TextField: UITextField!         // 終点位置 k
    @IBOutlet weak var stationM2TextField: UITextField!         // 終点位置 m
    
    @IBOutlet weak var tunnelTypeSegmentedControl2: UISegmentedControl!         // 観察記録様式タイプ
    
    // 所在地
    @IBOutlet weak var prefecturesTextField: UITextField!       // 都道府県
    @IBOutlet weak var cityTextField: UITextField!              // 市町村
    @IBOutlet weak var address1TextField: UITextField!          // 住所１
    @IBOutlet weak var address2TextField: UITextField!          // 住所２
    
    // PickerViewのプロパティ
    var prefecturesPickerView: UIPickerView = UIPickerView()
    
    
    
    // 岩石名の初期設定値
    let rockName: [String?] = ["粘板岩", "砂岩", "礫岩", "チャート", "石灰岩", "花崗岩", "ひん岩", "安山岩", "流紋岩", "片岩", "千枚岩", "頁岩", "玄武岩", "泥岩", "凝灰岩", "崖錐"]
    
    // 形成地質年代の初期設定値
    let geoAge: [String?] = [
        "新生代第四紀完新世", "新生代第四紀更新世", "新生代新第三紀鮮新世", "新生代新第三紀中新世", "新生代古第三紀漸新世", "新生代古第三紀始新世", "新生代古第三紀暁新世", "中生代白亜紀", "中生代ジュラ紀", "中生代三畳紀", "古生代二畳紀", "古生代石炭紀", "古生代デボン紀", "古生代シルリア紀", "古生代オルドビス紀", "古生代カンブリア紀", "先カンブリア代原生代", "先カンブリア代始生代"
    ]
    
    // 表示項目名の初期設定値
    let itemName: [String?] = ["坑口からの距離"]
    
    // 都道府県リスト
    let prefecturesDataSource = ["北海道", "青森県", "岩手県", "宮城県", "秋田県", "山形県", "福島県", "茨城県", "栃木県", "群馬県", "埼玉県", "千葉県", "東京都", "神奈川県","新潟県", "富山県", "石川県", "福井県", "山梨県", "長野県", "岐阜県", "静岡県", "愛知県", "三重県", "滋賀県", "京都府", "大阪府", "兵庫県", "奈良県", "和歌山県", "鳥取県", "島根県", "岡山県", "広島県", "山口県", "徳島県", "香川県", "愛媛県", "高知県", "福岡県", "佐賀県", "長崎県", "熊本県", "大分県", "宮崎県", "鹿児島県", "沖縄県"]
    
    var tunnelType: Int = 2      // 様式タイプ名
    
    // 観察記録の様式タイプを選択する
    @IBAction func tunnelTypeSegmentedControl(_ sender: UISegmentedControl) {
        
        // 選択されたボタンのタイトルを取得する
        self.tunnelType = sender.selectedSegmentIndex
        
        print(sender.titleForSegment(at: sender.selectedSegmentIndex)!)
    }
    
    // テキストフィールド以外をタップした時に実行される
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
    }
    
    
    
    // 新規作成ボタンが押された時に実行される
    @IBAction func createButton(_ sender: Any) {
        
        print("Create Button Push!")
        
        // トンネルデータの保存場所
        let tunnelListRef = Firestore.firestore().collection(FirestorePathList.tunnelListPath).document()
        
        // stationNoの計算
        let stationNo1: Float?
        let stationNo2: Float?
        
        stationNo1 = Float(stationKTextField.text!)! * 1000 + Float(stationMTextField.text!)!
        stationNo2 = Float(stationK2TextField.text!)! * 1000 + Float(stationM2TextField.text!)!
        
        print("stationNo1 \(stationNo1!)")
        
        // 保存するデータを辞書に格納する
        let tunnelDic = [
            "id": tunnelListRef.documentID,
            "tunnelId": tunnelIdTextField.text!,
            "tunnelName": tunnelNameTextField.text!,
            "stationNo1": stationNo1!,
            "stationNo2": stationNo2!,
            "tunnelType": tunnelType,
            "date": FieldValue.serverTimestamp(),
            "rockName": rockName,
            "geoAge": geoAge,
            "itemName": itemName
        ] as [String: Any]
     
        // Firestoreにデータを保存
        tunnelListRef.setData(tunnelDic)
        
        // StoryboardIDを指定して画面遷移する
        let TunnelListViewController = self.storyboard?.instantiateViewController(withIdentifier: "tunnelList") as! TunnelListViewController
        
        navigationController?.pushViewController(TunnelListViewController, animated: true)      // プッシュ画面遷移
        // self.present(tunnelListViewController, animated: true, completion: nil)              // モーダル画面遷移
    }
    
    // 遷移してきた時に１度だけ実行される
    override func viewDidLoad() {
        super.viewDidLoad()

        // tunnelTypeの初期値の設定
        let tunnelTypeIndex = 2         // 様式A：0、様式B：1、様式C：2
        tunnelTypeSegmentedControl2.selectedSegmentIndex = tunnelTypeIndex
        
        print("tunnelType: \(tunnelTypeIndex)")
        // self.tunnelType = tunnelTypeSegmentedControl2.titleForSegment(at: tunnelTypeIndex)
        
        // PickerViewをキーボードに設定
        prefecturesPickerView.tag = 1
        prefecturesPickerView.delegate = self
        
        self.prefecturesTextField.inputView = prefecturesPickerView
        self.prefecturesTextField.delegate = self
    }
    
    // PickerViewの列数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // PickerViewに表示する内容
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 1:
            return self.prefecturesDataSource[row]
        default:
            return "error"
        }
    }
    
    // PickerViewの行数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1:
            return prefecturesDataSource.count
        default:
            return 0
        }
    }
    
    // 各選択肢が選ばれた時の操作
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 1:
            return prefecturesTextField.text = prefecturesDataSource[row]
        default:
            return
        }
    }


}
