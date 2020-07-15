//
//  NotificationActionCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/2/2.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

class NotificationActionCell: UITableViewCell {
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelBrandName: UILabel!
    @IBOutlet weak var labelReceiveTime: UILabel!
    @IBOutlet weak var labelNotificationType: UILabel!
    @IBOutlet weak var labelReplyStatus: UILabel!
    @IBOutlet weak var imageDueTime: UIImageView!
    @IBOutlet weak var backView: ShadowGradientView!
    
    var notificationData: NotificationData = NotificationData()

    override func awakeFromNib() {
        super.awakeFromNib()
        self.labelReplyStatus.text = ""
        //self.textViewMessageBody.canCancelContentTouches = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public func AdjustAutoLayout()
    {
        self.backView.AdjustAutoLayout()
    }

    func checkExpire() -> Bool {
        if self.notificationData.dueTime == "" {
            print("self.notificationData.dueTime is blank")
            return false
        }
        
        let nowDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = DATETIME_FORMATTER
        let nowString = formatter.string(from: nowDate)
        
        //print("------  checkExpire ------")
        //print("self.notificationData.dueTime string = \(self.notificationData.dueTime)")
        //print("now date string = \(nowString)")
        if nowString > self.notificationData.dueTime {
            //print("NotificationActionCell checkExpire return true")
            return true
        } else {
            //print("NotificationActionCell checkExpire return false")
            return false
        }

    }

    func setData(notification: NotificationData) {
        self.notificationData = notification
        self.labelTitle.text = "來自 \(notification.orderOwnerName) 的團購訊息"
        self.labelTitle.textColor = UIColor.black
        self.labelBrandName.text = "【 \(notification.brandName) 】"
        //self.textViewMessageBody.text = notification.messageBody
        
        let formatter = DateFormatter()
        formatter.dateFormat = DATETIME_FORMATTER
        let receiveDate = formatter.date(from: notification.receiveTime)
        formatter.dateFormat = TAIWAN_DATETIME_FORMATTER
        let receiveTimeString = formatter.string(from: receiveDate!)
        self.labelReceiveTime.text = receiveTimeString
        self.labelReplyStatus.text = ""
        self.imageDueTime.isHidden = true
        
        switch notification.notificationType {
            case NOTIFICATION_TYPE_MESSAGE_DUETIME:
                self.labelNotificationType.text = "催訂通知"
                self.labelNotificationType.textColor = COLOR_PEPPER_RED
                if self.checkExpire() {
                    self.imageDueTime.isHidden = false
                    self.labelTitle.textColor = COLOR_PEPPER_RED
                }
                break
                
            case NOTIFICATION_TYPE_MESSAGE_INFORMATION:
                self.labelNotificationType.text = "團購訊息"
                self.labelNotificationType.textColor = UIColor.systemPurple
                break
                
            case NOTIFICATION_TYPE_ACTION_JOIN_ORDER:
                self.labelNotificationType.text = "團購邀請"
                self.labelNotificationType.textColor = UIColor.systemBlue
                if self.checkExpire() {
                    self.imageDueTime.isHidden = false
                    self.labelTitle.textColor = COLOR_PEPPER_RED
                }
                break
                
            case NOTIFICATION_TYPE_SHIPPING_NOTICE:
                self.labelNotificationType.text = "到貨通知"
                self.labelNotificationType.textColor = UIColor.systemBlue
                break

            default:
                self.labelNotificationType.text = ""
                self.labelNotificationType.textColor = UIColor.black
                break
        }
        
        if notification.isRead == "Y" {
            self.backView.gradientColor = 15
        } else {
            self.backView.gradientColor = 11
        }
        
        if notification.notificationType == NOTIFICATION_TYPE_SHIPPING_NOTICE || notification.notificationType == NOTIFICATION_TYPE_MESSAGE_INFORMATION {
            return
        }
        
        switch notification.replyStatus {
            case MENU_ORDER_REPLY_STATUS_ACCEPT:
                self.labelReplyStatus.text = "已回覆\n參加"
                self.labelReplyStatus.textColor = UIColor.systemBlue
                break

            case MENU_ORDER_REPLY_STATUS_REJECT:
                self.labelReplyStatus.text = "已回覆\n不參加"
                self.labelReplyStatus.textColor = COLOR_PEPPER_RED
                break

            default:
                self.labelReplyStatus.text = "尚未回覆"
                self.labelReplyStatus.textColor = UIColor.black
                break
        }

    }
}
