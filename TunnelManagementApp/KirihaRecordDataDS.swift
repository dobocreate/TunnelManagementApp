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
    var id: String                      // documentID
    var date: Date?                     // 保存日時
    var tunnelId: String?               // トンネルID
    var obsDate: Date?                  // 観察日時
    var obsName: String?                // 観察者（displayName）
    var stationNo: Float?               // 観察測点
    var distance: Float?                // 坑口からの距離
    var overburden: Float?              // 土被り（m）
    var rockType: String?               // 岩種
    var rockName: String?               // 岩石名
    var geoAge: String?                 // 形成地質年代
    var geoStructure: String?           // 地質構造
    var obsRecordArray:[Float?] = []    // 切羽評価点
    var structurePattern: Int?          // 地山等級
    var patternRate:[Double?] = []      // 採用確率
    var water: Float?                   // 湧水量
    
    // 観察記録
    var obsRecord00:[Int?] = []      // 地質構造
    var obsRecord01:[Int?] = []      // 切羽の状態
    var obsRecord02:[Int?] = []      // 素掘面の状態
    var obsRecord03:[Int?] = []      // 圧縮強度
    var obsRecord04:[Int?] = []      // 風化変質
    var obsRecord05:[Int?] = []      // 破砕部の切羽に占める割合
    var obsRecord06:[Int?] = []      // 割れ目の頻度
    var obsRecord07:[Int?] = []      // 割れ目の状態
    var obsRecord08:[Int?] = []      // 割れ目の形態
    var obsRecord09:[Int?] = []      // 湧水
    var obsRecord10:[Int?] = []      // 水による劣化
    var obsRecord11:[Int?] = []      // 割れ目の方向性：縦断方向
    var obsRecord12:[Int?] = []      // 割れ目の方向性：横断方向
    
    var specialTextArray:[String?] = []   // 特記事項
    
    // 初期化メソッド
    init(document: DocumentSnapshot) {
        
        let kirihaRecordDic = document.data()
        
        let timestamp = kirihaRecordDic?["date"] as? Timestamp
        
        self.id = document.documentID
        
        self.date = timestamp?.dateValue()
        
        self.tunnelId = kirihaRecordDic?["tunnelId"] as? String
        
        let obstimestamp = kirihaRecordDic?["obsDate"] as? Timestamp
        
        self.obsDate = obstimestamp?.dateValue()
        
        //self.obsDate = kirihaRecordDic?["obsDate"] as? Date
        
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
        
        if let obsRecord = kirihaRecordDic?["obsRecordArray"] as? [Float?] {
            
            self.obsRecordArray = obsRecord
        }
        
        self.structurePattern = kirihaRecordDic?["structurePattern"] as? Int
        
        if let patternRate = kirihaRecordDic?["patternRate"] as? [Double] {
            
            self.patternRate = patternRate
        }
        
        self.water = kirihaRecordDic?["water"] as? Float
        
        // 観察記録
        if let obsRecord00 = kirihaRecordDic?["obsRecord00"] as? [Int?] {     // 地質構造
            
            self.obsRecord00 = obsRecord00
        }
        
        if let obsRecord01 = kirihaRecordDic?["obsRecord01"] as? [Int?] {     // 切羽の安定
            
            self.obsRecord01 = obsRecord01
        }
        
        if let obsRecord02 = kirihaRecordDic?["obsRecord02"] as? [Int?] {     // 素掘面の状態
            
            self.obsRecord02 = obsRecord02
        }
        
        if let obsRecord03 = kirihaRecordDic?["obsRecord03"] as? [Int?] {     // 圧縮強度
            
            self.obsRecord03 = obsRecord03
        }
        
        if let obsRecord04 = kirihaRecordDic?["obsRecord04"] as? [Int?] {     // 風化変質
            
            self.obsRecord04 = obsRecord04
        }
        
        if let obsRecord05 = kirihaRecordDic?["obsRecord05"] as? [Int?] {     // 破砕部の切羽に占める割合
            
            self.obsRecord05 = obsRecord05
        }
        
        if let obsRecord06 = kirihaRecordDic?["obsRecord06"] as? [Int?] {     // 割れ目の頻度
            
            self.obsRecord06 = obsRecord06
        }
        
        if let obsRecord07 = kirihaRecordDic?["obsRecord07"] as? [Int?] {     // 割れ目の状態
            
            self.obsRecord07 = obsRecord07
        }
        
        if let obsRecord08 = kirihaRecordDic?["obsRecord08"] as? [Int?] {     // 割れ目の形態
            
            self.obsRecord08 = obsRecord08
        }
        
        if let obsRecord09 = kirihaRecordDic?["obsRecord09"] as? [Int?] {     // 湧水：目視での量
            
            self.obsRecord09 = obsRecord09
        }
        
        if let obsRecord10 = kirihaRecordDic?["obsRecord10"] as? [Int?] {     // 水による劣化
            
            self.obsRecord10 = obsRecord10
        }
        
        if let obsRecord11 = kirihaRecordDic?["obsRecord11"] as? [Int?] {     // 割れ目の方向性：縦断方向
            
            self.obsRecord11 = obsRecord11
        }
        
        if let obsRecord12 = kirihaRecordDic?["obsRecord12"] as? [Int?] {     // 割れ目の方向性：横断方向
            
            self.obsRecord12 = obsRecord12
        }
        
        if let specialText = kirihaRecordDic?["specialTextArray"] as? [String?] {     // 特記事項
            
            self.specialTextArray = specialText
        }
    }
}
