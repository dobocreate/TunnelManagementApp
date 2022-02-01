//
//  ViewController2.swift
//  BreakfastFinder
//
//  Created by 岸田展明 on 2022/02/01.
//  Copyright © 2022 Apple. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class RockTypeViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    // サブクラスで利用
    var bufferSize: CGSize = .zero      // バッファサイズ
    var rootLayer: CALayer! = nil       // ルートレイヤー
    
    // 参照
    @IBOutlet weak private var previewView: UIView!
    
    // ビデオキャプチャー
    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer! = nil
    private let videoDataOutput = AVCaptureVideoDataOutput()
    
    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // to be implemented in the subclass
    }
    
    //====================
    // ライフサイクル
    //====================
    // ビューロード時に呼ばれる
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ビデオキャプチャーのセットアップ
        setupAVCapture()
    }
    
    // メモリの警告を受け取った時に呼び出される
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //====================
    // ビデオキャプチャー
    //====================
    // ビデオキャプチャーのセットアップ
    func setupAVCapture() {
        
        // ビデオ入力の生成
        var deviceInput: AVCaptureDeviceInput!
        
        // Select a video device, make an input.
        let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
        do {
            deviceInput = try AVCaptureDeviceInput(device: videoDevice!)
        } catch {
            print("Could not create video device input: \(error). ビデオ入力の生成に失敗しました")
            return
        }
        
        // ビデオキャプチャーの設定開始
        session.beginConfiguration()
        
        // 画像解像度の設定(モデルの画像サイズに近いものを指定)
        session.sessionPreset = .vga640x480 // Model image size is smaller.
        
        // Add a video input. ビデオ入力の追加
        guard session.canAddInput(deviceInput) else {
            print("Could not add video device input to the session. ビデオ入力の追加に失敗しました")
            session.commitConfiguration()
            return
        }
        session.addInput(deviceInput)
        
        // ビデオ出力の追加
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
            // Add a video data output
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            print("Could not add video data output to the session. ビデオ出力の追加に失敗しました")
            session.commitConfiguration()
            return
        }
        
        // ビデオキャプチャーのコネクションの設定
        let captureConnection = videoDataOutput.connection(with: .video)
        // Always process the frames
        captureConnection?.isEnabled = true
        
        // バッファサイズの取得
        do {
            try  videoDevice!.lockForConfiguration()
            let dimensions = CMVideoFormatDescriptionGetDimensions((videoDevice?.activeFormat.formatDescription)!)
            bufferSize.width = CGFloat(dimensions.width)
            bufferSize.height = CGFloat(dimensions.height)
            videoDevice!.unlockForConfiguration()
        } catch {
            print(error)
        }
        
        // セッションの設定終了
        session.commitConfiguration()
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        // rootLayer = previewView.layer
        rootLayer = previewView.layer
        previewLayer.frame = rootLayer.bounds
        rootLayer.addSublayer(previewLayer)
    }
    
    // ビデオキャプチャーの開始
    func startCaptureSession() {
        session.startRunning()
    }
    
    // Clean up capture setup. ビデオキャプチャーの破棄
    func teardownAVCapture() {
        previewLayer.removeFromSuperlayer()
        previewLayer = nil
    }
    
    //====================
    // AVCaptureVideoDataOutputSampleBufferDelegate
    //====================
    // ビデオフレームの破棄時に呼ばれる
    func captureOutput(_ captureOutput: AVCaptureOutput, didDrop didDropSampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // print("frame dropped")
        // サブクラスで実装
    }

    
    //====================
    // ユーティリティ
    //====================
    // デバイス向きに応じたExifOrientationの取得
    public func exifOrientationFromDeviceOrientation() -> CGImagePropertyOrientation {
        let curDeviceOrientation = UIDevice.current.orientation
        let exifOrientation: CGImagePropertyOrientation
        
        switch curDeviceOrientation {
        case UIDeviceOrientation.portraitUpsideDown:  // Device oriented vertically, home button on the top
            exifOrientation = .left
        case UIDeviceOrientation.landscapeLeft:       // Device oriented horizontally, home button on the right
            exifOrientation = .upMirrored
        case UIDeviceOrientation.landscapeRight:      // Device oriented horizontally, home button on the left
            exifOrientation = .down
        case UIDeviceOrientation.portrait:            // Device oriented vertically, home button on the bottom
            exifOrientation = .up
        default:
            exifOrientation = .up
        }
        return exifOrientation
    }

}
