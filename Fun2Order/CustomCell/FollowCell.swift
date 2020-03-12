//
//  FollowCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/2/12.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

protocol FollowCellDelegate: class {
    func setFollowStatus(cell: UITableViewCell, follow_flag: Bool, data_index: Int)
}

class FollowCell: UITableViewCell {
    @IBOutlet weak var labelUserName: UILabel!
    @IBOutlet weak var buttonFollow: UIButton!
    @IBOutlet weak var backView: ShadowGradientView!
    @IBOutlet weak var textViewRecipe: UITextView!
    
    var followStatusFlag: Bool = false
    weak var delegate: FollowCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.buttonFollow.layer.cornerRadius = 6
        self.buttonFollow.setTitleColor(.white, for: .selected)
        self.textViewRecipe.setContentOffset(.zero, animated: true)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    public func AdjustAutoLayout()
    {
        self.backView.AdjustAutoLayout()
    }

    @IBAction func clickFollowButton(_ sender: UIButton) {
        self.followStatusFlag = !self.followStatusFlag
        self.buttonFollow.isSelected = self.followStatusFlag
        if self.buttonFollow.isSelected {
            self.buttonFollow.backgroundColor = CUSTOM_COLOR_LIGHT_ORANGE
        } else {
            self.buttonFollow.backgroundColor = UIColor.clear
        }
        
        delegate?.setFollowStatus(cell: self, follow_flag: self.followStatusFlag, data_index: self.tag)
    }
    
    func setData(member_content: MenuOrderMemberContent) {
        var contentString: String = ""
        
        self.labelUserName.text = member_content.orderContent.itemOwnerName
        if member_content.orderContent.menuProductItems != nil {
            for k in 0...member_content.orderContent.menuProductItems!.count - 1 {
                if k != 0 {
                    contentString = contentString + "\n"
                }
                contentString = contentString + member_content.orderContent.menuProductItems![k].itemName
                if member_content.orderContent.menuProductItems![k].menuRecipes != nil {
                    contentString = contentString + ": "
                    for i in 0...member_content.orderContent.menuProductItems![k].menuRecipes!.count - 1 {
                        if member_content.orderContent.menuProductItems![k].menuRecipes![i].recipeItems != nil {
                            for j in 0...member_content.orderContent.menuProductItems![k].menuRecipes![i].recipeItems!.count - 1 {
                                contentString = contentString + member_content.orderContent.menuProductItems![k].menuRecipes![i].recipeItems![j].recipeName + " "
                            }
                        }
                    }
                }
                
                contentString = contentString + " * " + String(member_content.orderContent.menuProductItems![k].itemQuantity)
                
                if member_content.orderContent.menuProductItems![k].itemComments == "" {
                    //contentString = contentString + "\n"
                    continue
                }
                
                contentString = contentString + "  (" + member_content.orderContent.menuProductItems![k].itemComments + ")"

            }
        }

        self.textViewRecipe.text = contentString
        self.textViewRecipe.setContentOffset(.zero, animated: true)
    }
}
