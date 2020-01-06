//
//  DateTimeViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/1/5.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

class DateTimeViewController: UIViewController {
    @IBOutlet weak var dateTimePicker: UIDatePicker!
    var dueDate: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        let formatter = DateFormatter()
        formatter.dateFormat = TAIWAN_DATETIME_FORMATTER2
        self.dueDate = formatter.string(from: self.dateTimePicker.date)
    }
    
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = TAIWAN_DATETIME_FORMATTER2
        self.dueDate = formatter.string(from: sender.date)
        print("DateTimeViewController self.dueDate = \(self.dueDate)")

    }
    
    public func getDueDate() -> String {
        return self.dueDate
    }
}
