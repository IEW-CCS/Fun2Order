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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setData(name: String, price: String) {
        self.labelProductName.text = name
        self.labelProductPrice.text = price
    }

}
