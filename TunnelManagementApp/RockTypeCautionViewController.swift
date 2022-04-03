//
//  RockTypeCautionViewController.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2022/04/01.
//

import UIKit

class RockTypeCautionViewController: UIViewController {

    @IBOutlet weak var cautionImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let createImage = UIImage(named: "cautionJiyama.png")

        cautionImageView.image = createImage
        
    }

}
