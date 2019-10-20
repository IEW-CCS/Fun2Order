//
//  ProductDetailCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/16.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class ProductDetailCell: UITableViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var btnFavorite: UIButton!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    let imageArray: [UIImage] = [UIImage(named: "Icon_Favorite2_Button.png")!, UIImage(named: "Add_Icon.png")!]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backView.layer.borderWidth = CGFloat(1.0)
        self.backView.layer.borderColor = BASIC_FRAME_BORDER_COLOR_GREEN.cgColor
        self.backView.layer.cornerRadius = 6
        self.productImage.layer.cornerRadius = 6
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setData(favorite: Bool, image: UIImage, title: String, sub_title: String, price: String) {
        self.productImage.image = image
        self.titleLabel.text = title
        self.subTitleLabel.text = sub_title
        self.priceLabel.text = price
        if favorite {
            self.btnFavorite.setImage(imageArray[0], for: .normal)
            self.btnFavorite.isHidden = false
            self.btnFavorite.isEnabled = true
        } else {
            self.btnFavorite.setImage(imageArray[1], for: .normal)
            self.btnFavorite.isHidden = false
            self.btnFavorite.isEnabled = true
        }
    }
}
