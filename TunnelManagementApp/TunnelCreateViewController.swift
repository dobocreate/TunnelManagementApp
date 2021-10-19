//
//  tunnelCreateViewController.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2021/10/19.
//

import UIKit
import Firebase

class TunnelCreateViewController: UIViewController {

    @IBOutlet weak var tunnelIdTextField: UITextField!
    
    @IBOutlet weak var tunnelNameTextField: UITextField!
    
    @IBOutlet weak var stationKTextField: UITextField!
    @IBOutlet weak var stationMTextField: UITextField!
    
    @IBOutlet weak var stationK2TextField: UITextField!
    @IBOutlet weak var stationM2TextField: UITextField!
    
    @IBOutlet weak var tunnelTypeSegmentedControl2: UISegmentedControl!
    
    // 岩石名の初期設定値
    let rockName: [String?] = ["粘板岩", "砂岩", "礫岩", "チャート", "石灰岩", "花崗岩", "ひん岩", "安山岩", "流紋岩", "片岩", "千枚岩", "頁岩",
                    "玄武岩", "泥岩", "凝灰岩", "崖錐"]
    
    // 形成地質年代の初期設定値
    let geoAge: [String?] = [
        "新生代第四紀完新世", "新生代第四紀更新世", "新生代新第三紀鮮新世", "新生代新第三紀中新世", "新生代古第三紀漸新世", "新生代古第三紀始新世", "新生代古第三紀暁新世",
        "中生代白亜紀", "中生代ジュラ紀", "中生代三畳紀",
        "古生代二畳紀", "古生代石炭紀", "古生代デボン紀", "古生代シルリア紀", "古生代オルドビス紀", "古生代カンブリア紀",
        "先カンブリア代原生代", "先カンブリア代始生代"
    ]
    
    // 表示項目名の初期設定値
    let itemName: [String?] = ["坑口からの距離"]
    
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
    }
}
