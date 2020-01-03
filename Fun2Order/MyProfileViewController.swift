//
//  MyProfileViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/12/12.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class MyProfileViewController: UIViewController {
    @IBOutlet weak var imageMyPhoto: UIImageView!
    @IBOutlet weak var labelUserName: UILabel!
    @IBOutlet weak var labelUserID: UILabel!
    @IBOutlet weak var segmentControl: UISegmentedControl!    
    
    var segmentIndicator = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSegment()
        //setupSegmentIndicator()
        self.imageMyPhoto.layer.cornerRadius = 40
        
        //saveUserImage(user_image: self.imageMyPhoto.image!)
        loadUserID()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleImageTap(_:)))
        self.imageMyPhoto.addGestureRecognizer(tapGesture)
        self.imageMyPhoto.isUserInteractionEnabled = true

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.receivePageChange(_:)),
            name: NSNotification.Name(rawValue: "PageChange"),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.refreshProfile(_:)),
            name: NSNotification.Name(rawValue: "RefreshProfile"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.updateProfile(_:)),
            name: NSNotification.Name(rawValue: "UpdateProfile"),
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        self.title = "我的設定"
        self.navigationController?.title = "我的設定"
        self.tabBarController?.title = "我的設定"
    }
    
    override func viewDidLayoutSubviews() {
        print("**************  viewDidLayoutSubviews to setupSegmentIndicator")
        setupSegmentIndicator()
    }
    
    @objc func handleImageTap(_ sender: UITapGestureRecognizer) {
        print("Group Image View is tapped")
        let controller = UIAlertController(title: "選取照片來源", message: nil, preferredStyle: .actionSheet)
        
        let photoAction = UIAlertAction(title: "相簿", style: .default) { (_) in
            // Add code to pick a photo from Album
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .photoLibrary
                imagePicker.allowsEditing = true
                imagePicker.delegate = self
                
                self.show(imagePicker, sender: self)
            }
        }
        
        photoAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        controller.addAction(photoAction)
        
        let cameraAction = UIAlertAction(title: "相機", style: .default) { (_) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = true
                imagePicker.delegate = self
                
                self.show(imagePicker, sender: self)
            }
        }
        
        cameraAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        controller.addAction(cameraAction)
        
        let cancelAction = UIAlertAction(title: "取消", style: .default) { (_) in
           print("Cancel update")
        }
        cancelAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        controller.addAction(cancelAction)
        
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func selectFunctions(_ sender: UISegmentedControl) {
        let numberOfSegments = CGFloat(self.segmentControl.numberOfSegments)
        let segmentWidth = CGFloat((self.segmentControl.layer.frame.maxX - self.segmentControl.layer.frame.minX)/numberOfSegments)

        self.segmentIndicator.removeConstraints(self.segmentIndicator.constraints)

        self.segmentIndicator.topAnchor.constraint(equalTo: self.segmentControl.bottomAnchor, constant: 3).isActive = true
        self.segmentIndicator.heightAnchor.constraint(equalToConstant: 2).isActive = true
        
        self.segmentIndicator.widthAnchor.constraint(equalToConstant: CGFloat(segmentWidth - 20)).isActive = true
        
        print("self.segmentControl.selectedSegmentIndex = \(self.segmentControl.selectedSegmentIndex)")
        self.segmentIndicator.centerXAnchor.constraint(equalTo: self.segmentControl.subviews[getSubViewIndex()].centerXAnchor).isActive = true
        
        UIView.animate(withDuration: 0.05, animations: {
            self.view.layoutIfNeeded()
        })
        
        NotificationCenter.default.post(name: NSNotification.Name("IndexChange"), object: self.segmentControl.selectedSegmentIndex)
    }
    
    func setupSegmentIndicator() {
        let numberOfSegments = CGFloat(self.segmentControl.numberOfSegments)
        let segmentWidth = CGFloat((self.segmentControl.layer.frame.maxX - self.segmentControl.layer.frame.minX)/numberOfSegments - 20)

        self.segmentIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.segmentIndicator.backgroundColor = CUSTOM_COLOR_LIGHT_ORANGE
        self.view.addSubview(self.segmentIndicator)
        
        self.segmentIndicator.topAnchor.constraint(equalTo: self.segmentControl.bottomAnchor, constant: 3).isActive = true
        self.segmentIndicator.heightAnchor.constraint(equalToConstant: 2).isActive = true
        
        self.segmentIndicator.widthAnchor.constraint(equalToConstant: CGFloat(segmentWidth)).isActive = true
        
        print("self.segmentControl.selectedSegmentIndex = \(self.segmentControl.selectedSegmentIndex)")
        self.segmentIndicator.centerXAnchor.constraint(equalTo: self.segmentControl.subviews[getSubViewIndex()].centerXAnchor).isActive = true
    }
    
    func getSubViewIndex() -> Int {
        struct xIndex {
            var index: Int = 0
            var centerX = CGFloat(0.0)
        }

        var indexArray = [xIndex]()
        
        for i in 0...self.segmentControl.subviews.count - 1 {
            var tmp = xIndex()
            tmp.index = i
            tmp.centerX = self.segmentControl.subviews[i].center.x
            indexArray.append(tmp)
        }
        
        let result = indexArray.sorted { $0.centerX < $1.centerX }

        return result[self.segmentControl.selectedSegmentIndex].index
    }
    
    func setupSegment() {
        self.segmentControl.backgroundColor = .clear
        self.segmentControl.tintColor = .clear
        
        self.segmentControl.translatesAutoresizingMaskIntoConstraints = false
        
        self.segmentControl.setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "AvenirNextCondensed-Medium", size: 18)!, NSAttributedString.Key.foregroundColor: UIColor.lightGray], for: .normal)
        
        self.segmentControl.setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "AvenirNextCondensed-Medium", size: 20)!, NSAttributedString.Key.foregroundColor: CUSTOM_COLOR_LIGHT_ORANGE], for: .selected)
        
        self.segmentControl.selectedSegmentIndex = 0
    }

    func loadUserID() {
        let path = NSHomeDirectory() + "/Documents/MyProfile.plist"
        if let plist = NSMutableDictionary(contentsOfFile: path) {
            if let userID = plist["UserID"] {labelUserID.text = userID as? String}
            if let userName = plist["UserName"] {labelUserName.text = userName as? String}
            //if let userImage = plist["UserImage"] {imageMyPhoto.image = UIImage(data: userImage as! Data)!}
            /*
             let userImage = plist["UserImage"] as! Data
             if userImage.isEmpty {
                 self.imageMyPhoto.image = UIImage(named: "Image_Default.Member.png")!
             } else {
                 self.imageMyPhoto.image = UIImage(data: userImage)!
             }
              */
            
            guard let userImage = plist["UserImage"] as? Data else {
                self.imageMyPhoto.image = UIImage(named: "Image_Default.Member.png")!
                return
            }
            self.imageMyPhoto.image = UIImage(data: userImage)!
        }
    }
    
    func saveUserInfo(user_image: UIImage) {
        let path = NSHomeDirectory() + "/Documents/MyProfile.plist"
        if let plist = NSMutableDictionary(contentsOfFile: path) {
            plist["UserImage"] = user_image.pngData()!
            plist["UserName"] = self.labelUserName.text
            
            if !plist.write(toFile: path, atomically: true) {
                print("Save MyProfile.plist failed")
            }
            
            let pathString = "UserProfile_Photo/\(Auth.auth().currentUser!.uid).png"
            print("pathString = \(pathString)")
            let storageRef = Storage.storage().reference().child(pathString)
            let uploadData = user_image.pngData()!
            storageRef.putData(uploadData, metadata: nil, completion: { (data, error) in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                
                let photoFullPath = storageRef.fullPath
                print("photoFullPath = \(photoFullPath)")
                
                let changeRequest = Auth.auth().currentUser!.createProfileChangeRequest()
                changeRequest.photoURL = URL(string: storageRef.fullPath)
                changeRequest.commitChanges(completion: { (error) in
                    if error != nil {
                        print(error!.localizedDescription)
                        return
                    }
                })
            })
            
            let databaseRef = Database.database().reference()
            let profilePath = getProfileDatabasePath(u_id: self.labelUserID.text!, key_value: "userName")
            databaseRef.child(profilePath).setValue(self.labelUserName.text)
            let photoUrlPath = getProfileDatabasePath(u_id: self.labelUserID.text!, key_value: "photoURL")
            databaseRef.child(photoUrlPath).setValue(pathString)
        }
    }
    
    @objc func receivePageChange(_ notification: Notification) {
        if let pageIndex = notification.object as? Int {
            print("MyProfileViewController received PageChange notification for page[\(pageIndex)]")
            self.segmentControl.selectedSegmentIndex = pageIndex
            self.segmentIndicator.centerXAnchor.constraint(equalTo: self.segmentControl.subviews[getSubViewIndex()].centerXAnchor).isActive = true
            UIView.animate(withDuration: 0.1, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc func refreshProfile(_ notification: Notification) {
        print("MyProfileViewController received RefreshProfile notification")
        //loadUserID()
        if let userName = notification.object as? String {
            self.labelUserName.text = userName
        }
    }

    @objc func updateProfile(_ notification: Notification) {
        print("MyProfileViewController received UpdateProfile notification")
        self.saveUserInfo(user_image: self.imageMyPhoto.image!)
    }

}

extension MyProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        let newImage = resizeImage(image: image, width: 320)
        self.imageMyPhoto.image = newImage
        //self.saveUserImage(user_image: newImage)
        dismiss(animated: true, completion: nil)
    }
}
