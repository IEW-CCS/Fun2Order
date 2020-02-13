//
//  ScanQRCodeViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/12/29.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ScanQRCodeViewController: UIViewController {
    @IBOutlet weak var viewPreview: UIView!
    @IBOutlet weak var labelMemberName: UILabel!
    var memberID: String = ""
    var memberUserName: String = ""
    var memberUserImage: UIImage = UIImage()
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.labelMemberName.text = ""
        
        configScanner()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.title = "掃描會員條碼"
        self.navigationController?.title = "掃描會員條碼"
        self.tabBarController?.title = "掃描會員條碼"
    }

    @IBAction func addToGroup(_ sender: UIButton) {
        let databaseRef = Database.database().reference()
        let profileDatabasePath = "USER_PROFILE/\(self.memberID)"
        
        databaseRef.child(profileDatabasePath).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                var tmpMemberInfo = GroupMember()
                let value = snapshot.value as? NSDictionary
                let userName = value?["userName"] as! String
                let photoUrl = value?["photoURL"] as! String
                self.memberUserName = userName
                print("userName = \(userName)")
                print("photoUrl = \(photoUrl)")
                tmpMemberInfo.memberID = self.memberID
                tmpMemberInfo.memberName = userName
                
                let storageRef = Storage.storage().reference()
                storageRef.child(photoUrl).getData(maxSize: 1 * 1024 * 1024, completion: { (data, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        DispatchQueue.main.async {
                            let httpAlert = alert(message: error.localizedDescription, title: "存取會員頭像錯誤")
                            self.present(httpAlert, animated : false, completion : nil)
                            return
                        }
                    }
                    
                    if data == nil {
                        print("Member image is nil !")
                        tmpMemberInfo.memberImage = UIImage(named: "Image_Default_Member.png")!
                    } else {
                        tmpMemberInfo.memberImage = UIImage(data: data!)!
                    }
                    
                    NotificationCenter.default.post(name: NSNotification.Name("AddMember"), object: tmpMemberInfo)
                    self.navigationController?.popViewController(animated: true)
                })
            } else {
                let memberAlert = alert(message: "不存在的會員條碼或條碼格式錯誤，請再重試一次", title: "條碼錯誤")
                self.present(memberAlert, animated : false, completion : nil)
                return
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func configScanner() {
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
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
                self.memberID = metadataObj.stringValue!
            }
        }
    }
}
