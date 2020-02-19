//
//  RecipeCategoryViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/2/15.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

class RecipeCategoryViewController: UIViewController {
    @IBOutlet weak var textRecipeCategory: UITextField!
    @IBOutlet weak var isMultiCheckbox: Checkbox!
    
    var checkStatus: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.isMultiCheckbox.valueChanged = { (isChecked) in
            print("checkbox is checked: \(isChecked)")
            self.checkStatus = isChecked
        }
    }
    
    func getCheckStatus() -> Bool {
        return self.checkStatus
    }
    
    func getRecipeCategory() -> String? {
        return self.textRecipeCategory.text
    }
}
