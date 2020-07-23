//
//  BrandCollectionViewCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/14.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

protocol BrandCollectionCellDelegate: class {
    func getBrandImage(sender: BrandCollectionViewCell, icon: UIImage?, index: Int)
}

class BrandCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var txtLabel: UILabel!
    
    weak var delegate: BrandCollectionCellDelegate?
    var brandImage: UIImage?
    var dataIndex: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imageIcon.layer.cornerRadius = 8
    }

    func setData(text: String, image: UIImage) {
        self.txtLabel.text = text
        self.imageIcon.image = image
    }

    func receiveBrandImage(image: UIImage?) {
        if image != nil {
            self.imageIcon.image = image!
        }
        self.delegate?.getBrandImage(sender: self, icon: image, index: self.dataIndex)
    }
    
    func setData(brand_name: String, brand_image: String?, index: Int) {
        self.txtLabel.text = brand_name
        if brand_image != nil {
            downloadFBBrandImage(brand_url: brand_image!, completion: receiveBrandImage)
        }
        self.dataIndex = index
    }
    
    func setData(brand_name: String, icon: UIImage?, index: Int) {
        self.txtLabel.text = brand_name
        if icon != nil {
            self.imageIcon.image = icon!
        }
        self.dataIndex = index
    }
}
