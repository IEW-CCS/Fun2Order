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
    
    var phoneString = ""
    var _verificationID = ""
    
    func EnterOTP(otp: String) {
      
        Auth.auth().settings!.isAppVerificationDisabledForTesting = true
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: self._verificationID , verificationCode: "\(otp)")
        
        Auth.auth().signIn(with: credential) { authData, error in
            if ((error) != nil) {
                // Handles error
                print("error in otp : \(String(describing: error?.localizedDescription))")
                
                let alert = UIAlertController(title: "Wrong OTP", message: "Please Enter Correct OTP for \(self.phoneString)", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
            else
            {
                let path = NSHomeDirectory() + "/Documents/MyProfile.plist"
                if let plist = NSMutableDictionary(contentsOfFile: path) {
                    plist["UserID"] = Auth.auth().currentUser?.uid
                    plist["PhoneNumber"] = Auth.auth().currentUser?.phoneNumber

                    if !plist.write(toFile: path, atomically: true) {
                        print("Save MyProfile.plist failed")
                    }
                }

                let databaseRef = Database.database().reference()
                
                let uidPathString = getProfileDatabasePath(u_id: Auth.auth().currentUser!.uid, key_value: "uID")
                databaseRef.child(uidPathString).setValue(Auth.auth().currentUser!.uid)

                let userNamePathString = getProfileDatabasePath(u_id: Auth.auth().currentUser!.uid, key_value: "userName")
                databaseRef.child(userNamePathString).setValue("")

                let photoUrlPathString = getProfileDatabasePath(u_id: Auth.auth().currentUser!.uid, key_value: "photoURL")
                databaseRef.child(photoUrlPathString).setValue("UserProfile_Photo/Image_Default_Member.png")
                
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "HomeTabBar") as! UITabBarController
                self.navigationController?.pushViewController(nextViewController, animated: true)
                
            }
        }            
    
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
                
                let alert = UIAlertController(title: "ERROR Varifying", message: String(describing: error?.localizedDescription), preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
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
                
                let alert = UIAlertController(title: "ERROR Varifying", message: String(describing: error?.localizedDescription), preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
        }
    }
}

