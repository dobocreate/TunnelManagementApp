//
//  RemarksTableViewCell.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2021/10/07.
//

import UIKit

class RemarksTableViewCell: UITableViewCell {

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var remarksTextView: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // RemarksDataの内容をセルに表示
    func setRemaksData(_ remarksData: RemarksData) {
        
        titleLabel.text = remarksData.title
        remarksTextView.text = remarksData.remarksText
    }
    
    
    
}
