//
//  RecipeCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/19.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class RecipeCell: UITableViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    var cellHeight: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backView.layer.borderWidth = CGFloat(1.0)
        self.backView.layer.borderColor = UIColor.darkGray.cgColor
        self.backView.layer.cornerRadius = 6

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setItemData(title: String, item_array: [String], number_for_row: Int) {
        self.titleLabel.text = title
        let CHECKBOX_WIDTH = 24
        let LABEL_WIDTH = 80
        let ITEM_WIDTH_SPACE = 5
        let ITEM_HEIGHT_SPACE = 5
        let ITEM_WIDTH = CHECKBOX_WIDTH + ITEM_WIDTH_SPACE + LABEL_WIDTH
        var cellTotalHeight: Int = 0

        titleLabel.centerXAnchor.constraint(equalTo: backView.centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: backView.centerYAnchor).isActive = true
        
        cellTotalHeight = Int(backView.frame.height)
        
        var rowCountIndex: Int = 0
        let initMargin: Int = 15
        var itemY: CGFloat = 0
        for index in 0...item_array.count - 1 {
            let mod_number = index%number_for_row
            rowCountIndex = (index - mod_number)/number_for_row
            itemY = CGFloat(self.backView.frame.maxY + CGFloat((ITEM_HEIGHT_SPACE + CHECKBOX_WIDTH)*rowCountIndex + 8))
            
            let chkRect = CGRect(x: CGFloat(self.backView.frame.minX + CGFloat(ITEM_WIDTH * mod_number + initMargin)), y: itemY, width: CGFloat(CHECKBOX_WIDTH), height: CGFloat(CHECKBOX_WIDTH))
            let checkBox = Checkbox(frame: chkRect)
            
            let lblRect = CGRect(x: CGFloat(self.backView.frame.minX + CGFloat(CHECKBOX_WIDTH + ITEM_WIDTH_SPACE + ITEM_WIDTH * mod_number + initMargin)), y: itemY, width: CGFloat(LABEL_WIDTH), height: CGFloat(CHECKBOX_WIDTH))
            let itemLabel = UILabel(frame: lblRect)
            
            itemLabel.text = item_array[index]
            self.addSubview(checkBox)
            self.addSubview(itemLabel)
        }
        
        cellTotalHeight = cellTotalHeight + (ITEM_HEIGHT_SPACE + CHECKBOX_WIDTH)*(rowCountIndex + 1)
        //print("-------------------------")
        //print("cellTotalHeight = \(cellTotalHeight)")
        //print("-------------------------")
        
        self.cellHeight = cellTotalHeight
    }
    
    func getCellHeight() -> Int {
        return self.cellHeight
    }
}
