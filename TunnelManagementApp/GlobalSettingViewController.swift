//
//  TunnelSettingViewController.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2021/10/16.
//

import UIKit

class GlobalSettingViewController: UIViewController {

    // 観察者名の変更をタップされた時に実行
    @IBAction func obsNameButton(_ sender: Any) {
        
        // StoryboardでSegueを設定した場合には、以下のコードは不要
        // self.performSegue(withIdentifier: "obsNameChangeSegue", sender: nil)      // Segueを使用した画面遷移
        
        /*
        let ObsNameChangeVC = self.storyboard?.instantiateViewController(withIdentifier: "obsNameChange") as! ObsNameChangeViewController
        self.present(ObsNameChangeVC, animated: true, completion: nil)
        */
    }
    
    
    
    /*
    // 項目名の変更がタップされた時に実行
    @IBAction func itemButton(_ sender: Any) {
        
        // StoryboardでSegueを設定した場合には、以下のコードは不要
        // self.performSegue(withIdentifier: "itemNameChanegeSegue", sender: nil)      // Segueを使用した画面遷移
        
        /*
        let ItemNameChangeVC = self.storyboard?.instantiateViewController(withIdentifier: "itemNameChange") as! ItemNameChangeViewController
        self.navigationController?.pushViewController(ItemNameChangeVC, animated: true)     // プッシュ遷移
        // self.present(ItemNameChangeVC, animated: true, completion: nil)                  // モーダル遷移
        */
    }
    
    // 岩種名の設定がタップされた時に実行
    @IBAction func rockNameButton(_ sender: Any) {
        
        // StoryboardでSegueを設定した場合には、以下のコードは不要
        // self.performSegue(withIdentifier: "rockNameSettingSegue", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // 画面がとじられる前に実行される
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // 画面遷移時に値を渡すときはここで記載する
        if segue.identifier == "itemNameChanegeSegue" {
            
            print("prepare: itemNameChanegeSegue")
        }
        else if segue.identifier == "obsNameChangeSegue" {
            
            print("prepare: obsNameChangeSegue")
        }
        else if segue.identifier == "rockNameSettingSegue" {
            
            print("prepare: rockNameSettingSegue")
        }
    }
    */

}
