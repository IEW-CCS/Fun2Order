//
//  NotificationShippingNoticeViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/6/21.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

protocol NotificationShippingNoticeDelegate: class {
    func getShippingNotice(sender: NotificationShippingNoticeViewController, shipping_date: String, shipping_location: String, shipping_notice: String)
}

class NotificationShippingNoticeViewController: UIViewController {
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var buttonConfirm: UIButton!
    @IBOutlet weak var labelShippingDateTime: UILabel!
    @IBOutlet weak var textShippingLocation: UITextField!
    @IBOutlet weak var textViewShippingNotice: UITextView!
    
    var shippingDateTime: String = ""
    weak var delegate: NotificationShippingNoticeDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textViewShippingNotice.layer.borderWidth = 1.0
        self.textViewShippingNotice.layer.borderColor = UIColor.lightGray.cgColor
        self.textViewShippingNotice.layer.cornerRadius = 6
        self.labelShippingDateTime.text = ""
        self.textShippingLocation.text = ""
    }
    
    @IBAction func AssignShippingDateTime(_ sender: UIButton) {
        let controller = UIAlertController(title: "指定預計到貨時間", message: nil, preferredStyle: .actionSheet)

        guard let dateTimeController = self.storyboard?.instantiateViewController(withIdentifier: "DATETIME_VC") as? DateTimeViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: DATETIME_VC can't find!! (NotificationShippingNoticeViewController)")
            return
        }
        
        controller.setValue(dateTimeController, forKey: "contentViewController")
        controller.addChild(dateTimeController)
        
        let cancelAction = UIAlertAction(title: "取消", style: .default) { (_) in
            print("Cancel to update due date!")
        }
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        controller.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
            let datetime_controller = controller.children[0] as! DateTimeViewController
            let dueTime: String = datetime_controller.getDueDate()
            self.labelShippingDateTime.text = dueTime
/*
            if dueTime == "" {
                presentSimpleAlertMessage(title: "提示訊息", message: "尚未指定新的團購單截止時間")
                return
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = TAIWAN_DATETIME_FORMATTER2
            let nowDateString = formatter.string(from: Date())
            if nowDateString > dueTime {
                presentSimpleAlertMessage(title: "錯誤訊息", message: "團購單截止時間不得早於現在時間")
                return
            }
*/
        }
        
        okAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        controller.addAction(okAction)
        
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func cancelShippingNotice(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func confirmShippingNotice(_ sender: UIButton) {
        self.delegate?.getShippingNotice(sender: self, shipping_date: self.labelShippingDateTime.text!, shipping_location: self.textShippingLocation.text!, shipping_notice: textViewShippingNotice.text)
        dismiss(animated: true, completion: nil)
    }
    
}
