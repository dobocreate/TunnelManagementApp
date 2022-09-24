//
//  KirihaPostData.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2022/09/25.
//

import UIKit
import Firebase

class KirihaPostData: NSObject {

    var id: String
    
    init(document: QueryDocumentSnapshot){
        
        self.id = document.documentID
        
    }
}
