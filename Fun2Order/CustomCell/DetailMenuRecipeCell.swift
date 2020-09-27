//
//  DetailMenuRecipeCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/7/11.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

protocol DetailMenuRecipeCellDelegate: class {
    func configProductRecipeRelation(sender: DetailMenuRecipeCell, index: Int, recipe_items: DetailRecipeTemplate)
}

class DetailMenuRecipeCell: UITableViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    weak var delegate: DetailMenuRecipeCellDelegate?
    var recipeTemplate: DetailRecipeTemplate = DetailRecipeTemplate()
    var recipeItemRelation: [Bool] = [Bool]()
    var recipeItems: DetailRecipeTemplate = DetailRecipeTemplate()
    var cellHeight: Int = 0
    var numberForRow: Int = 0

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
    
    func setData(recipe_data: DetailRecipeTemplate, recipe_items: DetailRecipeTemplate, recipe_relation: [Bool], number_for_row: Int) {
        if !self.recipeTemplate.recipeList.isEmpty {
            self.recipeTemplate.recipeList.removeAll()
        }
        
        self.recipeTemplate = recipe_data
        self.recipeItems = recipe_items
        self.recipeItemRelation = recipe_relation
        self.numberForRow = number_for_row
        self.titleLabel.text = recipe_data.templateName
        if recipe_data.mandatoryFlag {
            self.titleLabel.text = self.titleLabel.text! + " (必選)"
        } else {
            self.titleLabel.text = self.titleLabel.text! + " (選填)"
        }
        
        let ITEM_HEIGHT = 44
        let LABEL_WIDTH = 95
        //let BUTTON_WIDTH = 36
        let ITEM_WIDTH_SPACE = 5
        let ITEM_HEIGHT_SPACE = 5
        let CELL_MARGIN_HEIGHT = 15
        let ITEM_WIDTH = ITEM_WIDTH_SPACE + LABEL_WIDTH
        var cellTotalHeight: Int = 0
        
        for view in self.subviews {
            if view.isKind(of: ShadowGradientView.self) || view.isKind(of: UIButton.self){
                view.removeFromSuperview()
            }
        }
        
        cellTotalHeight = Int(backView.frame.height)
        
        var rowCountIndex: Int = 0
        var totalRowCount: Int = 0
        let initMargin: Int = 5
        var itemY2: CGFloat = 0
        
        if recipe_data.recipeList.isEmpty {
            cellTotalHeight = cellTotalHeight + (ITEM_HEIGHT_SPACE + ITEM_HEIGHT)*(totalRowCount + 1)
            self.cellHeight = cellTotalHeight + CELL_MARGIN_HEIGHT
            return
        }

        var displayIndex: Int = 0
        for index in 0...recipe_data.recipeList.count - 1 {
            //let mod_number = index%number_for_row
            let mod_number = displayIndex%number_for_row
            rowCountIndex = totalRowCount
            itemY2 = CGFloat(self.backView.frame.maxY + CGFloat((ITEM_HEIGHT_SPACE + ITEM_HEIGHT)*rowCountIndex + 8))
            let itemRect = CGRect(x: CGFloat(self.backView.frame.minX + CGFloat(ITEM_WIDTH_SPACE + ITEM_WIDTH * mod_number + initMargin)), y: CGFloat(itemY2), width: CGFloat(LABEL_WIDTH), height: CGFloat(ITEM_HEIGHT))

            let itemLabel = ShadowGradientView(frame: itemRect)
            itemLabel.gradientBorderColor = .lightGray
            itemLabel.gradientBorderWidth = Double(1.5)
            itemLabel.labelText = recipe_data.recipeList[index].itemName
            itemLabel.tag = index

            if self.recipeItems.recipeList[index].itemCheckedFlag {
                itemLabel.setSelected()
            } else {
                itemLabel.setUnSelected()
            }
            
            if recipe_relation[index] {
                self.addSubview(itemLabel)

                let tapGesture = UITapGestureRecognizer(target: self, action:#selector(self.itemClicked(_:)))
                itemLabel.addGestureRecognizer(tapGesture)
                displayIndex = displayIndex + 1
            } else {
                itemLabel.isHidden  = true
                self.addSubview(itemLabel)
            }
                        
            if (mod_number == (number_for_row - 1)) {
                if !(index == (recipe_data.recipeList.count - 1)) {
                    totalRowCount = totalRowCount + 1
                }
            }
        }
        
        cellTotalHeight = cellTotalHeight + (ITEM_HEIGHT_SPACE + ITEM_HEIGHT)*(totalRowCount + 1)
        self.cellHeight = cellTotalHeight + CELL_MARGIN_HEIGHT
    }
    
    func setData(recipe_data: DetailRecipeTemplate, recipe_items: DetailRecipeTemplate, recipe_relation: [Bool], number_for_row: Int, shortage_product: [ShortageItem]) {
        if !self.recipeTemplate.recipeList.isEmpty {
            self.recipeTemplate.recipeList.removeAll()
        }
        
        self.recipeTemplate = recipe_data
        self.recipeItems = recipe_items
        self.recipeItemRelation = recipe_relation
        self.numberForRow = number_for_row
        self.titleLabel.text = recipe_data.templateName
        if recipe_data.mandatoryFlag {
            self.titleLabel.text = self.titleLabel.text! + " (必選)"
        } else {
            self.titleLabel.text = self.titleLabel.text! + " (選填)"
        }
        
        let ITEM_HEIGHT = 44
        let LABEL_WIDTH = 95
        //let BUTTON_WIDTH = 36
        let ITEM_WIDTH_SPACE = 5
        let ITEM_HEIGHT_SPACE = 5
        let CELL_MARGIN_HEIGHT = 15
        let ITEM_WIDTH = ITEM_WIDTH_SPACE + LABEL_WIDTH
        var cellTotalHeight: Int = 0
        
        for view in self.subviews {
            if view.isKind(of: ShadowGradientView.self) || view.isKind(of: UIButton.self){
                view.removeFromSuperview()
            }
        }
        
        cellTotalHeight = Int(backView.frame.height)
        
        var rowCountIndex: Int = 0
        var totalRowCount: Int = 0
        let initMargin: Int = 5
        var itemY2: CGFloat = 0
        
        if recipe_data.recipeList.isEmpty {
            cellTotalHeight = cellTotalHeight + (ITEM_HEIGHT_SPACE + ITEM_HEIGHT)*(totalRowCount + 1)
            self.cellHeight = cellTotalHeight + CELL_MARGIN_HEIGHT
            return
        }

        var displayIndex: Int = 0
        for index in 0...recipe_data.recipeList.count - 1 {
            //let mod_number = index%number_for_row
            let mod_number = displayIndex%number_for_row
            rowCountIndex = totalRowCount
            itemY2 = CGFloat(self.backView.frame.maxY + CGFloat((ITEM_HEIGHT_SPACE + ITEM_HEIGHT)*rowCountIndex + 8))
            let itemRect = CGRect(x: CGFloat(self.backView.frame.minX + CGFloat(ITEM_WIDTH_SPACE + ITEM_WIDTH * mod_number + initMargin)), y: CGFloat(itemY2), width: CGFloat(LABEL_WIDTH), height: CGFloat(ITEM_HEIGHT))

            let itemLabel = ShadowGradientView(frame: itemRect)
            itemLabel.gradientBorderColor = .lightGray
            itemLabel.gradientBorderWidth = Double(1.5)
            itemLabel.labelText = recipe_data.recipeList[index].itemName
            itemLabel.tag = index

            if self.recipeItems.recipeList[index].itemCheckedFlag {
                itemLabel.setSelected()
            } else {
                itemLabel.setUnSelected()
            }
            
            var shortageFlag: Bool = false
            if shortage_product.contains(where: { $0.itemProduct == recipe_data.recipeList[index].itemName }) {
                shortageFlag = true
                itemLabel.setDisabled()
            }
            
            if recipe_relation[index] {
                self.addSubview(itemLabel)

                if !shortageFlag {
                    let tapGesture = UITapGestureRecognizer(target: self, action:#selector(self.itemClicked(_:)))
                    itemLabel.addGestureRecognizer(tapGesture)
                }
                displayIndex = displayIndex + 1
            } else {
                itemLabel.isHidden  = true
                self.addSubview(itemLabel)
            }

            if (mod_number == (number_for_row - 1)) {
                if !(index == (recipe_data.recipeList.count - 1)) {
                    totalRowCount = totalRowCount + 1
                }
            }
        }
        
        cellTotalHeight = cellTotalHeight + (ITEM_HEIGHT_SPACE + ITEM_HEIGHT)*(totalRowCount + 1)
        self.cellHeight = cellTotalHeight + CELL_MARGIN_HEIGHT
    }

    @objc func itemClicked(_ sender: UITapGestureRecognizer) {
        let selectedItem = sender.view as! ShadowGradientView
        let index = selectedItem.tag
        //print("Click item index = \(index)")
        
        self.recipeItems.recipeList[index].itemCheckedFlag = !self.recipeItems.recipeList[index].itemCheckedFlag
        //if self.recipeItemRelation[index] {
        if self.recipeItems.recipeList[index].itemCheckedFlag {
            selectedItem.setSelected()
        } else {
            selectedItem.setUnSelected()
        }
        
        if !self.recipeTemplate.allowMultiSelectionFlag {  //Allow to Select only one recipe item
            if recipeItems.recipeList[index].itemCheckedFlag  {
                selectedItem.setSelected()
                for i in 0...self.recipeItems.recipeList.count - 1 {
                    if i != index && self.recipeItems.recipeList[i].itemCheckedFlag == true {
                        self.self.recipeItems.recipeList[i].itemCheckedFlag = false
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
            if recipeItems.recipeList[index].itemCheckedFlag {
                selectedItem.setSelected()
            } else {
                selectedItem.setUnSelected()
            }
        }

        self.delegate?.configProductRecipeRelation(sender: self, index: self.tag, recipe_items: self.recipeItems)
    }
}

