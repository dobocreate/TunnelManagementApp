//
//  RockNameSetting2ViewController.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2022/10/14.
//

import UIKit
import Firebase

class RockNameSetting2ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addRockNameTextField: UITextField!
    
    // var tunnelSpecData: TunnelDataDS?       // トンネルデータ受け渡し用
    var row: Int?                           // 岩石名配列の行番号
    
    var tunnelDataDS: TunnelDataDS?         // Firestoreのデータ取得用
    
    var layerName: [String?] = []       // 地層名
    var rockName: [String?] = []        // 岩石名
    var dispRockName:[String?] = []     // 判定に使用する岩石名
    var geoAge: [String?] = []          // 形成地質年代
    
    // 画面遷移時に１度だけ実行される
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 遷移時のデータ受け取りの確認
        print("RockNameSetting2VC id: \(self.tunnelDataDS?.id), tunnelId: \(self.tunnelDataDS?.tunnelId)")
        
        // デリゲートの指定。ここで、selfとはViewController
        // デリゲートを指定することで、データ数を返すメソッドなどが使えるようになると考える
        tableView.delegate = self
        tableView.dataSource = self
        
        // rockNameの出力確認
        if let rockName = self.tunnelDataDS?.rockName {
            
            print("rockName: \(rockName)")
        }
        
        // Firestoreからデータの取得
        // 取得するドキュメントを設定
        if let id = self.tunnelDataDS?.id {
            
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
                if let rockName = self.tunnelDataDS?.rockName {
                    
                    self.rockName = rockName
                }
                
                // 地層名
                if self.tunnelDataDS?.layerName.isEmpty != true {
                    
                    if let layerName = self.tunnelDataDS?.layerName {
                        
                        self.layerName = layerName
                    }
                } else {
                    
                    let layerName = Array<String>(repeating: "", count: self.rockName.count)
                    self.layerName = layerName
                    self.tunnelDataDS?.layerName = layerName
                }
                
                // 判定に使用する岩石名
                if self.tunnelDataDS?.dispRockName.isEmpty != true {
                    
                    if let dispRockName = self.tunnelDataDS?.dispRockName {
                        
                        self.dispRockName = dispRockName
                    }
                } else {
                    
                    let dispRockName = Array<String>(repeating: "", count: self.rockName.count)
                    self.dispRockName = dispRockName
                    self.tunnelDataDS?.dispRockName = dispRockName
                }
                
                // 形成地質年代
                if self.tunnelDataDS?.geoAge.isEmpty != true {
                    
                    if let geoAge = self.tunnelDataDS?.geoAge {
                        
                        self.geoAge = geoAge
                    }
                } else {
                    
                    let geoAge = Array<String>(repeating: "", count: self.rockName.count)
                    self.geoAge = geoAge
                    self.tunnelDataDS?.geoAge = geoAge
                }
                
                print(self.rockName.count)
                
                self.tableView.reloadData()         // tableViewを更新する
            }
        }
    }
    
    // 画面が表示される前に呼び出されるメソッド
    // 画面遷移後に１度呼ばれ、他の画面に遷移して戻ってきた時にも呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        
        //　データを取得できた場合にテキストフィールドに代入する
        // 岩石名
        if let rockName = self.tunnelDataDS?.rockName {
            
            self.rockName = rockName
        }
        
        // 地層名
        if self.tunnelDataDS?.layerName.isEmpty != true {
            
            if let layerName = self.tunnelDataDS?.layerName {
                
                self.layerName = layerName
            }
        } else {
            
            let layerName = Array<String>(repeating: "", count: self.rockName.count)
            self.layerName = layerName
            self.tunnelDataDS?.layerName = layerName
        }
        
        // 判定に使用する岩石名
        if self.tunnelDataDS?.dispRockName.isEmpty != true {
            
            if let dispRockName = self.tunnelDataDS?.dispRockName {
                
                self.dispRockName = dispRockName
            }
        } else {
            
            let dispRockName = Array<String>(repeating: "", count: self.rockName.count)
            self.dispRockName = dispRockName
            self.tunnelDataDS?.dispRockName = dispRockName
        }
        
        // 形成地質年代
        if self.tunnelDataDS?.geoAge.isEmpty != true {
            
            if let geoAge = self.tunnelDataDS?.geoAge {
                
                self.geoAge = geoAge
            }
        } else {
            
            let geoAge = Array<String>(repeating: "", count: self.rockName.count)
            self.geoAge = geoAge
            self.tunnelDataDS?.geoAge = geoAge
        }
        
        print(self.rockName.count)
        
        self.tableView.reloadData()         // tableViewを更新する
    }
    
    // 更新ボタンがタップされた時に実行される
    @IBAction func updateButton(_ sender: Any) {
        
        print("更新ボタンがプッシュされました")
    
        if let id = self.tunnelDataDS?.id {
            
            let tunnelDic = [
                "rockName": self.rockName
            ] as [String: Any]
            
            let tunnelListRef = Firestore.firestore().collection("tunnelLists").document(id)
            
            tunnelListRef.updateData(tunnelDic)
            
            // 保存アラートを表示する処理
            let alert = UIAlertController(title: nil, message: "保存しました", preferredStyle: .alert)

            let alClose = UIAlertAction(title: "閉じる", style: .default, handler: {
                (action:UIAlertAction!) -> Void in

                // 閉じるボタンがプッシュされた際の処理内容をここに記載
                alert.dismiss(animated: true, completion: nil)                  // アラートを閉じる
                // self.navigationController?.popViewController(animated: true)    // 画面を閉じることで、１つ前の画面に戻る
            })
            
            alert.addAction(alClose)
            
            self.present(alert, animated: true, completion: nil)

            // 1秒後に自動で閉じる
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                
                // 秒後の処理内容をここに記載
                alert.dismiss(animated: true, completion: nil)                  // アラートを閉じる
                //self.navigationController?.popViewController(animated: true)    // 画面を閉じることで、１つ前の画面に戻る
            }
            
            print("変更を保存しました")
            
        }
    }
    
    // 追加ボタンをタップされた時に実行される
    @IBAction func addButton(_ sender: Any) {
        
        self.rockName.append(addRockNameTextField.text)     // rockNameに追加する
        
        self.layerName.append("")       // 地層名に空の要素を追加する
        self.dispRockName.append("")    // 判定に使用する岩石名に空の要素を追加する
        self.geoAge.append("")          // 形成地質年代に空の要素を追加する
        
        // tableViewを更新する
        tableView.reloadData()
        
        // テキストフィールド内を空にする
        self.addRockNameTextField.text = ""
        
        // キーボードを閉じる
        self.view.endEditing(true)
    }
    
    // デリゲートメソッド：データ数を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print("tableView rockName.count: \(self.rockName.count)")
        
        return self.rockName.count
    }
    
    // デリゲートメソッド：セルの表示内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // 値を設定する
        cell.textLabel!.text = self.rockName[indexPath.row]

        return cell
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }

    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let removed = self.rockName.remove(at: indexPath.row)
            
            print("\(removed)が削除されました")
        }
        
        tableView.reloadData()
    }
    
    // セルをクリックしたときに実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("セルがタップされました。indexPath.row: \(indexPath.row)")
        
        self.row = indexPath.row
        
        // Segue IDを指定して画面遷移させる
        performSegue(withIdentifier: "rockNameEditSegue",sender: nil)
    }
    
    // 画面を閉じる前に実行される
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        self.tunnelDataDS?.layerName = self.layerName
        self.tunnelDataDS?.rockName = self.rockName
        self.tunnelDataDS?.dispRockName = self.dispRockName
        self.tunnelDataDS?.geoAge = self.geoAge
        
        if segue.identifier == "rockNameEditSegue" {
            
            let rockNameEditVC = segue.destination as! RockNameEditViewController
            
            if let tunnelDataDS = self.tunnelDataDS {
                
                rockNameEditVC.tunnelDataDS = tunnelDataDS
                rockNameEditVC.row = self.row
            }
        }
    }
    
    // テキストフィールド以外をタップした時に実行される
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
    }
    

}
