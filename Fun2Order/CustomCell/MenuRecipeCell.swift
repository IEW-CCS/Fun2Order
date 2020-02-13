//
//  MenuRecipeCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/1/14.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

protocol MenuRecipeCellDelegate: class {
    func setMenuRecipe(cell: UITableViewCell, menu_recipe: MenuRecipe, data_index: Int)
}

class MenuRecipeCell: UITableViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    weak var delegate: MenuRecipeCellDelegate?
    var menuRecipe: MenuRecipe = MenuRecipe()
    var cellHeight: Int = 0
    var isSelectRecipeMode: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()

        self.backView.layer.borderWidth = CGFloat(1.0)
        self.backView.layer.borderColor = UIColor.darkGray.cgColor
        self.backView.layer.cornerRadius = 6

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func getCellHeight() -> Int {
        return self.cellHeight
    }
    
    func setData(recipe_data: MenuRecipe, number_for_row: Int) {
        if self.menuRecipe.recipeItems != nil {
            self.menuRecipe.recipeItems?.removeAll()
        } else {
            print("MenuRecipeCell -> self.menuRecipe.recipeItems is nil")
            return
        }
        
        self.menuRecipe = recipe_data
        self.titleLabel.text = recipe_data.recipeCategory
        
        let ITEM_HEIGHT = 36
        let LABEL_WIDTH = 90
        let ITEM_WIDTH_SPACE = 5
        let ITEM_HEIGHT_SPACE = 5
        let CELL_MARGIN_HEIGHT = 15
        let ITEM_WIDTH = ITEM_WIDTH_SPACE + LABEL_WIDTH
        var cellTotalHeight: Int = 0
        
        //titleLabel.centerXAnchor.constraint(equalTo: backView.centerXAnchor).isActive = true
        //titleLabel.centerYAnchor.constraint(equalTo: backView.centerYAnchor).isActive = true
        for view in self.subviews {
            if view.isKind(of: ShadowGradientView.self) {
                view.removeFromSuperview()
            }
        }
        
        cellTotalHeight = Int(backView.frame.height)
        
        var rowCountIndex: Int = 0
        var totalRowCount: Int = 0
        let initMargin: Int = 15
        var itemY2: CGFloat = 0
        
        for index in 0...recipe_data.recipeItems!.count - 1 {
            let mod_number = index%number_for_row
            rowCountIndex = totalRowCount
            itemY2 = CGFloat(self.backView.frame.maxY + CGFloat((ITEM_HEIGHT_SPACE + ITEM_HEIGHT)*rowCountIndex + 8))
            let itemRect = CGRect(x: CGFloat(self.backView.frame.minX + CGFloat(ITEM_WIDTH_SPACE + ITEM_WIDTH * mod_number + initMargin)), y: CGFloat(itemY2), width: CGFloat(LABEL_WIDTH), height: CGFloat(ITEM_HEIGHT))
            let itemLabel = ShadowGradientView(frame: itemRect)
            itemLabel.gradientBorderColor = .lightGray
            itemLabel.gradientBorderWidth = Double(1.5)
            itemLabel.labelText = recipe_data.recipeItems![index].recipeName
            
            if recipe_data.recipeItems![index].checkedFlag {
                itemLabel.setSelected()
            }

            itemLabel.tag = index

            self.addSubview(itemLabel)

            let tapGesture = UITapGestureRecognizer(target: self, action:#selector(self.itemClicked(_:)))
            itemLabel.addGestureRecognizer(tapGesture)
            
            if (mod_number == (number_for_row - 1)) {
                if !(index == (recipe_data.recipeItems!.count - 1)) {
                    totalRowCount = totalRowCount + 1
                }
            }
             
            //totalRowCount = totalRowCount + 1
            //print("RecipeCell --> totalRowCounnt = \(totalRowCount)")
        }
        
        cellTotalHeight = cellTotalHeight + (ITEM_HEIGHT_SPACE + ITEM_HEIGHT)*(totalRowCount + 1)
        self.cellHeight = cellTotalHeight + CELL_MARGIN_HEIGHT
    }
    
    @objc func itemClicked(_ sender: UITapGestureRecognizer) {
        let selectedItem = sender.view as! ShadowGradientView
        let index = selectedItem.tag

        if !self.isSelectRecipeMode {
            self.menuRecipe.recipeItems![index].checkedFlag = !self.menuRecipe.recipeItems![index].checkedFlag
            if self.menuRecipe.recipeItems![index].checkedFlag {
                selectedItem.setSelected()
            } else {
                selectedItem.setUnSelected()
            }

            delegate?.setMenuRecipe(cell: self, menu_recipe: self.menuRecipe, data_index: self.tag)
        } else {
            self.menuRecipe.recipeItems![index].checkedFlag = !self.menuRecipe.recipeItems![index].checkedFlag
            if self.menuRecipe.recipeItems![index].checkedFlag {
                selectedItem.setSelected()
            } else {
                selectedItem.setUnSelected()
            }
            
            //delegate?.setMenuRecipe(cell: self, menu_recipe: self.menuRecipe, data_index: index)
            delegate?.setMenuRecipe(cell: self, menu_recipe: self.menuRecipe, data_index: self.tag)
            
            if !self.menuRecipe.isAllowedMulti {  //Allow to Select only one recipe item
                if self.menuRecipe.recipeItems![index].checkedFlag {
                    selectedItem.setSelected()
                    for i in 0...self.menuRecipe.recipeItems!.count - 1 {
                        if i != index && self.menuRecipe.recipeItems![i].checkedFlag == true {
                            self.menuRecipe.recipeItems![i].checkedFlag = false
                            //delegate?.setMenuRecipe(cell: self, menu_recipe: self.menuRecipe, data_index: i)
                            delegate?.setMenuRecipe(cell: self, menu_recipe: self.menuRecipe, data_index: self.tag)
                            for view in self.subviews {
                                if view.isKind(of: ShadowGradientView.self) {
                                    let itemView = view as! ShadowGradientView
                                    if itemView.tag == i {
                                        itemView.setUnSelected()
                                        break
                                    }
                                }
                            }
                            break
                        }
                    }
                }
            } else {
                //self.menuRecipe.recipeItems![index].checkedFlag = !self.menuRecipe.recipeItems![index].checkedFlag
                if self.menuRecipe.recipeItems![index].checkedFlag {
                    selectedItem.setSelected()
                } else {
                    selectedItem.setUnSelected()
                }
            }
        }
    }

}
