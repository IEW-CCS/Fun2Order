//
//  OrderHistoryCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/21.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

protocol DisplayQRCodeDelegate {
    func didQRCodeButtonPressed(at index: IndexPath)
}

class OrderHistoryCell: UITableViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var backView2: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var brandImage: UIImageView!
    @IBOutlet weak var orderTimeLabel: UILabel!
    @IBOutlet weak var orerNumberLabel: UILabel!
    @IBOutlet weak var orderContentTextView: UITextView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var memberImage: UIImageView!
    
    var delegate: DisplayQRCodeDelegate??
    var indexPath: IndexPath!
    
    let imageArray: [UIImage] = [UIImage(named: "Image_Person.png")!, UIImage(named: "Image_Group.png")!]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backView.layer.borderWidth = CGFloat(1.5)
        self.backView.layer.borderColor = BASIC_FRAME_BORDER_COLOR_BLUE.cgColor
        self.backView.layer.cornerRadius = 6
        self.backView2.layer.cornerRadius = 2.5
        self.titleLabel.layer.cornerRadius = 6
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setTitle(title: String, brand: UIImage) {
        self.titleLabel.text = title
        self.brandImage.image = brand
    }
    
    @IBAction func displayQRCode(_ sender: UIButton) {
        delegate??.didQRCodeButtonPressed(at: indexPath)
    }
    
    func setOrderContent(group_order: Bool, order_time: String, order_no: String, order_content: String, status: String) {
        if group_order {
            self.memberImage.image = self.imageArray[1]
        } else {
            self.memberImage.image = self.imageArray[0]
        }
        
        self.orderTimeLabel.text = order_time
        self.orerNumberLabel.text = order_no
        self.orderContentTextView.text = order_content
        self.statusLabel.text = status
    }
}
