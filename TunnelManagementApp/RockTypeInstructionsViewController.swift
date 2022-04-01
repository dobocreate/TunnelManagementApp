//
//  RockTypeInstructionsViewController.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2021/10/17.
//

import UIKit

class RockTypeInstructionsViewController: UIViewController {

    
    @IBOutlet weak var instructionsImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let createImage = UIImage(named: "rockTypeInstructions.png")

        instructionsImageView.image = createImage
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
