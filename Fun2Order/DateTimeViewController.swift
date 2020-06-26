//
//  DateTimeViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/1/5.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
import Foundation

class DateTimeViewController: UIViewController {
    @IBOutlet weak var dateTimePicker: UIDatePicker!
    var dueDate: String = ""
    var initDateTime: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //if self.initDateTime != "" {
            //let formatter = DateFormatter()
            //formatter.dateFormat = DATETIME_FORMATTER
            //formatter.dateFormat = TAIWAN_DATETIME_FORMATTER2
            
            //let dateData = formatter.date(from: self.initDateTime)
            //self.dateTimePicker.setDate(dateData!, animated: false)
        //}
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
    
    func setDateTime(date_time: String) {
        self.initDateTime = date_time
        let formatter = DateFormatter()
        //formatter.dateFormat = DATETIME_FORMATTER
        formatter.dateFormat = TAIWAN_DATETIME_FORMATTER2
        
        if let dateData = formatter.date(from: date_time) {
            self.dateTimePicker.date = dateData
        }
        //self.dateTimePicker.setDate(dateData!, animated: false)
    }
}
