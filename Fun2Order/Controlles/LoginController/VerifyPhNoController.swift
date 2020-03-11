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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        PhoneNumberTextField.layer.masksToBounds = true
        PhoneNumberTextField.layer.cornerRadius = 20
        PhoneNumberTextField.layer.borderWidth = 2
        PhoneNumberTextField.layer.borderColor = UIColor.clear.cgColor
        //self.buttonEMail.isHidden = true
        //self.buttonEMail.isEnabled = false
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
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "OTPVerificationController") as! OTPVerificationController
        if PhoneNumberTextField.getRawPhoneNumber() != nil
        {
            nextViewController.phoneString = PhoneNumberTextField.getFormattedPhoneNumber(format: .E164)!
        }
        else
        {
            presentSimpleAlertMessage(title: "輸入錯誤", message: "請輸入有效的電話號碼")
            //let alert = UIAlertController(title: "Sign Up", message: "Please enter the Valid Phone Number", preferredStyle: UIAlertController.Style.alert)
            //alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            //self.present(alert, animated: true, completion: nil)
        }
        navigationController?.pushViewController(nextViewController, animated: true)
    }
}

