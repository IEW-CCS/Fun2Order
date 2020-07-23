//
//  StoreContactInformationViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/4/19.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

protocol StoreContactInformationDelegate: class {
    func getStoreContactInfo(sender: StoreContactInformationViewController, contact: StoreContactInformation)
}

class StoreContactInformationViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {
    @IBOutlet weak var textStoreName: UITextField!
    @IBOutlet weak var textStoreAddress: UITextField!
    @IBOutlet weak var textStorePhoneNumber: UITextField!
    
    weak var delegate: StoreContactInformationDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
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

    func setData(store_info: StoreContactInformation) {
        self.textStoreName.text = store_info.storeName
        self.textStoreAddress.text = store_info.storeAddress
        self.textStorePhoneNumber.text = store_info.storePhoneNumber
    }
    
    @IBAction func cancelEdit(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmEdit(_ sender: UIButton) {
        var contact_info: StoreContactInformation = StoreContactInformation()
        
        contact_info.storeName = self.textStoreName.text
        contact_info.storeAddress = self.textStoreAddress.text
        contact_info.storePhoneNumber = self.textStorePhoneNumber.text
        
        delegate?.getStoreContactInfo(sender: self, contact: contact_info)
        self.dismiss(animated: true, completion: nil)
    }
}
