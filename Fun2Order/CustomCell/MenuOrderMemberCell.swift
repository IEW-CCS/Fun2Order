//
//  MenuOrderMemberCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/1/22.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

class MenuOrderMemberCell: UITableViewCell {
    @IBOutlet weak var imageMember: UIImageView!
    @IBOutlet weak var labelMemberName: UILabel!
    @IBOutlet weak var textViewDetail: UITextView!
    @IBOutlet weak var labelReplyTime: UILabel!
    @IBOutlet weak var labelLocation: UILabel!
    @IBOutlet weak var labelQuantity: UILabel!
    @IBOutlet weak var backView: ShadowGradientView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textViewDetail.layer.borderWidth = 1.0
        self.textViewDetail.layer.borderColor = UIColor.darkGray.cgColor
        self.textViewDetail.layer.cornerRadius = 6
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

    func setData(image: UIImage, name: String, location: String) {
        self.imageMember.image = image
        self.labelMemberName.text = name
        self.labelLocation.text = location
    }
    
    func setData(item_content: MenuOrderMemberContent) {
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
        
        self.labelMemberName.text = item_content.orderContent.itemOwnerName
        self.labelLocation.text = item_content.orderContent.location
        self.labelQuantity.text = String(item_content.orderContent.itemQuantity)
        let formatter = DateFormatter()
        formatter.dateFormat = DATETIME_FORMATTER
        let receiveDate = formatter.date(from: item_content.orderContent.createTime)
        formatter.dateFormat = TAIWAN_DATETIME_FORMATTER
        let receiveTimeString = formatter.string(from: receiveDate!)
        self.labelReplyTime.text = "回覆時間: " + receiveTimeString
        
        setContentString(item: item_content)
    }
    
    func setContentString(item: MenuOrderMemberContent) {
        var contentString: String = ""

        if item.orderContent.menuProductItems != nil {
            for k in 0...item.orderContent.menuProductItems!.count - 1 {
                if k != 0 {
                    contentString = contentString + "\n"
                }
                
                contentString = contentString + item.orderContent.menuProductItems![k].itemName + ": "
                if item.orderContent.menuProductItems![k].menuRecipes != nil {
                    for i in 0...item.orderContent.menuProductItems![k].menuRecipes!.count - 1 {
                        if item.orderContent.menuProductItems![k].menuRecipes![i].recipeItems != nil {
                            for j in 0...item.orderContent.menuProductItems![k].menuRecipes![i].recipeItems!.count - 1 {
                                contentString = contentString + item.orderContent.menuProductItems![k].menuRecipes![i].recipeItems![j].recipeName + " "
                            }
                        }
                    }
                }
                
                contentString = contentString + " * " + String(item.orderContent.menuProductItems![k].itemQuantity)
                
                if item.orderContent.menuProductItems![k].itemComments == "" {
                    //contentString = contentString + "\n"
                    continue
                }
                
                contentString = contentString + "  (" + item.orderContent.menuProductItems![k].itemComments + ")"

            }

        }

        self.textViewDetail.text = contentString
    }
}
