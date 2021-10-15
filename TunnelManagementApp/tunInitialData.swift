//
//  tunInitialData.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2021/10/15.
//

import UIKit
import Firebase

// Firestoreに保存したデータを格納するクラス
class tunInitialData: NSObject {
    
    // プロパティ
    var id: String
    var tunnelId: String?       // トンネルID
    var tunnelName: String?     // トンネル名
    var stationNo1: Float?      // 開始測点
    var stationNo2: Float?      // 完了測点
    var tunnelType: String?     // 記録様式
    var date: Date?             // 保存日時
    
    // 初期化メソッド
    init(document: QueryDocumentSnapshot) {
        
        self.id = document.documentID
        
        // データを辞書形式で取り出す
        let tunnelDataDic = document.data()
        
        self.tunnelId = tunnelDataDic["tunnelId"] as? String
        self.tunnelName = tunnelDataDic["tunnelName"] as? String
        self.stationNo1 = tunnelDataDic["stationNo1"] as? Float
        self.stationNo2 = tunnelDataDic["stationNo2"] as? Float
        self.tunnelType = tunnelDataDic["tunnelType"] as? String
        
        let timestamp = tunnelDataDic["date"] as? Timestamp
        
        self.date = timestamp?.dateValue()
    }
    
    
}


