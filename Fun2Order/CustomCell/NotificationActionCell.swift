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
    @IBOutlet weak var textViewMessageBody: UITextView!
    @IBOutlet weak var backView: ShadowGradientView!
    
    var notificationData: NotificationData = NotificationData()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func AdjustAutoLayout()
    {
        self.backView.AdjustAutoLayout()
    }

    func setData(notification: NotificationData) {
        self.labelTitle.text = "來自 \(notification.orderOwnerName) 的團購訊息"
        self.labelBrandName.text = notification.brandName
        self.textViewMessageBody.text = notification.messageBody
        
        let formatter = DateFormatter()
        formatter.dateFormat = DATETIME_FORMATTER
        let receiveDate = formatter.date(from: notification.receiveTime)
        formatter.dateFormat = TAIWAN_DATETIME_FORMATTER
        let receiveTimeString = formatter.string(from: receiveDate!)
        self.labelReceiveTime.text = receiveTimeString
        
        switch notification.notificationType {
            case NOTIFICATION_TYPE_MESSAGE_DUETIME:
                self.labelNotificationType.text = "團購催訂"
                self.labelNotificationType.textColor = COLOR_PEPPER_RED
                break
                
            case NOTIFICATION_TYPE_MESSAGE_INFORMATION:
                self.labelNotificationType.text = "團購訊息"
                break
                
            case NOTIFICATION_TYPE_ACTION_JOIN_ORDER:
                self.labelNotificationType.text = "團購邀請"
                break
                
            default:
                break
        }
        
        if notification.isRead {
            self.backView.gradientColor = 15
        } else {
            self.backView.gradientColor = 11
        }
    }
}
