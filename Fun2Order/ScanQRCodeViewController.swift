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

protocol ScanQRCodeDelegate: class {
    func getQRCodeMemberInfo(sender: ScanQRCodeViewController, member_id: String, member_name: String)
}

class ScanQRCodeViewController: UIViewController {
    @IBOutlet weak var viewPreview: UIView!
    
    var memberID: String = ""
    var memberUserName: String = ""
    var memberUserImage: UIImage = UIImage()
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    weak var delegate: ScanQRCodeDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        configScanner()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.title = "掃描好友條碼"
        self.navigationController?.title = "掃描好友條碼"
        self.tabBarController?.title = "掃描好友條碼"
    }
    
    @IBAction func readQRCodeFromAlbum(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            imagePicker.delegate = self
            
            self.show(imagePicker, sender: self)
        }

    }
    
    func displayUserID(user_id: String) {
        let controller = UIAlertController(title: "掃描內容", message: nil, preferredStyle: .alert)

        guard let addFriendController = self.storyboard?.instantiateViewController(withIdentifier: "ADD_FRIEND_VC") as? AddFriendViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: ADD_FRIEND_VC can't find!! (QRCodeViewController)")
            return
        }

        controller.setValue(addFriendController, forKey: "contentViewController")
        addFriendController.preferredContentSize.height = 120
        controller.preferredContentSize.height = 120
        controller.addChild(addFriendController)
        addFriendController.setData(user_id: user_id)
        addFriendController.delegate = self
        
        present(controller, animated: true, completion: nil)

    }
    
    func checkUserProfile() {
        let databaseRef = Database.database().reference()
        let profileDatabasePath = "USER_PROFILE/\(self.memberID)"
        
        databaseRef.child(profileDatabasePath).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let value = snapshot.value as? NSDictionary
                let userName = value?["userName"] as! String
                self.memberUserName = userName
                
                self.delegate?.getQRCodeMemberInfo(sender: self, member_id: self.memberID, member_name: userName)
                self.navigationController?.popViewController(animated: true)
                self.dismiss(animated: false, completion: nil)
            } else {
                presentSimpleAlertMessage(title: "錯誤訊息", message: "不存在的會員條碼或條碼格式錯誤，請再重試一次")
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
            //self.labelMemberName.text = "No QR code is detected"
            return
        }

        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject

        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.layer.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                //self.labelMemberName.text = metadataObj.stringValue
                self.memberID = metadataObj.stringValue!
                self.displayUserID(user_id: self.memberID)
            }
        }
    }
}

extension ScanQRCodeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        dismiss(animated: true, completion: nil)

        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])!
        let ciImage = CIImage(image: image)

        let features = detector.features(in: ciImage!) as? [CIQRCodeFeature]
        
        if features == nil || features!.count == 0 {
            presentSimpleAlertMessage(title: "錯誤訊息", message: "無法辨識出任何ID，請再重選其他照片")
            return
        }

        for feature in features! {
            print("messageString = \(feature.messageString ?? "")")
        }

        let feature = features?.first
        let userID = feature?.messageString
        if userID != nil {
            if Auth.auth().currentUser?.uid != nil {
                if Auth.auth().currentUser?.uid == userID {
                    print("Read ID is the same with own ID, cannot add into Friend")
                    presentSimpleAlertMessage(title: "錯誤訊息", message: "掃描到自己的ID，無法將自己加入好友")
                    return
                }
                print("userID = \(userID!)")
                self.memberID = userID!
                self.displayUserID(user_id: self.memberID)
            }
        }
    }
}

extension ScanQRCodeViewController: AddFriendDelegate {
    func confirmToAddFriend(sender: AddFriendViewController) {
        print("Receive to add firend, id = [\(self.memberID)]")
        checkUserProfile()
    }
}
