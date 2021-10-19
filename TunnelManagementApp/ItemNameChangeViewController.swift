//
//  ItemNameChangeViewController.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2021/10/16.
//

import UIKit
import Firebase

class ItemNameChangeViewController: UIViewController {

    
    @IBOutlet weak var itemName1TextField: UITextField!
    
    var tunnelSpecData: TunnelDataDS?       // データ受け取り用
    var tunnelDataDS: TunnelDataDS?         // Firestoreのデータ取得用
    
    var itemName: [String?] = []
    
    // 更新ボタンがタップされた時に実行される
    @IBAction func updateButton(_ sender: Any) {
        
        print("更新ボタンがプッシュされました")
        
        self.itemName[0] = self.itemName1TextField.text
        
        if let id = self.tunnelSpecData?.id {
            
            let tunnelDic = [
                "itemName": itemName
            ] as [String: Any]
            
            let tunnelListRef = Firestore.firestore().collection("tunnelLists").document(id)
            
            tunnelListRef.updateData(tunnelDic)
            
            print("変更を保存しました")
        }
        
        // テキストフィールド内を空にする
        // self.itemName1TextField.text = ""
        
        // キーボードを閉じる
        self.view.endEditing(true)
    }
    
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
                // 表示項目名
                if let itemName = self.tunnelDataDS?.itemName {
                    
                    self.itemName1TextField.text = itemName[0]
                }
                else {
                    self.itemName1TextField.text = self.itemName[0]
                }
            }
        }
    }
    
    // 画面が表示される前に呼び出されるメソッド
    // 画面遷移後に１度呼ばれ、他の画面に遷移して戻ってきた時にも呼ばれる
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 遷移時のデータ受け取りの確認
        print("ItemNameChangeVC id: \(self.tunnelSpecData?.id), tunnelId: \(self.tunnelSpecData?.tunnelId)")
        

        if let itemName = self.tunnelSpecData?.itemName {
            
            print("ItemNameChangeVC itemName: \(itemName)")
            
            self.itemName = itemName
        }
        else {
            
            self.itemName.append("坑口からの距離")
        }
    }
}
