//
//  BirthdayViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/12/23.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class BirthdayViewController: UIViewController {
    @IBOutlet weak var birthdayPickerView: UIDatePicker!
    var birthdayDate: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = DATE_FORMATTER
        self.birthdayDate = formatter.string(from: sender.date)
        print("BirthdayViewController self.birthdayDate = \(self.birthdayDate)")
    }

    public func getBirthday() -> String {
        return self.birthdayDate
    }
}

