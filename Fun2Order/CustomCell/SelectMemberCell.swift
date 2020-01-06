//
//  SelectMemberCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/1/5.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

class SelectMemberCell: UITableViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var memberImage: UIImageView!
    @IBOutlet weak var memberLabel: UILabel!
    @IBOutlet weak var selectCheckBox: Checkbox!
    var checkStatus: Bool = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backView.layer.borderWidth = CGFloat(1.0)
        self.backView.layer.borderColor = UIColor.systemBlue.cgColor
        self.backView.layer.cornerRadius = 6
        self.selectCheckBox.isChecked = true
        
        self.selectCheckBox.valueChanged = { (isChecked) in
            print("checkbox is checked: \(isChecked)")
            self.checkStatus = isChecked
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setData(image: UIImage, name: String) {
        self.memberImage.image = image
        self.memberLabel.text = name
    }
    
    func getCheckStatus() -> Bool {
        return self.checkStatus
    }
}
