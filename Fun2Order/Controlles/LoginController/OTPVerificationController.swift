//
//  PhNoVerificationController.swift
//  Fun2Order
//
//  Created by chris on 2019/10/17.
//  Copyright © 2019 JStudio. All rights reserved.
//


import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class OTPVerificationController: UIViewController,OtpViewDelegate {
    
    var phoneString: String = ""
    var _verificationID: String = ""
    var userName: String = ""
    
    func EnterOTP(otp: String) {
        Auth.auth().settings!.isAppVerificationDisabledForTesting = true
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: self._verificationID , verificationCode: "\(otp)")
        
        Auth.auth().signIn(with: credential) { authData, error in
            if ((error) != nil) {
                // Handles error
                print("error in otp : \(String(describing: error?.localizedDescription))")
                presentSimpleAlertMessage(title: "認證碼錯誤", message: "請對電話號碼(\(self.phoneString))輸入正確的認證碼")
            }
            else
            {
                self.inputUserName()
/*
                let path = NSHomeDirectory() + "/Documents/MyProfile.plist"
                if let plist = NSMutableDictionary(contentsOfFile: path) {
                    plist["UserID"] = Auth.auth().currentUser?.uid
                    plist["PhoneNumber"] = Auth.auth().currentUser?.phoneNumber

                    if !plist.write(toFile: path, atomically: true) {
                        print("Save MyProfile.plist failed")
                    }
                }

                self.setupFBUserProfile()
                
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "HomeTabBar") as! UITabBarController
                self.navigationController?.pushViewController(nextViewController, animated: true)
*/
            }
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

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        otpNumber.resignFirstResponder()
    }
    
    @IBOutlet var otpView: UIView!
    @IBOutlet var otpNumber: UIView!

    @IBAction func ResendOTP(_ sender: Any) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneString, uiDelegate: nil) { verificationID, error in
            if (error == nil) {
                self._verificationID = verificationID!
                print(" varifying PhoneNumber OK !!")
            } else {
                print("error varifying PhoneNumber: \(String(describing: error))")
                
                presentSimpleAlertMessage(title: "認證錯誤", message: error!.localizedDescription)
                //let alert = UIAlertController(title: "認證錯誤", message: String(describing: error?.localizedDescription), preferredStyle: UIAlertController.Style.alert)
                //alert.addAction(UIAlertAction(title: "確定", style: UIAlertAction.Style.default, handler: nil))
                //self.present(alert, animated: true, completion: nil)
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let frm: CGRect = otpNumber.frame
        
        otpNumber = OtpView(frame: CGRect(x: frm.origin.x , y: frm.origin.y + 20, width: frm.size.width, height: frm.size.height), numberOfDigits: 6,  borderType: .ROUND, borderColor: .gray,keyboardType: .phonePad,delegate:self)
        
        self.otpView.addSubview(otpNumber)
       
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneString, uiDelegate: nil) { verificationID, error in
            if (error == nil) {
                self._verificationID = verificationID!
                print(" varifying PhoneNumber OK !!")
            } else {
                print("error varifying PhoneNumber: \(String(describing: error))")
                presentSimpleAlertMessage(title: "認證錯誤", message: error!.localizedDescription)
                
                //let alert = UIAlertController(title: "認證錯誤", message: String(describing: error?.localizedDescription), preferredStyle: UIAlertController.Style.alert)
                //alert.addAction(UIAlertAction(title: "確定", style: UIAlertAction.Style.default, handler: nil))
                //self.present(alert, animated: true, completion: nil)
                
            }
        }
    }
}

extension OTPVerificationController: UserNameDelegate {
    func setUserName(sender: UserNameViewController, user_name: String) {
        print("OTPVerificationController received user name = \(user_name)")
        self.userName = user_name

        self.setupFBUserProfile()
    }
}
