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
    @IBOutlet weak var memberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backView.layer.borderWidth = CGFloat(1.0)
        self.backView.layer.borderColor = UIColor.lightGray.cgColor
        self.backView.layer.cornerRadius = 6
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func receiveMemberImage(member_image: UIImage) {
        self.memberImage.image = member_image
    }
    
    func setData(image: UIImage, name: String) {
        self.memberImage.image = image
        self.memberLabel.text = name
    }
    
    func setData(member_id: String, member_name: String) {
        self.memberLabel.text = member_name
        downloadFBMemberImage(member_id: member_id, completion: receiveMemberImage)
    }
}
