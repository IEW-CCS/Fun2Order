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
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "HomeTabBar") as! UITabBarController
                self!.navigationController?.pushViewController(nextViewController, animated: true)
                                
            }
        }
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
