//
//  CustomProductViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/7/10.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

protocol CustomProductDelegate : class {
    func getAddedProductInfo(sender: CustomProductViewController, name: String, quantity: Int, single_price: Int, comments: String)
}

class CustomProductViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {
    @IBOutlet weak var textProductName: UITextField!
    @IBOutlet weak var labelQuantity: UILabel!
    @IBOutlet weak var textComments: UITextField!
    @IBOutlet weak var textSinglePrice: UITextField!
    
    var productQuantity: Int = 1
    var singlePrice: Int = 0
    weak var delegate: CustomProductDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textSinglePrice.keyboardType = .numberPad
        self.labelQuantity.text = "1"

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

    @IBAction func changeQuantity(_ sender: UIStepper) {
        self.productQuantity = Int(sender.value)
        self.labelQuantity.text = String(self.productQuantity)
    }
    
    @IBAction func actionCancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionAddProduct(_ sender: UIButton) {
        
        if self.productQuantity <= 0 {
            presentSimpleAlertMessage(title: "錯誤資訊", message: "產品數量有誤，請重新指定產品數量")
            return
        }
        
        let product_string = self.textProductName.text
        if product_string == nil || product_string!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            presentSimpleAlertMessage(title: "錯誤訊息", message: "新增的產品名稱不能為空白，請重新輸入")
            return
        }

        var comments_string: String = ""
        if self.textComments.text != nil {
            comments_string = self.textComments.text!
        }
        
        if self.textSinglePrice.text != nil {
            self.singlePrice = Int(self.textSinglePrice.text!)!
        }

        self.delegate?.getAddedProductInfo(sender: self, name: self.textProductName.text!, quantity: self.productQuantity, single_price: self.singlePrice, comments: comments_string)
        dismiss(animated: true, completion: nil)
    }
    
}
