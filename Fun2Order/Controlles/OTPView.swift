//
//  OTPView.swift
//  Fun2Order
//
//  Created by chris on 2020/1/2.
//  Copyright © 2020 JStudio. All rights reserved.
//

import Foundation
import UIKit

public class OtpView: UIView,UITextFieldDelegate {
    
    var numberOfDigits:Int!
    var borderType:BorderType!
    var textfields:[UITextField] = [UITextField]()
    var borderColor:UIColor!
    var totalWidth:CGFloat!
    var boxWidth:CGFloat!
    var marginEach:CGFloat = 10
    var keyboardType:UIKeyboardType!
    var delegate:OtpViewDelegate?
    
    
    convenience public init(frame:CGRect,numberOfDigits:Int,borderType:BorderType = .SQUARE,borderColor:UIColor = .black,keyboardType:UIKeyboardType = .phonePad, delegate:OtpViewDelegate){
        self.init(frame: frame)
        self.numberOfDigits=numberOfDigits
        self.borderType = borderType
        self.borderColor = borderColor
        self.keyboardType = keyboardType
        self.delegate=delegate
        self.calculateSizes()
        self.setup()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init(coder: aDecoder)
    }
    
    func setup(){
        
        for i in 0..<self.numberOfDigits {
            let textField = UITextField()
            textField.translatesAutoresizingMaskIntoConstraints=false
            textField.textColor = self.borderColor
            textField.delegate = self
            textField.textAlignment = .center
            textField.tag = i
            textField.keyboardType = self.keyboardType
            
            if self.borderType == .ROUND {
                textField.layer.cornerRadius = self.boxWidth / 2
            }
            
            textField.layer.borderColor = self.borderColor.cgColor
            textField.layer.borderWidth = 2
            
            
            let leftConstraint = NSLayoutConstraint(item: textField, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.subviews.count > 0 ? self.subviews[self.subviews.count - 1] : self, attribute: self.subviews.count > 0 ? NSLayoutConstraint.Attribute.right : NSLayoutConstraint.Attribute.left, multiplier: 1, constant: self.marginEach)
            let centerYConstraint = NSLayoutConstraint(item: textField, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
            let widthConstraint = NSLayoutConstraint(item: textField, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: self.boxWidth)
            let heightConstraint = NSLayoutConstraint(item: textField, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: self.boxWidth)
            
            textField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
            
            self.textfields.append(textField)
            self.addSubview(textField)
            
            NSLayoutConstraint.activate([leftConstraint,centerYConstraint,widthConstraint,heightConstraint])
        }
    }
    
    func calculateSizes(){
        self.totalWidth = self.frame.width
        let onlyBoxesTotalWidth = self.totalWidth - (2 * self.marginEach)
        let spacesBetween = CGFloat(self.numberOfDigits - 1)
        let boxWidthTotal =  onlyBoxesTotalWidth - ( spacesBetween * self.marginEach)
        self.boxWidth = boxWidthTotal / CGFloat(self.numberOfDigits)
        
    }
    
    @objc func textFieldChanged(_ sender:UITextField){
        let index = sender.tag
        if self.textfields[index].text != nil && self.textfields[index].text! != "" && index < self.numberOfDigits - 1 {
            self.textfields[index+1].becomeFirstResponder()
        }
        if checkForValidity() {
            self.delegate?.EnterOTP(otp: self.CaptureOTP())
        }
    }
    
    func checkForValidity()->Bool{
        var isValid = true
        for textField in self.textfields {
            if textField.text == nil || textField.text! == "" {
                isValid=false
            }
        }
        return isValid
    }
    
    func CaptureOTP()->String {
        var otp = ""
        for textField in self.textfields {
            otp += textField.text!
        }
        return otp
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "" {
            return true
        }else if textField.text!.count == 0 {
            return true
        }else {
            return false
        }
    }
    
}

public enum BorderType {
    case ROUND,SQUARE
}

public protocol OtpViewDelegate {
    
    func EnterOTP(otp:String)
    
}
