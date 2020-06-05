//
//  VerifyPhNoController.swift
//  Fun2Order
//
//  Created by chris on 2019/10/17.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit
import FlagPhoneNumber
import Firebase
import FirebaseAuth

class VerifyPhNoController: UIViewController {
    
    @IBOutlet  var PhoneNumberTextField: FPNTextField!
    @IBOutlet weak var buttonEMail: UIButton!
    var userName: String = ""
    var phoneString: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        PhoneNumberTextField.layer.masksToBounds = true
        PhoneNumberTextField.layer.cornerRadius = 20
        PhoneNumberTextField.layer.borderWidth = 2
        PhoneNumberTextField.layer.borderColor = UIColor.clear.cgColor
        self.buttonEMail.isHidden = true
        self.buttonEMail.isEnabled = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        PhoneNumberTextField.resignFirstResponder()
    }
    
    @IBAction func loginEmailButton(_ sender: UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "VerifyMailController") as! VerifyMailController
        navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    @IBAction func nextButton(_ sender: Any) {
        if checkDemoAccounts() {
            self.phoneString = PhoneNumberTextField.getFormattedPhoneNumber(format: .E164)!
            loginDemoAccount()
        } else {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "OTPVerificationController") as! OTPVerificationController
            if PhoneNumberTextField.getRawPhoneNumber() != nil
            {
                nextViewController.phoneString = PhoneNumberTextField.getFormattedPhoneNumber(format: .E164)!
            }
            else
            {
                presentSimpleAlertMessage(title: "輸入錯誤", message: "請輸入有效的電話號碼")
            }
            navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
    
    func checkDemoAccounts() -> Bool {
        let phoneNumber = PhoneNumberTextField.getFormattedPhoneNumber(format: .E164)!
        for i in 0...DEMO_ACCOUNTS.count - 1 {
            if phoneNumber == DEMO_ACCOUNTS[i] {
                return true
            }
        }
        return false
    }
    
    func loginDemoAccount() {
        var index: Int = -1
        let phoneNumber = PhoneNumberTextField.getFormattedPhoneNumber(format: .E164)!
        for i in 0...DEMO_ACCOUNTS.count - 1 {
            if phoneNumber == DEMO_ACCOUNTS[i] {
                index = i
            }
        }
        
        if index < 0 {
            presentSimpleAlertMessage(title: "Error", message: "loginDemoAccount index error")
            return
        }

        let email = DEMO_EMAILS[index]
        let password = DEMO_PASSWD[index]
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] user, error in
            guard let strongSelf = self else {
                return
            }
            
            if error != nil {
                print(error as Any)
                print(strongSelf)
                presentSimpleAlertMessage(title: "Error", message: "Input Phone Number [\(phoneNumber)], " + error!.localizedDescription)
                return
            }
            self?.inputUserName()
        }
    }
    
    func setupFBUserProfile() {
        let databaseRef = Database.database().reference()
        if Auth.auth().currentUser?.uid == nil {
            print("setupFBUserProfile Auth.auth().currentUser?.uid == nil")
            return
        }
        
        let uidPathString = getProfileDatabasePath(u_id: Auth.auth().currentUser!.uid, key_value: "userID")
        databaseRef.child(uidPathString).setValue(Auth.auth().currentUser!.uid)

        let userNamePathString = getProfileDatabasePath(u_id: Auth.auth().currentUser!.uid, key_value: "userName")
        databaseRef.child(userNamePathString).setValue(self.userName)

        let phoneNumberPathString = getProfileDatabasePath(u_id: Auth.auth().currentUser!.uid, key_value: "phoneNumber")
        databaseRef.child(phoneNumberPathString).setValue(self.phoneString)

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
                    plist["PhoneNumber"] = self.phoneString
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
        
        if Auth.auth().currentUser?.uid != nil {
            userNameController.userID = Auth.auth().currentUser!.uid
        }
        
        userNameController.delegate = self
        controller.preferredContentSize.height = 220
        controller.preferredContentSize.width = 320
        controller.addChild(userNameController)
        
        present(controller, animated: true, completion: nil)
    }
}

extension VerifyPhNoController: UserNameDelegate {
    func setUserName(sender: UserNameViewController, user_name: String) {
        print("OTPVerificationController received user name = \(user_name)")
        self.userName = user_name

        self.setupFBUserProfile()
    }
}
