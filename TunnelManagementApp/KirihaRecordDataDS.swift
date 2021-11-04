//
//  KirihaRecordData3.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2021/10/18.
//

import Foundation
import Firebase

// Firestoreに保存するデータを格納するクラス
class KirihaRecordDataDS: NSObject {
    
    // プロパティ
    var id: String                  // documentID
    var date: Date?                 // 保存日時
    var tunnelId: String?           // トンネルID
    var obsDate: Date?              // 観察日時
    var obsName: String?            // 観察者（displayName）
    var stationNo: Float?           // 観察測点
    var distance: Float?            // 坑口からの距離
    var overburden: Float?          // 土被り（m）
    var rockType: String?           // 岩種
    var rockName: String?           // 岩石名
    var geoAge: String?             // 形成地質年代
    var geoStructure: String?       // 地質構造
    var obsRecordArray:[Int?] = []  // 観察記録
    var structurePattern: Int?      // 地山等級
    var patternRate:[Double?] = []   // 採用確率
    var water: Float?              // 湧水量
    
    // 初期化メソッド
    init(document: DocumentSnapshot) {
        
        let kirihaRecordDic = document.data()
        
        let timestamp = kirihaRecordDic?["date"] as? Timestamp
        
        self.id = document.documentID
        
        self.date = timestamp?.dateValue()
        
        self.tunnelId = kirihaRecordDic?["tunnelId"] as? String
        
        self.obsDate = kirihaRecordDic?["obsDate"] as? Date
        
        // 観察者名をアカウント作成時に設定した表示名にする
        if let displayName = Auth.auth().currentUser?.displayName {
            
            self.obsName = displayName
        }
        
        self.stationNo = kirihaRecordDic?["stationNo"] as? Float
        
        self.distance = kirihaRecordDic?["distance"] as? Float
        
        self.overburden = kirihaRecordDic?["overburden"] as? Float
        
        self.rockType = kirihaRecordDic?["rockType"] as? String
        
        self.rockName = kirihaRecordDic?["rockName"] as? String
        
        self.geoAge = kirihaRecordDic?["geoAge"] as? String
        
        self.geoStructure = kirihaRecordDic?["geoStructure"] as? String
        
        if let obsRecord = kirihaRecordDic?["obsRecordArray"] as? [Int?] {
            
            self.obsRecordArray = obsRecord
        }
        
        self.structurePattern = kirihaRecordDic?["structurePattern"] as? Int
        
        if let patternRate = kirihaRecordDic?["patternRate"] as? [Double] {
            
            self.patternRate = patternRate
        }
        
        self.water = kirihaRecordDic?["water"] as? Float
    }
}
