//
//  JoinInvitationCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/2/13.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

protocol JoinInvitationCellDelegate: class {
    func attendOrderInvitation(data_index: Int)
    func rejectOrderInvitation(data_index: Int)
}

class JoinInvitationCell: UITableViewCell {
    @IBOutlet weak var labelBrandName: UILabel!
    @IBOutlet weak var labelOwnerName: UILabel!
    @IBOutlet weak var labelStartTime: UILabel!
    @IBOutlet weak var labelReplyStatus: UILabel!
    @IBOutlet weak var buttonAttend: UIButton!
    @IBOutlet weak var buttonReject: UIButton!
    @IBOutlet weak var backView: ShadowGradientView!
    
    var notificationData: NotificationData = NotificationData()
    weak var delegate: JoinInvitationCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public func AdjustAutoLayout()
    {
        self.backView.AdjustAutoLayout()
    }
    
    @IBAction func attendOrder(_ sender: UIButton) {
        delegate?.attendOrderInvitation(data_index: self.tag)
    }
    
    @IBAction func rejectOrder(_ sender: UIButton) {
        delegate?.rejectOrderInvitation(data_index: self.tag)
    }
    
    func setData(notify_data: NotificationData) {
        self.notificationData = notify_data
        self.labelBrandName.text = notify_data.brandName
        self.labelOwnerName.text = notify_data.orderOwnerName
        self.labelReplyStatus.text = ""
        
        let formatter = DateFormatter()
        formatter.dateFormat = DATETIME_FORMATTER
        let startDate = formatter.date(from: notify_data.receiveTime)!
        
        formatter.dateFormat = TAIWAN_DATETIME_FORMATTER
        let startTimeString = formatter.string(from: startDate)
        self.labelStartTime.text = startTimeString
        setupReplyStatus()
        checkExpire()
    }
    
    func setupReplyStatus() {
        var replyString: String = ""
        if self.notificationData.replyStatus != "" {
            if self.notificationData.replyTime != "" {
                let formatter = DateFormatter()
                formatter.dateFormat = DATETIME_FORMATTER
                let replyDate = formatter.date(from: self.notificationData.replyTime)!
                
                formatter.dateFormat = TAIWAN_DATETIME_FORMATTER
                replyString = formatter.string(from: replyDate)
            }
        }
        
        switch self.notificationData.replyStatus {
            case MENU_ORDER_REPLY_STATUS_ACCEPT:
                self.labelReplyStatus.text = "已於 \(replyString)\n回覆 參加"
                break
            
            case MENU_ORDER_REPLY_STATUS_REJECT:
                self.labelReplyStatus.text = "已於 \(replyString)\n回覆 不參加"
                break
                
            default:
                self.labelReplyStatus.text = "尚未回覆"
                break
        }

    }
    
    func checkExpire() {
        if self.notificationData.dueTime == "" {
            return
        }
        
        let nowDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = DATETIME_FORMATTER
        let nowString = formatter.string(from: nowDate)
        
        print("------  checkExpire ------")
        print("self.notificationData.dueTime string = \(self.notificationData.dueTime)")
        print("now date string = \(nowString)")
        
        if nowString > self.notificationData.dueTime {
            self.buttonAttend.isEnabled = false
            self.buttonReject.isEnabled = false
            
            self.labelBrandName.text = self.labelBrandName.text! + " -- 團購單已逾期"
            self.labelBrandName.textColor = COLOR_PEPPER_RED
        } else {
            self.buttonAttend.isEnabled = true
            self.buttonReject.isEnabled = true
            self.labelBrandName.textColor = UIColor.black
        }
    }
}
