//
//  EditPaymentCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/1/24.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
import Firebase

class EditPaymentCell: UITableViewCell {
    @IBOutlet weak var backView: ShadowGradientView!
    @IBOutlet weak var imageMember: UIImageView!
    @IBOutlet weak var labelMemberName: UILabel!
    @IBOutlet weak var labelProductRecipe: UILabel!
    @IBOutlet weak var labelPayStatus: UILabel!
    @IBOutlet weak var labelPayTime: UILabel!
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var buttonEdit: UIButton!
    var itemContent: MenuOrderMemberContent = MenuOrderMemberContent()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageMember.layer.cornerRadius = 6
        //downloadMemberImage()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    public func AdjustAutoLayout()
    {
        self.backView.AdjustAutoLayout()
    }
    
    @IBAction func editPaymentStatus(_ sender: UIButton) {
        var alertWindow: UIWindow!
        
        let controller = UIAlertController(title: "請輸入收取金額", message: nil, preferredStyle: .alert)
        controller.addTextField { (textField) in
            textField.placeholder = "輸入金額"
        }
        
        let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
            let priceString = controller.textFields?[0].text
            if priceString == nil || priceString! == "" {
                presentSimpleAlertMessage(title: "錯誤訊息", message: "輸入金額不能為空白，請重新輸入")
                alertWindow.isHidden = true
                return
            }
            
            self.labelPrice.text = priceString
            self.itemContent.orderContent.isPayChecked = true
            self.itemContent.orderContent.payNumber = Int((controller.textFields?[0].text)!)!
            let formatter = DateFormatter()
            formatter.dateFormat = TAIWAN_DATETIME_FORMATTER
            let formatter2 = DateFormatter()
            formatter2.dateFormat = DATETIME_FORMATTER
            
            let dateNow = Date()
            let taiwanDatetimeString = formatter.string(from: dateNow)
            let datetimeString = formatter2.string(from: dateNow)
            
            self.labelPayTime.text = taiwanDatetimeString
            self.itemContent.orderContent.payTime = datetimeString
            self.labelPayStatus.text = "付款日"
            uploadFBMenuOrderContentItem(item: self.itemContent)
            
            //Send notification to EditPaymentStatusTableViewController to refresh cells
            //NotificationCenter.default.post(name: NSNotification.Name("EditDeleteOrderProduct"), object: nil)
            alertWindow.isHidden = true
        }
        controller.addAction(okAction)
        
        //let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (_) in
            print("Cancel the action")
            alertWindow.isHidden = true
        }
        controller.addAction(cancelAction)
        alertWindow = presentAlert(controller)
    }
    
    func receiveMemberImage(member_image: UIImage) {
        self.imageMember.image = member_image
    }
    
    func setData(item_content: MenuOrderMemberContent) {
        self.itemContent = item_content
        
        //let memberImage = retrieveMemberImage(user_id: item_content.memberID)
        //self.imageMember.image = memberImage
        //downloadMemberImage()
        downloadFBMemberImage(member_id: self.itemContent.memberID, completion: receiveMemberImage)
        
        self.labelMemberName.text = item_content.orderContent.itemOwnerName
        if !item_content.orderContent.isPayChecked {
            self.labelPayStatus.text = "尚未付款"
            self.labelPayTime.text = ""
            self.labelPrice.text = ""
        } else {
            self.labelPayStatus.text = "付款日"
            let formatter = DateFormatter()
            formatter.dateFormat = DATETIME_FORMATTER
            let date = formatter.date(from: item_content.orderContent.payTime)
            
            let formatter2 = DateFormatter()
            formatter2.dateFormat = TAIWAN_DATETIME_FORMATTER
            let dateString = formatter2.string(from: date!)
            self.labelPayTime.text = dateString
            
            self.labelPrice.text = String(item_content.orderContent.payNumber)
        }
        setContentString(item: item_content)
    }
    
    func setContentString(item: MenuOrderMemberContent) {
        var contentString: String = ""

        if item.orderContent.menuProductItems != nil {
            for k in 0...item.orderContent.menuProductItems!.count - 1 {
                contentString = contentString + item.orderContent.menuProductItems![k].itemName + ": "
                if item.orderContent.menuProductItems![k].menuRecipes != nil {
                    for i in 0...item.orderContent.menuProductItems![k].menuRecipes!.count - 1 {
                        if item.orderContent.menuProductItems![k].menuRecipes![i].recipeItems != nil {
                            for j in 0...item.orderContent.menuProductItems![k].menuRecipes![i].recipeItems!.count - 1 {
                                contentString = contentString + item.orderContent.menuProductItems![k].menuRecipes![i].recipeItems![j].recipeName + " "
                            }
                        }
                    }
                    contentString = contentString + " * " + String(item.orderContent.itemQuantity) + "\n"
                }
            }
        }

        self.labelProductRecipe.text = contentString
    }
}
