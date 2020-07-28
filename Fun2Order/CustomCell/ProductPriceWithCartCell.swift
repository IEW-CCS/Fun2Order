//
//  ProductPriceWithCartCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/7/11.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

protocol ProductPriceWithCartDelegate: class {
    func addProductToCart(sender: ProductPriceWithCartCell, index: Int)
}

class ProductPriceWithCartCell: UITableViewCell {
    @IBOutlet weak var labelProductName: UILabel!
    @IBOutlet weak var stackViewPrice: UIStackView!
    @IBOutlet weak var buttonCart: UIButton!
    @IBOutlet weak var labelDescription: UILabel!
    
    var rowIndex: Int = 0
    weak var delegate: ProductPriceWithCartDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.stackViewPrice.distribution = .fillEqually
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setData(name: String, description: String, contents: [String], index: Int, style: Int, standalone_flag: Bool) {
        for subView in self.stackViewPrice.arrangedSubviews {
            subView.removeFromSuperview()
            self.stackViewPrice.removeArrangedSubview(subView)
        }

        self.rowIndex = index
        self.labelProductName.text = name
        self.labelDescription.text = description
        if style == 0 {
            self.labelProductName.textColor = UIColor.systemBlue
            self.labelProductName.text = "品名"
            self.buttonCart.isHidden = true
            self.buttonCart.isEnabled = false
        } else {
            self.labelProductName.textColor = nil
            if standalone_flag {
                self.buttonCart.isHidden = false
                self.buttonCart.isEnabled = true
            } else {
                self.buttonCart.isHidden = true
                self.buttonCart.isEnabled = false
            }
        }
        
        if contents.isEmpty {
            return
        }
        
        for i in 0...contents.count - 1 {
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
    
    @IBAction func addToCart(_ sender: UIButton) {
        self.delegate?.addProductToCart(sender: self, index: self.rowIndex)
    }
}
