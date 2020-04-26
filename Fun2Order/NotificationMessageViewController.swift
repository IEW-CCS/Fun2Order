//
//  NotificationMessageViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/4/13.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

protocol NotificationMessageDelegate: class {
    func getNotificationMessage(sender: NotificationMessageViewController, message: String)
}

class NotificationMessageViewController: UIViewController {
    @IBOutlet weak var textViewMessage: UITextView!
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var buttonConfirm: UIButton!
    
    var messageContent: String = ""
    weak var delegate: NotificationMessageDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.textViewMessage.layer.borderWidth = 1.0
        self.textViewMessage.layer.borderColor = UIColor.lightGray.cgColor
        self.textViewMessage.layer.cornerRadius = 6
    }
    
    @IBAction func doCancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doConfirm(_ sender: UIButton) {
        let message_content = self.textViewMessage.text
        if message_content == nil || message_content! == "" {
            presentSimpleAlertMessage(title: "錯誤訊息", message: "輸入的訊息內容不能為空白，請重新輸入")
            return
        }
        
        self.messageContent = message_content!
        delegate?.getNotificationMessage(sender: self, message: self.messageContent)
        self.dismiss(animated: true, completion: nil)
    }

}
