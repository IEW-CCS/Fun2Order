//
//  VerifyMailController.swift
//  Fun2Order
//
//  Created by inx on 2019/10/21.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class VerifyMailController: UIViewController {

    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    var userName: String = ""
    var phoneString: String = "123456789012345"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailText.resignFirstResponder()
        passwordText.resignFirstResponder()
    }
    
    @IBAction func login(_ sender: Any) {
        
        if emailText.text == "" && passwordText.text == "" {
            let alert = UIAlertController(title: "Sign In", message: "Please Enter Email or Password.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        let email = emailText.text!
        let password = passwordText.text!
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] user, error in
            guard let strongSelf = self else { return }
            if error != nil {
                print(error as Any)
                print(strongSelf)
                let alert = UIAlertController(title: "Sign In Error", message: "Please Enter Correct Email or Password.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self!.present(alert, animated: true, completion: nil)
                
            } else {
                self!.inputUserName()
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
        
        if Auth.auth().currentUser?.uid != nil {
            userNameController.userID = Auth.auth().currentUser!.uid
        }
        userNameController.delegate = self
        controller.preferredContentSize.height = 220
        controller.preferredContentSize.width = 320
        controller.addChild(userNameController)
        
        present(controller, animated: true, completion: nil)
    }

    @IBAction func forgotPasswordButton(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ForgotPasswordController") as! ForgotPasswordController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    @IBAction func signupUserButton(_ sender: Any) {

        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SignUpMailController") as! SignUpMailController
        navigationController?.pushViewController(nextViewController, animated: true)
    }
    
}

extension VerifyMailController: UserNameDelegate {
    func setUserName(sender: UserNameViewController, user_name: String) {
        print("VerifyMailController received user name = \(user_name)")
        self.userName = user_name

        self.setupFBUserProfile()
    }
}
