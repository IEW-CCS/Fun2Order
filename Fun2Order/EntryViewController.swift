//
//  EntryViewController.swift
//  Fun2Order
//
//  Created by chris on 2019/10/17.
//  Copyright © 2019 JStudio. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class EntryViewController: UIViewController {
    @IBOutlet weak var buttonVerifyPhone: UIButton!
    @IBOutlet weak var buttonGuest: UIButton!
    @IBOutlet weak var labelLoginMethod: UILabel!
    
    var ref: DatabaseReference!
    var userName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        if(Auth.auth().currentUser?.uid != nil)
        {
            print("Auth.auth().currentUser?.displayName = \(String(describing: Auth.auth().currentUser?.displayName))")
            self.labelLoginMethod.isHidden = true
            self.buttonVerifyPhone.isEnabled = false
            self.buttonGuest.isEnabled = false
            self.buttonGuest.isHidden = true
            if Auth.auth().currentUser?.displayName == nil || Auth.auth().currentUser?.displayName == "" {
                inputUserName()
            } else {
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "HomeTabBar") as! UITabBarController
                navigationController?.pushViewController(nextViewController, animated: true)
            }
        }
    }

    func setupFBUserProfile() {
        let databaseRef = Database.database().reference()
        
        let uidPathString = getProfileDatabasePath(u_id: Auth.auth().currentUser!.uid, key_value: "uID")
        databaseRef.child(uidPathString).setValue(Auth.auth().currentUser!.uid)

        let userNamePathString = getProfileDatabasePath(u_id: Auth.auth().currentUser!.uid, key_value: "userName")
        databaseRef.child(userNamePathString).setValue(self.userName)

        let phoneNumberPathString = getProfileDatabasePath(u_id: Auth.auth().currentUser!.uid, key_value: "phoneNumber")
        databaseRef.child(phoneNumberPathString).setValue(Auth.auth().currentUser!.phoneNumber)

        let photoUrlPathString = getProfileDatabasePath(u_id: Auth.auth().currentUser!.uid, key_value: "photoURL")
        databaseRef.child(photoUrlPathString).setValue("UserProfile_Photo/Image_Default_Member.png")

        let changeRequest = Auth.auth().currentUser!.createProfileChangeRequest()
        changeRequest.displayName = self.userName
        changeRequest.commitChanges(completion: { (error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            } else {
                print("Auth.auth().currentUser?.displayName = \(String(describing: Auth.auth().currentUser?.displayName))")

                let path = NSHomeDirectory() + "/Documents/MyProfile.plist"
                if let plist = NSMutableDictionary(contentsOfFile: path) {
                    plist["UserID"] = Auth.auth().currentUser?.uid
                    plist["PhoneNumber"] = Auth.auth().currentUser?.phoneNumber
                    plist["UserName"] = self.userName

                    if !plist.write(toFile: path, atomically: true) {
                        print("Save MyProfile.plist failed")
                    }
                }

                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "HomeTabBar") as! UITabBarController
                self.navigationController?.pushViewController(nextViewController, animated: true)
            }
        })

    }

    func inputUserName() {
        let controller = UIAlertController(title: "使用者名稱", message: nil, preferredStyle: .alert)

        guard let userNameController = self.storyboard?.instantiateViewController(withIdentifier: "USER_NAME_VC") as? UserNameViewController else {
            assertionFailure("[AssertionFailure] StoryBoard: USER_NAME_VC can't find!! (UserNameViewController)")
            return
        }

        controller.setValue(userNameController, forKey: "contentViewController")
        userNameController.preferredContentSize.height = 220
        userNameController.preferredContentSize.width = 320
        
        userNameController.delegate = self
        controller.preferredContentSize.height = 220
        controller.preferredContentSize.width = 320
        controller.addChild(userNameController)
        
        present(controller, animated: true, completion: nil)
    }

    @IBAction func guest(_ sender: Any) {
        
         let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
         let nextViewController = storyBoard.instantiateViewController(withIdentifier: "HomeTabBar") as! UITabBarController
         navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    
    @IBAction func authentication(_ sender: Any) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "VerifyPhNoController") as! VerifyPhNoController
        navigationController?.pushViewController(nextViewController, animated: true)
        
        
    }
}

extension EntryViewController: UserNameDelegate {
    func setUserName(sender: UserNameViewController, user_name: String) {
        print("EntryViewController received user name = \(user_name)")
        self.userName = user_name

        self.setupFBUserProfile()
    }
}
