//
//  ProductBriefCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/17.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class ProductBriefCell: UITableViewCell {
    @IBOutlet weak var productLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(favorite: Bool, product_name: String) {
        self.productLabel.text = product_name
        if favorite {
            self.productLabel.textColor = COLOR_PEPPER_RED
        }
    }
}
