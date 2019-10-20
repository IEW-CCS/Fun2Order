//
//  CategorySectionView.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/17.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit


class CategorySectionView: UITableViewHeaderFooterView {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var categoryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backView.layer.borderWidth = CGFloat(1.0)
        self.backView.layer.borderColor = UIColor.darkGray.cgColor
        self.backView.layer.cornerRadius = 6
        
    }

    func setData(catetory: String) {
        self.categoryLabel.text = catetory
    }
}
