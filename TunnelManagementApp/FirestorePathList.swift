//
//  FirestorePathList.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2021/10/15.
//

import Foundation

struct FirestorePathList{
    
    static let tunnelListPath = "tunnelLists"       // Firestore内のトンネルリストの保存場所
    static let oshimaPath = "oshima"                // 渡島トンネルの観察記録の保存場所
    static let uchiuraPath = "uchiura"              // 内浦トンネルの観察記録の保存場所
    static let ImagePath = "kirihaImages"           // 切羽写真の保存場所
}
