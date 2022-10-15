//
//  RockListViewController.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2022/10/14.
//

import UIKit

class RockListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    // データ受け渡し
    var tunnelDataDS: TunnelDataDS?
    var row: Int?
    var vcName: String!
    
    var layerName: [String?] = []
    var rockName: [String?] = []
    var geoAge: [String?] = []
    
    var rockNum: Int?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        // カスタムセルの登録
        let nib = UINib(nibName: "RockListTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
        if let layerName = tunnelDataDS?.layerName {
            
            self.layerName = layerName
        }
        
        if let rockName = tunnelDataDS?.rockName {
            
            self.rockName = rockName
        }
        
        if let geoAge = tunnelDataDS?.geoAge {
            
            self.geoAge = geoAge
        }
        
        print("RockListVC didLoad rockNum: \(self.rockNum)")
    }
    
    // デリゲートメソッド：データ数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return rockName.count
    }
    
    // デリゲートメソッド：セルの表示内容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RockListTableViewCell
        
        cell.layerNameLabel.text = layerName[indexPath.row]
        cell.rockNameLabel.text = rockName[indexPath.row]
        cell.geoAgeLabel.text = geoAge[indexPath.row]
        
        return cell
    }
    
    // セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("セルがタップされました")
        
        self.row = indexPath.row
        
        if vcName == "KirihaSpec1VC" {
            
            let nc = self.navigationController as! UINavigationController
            let KirihaSpec1VC = nc.viewControllers[nc.viewControllers.count - 2] as! KirihaSpec1ViewController
            
            KirihaSpec1VC.rockListRow = self.row
            KirihaSpec1VC.rockNum = self.rockNum
            
            print("遷移先vc: \(KirihaSpec1VC), row: \(self.row)")
            print("RockListVC 1 rockNum: \(self.rockNum)")
            
            self.navigationController?.popViewController(animated: true)
        }
        
    }

}
