//
//  MenuLocationCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/1/10.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

class MenuLocationCell: UITableViewCell {
    @IBOutlet weak var labelLocation: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(location_id: String) {
        self.labelLocation.text = location_id
    }
}
