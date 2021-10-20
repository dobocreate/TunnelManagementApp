//
//  geoAgeSettingViewController.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2021/10/20.
//

import UIKit
import Firebase

class GeoAgeSettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addGeoAgeTextField: DoneTextFierd!
    
    
    var tunnelSpecData: TunnelDataDS?       // トンネルデータ受け渡し用
    
    var tunnelDataDS: TunnelDataDS?         // Firestoreのデータ取得用
    
    var geoAge: [String?] = []                // 岩石名格納用
    
    // 更新ボタンがタップされた時に実行される
    @IBAction func updateButton(_ sender: Any) {
        
        print("更新ボタンがプッシュされました")
    
        if let id = self.tunnelSpecData?.id {
            
            let tunnelDic = [
                "geoAge": self.geoAge
            ] as [String: Any]
            
            let tunnelListRef = Firestore.firestore().collection("tunnelLists").document(id)
            
            tunnelListRef.updateData(tunnelDic)
            
            print("変更を保存しました")
            
        }
    }
    
    
    // 追加ボタンをタップされた時に実行される
    @IBAction func addButton(_ sender: Any) {
        
        // rockNameに追加する
        self.geoAge.append(addGeoAgeTextField.text)
        
        // tableViewを更新する
        tableView.reloadData()
        
        // テキストフィールド内を空にする
        self.addGeoAgeTextField.text = ""
        
        // キーボードを閉じる
        self.view.endEditing(true)
    }
    
    // 画面遷移時に１度だけ実行される
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 遷移時のデータ受け取りの確認
        print("RockNameChangeVC id: \(self.tunnelSpecData?.id), tunnelId: \(self.tunnelSpecData?.tunnelId)")
        
        // デリゲートの指定。ここで、selfとはViewController
        // デリゲートを指定することで、データ数を返すメソッドなどが使えるようになると考える
        tableView.delegate = self
        tableView.dataSource = self
        
        // rockNameの出力確認
        if let geoAge = self.tunnelSpecData?.geoAge {
            
            print("geoAge: \(geoAge)")
        }
    }
    
    // 画面が表示される前に呼び出されるメソッド
    // 画面遷移後に１度呼ばれ、他の画面に遷移して戻ってきた時にも呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        
        // Firestoreからデータの取得
        if let tunnelId = self.tunnelSpecData?.tunnelId, let id = tunnelSpecData?.id {
            
            // 取得するドキュメントを設定
            let tunnelSpecDataRef = Firestore.firestore().collection("tunnelLists").document(id)
            
            // Firestoreのdocumentを取得する
            tunnelSpecDataRef.getDocument {(documentSnapshot, error) in
            
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
                if let geoAge = self.tunnelDataDS?.geoAge {
                    
                    self.geoAge = geoAge
                }
                
                print(self.geoAge.count)
                self.tableView.reloadData()
            }
        }
    }
    
    // デリゲートメソッド：データ数を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print("tableView rockName.count: \(self.geoAge.count)")
        
        return self.geoAge.count
    }
    
    // デリゲートメソッド：セルの表示内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // 値を設定する
        cell.textLabel!.text = self.geoAge[indexPath.row]

        return cell
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }

    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let removed = self.geoAge.remove(at: indexPath.row)
            
            print("\(removed)が削除されました")
        }
        
        tableView.reloadData()
    }
    
    // テキストフィールド以外をタップした時に実行される
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
    }

}
