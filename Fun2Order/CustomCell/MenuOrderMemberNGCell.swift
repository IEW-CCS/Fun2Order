//
//  MenuOrderMemberNGCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/1/22.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

class MenuOrderMemberNGCell: UITableViewCell {
    @IBOutlet weak var imageMember: UIImageView!
    @IBOutlet weak var labelMemberName: UILabel!
    @IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var backView: ShadowGradientView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageMember.layer.cornerRadius = 6
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    public func AdjustAutoLayout()
    {
        self.backView.AdjustAutoLayout()
    }

    func receiveMemberImage(member_image: UIImage?) {
        if member_image != nil {
            self.imageMember.image = member_image!
        }
    }

    func setData(image: UIImage, name: String, status: String) {
        self.imageMember.image = image
        self.labelMemberName.text = name
        
        switch status {
        case MENU_ORDER_REPLY_STATUS_WAIT:
            self.backView.gradientColor = 8
            self.labelStatus.text = "等待回覆"

        case MENU_ORDER_REPLY_STATUS_REJECT:
            self.backView.gradientColor = 6
            self.labelStatus.text = "不參加"

        case MENU_ORDER_REPLY_STATUS_EXPIRE:
            self.backView.gradientColor = 14
            self.labelStatus.text = "逾期未回覆"

        default:
            break
        }
    }

    func setData(item_content: MenuOrderMemberContent) {
        self.labelMemberName.text = item_content.orderContent.itemOwnerName
        if item_content.memberID == item_content.orderOwnerID {
            let path = NSHomeDirectory() + "/Documents/MyProfile.plist"
            if let plist = NSMutableDictionary(contentsOfFile: path) {
                let userImage = plist["UserImage"] as? Data
                if (userImage == nil || userImage?.count == 0) {
                    self.imageMember.image = UIImage(named: "Image_Default_Member.png")!
                } else {
                    self.imageMember.image = UIImage(data: userImage!)
                }
            }
        } else {
            //let memberImage = retrieveMemberImage(user_id: item_content.memberID)
            //self.imageMember.image = memberImage
            downloadFBMemberImage(member_id: item_content.memberID, completion: receiveMemberImage)
        }

        switch item_content.orderContent.replyStatus {
        case MENU_ORDER_REPLY_STATUS_WAIT:
            self.backView.gradientColor = 8
            self.labelStatus.text = "等待回覆"

        case MENU_ORDER_REPLY_STATUS_REJECT:
            self.backView.gradientColor = 6
            self.labelStatus.text = "不參加"

        case MENU_ORDER_REPLY_STATUS_EXPIRE:
            self.backView.gradientColor = 14
            self.labelStatus.text = "逾期未回覆"

        default:
            break
        }

    }
}
