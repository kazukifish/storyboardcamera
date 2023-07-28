//
//  ViewController.swift
//  StoryBoardCamera
//
//  Created by 出田和毅 on 2023/07/28.
//

import UIKit
import AVFoundation

class ViewController: UIViewController,AVCaptureMetadataOutputObjectsDelegate {

    let captureSession = AVCaptureSession()
    var captureDevice: AVCaptureDevice?
    var previewLayer: AVCaptureVideoPreviewLayer?
    let metadataOutput = AVCaptureMetadataOutput()
    let backgroundQueue = DispatchQueue.global()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // カメラの設定
        setupCamera()
        // 画像出力の設定
        setupPreviewLayer()
        // Outputに関する設定
        captureSession.addOutput(metadataOutput)
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        // バックグラウンドでの実行
        backgroundQueue.async {
            self.startRunningCaptureSession()
            // デバッグ部分
            if self.captureSession.isRunning {
                print("runnnig")
            } else {
                print("not run")
            }
            //デバッグ部分
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopRunningCaptureSession()
    }
}
// メソッドの追加
extension ViewController {

    func setupCamera() {
        //Sessionに追加するメディアの品質を指定
        captureSession.sessionPreset = .photo
        //deviceの指定
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.back)
        let devices = deviceDiscoverySession.devices
        for device in devices {
            if device.position == .back {
                captureDevice = device
                //デバッグ部分
                print("find camera")
                print(device)
                //デバッグ部分
                break
            } else {
                print("device discovery error")
                continue
            }
        }
        //Inputの定義
        let deviceInput: AVCaptureDeviceInput
        do {
            deviceInput = try AVCaptureDeviceInput(device: captureDevice!)
            if captureSession.canAddInput(deviceInput) {
                captureSession.addInput(deviceInput)
            } else {
                print("addInput error")
                return
            }
        } catch {
            print("deviceInput error")
            return
        }
    }
    //カメラの画像の出力
    func setupPreviewLayer() {
        // 1. previewLayerにcaptureSesionを追加
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        // 2. 画面
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = view.layer.bounds
        // 3. Viewへの追加
        view.layer.addSublayer(previewLayer!)
    }
    // カメラ開始
    func startRunningCaptureSession() {
        captureSession.startRunning()
    }
    // カメラ停止
    func stopRunningCaptureSession() {
        captureSession.stopRunning()
        // プレビューレイヤーをビューの階層から取り除く
        previewLayer?.removeFromSuperlayer()
        // プレビューレイヤーを解放する
        previewLayer = nil
    }
}

// QRコードの読み取りに関する機能の拡張
extension ViewController {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // 既存のバウンディングボックスをすべて削除
        for subview in view.subviews {
            subview.removeFromSuperview()
        }

        // QRコードのバウンディングボックスを描画する処理
        for metadataObject in metadataObjects {
            guard let transformedObject = previewLayer?.transformedMetadataObject(for: metadataObject) else { continue }
            
            if let qrCodeObject = transformedObject as? AVMetadataMachineReadableCodeObject {
                // QRコードの位置情報を取得
                let qrCodeFrame = qrCodeObject.bounds
                
                // 緑色のバウンディングボックスを描画
                let boundingBoxView = UIView(frame: qrCodeFrame)
                boundingBoxView.layer.borderColor = UIColor.green.cgColor
                boundingBoxView.layer.borderWidth = 2.0
                boundingBoxView.backgroundColor = UIColor.clear
                view.addSubview(boundingBoxView)
            }
        }
    }
}

