//
//  CartListCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/21.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class CartListCell: UITableViewCell {

    @IBOutlet weak var memberImage: UIImageView!
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var recipeLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var quantityStepper: UIStepper!
    @IBOutlet weak var payImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.productLabel.textColor = COLOR_PEPPER_RED
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setData(me_flag: Bool, member_image: UIImage, product_title: String, recipe: String, quantity: String, pay_image: UIImage) {
        if me_flag {
            self.payImage.isHidden = true
            self.quantityStepper.isHidden = false
            self.quantityStepper.isEnabled = true
        } else {
            self.payImage.isHidden = false
            self.payImage.image = pay_image
            self.quantityStepper.isHidden = true
            self.quantityStepper.isEnabled = false
        }
        
        self.memberImage.image = member_image
        self.productLabel.text = product_title
        self.recipeLabel.text = recipe
        self.quantityLabel.text = quantity
    }
    
    @IBAction func changeQuantity(_ sender: UIStepper) {
        let quantity = Int(sender.value)
        self.quantityLabel?.text = String(quantity)
    }
}
