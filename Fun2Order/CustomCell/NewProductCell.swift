//
//  NewProductCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/2/12.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

class NewProductCell: UITableViewCell {
    @IBOutlet weak var labelProductName: UILabel!
    @IBOutlet weak var labelRecipe: UILabel!
    @IBOutlet weak var labelQuantity: UILabel!
    @IBOutlet weak var backView: ShadowGradientView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.labelRecipe.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    public func AdjustAutoLayout()
    {
        self.backView.AdjustAutoLayout()
    }

    func setData(item: MenuProductItem) {
        var contentString: String = ""
        
        self.labelQuantity.text = String(item.itemQuantity)
        self.labelProductName.text = item.itemName
        if item.menuRecipes != nil {
            for i in 0...item.menuRecipes!.count - 1 {
                if item.menuRecipes![i].recipeItems != nil {
                    for j in 0...item.menuRecipes![i].recipeItems!.count - 1 {
                        contentString = contentString + item.menuRecipes![i].recipeItems![j].recipeName + " "
                    }
                }
            }
            self.labelRecipe.text = contentString
        }
    }
}
