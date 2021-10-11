//
//  PostRockViewController.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2021/10/09.
//

import UIKit
import Firebase
import SVProgressHUD

class PostRockViewController: UIViewController {
    
    var image: UIImage!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageChangeButton: UIButton!
    
    @IBOutlet weak var rockSelectButton2: UIButton!
    @IBOutlet weak var rockNameLabel: UILabel!
    
    // 結果の送信ボタンがプッシュされたら実行される
    @IBAction func resultUploadButton(_ sender: Any) {
        
        // 画像をJPEG形式に変換する
        let imageData = image.jpegData(compressionQuality: 0.75)    // 圧縮率２５％
        
        // 画像と投稿データの保存場所を定義する
        let postRef = Firestore.firestore().collection(Const.PostPath).document()
        
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postRef.documentID + ".jpg")
        
        // HUDで投稿処理中の表示を開始
        SVProgressHUD.show()
        
        // Storageに画像をアップロードする
        let metadata = StorageMetadata()
        
        metadata.contentType = "image/jpeg"
        
        imageRef.putData(imageData!, metadata: metadata) { (metadata, error) in
            if error != nil {
                
                // 画像のアップロード失敗
                print(error!)
                
                SVProgressHUD.showError(withStatus: "画像のアップロードが失敗しました")
                
                // 投稿処理をキャンセルし、先頭画面に戻る
                UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
                
                return
            }
            
            // FireStoreに投稿データを保存する
            let name = Auth.auth().currentUser?.displayName
            
            let postDic = [
                "name": name!,
                "caption": self.rockNameLabel.text!,
                "date": FieldValue.serverTimestamp(),
                ] as [String : Any]
            
            postRef.setData(postDic)
            
            // HUDで投稿完了を表示する
            SVProgressHUD.showSuccess(withStatus: "投稿しました")
            
            // 投稿処理が完了したので先頭画面に戻る
           UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    // キャンセルボタンをプッシュされたら実行される
    @IBAction func cancelButton(_ sender: Any) {
        
        // 画面を閉じる
        //self.dismiss(animated: true, completion: nil)
        UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    let rockNameList: [String] = ["花崗岩", "粘板岩", "砂岩"]
    
    var rockNameMenu: [UIAction] = []
    
    // 岩種選定リストの設定
    func addRockNameMenu() -> UIMenu{
        
        for i in 0 ..< rockNameList.count {
            rockNameMenu.append(UIAction(title: rockNameList[i], image: nil) { (action) in
                
                self.rockNameLabel.text = self.rockNameList[i]
                
                print(self.rockNameLabel.text!)
            })
        }
        
        let menu = UIMenu(title: "岩種の選定リスト", image: nil, identifier: nil, options: .displayInline, children: rockNameMenu)
    
        return menu
    }

    // 修正ボタンがプッシュされた時の処理
    @IBAction func rockSelectButton(_ sender: UIButton) {
        
        /*
        rockNameMenu.append(UIAction(title: "test", image: nil) { (action) in
            
            self.rockNameLabel.text = "test"
            
            print("test")
        })
        */
    }
    
    
    
    // 画面が表示された後に、１度だけ実行される。
    // 他の画面から戻ってきても実行されない。
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = image
    }
    
    // 画面が表示された後に、毎回実行される
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 修正ボタンがプッシュされた時のメニュー
        print("rockNameList:\(rockNameList.count)")
        
        let menu = addRockNameMenu()
        
        rockSelectButton2.menu = menu
        rockSelectButton2.showsMenuAsPrimaryAction = true
    }
}
