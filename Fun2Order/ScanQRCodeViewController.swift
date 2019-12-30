//
//  ScanQRCodeViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/12/29.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit
import AVFoundation

class ScanQRCodeViewController: UIViewController {
    @IBOutlet weak var viewPreview: UIView!
    @IBOutlet weak var labelMemberName: UILabel!
    
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.labelMemberName.text = ""
        
        configScanner()
    }
    
    @IBAction func addToGroup(_ sender: UIButton) {
        
    }
    
    func configScanner() {
        //let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
        //guard let captureDevice = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInDualCamera, for: AVMediaType.video, position: .back) else {
        //guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
        } catch {
            print(error.localizedDescription)
            return
        }
        
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(captureMetadataOutput)
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = [.qr, .ean8, .code39, .ean13, .pdf417]
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        //videoPreviewLayer?.frame = viewPreview.layer.frame
        videoPreviewLayer?.frame = viewPreview.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        captureSession.startRunning()
        
        self.qrCodeFrameView = UIView()

        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = CUSTOM_COLOR_LIGHT_ORANGE.cgColor
            qrCodeFrameView.layer.borderWidth = 2.5
            view.addSubview(qrCodeFrameView)
            view.bringSubviewToFront(qrCodeFrameView)
        }
    }

}

extension ScanQRCodeViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            self.labelMemberName.text = "No QR code is detected"
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject

        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.layer.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                self.labelMemberName.text = metadataObj.stringValue
            }
        }
    }
}
