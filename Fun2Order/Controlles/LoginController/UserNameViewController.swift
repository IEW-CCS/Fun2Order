//
//  UserNameViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/3/10.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

protocol UserNameDelegate: class {
    func setUserName(sender: UserNameViewController, user_name: String)
}

class UserNameViewController: UIViewController {
    @IBOutlet weak var labelUserName: UITextField!
    @IBOutlet weak var buttonConfirm: UIButton!
    
    weak var delegate: UserNameDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func ClickToSetUserName(_ sender: UIButton) {
        if labelUserName.text == nil || labelUserName.text! == "" {
            presentSimpleAlertMessage(title: "錯誤訊息", message: "使用者名稱為必填資訊，請重新輸入")
            return
        }
        
        delegate?.setUserName(sender: self, user_name: labelUserName.text!)
        dismiss(animated: true, completion: nil)
    }
    
}
