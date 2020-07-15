//
//  MenuItemWithCartCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/7/14.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

protocol MenuItemWithCartDelegate: class {
    func addProductToSelectRecipe(sender: MenuItemWithCartCell, index: Int)
}

class MenuItemWithCartCell: UITableViewCell {
    @IBOutlet weak var labelProductName: UILabel!
    @IBOutlet weak var stackViewPrice: UIStackView!
    @IBOutlet weak var buttonCart: UIButton!
    
    var rowIndex: Int = 0
    weak var delegate: MenuItemWithCartDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.stackViewPrice.distribution = .fillEqually
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setDisable() {
        self.labelProductName.textColor = COLOR_PEPPER_RED
        //self.labelProductPrice.textColor = COLOR_PEPPER_RED
        //self.labelQuantityLimit.textColor = COLOR_PEPPER_RED
    }

    /*
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

            self.labelProductName.textColor = nil
            self.labelProductPrice.textColor = nil
            self.labelQuantityLimit.textColor = COLOR_PEPPER_RED
        }
    }
    */

    func setData(name: String, contents: [String], index: Int, style: Int) {
        for subView in self.stackViewPrice.arrangedSubviews {
            subView.removeFromSuperview()
            self.stackViewPrice.removeArrangedSubview(subView)
        }

        self.rowIndex = index
        self.labelProductName.text = name
        if style == 0 {
            self.labelProductName.textColor = UIColor.systemBlue
            self.labelProductName.text = "產品名稱"
            self.buttonCart.isHidden = true
            self.buttonCart.isEnabled = false
        } else {
            self.labelProductName.textColor = nil
            self.buttonCart.isHidden = false
            self.buttonCart.isEnabled = true
        }
        
        if contents.isEmpty {
            return
        }
        
        for i in 0...contents.count - 1 {
            let squareView = UILabel(frame: CGRect(x: 0, y: 0, width: 30.0, height: 30.0))
            squareView.textAlignment = .center
            if style == 0 {
                squareView.layer.borderWidth = 1.0
                squareView.layer.borderColor = UIColor.darkGray.cgColor
                squareView.layer.cornerRadius = 3
            } else {
                squareView.layer.borderWidth = 0
                squareView.layer.borderColor = nil
                squareView.layer.cornerRadius = 3
            }
            squareView.text = contents[i]
            
            self.stackViewPrice.addArrangedSubview(squareView)
        }
    }

    @IBAction func addToCart(_ sender: UIButton) {
        self.delegate?.addProductToSelectRecipe(sender: self, index: self.rowIndex)
    }
}
