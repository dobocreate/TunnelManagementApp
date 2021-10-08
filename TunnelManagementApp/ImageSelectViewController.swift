//
//  ImageSelectViewController.swift
//  TunnelManagementApp
//
//  Created by 岸田展明 on 2021/10/09.
//

import UIKit
import CLImageEditor

class ImageSelectViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLImageEditorDelegate {

    // ライブラリボタンをプッシュした時に実行される
    @IBAction func handleLibraryButton(_ sender: Any) {
        
        // ライブラリ（カメラロール）を指定してピッカーを開く
        // .isSourceTypeAvailable(_:)メソッドは、利用可能かどうか確認んするメソッド
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            
            let pickerController = UIImagePickerController()
            
            pickerController.delegate = self        // ここのselfは何を意味する？
            pickerController.sourceType = .photoLibrary
            
            self.present(pickerController, animated: true, completion: nil)
        }
    }
    
    // カメラボタンをプッシュした時に実行される
    @IBAction func handleCameraButton(_ sender: Any) {
        
        // カメラを指定してピッカーを開く
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            let pickerController = UIImagePickerController()
            
            pickerController.delegate = self
            pickerController.sourceType = .camera
            
            self.present(pickerController, animated: true, completion: nil)
        }
    }
    
    // キャンセルボタンをプッシュした時に実行される
    @IBAction func handleCancelButton(_ sender: Any) {
        
        // 画面を閉じる
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // 写真を撮影/選択した場合に実行される
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // info[.originalImage]で、選択/撮影した画像を取得する
        if info[.originalImage] != nil {
            
            // 撮影/選択された画像を取得する
            // info[.originalImage]をUIImage型として扱う
            let image = info[.originalImage] as! UIImage

            // あとでCLImageEditorライブラリで加工する
            print("DEBUG_PRINT: image = \(image)")
            
            // CLImageEditorにimageを渡して、加工画面を起動する。
            let editor = CLImageEditor(image: image)!
            
            editor.delegate = self
            
            editor.modalPresentationStyle = .fullScreen
            
            picker.present(editor, animated: true, completion: nil)
        }
    }
    
    // キャンセルされた場合に実行される
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // ImageSelectViewController画面を閉じてタブ画面に戻る
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    // CLImageEditorで加工が終わったときに呼ばれるメソッド
    func imageEditor(_ editor: CLImageEditor!, didFinishEditingWith image: UIImage!) {
        // 投稿画面を開く
        let postViewController = self.storyboard?.instantiateViewController(withIdentifier: "Post") as! PostViewController
        
        postViewController.image = image!
        
        editor.present(postViewController, animated: true, completion: nil)
    }
    
    // CLImageEditorの編集がキャンセルされた時に呼ばれるメソッド
    func imageEditorDidCancel(_ editor: CLImageEditor!) {
        // ImageSelectViewController画面を閉じてタブ画面に戻る
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
