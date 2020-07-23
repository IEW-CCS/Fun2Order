//
//  PersonalContactViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/6/20.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

protocol PersonalContactInfoDelegate: class {
    func getUserContactInfo(sender: PersonalContactViewController, contact: UserContactInformation?)
}

class PersonalContactViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var buttonConfirm: UIButton!
    @IBOutlet weak var textName: UITextField!
    @IBOutlet weak var textPhoneNumber: UITextField!
    @IBOutlet weak var textAddress: UITextField!
    
    weak var delegate: PersonalContactInfoDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.textPhoneNumber.keyboardType = .numberPad

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
          textField.resignFirstResponder()
          return true
    }
    
    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }

    func setData(user_info: UserContactInformation) {
        self.textName.text = user_info.userName
        self.textPhoneNumber.text = user_info.userPhoneNumber
        self.textAddress.text = user_info.userAddress
    }

    @IBAction func cancelContactInfo(_ sender: UIButton) {
        delegate?.getUserContactInfo(sender: self, contact: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmContactInfo(_ sender: UIButton) {
        var contact_info: UserContactInformation = UserContactInformation()
        
        contact_info.userName = self.textName.text
        contact_info.userPhoneNumber = self.textPhoneNumber.text
        contact_info.userAddress = self.textAddress.text
        
        delegate?.getUserContactInfo(sender: self, contact: contact_info)
        self.dismiss(animated: true, completion: nil)
    }

}
