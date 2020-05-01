//
//  ReportCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/4/20.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

class ReportCell: UICollectionViewCell {
    @IBOutlet weak var labelTitle: UILabel!
    var cellData: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setData(title: String) {
        self.cellData = title
        self.labelTitle.text = title
        self.labelTitle.textAlignment = .left
        
        //self.contentView.backgroundColor = UIColor.clear
        //self.backgroundView?.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = CUSTOM_COLOR_REPORT_BACKGROUND_LIGHT_YELLOW
        self.backgroundView?.backgroundColor = CUSTOM_COLOR_REPORT_BACKGROUND_LIGHT_YELLOW
    }
    
    func setColumnHeaderStyle() {
        self.contentView.backgroundColor = CUSTOM_COLOR_LIGHT_BLUE
        self.backgroundView?.backgroundColor = CUSTOM_COLOR_LIGHT_BLUE
    }
    
    func setSectionHeaderStyle() {
        self.labelTitle.textAlignment = .center
        self.contentView.backgroundColor = CUSTOM_COLOR_LIGHT_ORANGE
        self.backgroundView?.backgroundColor = CUSTOM_COLOR_LIGHT_ORANGE
    }
    
}
