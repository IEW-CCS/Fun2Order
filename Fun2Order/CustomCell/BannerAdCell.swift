//
//  BannerAdCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/6/4.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

class BannerAdCell: UITableViewCell {
    @IBOutlet weak var backView: ShadowGradientView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    public func AdjustAutoLayout()
    {
        self.backView.AdjustAutoLayout()
    }

}
