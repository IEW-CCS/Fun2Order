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
    var itemsControlTable = [RecipeItemControl]()
    var itemViewArray = [ShadowGradientView]()
    var favoriteProductRecipe = ProductRecipeInformation()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backView.layer.borderWidth = CGFloat(1.0)
        self.backView.layer.borderColor = UIColor.darkGray.cgColor
        self.backView.layer.cornerRadius = 6

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setData(recipe_data: ProductRecipeInformation, number_for_row: Int) {
        self.favoriteProductRecipe = recipe_data
        self.titleLabel.text = recipe_data.recipeCategory
        
        var isMainCateCreated: Bool = false

        let ITEM_HEIGHT = 36
        let LABEL_WIDTH = 90
        let ITEM_WIDTH_SPACE = 5
        let ITEM_HEIGHT_SPACE = 5
        let CELL_MARGIN_HEIGHT = 15
        let ITEM_WIDTH = ITEM_WIDTH_SPACE + LABEL_WIDTH
        var cellTotalHeight: Int = 0
        
        titleLabel.centerXAnchor.constraint(equalTo: backView.centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: backView.centerYAnchor).isActive = true
        
        cellTotalHeight = Int(backView.frame.height)
        
        var rowCountIndex: Int = 0
        var totalRowCount: Int = 0
        let initMargin: Int = 15
        var itemY1: CGFloat = 0
        var itemY2: CGFloat = 0
        
        for i in 0...recipe_data.recipeSubCategoryDetail.count - 1 {
            if recipe_data.recipeSubCategoryDetail.count > 1 {
                isMainCateCreated = false
            } else {
                isMainCateCreated = true
            }
            
            for j in 0...recipe_data.recipeSubCategoryDetail[i].count - 1 {
                if !isMainCateCreated {
                    itemY1 = CGFloat(self.backView.frame.maxY + CGFloat((ITEM_HEIGHT_SPACE + ITEM_HEIGHT)*totalRowCount + 8))

                    let lblMainCateRect = CGRect(x: CGFloat(self.backView.frame.minX + CGFloat(ITEM_WIDTH_SPACE + initMargin)), y: CGFloat(itemY1), width: CGFloat(LABEL_WIDTH), height: CGFloat(ITEM_HEIGHT))
                    let lblMainCate = UILabel(frame: lblMainCateRect)
                    lblMainCate.text = recipe_data.recipeSubCategoryDetail[i][j].recipeMainCategory
                    totalRowCount = totalRowCount + 1
                    self.addSubview(lblMainCate)
                    isMainCateCreated = true
                    print("******* Add category label: \(lblMainCate.text!) and totalRowCount = \(totalRowCount)")
                }
                
                for index in 0...recipe_data.recipeSubCategoryDetail[i][j].recipeDetail.count - 1 {
                    let mod_number = index%number_for_row
                    rowCountIndex = totalRowCount
                    print("Item: \(recipe_data.recipeSubCategoryDetail[i][j].recipeDetail[index].recipeName), rowCountIndex = \(rowCountIndex)")
                    itemY2 = CGFloat(self.backView.frame.maxY + CGFloat((ITEM_HEIGHT_SPACE + ITEM_HEIGHT)*rowCountIndex + 8))
                    let itemRect = CGRect(x: CGFloat(self.backView.frame.minX + CGFloat(ITEM_WIDTH_SPACE + ITEM_WIDTH * mod_number + initMargin)), y: CGFloat(itemY2), width: CGFloat(LABEL_WIDTH), height: CGFloat(ITEM_HEIGHT))
                    let itemLabel = ShadowGradientView(frame: itemRect)
                    itemLabel.gradientBorderColor = .lightGray
                    itemLabel.gradientBorderWidth = Double(1.5)
                    itemLabel.labelText = recipe_data.recipeSubCategoryDetail[i][j].recipeDetail[index].recipeName
                    
                    if recipe_data.recipeSubCategoryDetail[i][j].recipeDetail[index].checkedFlag {
                        itemLabel.setSelected()
                    }

                    var tmpControl = RecipeItemControl()
                    tmpControl.rowIndex = self.favoriteProductRecipe.rowIndex
                    tmpControl.mainCategoryIndex = i
                    tmpControl.subCategoryIndex = j
                    tmpControl.itemIndex = index
                    self.itemViewArray.append(itemLabel)
                    
                    itemLabel.setRecipeItemIndex(item_index: tmpControl)
                    self.itemsControlTable.append(tmpControl)

                    self.addSubview(itemLabel)

                    let tapGesture = UITapGestureRecognizer(target: self, action:#selector(self.itemClicked(_:)))
                    itemLabel.addGestureRecognizer(tapGesture)
                    
                    if (mod_number == (number_for_row - 1)) {
                        if !(index == (recipe_data.recipeSubCategoryDetail[i][j].recipeDetail.count - 1)  && (j == recipe_data.recipeSubCategoryDetail[i].count - 1 )) {
                            totalRowCount = totalRowCount + 1
                        }
                    }
                    print("******* Add item: \(itemLabel.labelText), rowCountIndex: \(rowCountIndex)")
                }
            }
            
            totalRowCount = totalRowCount + 1
            print("RecipeCell --> totalRowCounnt = \(totalRowCount)")
        }
        
        cellTotalHeight = cellTotalHeight + (ITEM_HEIGHT_SPACE + ITEM_HEIGHT)*(totalRowCount)
        self.cellHeight = cellTotalHeight + CELL_MARGIN_HEIGHT
    }
    
    func getCellHeight() -> Int {
        return self.cellHeight
    }
    
    @objc func itemClicked(_ sender: UITapGestureRecognizer) {
        print("Recipe Item clicked!!")
        let selectedItem = sender.view as! ShadowGradientView
        let index = selectedItem.getRecipeItemIndex()
   
        if self.favoriteProductRecipe.recipeSubCategoryDetail[index.mainCategoryIndex][index.subCategoryIndex].recipeDetail[index.itemIndex].checkedFlag {
            self.favoriteProductRecipe.recipeSubCategoryDetail[index.mainCategoryIndex][index.subCategoryIndex].recipeDetail[index.itemIndex].checkedFlag = false
            selectedItem.setUnSelected()
        } else {
            self.favoriteProductRecipe.recipeSubCategoryDetail[index.mainCategoryIndex][index.subCategoryIndex].recipeDetail[index.itemIndex].checkedFlag = true
            
            selectedItem.setSelected()
        }

        print("selected index: \(index)")
        updateRecipeItemStatus(selected_index: index)
        NotificationCenter.default.post(name: NSNotification.Name("ProductPriceUpdate"), object: self.favoriteProductRecipe)
    }
    
    func updateRecipeItemStatus(selected_index: RecipeItemControl) {
        var mainIndex: Int = 0
        var subIndex: Int = 0
        
        for i in 0...self.itemsControlTable.count - 1 {
            mainIndex = self.itemsControlTable[i].mainCategoryIndex
        }
        
        for i in 0...self.itemsControlTable.count - 1 {
            if self.itemsControlTable[i].mainCategoryIndex == selected_index.mainCategoryIndex {
                subIndex = self.itemsControlTable[i].subCategoryIndex
            }
        }
        
        if mainIndex > 0 {
            for i in 0...self.itemsControlTable.count - 1 {
                if self.itemsControlTable[i].mainCategoryIndex != selected_index.mainCategoryIndex {
                self.favoriteProductRecipe.recipeSubCategoryDetail[self.itemsControlTable[i].mainCategoryIndex][self.itemsControlTable[i].subCategoryIndex].recipeDetail[self.itemsControlTable[i].itemIndex].checkedFlag = false
                    self.itemViewArray[i].setUnSelected()
                } else {
                    if subIndex > 0 {
                        if self.itemsControlTable[i].subCategoryIndex == selected_index.subCategoryIndex {
                            if self.itemsControlTable[i].itemIndex != selected_index.itemIndex {
                            self.favoriteProductRecipe.recipeSubCategoryDetail[self.itemsControlTable[i].mainCategoryIndex][self.itemsControlTable[i].subCategoryIndex].recipeDetail[self.itemsControlTable[i].itemIndex].checkedFlag = false
                                self.itemViewArray[i].setUnSelected()
                            }
                        }
                    } else { //subIndex == 0
                        if self.itemsControlTable[i].itemIndex != selected_index.itemIndex {
                        self.favoriteProductRecipe.recipeSubCategoryDetail[self.itemsControlTable[i].mainCategoryIndex][self.itemsControlTable[i].subCategoryIndex].recipeDetail[self.itemsControlTable[i].itemIndex].checkedFlag = false
                            self.itemViewArray[i].setUnSelected()
                        }
                    }
                }
            }
        } else { //mainIndex == 0
            for i in 0...self.itemsControlTable.count - 1 {
                if subIndex > 0 {
                    if self.itemsControlTable[i].subCategoryIndex == selected_index.subCategoryIndex {
                        if self.itemsControlTable[i].itemIndex != selected_index.itemIndex {
                        self.favoriteProductRecipe.recipeSubCategoryDetail[self.itemsControlTable[i].mainCategoryIndex][self.itemsControlTable[i].subCategoryIndex].recipeDetail[self.itemsControlTable[i].itemIndex].checkedFlag = false
                            self.itemViewArray[i].setUnSelected()
                        }
                    }
                } else { //subIndex == 0
                    if self.itemsControlTable[i].itemIndex != selected_index.itemIndex {
                    self.favoriteProductRecipe.recipeSubCategoryDetail[self.itemsControlTable[i].mainCategoryIndex][self.itemsControlTable[i].subCategoryIndex].recipeDetail[self.itemsControlTable[i].itemIndex].checkedFlag = false
                        self.itemViewArray[i].setUnSelected()
                    }
                }
            }
        }
    }
}
