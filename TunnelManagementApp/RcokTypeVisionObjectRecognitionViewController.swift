//
//  VisionObjectRecognitionViewController2.swift
//  BreakfastFinder
//
//  Created by 岸田展明 on 2022/02/01.
//  Copyright © 2022 Apple. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class RcokTypeVisionObjectRecognitionViewController: RockTypeViewController {

    
    private var detectionOverlay: CALayer! = nil    // オーバーレイ（CALayer型）を宣言する
    private var requests = [VNRequest]()            // Vision parts. リクエスト
    
    
    //====================
    // Vision
    //====================
    // Visionのセットアップ
    @discardableResult
    func setupVision() -> NSError? {
        
        // Setup Vision parts : Visionのセットアップ
        let error: NSError! = nil
        
        // モデルの読み込み
        //guard let modelURL = Bundle.main.url(forResource: "ObjectDetector", withExtension: "mlmodelc")
        guard let modelURL = Bundle.main.url(forResource: "rockTypeObjectDetector22.09.05", withExtension: "mlmodelc") else {
            return NSError(domain: "VisionObjectRecognitionViewController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model file is missing"])
        }
        do {
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            
            let objectRecognition = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
                DispatchQueue.main.async(execute: {
                    // perform all the UI updates on the main queue
                    if let results = request.results {
                        self.drawVisionRequestResults(results)
                    }
                })
            })
            self.requests = [objectRecognition]
        } catch let error as NSError {
            print("Model loading went wrong: \(error)")
        }
        return error
    }
    
    // リクエスト結果の表示
    func drawVisionRequestResults(_ results: [Any]) {
        
        // トランザクションの開始
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        // サブレイヤーの削除
        detectionOverlay.sublayers = nil // remove all the old recognized objects
        
        // サブレイヤーの追加
        for observation in results where observation is VNRecognizedObjectObservation {
            
            guard let objectObservation = observation as? VNRecognizedObjectObservation else {
                continue
            }
            
            let topLabelObservation = objectObservation.labels[0]       // Select only the label with the highest confidence. ラベルの追加
            
            let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(bufferSize.width), Int(bufferSize.height))   // 領域
            
            let shapeLayer = self.createRoundedRectLayerWithBounds(objectBounds)    // シェイプレイヤー
            
            // テキストレイヤー
            let textLayer = self.createTextSubLayerInBounds(objectBounds,
                                                            identifier: topLabelObservation.identifier,
                                                            confidence: topLabelObservation.confidence)
            
            shapeLayer.addSublayer(textLayer)
            detectionOverlay.addSublayer(shapeLayer)
        }
        self.updateLayerGeometry()
        
        // トランザクションの終了
        CATransaction.commit()
    }
    
    
    //====================
    // AVCaptureVideoDataOutputSampleBufferDelegate
    //====================
    // ビデオフレーム更新時に呼ばれる
    override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let exifOrientation = exifOrientationFromDeviceOrientation()
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientation, options: [:])
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
    
    
    //====================
    // ビデオキャプチャー
    //====================
    // ビデオキャプチャーのセットアップ
    override func setupAVCapture() {
        super.setupAVCapture()
        
        // setup Vision parts
        setupLayers()
        updateLayerGeometry()
        setupVision()
        
        // start the capture. ビデオキャプチャーの開始
        startCaptureSession()
    }
    
    // オーバーレイの生成
    func setupLayers() {
        detectionOverlay = CALayer() // container layer that has all the renderings of the observations
        detectionOverlay.name = "DetectionOverlay"
        detectionOverlay.bounds = CGRect(x: 0.0,
                                         y: 0.0,
                                         width: bufferSize.width,
                                         height: bufferSize.height)
        detectionOverlay.position = CGPoint(x: rootLayer.bounds.midX, y: rootLayer.bounds.midY)
        rootLayer.addSublayer(detectionOverlay)
    }
    
    // オーバーレイの配送の更新
    func updateLayerGeometry() {
        let bounds = rootLayer.bounds
        var scale: CGFloat
        
        let xScale: CGFloat = bounds.size.width / bufferSize.height
        let yScale: CGFloat = bounds.size.height / bufferSize.width
        
        scale = fmax(xScale, yScale)
        if scale.isInfinite {
            scale = 1.0
        }
        
        // トランザクションの開始
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        // rotate the layer into screen orientation and scale and mirror. オーバーレイの配置の更新（レイヤーを画面の向きに回転させ、拡大縮小やミラーリングを行う）
        detectionOverlay.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: scale, y: -scale))
        // center the layer
        detectionOverlay.position = CGPoint(x: bounds.midX, y: bounds.midY)
        
        CATransaction.commit()      // トランザクションのコミット
        
    }
    
    // テキストレイヤーの生成
    func createTextSubLayerInBounds(_ bounds: CGRect, identifier: String, confidence: VNConfidence) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.name = "Object Label"
        
        var rockLabel: String?
        
        if identifier == "Tuff_breccia" {
            // rockLabel = "フレベシ凝灰角礫岩"
            rockLabel = "凝灰角礫岩"
        }
        else if identifier == "Lava_Ab" {
            // rockLabel = "フレベシ自破砕溶岩"
            rockLabel = "自破砕溶岩"
        }
        else if identifier == "Chert" {
            rockLabel = "チャート"
        }
        else if identifier == "Chert_WR" {
            rockLabel = "チャート（風化）"
        }
        else if identifier == "Tuff" {
            rockLabel = "凝灰岩"
        }
        else if identifier == "Shale" {
            rockLabel = "頁岩"
        }
        
        // \nは、改行
        // let formattedString = NSMutableAttributedString(string: String(format: "\(identifier)\nConfidence:  %.2f", confidence))
        let formattedString = NSMutableAttributedString(string: String(format: "\(rockLabel!)\n信頼度：  %.2f", confidence))
        
        let largeFont = UIFont(name: "Helvetica", size: 12.0)!
        
        // formattedString.addAttributes([NSAttributedString.Key.font: largeFont], range: NSRange(location: 0, length: identifier.count))
        formattedString.addAttributes([NSAttributedString.Key.font: largeFont], range: NSRange(location: 0, length: rockLabel!.count))
        
        textLayer.string = formattedString
        textLayer.bounds = CGRect(x: 0, y: 0, width: bounds.size.height - 10, height: bounds.size.width - 10)
        textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        textLayer.shadowOpacity = 0.7
        textLayer.shadowOffset = CGSize(width: 2, height: 2)
        textLayer.foregroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.0, 0.0, 0.0, 1.0])
        textLayer.contentsScale = 2.0 // retina rendering
        // rotate the layer into screen orientation and scale and mirror
        textLayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: 1.0, y: -1.0))
        return textLayer
    }
    
    // シェイプレイヤーの生成
    func createRoundedRectLayerWithBounds(_ bounds: CGRect) -> CALayer {
        let shapeLayer = CALayer()
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        shapeLayer.name = "Found Object"
        shapeLayer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 0.2, 0.4])
        shapeLayer.cornerRadius = 7
        return shapeLayer
    }

}
