//
//  BasicTitleCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/5/30.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

class BasicTitleCell: UITableViewCell {
    @IBOutlet weak var labelTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(title: String) {
        self.labelTitle.text = title
    }
}
