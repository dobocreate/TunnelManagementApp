//
//  RockListTableViewCell.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2022/10/14.
//

import UIKit

class RockListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var layerNameLabel: UILabel!
    @IBOutlet weak var rockNameLabel: UILabel!
    @IBOutlet weak var geoAgeLabel: UILabel!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
