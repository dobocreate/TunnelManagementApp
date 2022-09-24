//
//  KirihaPostTableViewCell.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2022/09/25.
//

import UIKit

class KirihaPostTableViewCell: UITableViewCell {

    
    @IBOutlet weak var stationLabel: UILabel!
    @IBOutlet weak var patternLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /*
    func setKirihaPostData(_ kirihaPostData: KirihaRecordData) {
        
        // 測点の表示
        self.stationLabel.text = "測点： \(kirihaPostData.stationNo)"
        
        
    }
    */
    
    
    
    
}
