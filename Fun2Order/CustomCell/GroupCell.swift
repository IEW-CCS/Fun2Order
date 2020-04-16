//
//  GroupCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/12/26.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit


class GroupCell: UICollectionViewCell {
    @IBOutlet weak var imageGroup: UIImageView!
    @IBOutlet weak var labelGroupName: UILabel!
    var indexPath: IndexPath = IndexPath()

    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageGroup.layer.cornerRadius = 6
    }

    func setData(group_image: UIImage, group_name: String, index: IndexPath) {
        self.imageGroup.image = group_image
        self.labelGroupName.text = group_name
        self.indexPath = index
    }
    
    func setTitleColor(title_color: UIColor) {
        self.labelGroupName.textColor = title_color
        
        if let tintImageGroup = self.imageGroup.image {
            let colorlessImage = tintImageGroup.withRenderingMode(.alwaysTemplate)
            self.imageGroup.image = colorlessImage
            self.imageGroup.tintColor = title_color
        }
    }
}
