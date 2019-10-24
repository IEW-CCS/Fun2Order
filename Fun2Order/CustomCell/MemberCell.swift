//
//  MemberCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/23.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class MemberCell: UITableViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var memberImage: UIImageView!
    @IBOutlet weak var checkBodAttend: Checkbox!
    @IBOutlet weak var memberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backView.layer.borderWidth = CGFloat(1.5)
        self.backView.layer.borderColor = UIColor.darkGray.cgColor
        self.backView.layer.cornerRadius = 6
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setData(image: UIImage, name: String) {
        self.memberImage.image = image
        self.memberLabel.text = name
    }
}
