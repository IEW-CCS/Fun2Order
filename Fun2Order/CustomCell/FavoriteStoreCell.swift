//
//  FavoriteStoreCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/13.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

protocol DisplayGroupOrderDelegate {
    func didGroupButtonPressed(at index: IndexPath)
}

class FavoriteStoreCell: UITableViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var brandImage: UIImageView!
    @IBOutlet weak var txtTitle: UILabel!
    @IBOutlet weak var txtSubTitle: UILabel!
    @IBOutlet weak var btnGroup: UIButton!
    
    var delegate: DisplayGroupOrderDelegate??
    var indexPath: IndexPath!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backView.layer.borderWidth = CGFloat(1.0)
        //self.backView.layer.borderColor = UIColor.lightGray.cgColor
        self.backView.layer.borderColor = BASIC_FRAME_BORDER_COLOR_GREEN.cgColor
        self.backView.layer.cornerRadius = 6
        self.btnGroup.layer.cornerRadius = 6
        self.brandImage.layer.cornerRadius = 6
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setData(brand_image: UIImage, title: String, sub_title: String) {
        txtTitle.text = title
        txtSubTitle.text = sub_title
        brandImage.image = brand_image
    }
    
    @IBAction func displayGroupView(_ sender: UIButton) {
        delegate??.didGroupButtonPressed(at: indexPath)
    }
}
