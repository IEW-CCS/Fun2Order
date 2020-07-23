//
//  BasicProductViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/6/14.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

protocol BasicProductDelegate: class {
    func addBasicProductInformation(sender: BasicProductViewController, product_info: MenuItem)
    func copyBasicProductInformation(sender: BasicProductViewController, product_info: MenuItem)
    func editBasicProductInformation(sender: BasicProductViewController, product_info: MenuItem)
}

extension BasicProductDelegate {
    func addBasicProductInformation(sender: BasicProductViewController, product_info: MenuItem) {}
    func copyBasicProductInformation(sender: BasicProductViewController, product_info: MenuItem) {}
    func editBasicProductInformation(sender: BasicProductViewController, product_info: MenuItem) {}
}

class BasicProductViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var buttonConfirm: UIButton!
    @IBOutlet weak var textProductName: UITextField!
    @IBOutlet weak var textProductPrice: UITextField!
    @IBOutlet weak var textQuantityLimit: UITextField!
    @IBOutlet weak var checkboxNoLimit: Checkbox!
    @IBOutlet weak var checkboxYesLimit: Checkbox!
    
    weak var delegate: BasicProductDelegate?
    var productIndex: Int = -1
    var isQuantityLimit: Bool = false
    var operationMode: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.checkboxNoLimit.borderStyle = .circle
        self.checkboxNoLimit.checkmarkStyle = .circle
        self.checkboxYesLimit.borderStyle = .circle
        self.checkboxYesLimit.checkmarkStyle = .circle
        self.checkboxNoLimit.isChecked = true
        self.checkboxYesLimit.isChecked = false
        
        self.checkboxNoLimit.valueChanged = { (isChecked) in
            print("checkboxNoLimit is checked: \(isChecked)")
            if isChecked {
                self.checkboxYesLimit.isChecked = false
                self.textQuantityLimit.isEnabled = false
                self.textQuantityLimit.text = ""
                self.isQuantityLimit = false
            } else {
                self.checkboxYesLimit.isChecked = true
                self.textQuantityLimit.isEnabled = true
                self.isQuantityLimit = true
            }
            print("self.isQuantityLisy: \(self.isQuantityLimit)")
        }

        self.checkboxYesLimit.valueChanged = { (isChecked) in
            print("checkboxYesLimit is checked: \(isChecked)")
            if isChecked {
                self.checkboxNoLimit.isChecked = false
                self.textQuantityLimit.isEnabled = true
                self.isQuantityLimit = true
            } else {
                self.checkboxNoLimit.isChecked = true
                self.textQuantityLimit.isEnabled = false
                self.isQuantityLimit = false
            }
            print("self.isQuantityLisy: \(self.isQuantityLimit)")
        }

        self.textProductPrice.keyboardType = .numberPad
        self.textQuantityLimit.keyboardType = .numberPad
        
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

    func setData(product_item: MenuItem) {
        self.textProductName.text = product_item.itemName
        self.textProductPrice.text = String(product_item.itemPrice)
        if product_item.quantityLimitation == nil {
            self.checkboxNoLimit.isChecked = true
            self.checkboxYesLimit.isChecked = false
            self.textQuantityLimit.text = ""
            self.textQuantityLimit.isEnabled = false
            self.isQuantityLimit = false
        } else {
            self.checkboxNoLimit.isChecked = false
            self.checkboxYesLimit.isChecked = true
            self.textQuantityLimit.text = String(product_item.quantityLimitation!)
            self.textQuantityLimit.isEnabled = true
            self.isQuantityLimit = true
        }
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmAction(_ sender: UIButton) {
        var tmpProductItem = MenuItem()
        
        let product_string = self.textProductName.text
        if product_string == nil || product_string!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            presentSimpleAlertMessage(title: "錯誤訊息", message: "輸入的產品名稱不能為空白，請重新輸入")
            return
        }
        
        tmpProductItem.itemName = product_string!
        let price_string = self.textProductPrice.text
        if price_string != "" {
            tmpProductItem.itemPrice = Int(price_string!)!
        }

        if self.isQuantityLimit {
            let quantity_limit = self.textQuantityLimit.text
            if quantity_limit == nil || quantity_limit!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                presentSimpleAlertMessage(title: "錯誤訊息", message: "請輸入產品限量之數量")
                return
            }
            tmpProductItem.quantityLimitation = Int(quantity_limit!)
            tmpProductItem.quantityRemained = Int(quantity_limit!)
            if tmpProductItem.quantityLimitation! == 0 {
                presentSimpleAlertMessage(title: "錯誤訊息", message: "產品限量之數量不能為0，請重新輸入")
                return
            }
        }
        
        switch self.operationMode {
            case PRODUCT_OPERATION_MODE_ADD:
                self.delegate?.addBasicProductInformation(sender: self, product_info: tmpProductItem)
                break

            case PRODUCT_OPERATION_MODE_COPY:
                self.delegate?.copyBasicProductInformation(sender: self, product_info: tmpProductItem)
                break

            case PRODUCT_OPERATION_MODE_EDIT:
                self.delegate?.editBasicProductInformation(sender: self, product_info: tmpProductItem)
                break

            default:
                break
        }
        
        self.dismiss(animated: true, completion: nil)
    }

}
