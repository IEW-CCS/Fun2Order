//
//  MenuHomeNativeAdCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/2/17.
//  Copyright © 2020 JStudio. All rights reserved.
//
import GoogleMobileAds
import UIKit

class MenuHomeNativeAdCell: UITableViewCell {
    @IBOutlet weak var nativeAdView: GADUnifiedNativeAdView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.nativeAdView.layer.borderWidth = CGFloat(1.0)
        self.nativeAdView.layer.borderColor = BASIC_FRAME_BORDER_COLOR_GREEN.cgColor
        self.nativeAdView.layer.cornerRadius = 6
        self.nativeAdView.iconView?.layer.borderWidth = 1.0
        self.nativeAdView.iconView?.layer.borderColor = UIColor.clear.cgColor
        self.nativeAdView.iconView?.layer.cornerRadius = 6
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
