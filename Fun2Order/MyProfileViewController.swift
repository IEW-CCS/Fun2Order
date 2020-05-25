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
        navigationController?.navigationBar.backItem?.setHidesBackButton(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //testResetMyFriendToolTip()
        //testResetGroupOrderToolTip()
        showMyFriendToolTip()
        showMyGroupToolTip()
        showGroupOrderToolTip()
    }
    
    func showMyFriendToolTip() {
        let path = NSHomeDirectory() + "/Documents/GuideToolTip.plist"
        let plist = NSMutableDictionary(contentsOfFile: path)
        let toolTipOption = plist!["ToolTipOption"] as! Bool
        let myFriendToolTip = plist!["showedMyFriendToolTip"] as! Bool
        let myProfileToolTip = plist!["showedMyProfileToolTip"] as! Bool
        
        if myFriendToolTip == true || toolTipOption == false {
            print("myFriendToolTip is true, so skip to show my friend tooltip")
            return
        }
        
        if myProfileToolTip == false {
            print("showedMyProfileToolTip is false")
            return
        }
                
        let frame = CGRect(x: (self.view.frame.minX + self.view.frame.maxX) / 3, y: self.segmentControl.frame.minY, width: (self.view.frame.minX + self.view.frame.maxX) / 3, height: (self.segmentControl.frame.maxY - self.segmentControl.frame.minY))
        DispatchQueue.main.async {
            showGuideToolTip(text: "恭喜您加入第一張菜單\n接下來請從這裡開始\n加入您的好友", dir: PopTipDirection.down, parent: self.view, target: frame, duration: 8)
        }
        
        if let writePlist = NSMutableDictionary(contentsOfFile: path) {
            writePlist["showedMyFriendToolTip"] = true
            if writePlist.write(toFile: path, atomically: true) {
                print("Write showedMyFriendToolTip to GuideToolTip.plist successfule.")
            } else {
                print("Write showedMyFriendToolTip to GuideToolTip.plist failed.")
            }
        }

    }
    
    func showMyGroupToolTip() {
        let path = NSHomeDirectory() + "/Documents/GuideToolTip.plist"
        let plist = NSMutableDictionary(contentsOfFile: path)
        let toolTipOption = plist!["ToolTipOption"] as! Bool
        let myFriendToolTip = plist!["showedMyFriendToolTip"] as! Bool
        let myGroupToolTip = plist!["showedMyGroupToolTip"] as! Bool

        if myGroupToolTip == true || toolTipOption == false {
            print("myGroupToolTip is true, so skip to show my group tooltip")
            return
        }

        if myFriendToolTip == false {
            print("showedMyFriendToolTip is false")
            return
        }

        let friendList = retrieveFriendList()
        if friendList.isEmpty {
            print("showMyFriendToolTip -> Friend List is Empty")
            return
        } else {
            if friendList.count > 1 {
                print("showMyFriendToolTip -> Friend List count is more than 1")
                return
            }
        }

        let frame = CGRect(x: (self.view.frame.minX + self.view.frame.maxX) * 2 / 3, y: self.segmentControl.frame.minY, width: (self.view.frame.minX + self.view.frame.maxX) / 3, height: (self.segmentControl.frame.maxY - self.segmentControl.frame.minY))
        DispatchQueue.main.async {
            showGuideToolTip(text: "您已加入第一個好友\n接下來請從這裡開始\n編輯群組並加入好友", dir: PopTipDirection.down, parent: self.view, target: frame, duration: 8)
        }

        if let writePlist = NSMutableDictionary(contentsOfFile: path) {
            writePlist["showedMyGroupToolTip"] = true
            if writePlist.write(toFile: path, atomically: true) {
                print("Write showedMyGroupToolTip to GuideToolTip.plist successfule.")
            } else {
                print("Write showedMyGroupToolTip to GuideToolTip.plist failed.")
            }
        }

    }
    
    func showGroupOrderToolTip() {
        let path = NSHomeDirectory() + "/Documents/GuideToolTip.plist"
        let plist = NSMutableDictionary(contentsOfFile: path)
        let toolTipOption = plist!["ToolTipOption"] as! Bool
        let myGroupToolTip = plist!["showedMyGroupToolTip"] as! Bool
        let groupOrderToolTip = plist!["showedGroupOrderToolTip"] as! Bool

        if groupOrderToolTip == true || toolTipOption == false {
            print("groupOrderToolTip is true, so skip to show group order tooltip")
            return
        }
        
        if myGroupToolTip == false {
            print("showedMyGroupToolTip is false")
            return
        }

        let groupList = retrieveGroupList()
        if groupList.isEmpty {
            print("showMyGroupToolTip -> Group List is Empty, tooltip is non-necessary")
            return
        } else {
            if groupList.count > 1 {
                print("showMyGroupToolTip -> Group List count is more than 1")
                return
            }
        }
        
        let app = UIApplication.shared.delegate as! AppDelegate
                
        if let tabBar = app.myTabBar {
            let frame = CGRect(x: 0, y: tabBar.frame.minY, width: (tabBar.frame.minX + tabBar.frame.maxX) / 4, height: tabBar.frame.maxY - tabBar.frame.minY)
            
            DispatchQueue.main.async {
                showGuideToolTip(text: "太好了，將好友加入群組後\n接下來就可以從菜單首頁\n開始邀情您的好友\n一起參加揪團", dir: PopTipDirection.up, parent: self.view, target: frame, duration: 8)
            }
        }

        if let writePlist = NSMutableDictionary(contentsOfFile: path) {
            writePlist["showedGroupOrderToolTip"] = true
            if writePlist.write(toFile: path, atomically: true) {
                print("Write showedGroupOrderToolTip to GuideToolTip.plist successfule.")
            } else {
                print("Write showedGroupOrderToolTip to GuideToolTip.plist failed.")
            }
        }

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

            let userImage = plist["UserImage"] as? Data
            if (userImage == nil || userImage?.count == 0) {
                self.imageMyPhoto.image = UIImage(named: "Image_Default_Member.png")!
            } else {
                self.imageMyPhoto.image = UIImage(data: userImage!)
            }
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
        let newImage = resizeImage(image: image, width: 120)
        self.imageMyPhoto.image = newImage
        dismiss(animated: true, completion: nil)
    }
}
