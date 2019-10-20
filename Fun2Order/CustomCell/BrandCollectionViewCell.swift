//
//  BrandCollectionViewCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/14.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class BrandCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageIcon: UIImageView!
    
    @IBOutlet weak var txtLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imageIcon.layer.cornerRadius = 8
    }

    func setData(text: String, image: UIImage) {
        self.txtLabel.text = text
        self.imageIcon.image = image
    }

}
