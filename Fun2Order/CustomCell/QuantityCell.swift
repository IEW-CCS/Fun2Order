//
//  QuantityCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/20.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class QuantityCell: UITableViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var quantityStepprt: UIStepper!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    var singlePrice: Int = 0
    var quantity: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backView.layer.borderWidth = CGFloat(1.5)
        self.backView.layer.borderColor = BASIC_FRAME_BORDER_COLOR_GREEN.cgColor
        self.backView.layer.cornerRadius = 6
        self.priceLabel.text = "0 元"
        self.quantityLabel.text = "0"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func changeQuantity(_ sender: UIStepper) {
        self.quantity = Int(sender.value)
        self.quantityLabel.text = String(self.quantity)
        self.priceLabel.text = String(self.singlePrice * self.quantity)  + " 元"
    }
    
    func setSinglePrice(price: Int) {
        self.singlePrice = price
        
        self.priceLabel.text = String(self.singlePrice * self.quantity) + " 元"
    }
}
