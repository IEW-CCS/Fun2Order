//
//  MenuItemCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/1/11.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

class MenuItemCell: UITableViewCell {
    @IBOutlet weak var labelProductName: UILabel!
    @IBOutlet weak var labelProductPrice: UILabel!
    @IBOutlet weak var labelQuantityLimit: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //self.labelProductName.textColor = UIColor.
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setData(name: String, price: String) {
        self.labelProductName.text = name
        self.labelProductPrice.text = price
    }
    
    func setDisable() {
        self.labelProductName.textColor = COLOR_PEPPER_RED
        self.labelProductPrice.textColor = COLOR_PEPPER_RED
        self.labelQuantityLimit.textColor = COLOR_PEPPER_RED
    }

    func setProductInfo(product_info: MenuItem, type: Int) {
        if type == MENU_ITEM_CELL_TYPE_LIMIT_HEADER {
            self.labelProductName.text = "產品名稱"
            self.labelProductPrice.text = "價格"
            self.labelQuantityLimit.text = "限量"
            self.labelProductName.textColor = UIColor.systemBlue
            self.labelProductPrice.textColor = UIColor.systemBlue
            self.labelQuantityLimit.textColor = COLOR_PEPPER_RED
        } else if type == MENU_ITEM_CELL_TYPE_REMAINED_HEADER{
            self.labelProductName.text = "產品名稱"
            self.labelProductPrice.text = "價格"
            self.labelQuantityLimit.text = "餘量"
            self.labelProductName.textColor = UIColor.systemBlue
            self.labelProductPrice.textColor = UIColor.systemBlue
            self.labelQuantityLimit.textColor = COLOR_PEPPER_RED
        } else if type == MENU_ITEM_CELL_TYPE_LIMIT_BODY {
            self.labelProductName.text = product_info.itemName
            self.labelProductPrice.text = String(product_info.itemPrice)
            if product_info.quantityLimitation == nil {
                self.labelQuantityLimit.text = ""
                self.labelQuantityLimit.textColor = nil
            } else {
                self.labelQuantityLimit.text = String(product_info.quantityLimitation!)
                self.labelQuantityLimit.textColor = COLOR_PEPPER_RED
            }
            self.labelProductName.textColor = nil
            self.labelProductPrice.textColor = nil
        } else if type == MENU_ITEM_CELL_TYPE_REMAINED_BODY {
            self.labelProductName.text = product_info.itemName
            self.labelProductPrice.text = String(product_info.itemPrice)
            
            if product_info.quantityLimitation == nil {
                self.labelQuantityLimit.text = ""
            } else {
                if product_info.quantityRemained != nil {
                    self.labelQuantityLimit.text = String(product_info.quantityRemained!)
                } else {
                    self.labelQuantityLimit.text = String(product_info.quantityLimitation!)
                }
            }
/*
            if product_info.quantityRemained == nil {
                if product_info.quantityLimitation != nil {
                    self.labelQuantityLimit.text = String(product_info.quantityLimitation!)
                } else {
                    self.labelQuantityLimit.text = ""
                }
                self.labelQuantityLimit.textColor = nil
            } else {
                self.labelQuantityLimit.text = String(product_info.quantityRemained!)
            }
 */
            self.labelProductName.textColor = nil
            self.labelProductPrice.textColor = nil
            self.labelQuantityLimit.textColor = COLOR_PEPPER_RED
        }
    }
}
