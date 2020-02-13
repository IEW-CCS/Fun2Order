//
//  ChangePasswordViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/12/21.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController {

    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var buttonUpdate: UIButton!
    @IBOutlet weak var textOldPassword: UITextField!
    @IBOutlet weak var textNewPassword: UITextField!
    @IBOutlet weak var textConfirmPassword: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func cancelChange(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func updateChange(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
