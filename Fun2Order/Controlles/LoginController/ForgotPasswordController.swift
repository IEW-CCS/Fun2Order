//
//  ForgotPasswordController.swift
//  Fun2Order
//
//  Created by inx on 2019/10/21.
//  Copyright © 2019 JStudio. All rights reserved.
//



import UIKit
import Firebase
import FirebaseAuth

class ForgotPasswordController: UIViewController {

    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var sendButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailText.endEditing(false)
    }
    
    @IBAction func sendButton(_ sender: Any) {
        self.emailText.endEditing(true)
        Auth.auth().sendPasswordReset(withEmail: emailText.text!) { error in
            DispatchQueue.main.async {
                if self.emailText.text?.isEmpty==true || error != nil {
                    let resetFailedAlert = UIAlertController(title: "Reset Failed", message: "Error: \(String(describing: error?.localizedDescription))", preferredStyle: .alert)
                    resetFailedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(resetFailedAlert, animated: true, completion: nil)
                }
                if error == nil && self.emailText.text?.isEmpty==false{
                    let resetEmailAlertSent = UIAlertController(title: "Reset Email Sent", message: "Reset email has been sent to your login email, please follow the instructions in the mail to reset your password", preferredStyle: .alert)
                    resetEmailAlertSent.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                        (action: UIAlertAction!) -> Void in
                        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "VerifyMailController") as! VerifyMailController
                        self.navigationController?.pushViewController(nextViewController, animated: true)
                    }))
                    self.present(resetEmailAlertSent, animated: true, completion: nil)
                }
            }
        }
    }

    @IBAction func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: false, completion: nil)
    }
    
}



