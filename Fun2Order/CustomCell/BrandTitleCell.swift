//
//  BrandTitleCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/5/9.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

class BrandTitleCell: UICollectionViewCell {
    @IBOutlet weak var labelBrandTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setData(title: String) {
        self.labelBrandTitle.text = title
    }
}
