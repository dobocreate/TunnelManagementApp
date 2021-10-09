//
//  PostRockViewController.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2021/10/09.
//

import UIKit

class PostRockViewController: UIViewController {
    
    var image: UIImage!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageChangeButton: UIButton!
    
    @IBOutlet weak var rockSelectButton: UIButton!
    @IBOutlet weak var rockNameLabel: UILabel!
    
    @IBOutlet weak var resultUploadButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    

    let rockNameList: [String] = ["花崗岩", "粘板岩", "砂岩"]
    
    var rockNameMenu: [UIAction] = []
    
    
    
    func addMenuToButton(){
        
        print("rockNameList:\(rockNameList.count)")
        
        for i in 0 ..< rockNameList.count {
            rockNameMenu.append(UIAction(title: rockNameList[i], image: nil) { (action) in
                
                self.rockNameLabel.text = self.rockNameList[i]
                
                print(self.rockNameLabel.text!)
            })
        }
        
        let menu = UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: rockNameMenu)
        
        rockSelectButton.menu = menu
        rockSelectButton.showsMenuAsPrimaryAction = true
    }
    

    @IBAction func rockSelectButton2(_ sender: UIButton) {
        
        print("rockNameList:\(rockNameList.count)")
        
        for i in 0 ..< rockNameList.count {
            rockNameMenu.append(UIAction(title: rockNameList[i], image: nil) { (action) in
                
                self.rockNameLabel.text = self.rockNameList[i]
                
                print(self.rockNameLabel.text!)
            })
        }
        
        let menu = UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: rockNameMenu)
        
        rockSelectButton.menu = menu
        rockSelectButton.showsMenuAsPrimaryAction = true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = image
        
        // addMenuToButton()
    }
}
