//
//  OrderHistoryCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/21.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit
import CoreData

protocol DisplayQRCodeDelegate {
    func didQRCodeButtonPressed(at index: IndexPath)
}

class OrderHistoryCell: UITableViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var backView2: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var brandImage: UIImageView!
    @IBOutlet weak var orderTimeLabel: UILabel!
    @IBOutlet weak var orderNumberLabel: UILabel!
    @IBOutlet weak var memberImage: UIImageView!
    @IBOutlet weak var orderQuantityLabel: UILabel!
    @IBOutlet weak var orderPriceLabel: UILabel!
    @IBOutlet weak var memberLabel: UILabel!
    @IBOutlet weak var memberCountLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var buttonQRCode: UIButton!
    
    var delegate: DisplayQRCodeDelegate??
    var indexPath: IndexPath!
    
    let imageArray: [UIImage] = [UIImage(named: "Image_Person.png")!,
                              UIImage(named: "Image_Group.png")!,
                              UIImage(named: "Icon_Menu_Recipe.png")!]
    
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backView.layer.borderWidth = CGFloat(1.5)
        self.backView.layer.borderColor = BASIC_FRAME_BORDER_COLOR_BLUE.cgColor
        self.backView.layer.cornerRadius = 6
        self.backView2.layer.cornerRadius = 2.5
        self.titleLabel.layer.cornerRadius = 6
        self.buttonQRCode.imageView?.image = UIImage(named: "Image_QR_Code.png")?.withRenderingMode(.alwaysTemplate)
        self.buttonQRCode.tintColor = CUSTOM_COLOR_EMERALD_GREEN
        
        vc = app.persistentContainer.viewContext
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func displayQRCode(_ sender: UIButton) {
        delegate??.didQRCodeButtonPressed(at: indexPath)
    }
    
    func setData(order_info: OrderInformation) {
        self.titleLabel.text = "\(order_info.brandName)  \(order_info.storeName)"
        let brand_profile = retrieveBrandProfile(brand_id: order_info.brandID)
        if brand_profile != nil {
            self.brandImage.image = UIImage(data: (brand_profile?.brandIconImage!)!)!
        } else {
            self.brandImage.isHidden = true
        }

        if order_info.orderType == ORDER_TYPE_SINGLE {
            self.memberImage.image = UIImage(named: "Image_Person.png")!.withRenderingMode(.alwaysTemplate)
            self.memberImage.tintColor = CUSTOM_COLOR_EMERALD_GREEN
        } else if order_info.orderType == ORDER_TYPE_GROUP {
            self.memberImage.image = UIImage(named: "Image_Group.png")!.withRenderingMode(.alwaysTemplate)
            self.memberImage.tintColor = CUSTOM_COLOR_EMERALD_GREEN
        } else if order_info.orderType == ORDER_TYPE_MENU {
            self.memberImage.image = UIImage(named: "Icon_Menu_Recipe.png")!.withRenderingMode(.alwaysTemplate)
            self.memberImage.tintColor = CUSTOM_COLOR_EMERALD_GREEN
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = TAIWAN_DATETIME_FORMATTER
        let dateString = formatter.string(from: order_info.orderCreateTime)
        self.orderTimeLabel.text = dateString
        self.orderNumberLabel.text = order_info.orderNumber

        self.orderQuantityLabel.text = String(order_info.orderTotalQuantity)
        self.orderPriceLabel.text = String(order_info.orderTotalPrice)
        //self.statusLabel.text = getOrderStatusDescription(status_code: order_info.orderStatus)

        //self.orderContentTextView.text = makeContentString(order_info: order_info)
    }
    
    func setMenuData(menu_order: MenuOrder) {
        self.quantityLabel.isHidden = true
        self.orderQuantityLabel.isHidden = true
        self.priceLabel.isHidden = true
        self.orderPriceLabel.isHidden = true
        self.memberLabel.isHidden = false
        self.memberCountLabel.isHidden = false
        self.memberCountLabel.text = String(menu_order.contentItems.count)
        
        self.titleLabel.text = "\(menu_order.brandName)"
        self.memberImage.image = UIImage(named: "Icon_Menu_Recipe.png")!.withRenderingMode(.alwaysTemplate)
        self.memberImage.tintColor = CUSTOM_COLOR_EMERALD_GREEN
        self.brandImage.isHidden = true
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = DATETIME_FORMATTER
        let dateData = timeFormatter.date(from: menu_order.createTime)
        
        let formatter = DateFormatter()
        formatter.dateFormat = TAIWAN_DATETIME_FORMATTER
        let dateString = formatter.string(from: dateData!)
        self.orderTimeLabel.text = dateString
        self.orderNumberLabel.text = menu_order.orderNumber

        self.orderQuantityLabel.text = String(menu_order.orderTotalQuantity)
        self.orderPriceLabel.text = String(menu_order.orderTotalPrice)
        //self.statusLabel.text = getOrderStatusDescription(status_code: menu_order.orderStatus)
        //self.orderContentTextView.text = makeContentString(order_info: order_info)
        
    }
    
    func makeContentString(order_info: OrderInformation) -> String {
        var contentString: String = ""
        if order_info.contentList.isEmpty {
            return ""
        }
        
        for i in 0...order_info.contentList.count - 1 {
            var itemString: String = ""
            itemString = itemString + order_info.contentList[i].productName + "*\(order_info.contentList[i].itemQuantity)  "
            for j in 0...order_info.contentList[i].itemRecipe.count - 1 {
                itemString = itemString + order_info.contentList[i].itemRecipe[j].recipeSubCode + "  "
            }
            itemString = itemString + "共 \(order_info.contentList[i].itemFinalPrice) 元\n"
            contentString = contentString + itemString
        }
        
        return contentString
    }
}
