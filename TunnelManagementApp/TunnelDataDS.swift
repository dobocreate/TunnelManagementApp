//
//  TunnelDataDS.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2021/10/19.
//

import UIKit
import Firebase

// Firestoreに保存したデータを格納するクラス
class TunnelDataDS: NSObject {
    
    // プロパティ
    var id: String
    var tunnelId: String?           // トンネルID
    var tunnelName: String?         // トンネル名
    var stationNo1: Float?          // 開始測点
    var stationNo2: Float?          // 完了測点
    var tunnelType: Int?            // 記録様式
    var date: Date?                 // 保存日時
    
    var layerName: [String?] = []   // 地層名
    var rockName: [String?] = []    // 岩石名
    var dispRockName:[String?] = [] // 判定に使用する岩石名
    var geoAge: [String?] = []      // 形成地質年代
    
    var itemName: [String?] = []    // 表示項目名（坑口からの距離）
    
    // 初期化メソッド
    init(document: DocumentSnapshot) {
        
        self.id = document.documentID
        
        // データを辞書形式で取り出す
        let tunnelDataDic = document.data()
        
        self.tunnelId = tunnelDataDic?["tunnelId"] as? String
        self.tunnelName = tunnelDataDic?["tunnelName"] as? String
        self.stationNo1 = tunnelDataDic?["stationNo1"] as? Float
        self.stationNo2 = tunnelDataDic?["stationNo2"] as? Float
        self.tunnelType = tunnelDataDic?["tunnelType"] as? Int
        
        let timestamp = tunnelDataDic?["date"] as? Timestamp
        self.date = timestamp?.dateValue()
        
        if let layerName = tunnelDataDic?["layerName"] as? [String] {
            
            self.layerName = layerName
        }
        
        if let rockName = tunnelDataDic?["rockName"] as? [String] {
            
            self.rockName = rockName
        }
        
        if let dispRockName = tunnelDataDic?["dispRockName"] as? [String] {
            
            self.dispRockName = dispRockName
        }
        
        if let geoAge = tunnelDataDic?["geoAge"] as? [String] {
            
            self.geoAge = geoAge
        }
        
        if let itemName = tunnelDataDic?["itemName"] as? [String] {
            
            self.itemName = itemName
        }
    }
}

