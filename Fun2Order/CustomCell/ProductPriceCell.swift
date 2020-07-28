//
//  ProductPriceCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/6/27.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

class ProductPriceCell: UITableViewCell {
    @IBOutlet weak var labelProductName: UILabel!
    @IBOutlet weak var stackViewPrice: UIStackView!
    @IBOutlet weak var labelDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.stackViewPrice.distribution = .fillEqually
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setData(name: String, description: String, contents: [String], style: Int) {
        for subView in self.stackViewPrice.arrangedSubviews {
            subView.removeFromSuperview()
            self.stackViewPrice.removeArrangedSubview(subView)
        }

        self.labelProductName.text = name
        self.labelDescription.text = description
        if style == 0 {
            self.labelProductName.textColor = UIColor.systemBlue
            self.labelProductName.text = "品名"
        } else {
            self.labelProductName.textColor = nil
        }
        
        if contents.isEmpty {
            return
        }
        
        for i in 0...contents.count - 1 {
            //let squareView = UIView(frame: CGRect(x: 0, y: 0, width: 30.0, height: 30.0))
            let squareView = UILabel(frame: CGRect(x: 0, y: 0, width: 30.0, height: 30.0))
            squareView.textAlignment = .center
            if style == 0 {
                squareView.layer.borderWidth = 1.0
                squareView.layer.borderColor = UIColor.darkGray.cgColor
                squareView.layer.cornerRadius = 3
            } else {
                squareView.layer.borderWidth = 0
                squareView.layer.borderColor = nil
                squareView.layer.cornerRadius = 3
            }
            squareView.text = contents[i]
            
            self.stackViewPrice.addArrangedSubview(squareView)
        }
    }
    
}
