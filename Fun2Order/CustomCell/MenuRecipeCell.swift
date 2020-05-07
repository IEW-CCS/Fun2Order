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
    func addRecipeItem(cell: UITableViewCell, menu_recipe: MenuRecipe, data_index: Int)
}

class MenuRecipeCell: UITableViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    weak var delegate: MenuRecipeCellDelegate?
    var menuRecipe: MenuRecipe = MenuRecipe()
    var savedMenuRecipe: MenuRecipe = MenuRecipe()
    var cellHeight: Int = 0
    var isSelectRecipeMode: Bool = false
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
    
    func setData(recipe_data: MenuRecipe, number_for_row: Int) {
        if self.menuRecipe.recipeItems != nil {
            self.menuRecipe.recipeItems?.removeAll()
        } //else {
          //  print("MenuRecipeCell -> self.menuRecipe.recipeItems is nil")
          //  return
        //}
        
        self.menuRecipe = recipe_data
        self.numberForRow = number_for_row
        self.titleLabel.text = recipe_data.recipeCategory
        
        let ITEM_HEIGHT = 36
        let LABEL_WIDTH = 90
        let BUTTON_WIDTH = 36
        let ITEM_WIDTH_SPACE = 5
        let ITEM_HEIGHT_SPACE = 5
        let CELL_MARGIN_HEIGHT = 15
        let ITEM_WIDTH = ITEM_WIDTH_SPACE + LABEL_WIDTH
        var cellTotalHeight: Int = 0
        
        //titleLabel.centerXAnchor.constraint(equalTo: backView.centerXAnchor).isActive = true
        //titleLabel.centerYAnchor.constraint(equalTo: backView.centerYAnchor).isActive = true
        for view in self.subviews {
            if view.isKind(of: ShadowGradientView.self) || view.isKind(of: UIButton.self){
                view.removeFromSuperview()
            }
        }
        
        cellTotalHeight = Int(backView.frame.height)
        
        var rowCountIndex: Int = 0
        var totalRowCount: Int = 0
        let initMargin: Int = 15
        var itemY2: CGFloat = 0
        
        //if recipe_data.recipeItems!.isEmpty {
        if recipe_data.recipeItems == nil {
            //totalRowCount = totalRowCount + 1
            if !self.isSelectRecipeMode {
                rowCountIndex = totalRowCount
                itemY2 = CGFloat(self.backView.frame.maxY + CGFloat((ITEM_HEIGHT_SPACE + ITEM_HEIGHT)*rowCountIndex + 8))
                let buttonRect = CGRect(x: CGFloat(self.backView.frame.minX + CGFloat(ITEM_WIDTH_SPACE + initMargin)), y: CGFloat(itemY2), width: CGFloat(BUTTON_WIDTH), height: CGFloat(ITEM_HEIGHT))

                let addButton = UIButton(frame: buttonRect)
                addButton.setImage(UIImage(named: "Icon_Add_Group.png")!, for: .normal)
                //addButton.setImage(UIImage(named: "Add_Icon.png")!, for: .normal)
                addButton.imageView?.contentMode = .scaleAspectFit
                if let tintImageAdd = addButton.imageView?.image {
                    let colorlessImage = tintImageAdd.withRenderingMode(.alwaysTemplate)
                    addButton.imageView?.image = colorlessImage
                    addButton.imageView?.tintColor = UIColor.lightGray
                }

                self.addSubview(addButton)
                
                let tapGesture = UITapGestureRecognizer(target: self, action:#selector(self.addItemClicked(_:)))
                addButton.addGestureRecognizer(tapGesture)
                cellTotalHeight = cellTotalHeight + (ITEM_HEIGHT_SPACE + ITEM_HEIGHT)*(totalRowCount + 1)
                self.cellHeight = cellTotalHeight + CELL_MARGIN_HEIGHT
            } else {
                cellTotalHeight = cellTotalHeight + (ITEM_HEIGHT_SPACE + ITEM_HEIGHT)*(totalRowCount + 1)
                self.cellHeight = cellTotalHeight + CELL_MARGIN_HEIGHT
            }
            
            return
        }
        
        for index in 0...recipe_data.recipeItems!.count {
            let mod_number = index%number_for_row
            rowCountIndex = totalRowCount
            itemY2 = CGFloat(self.backView.frame.maxY + CGFloat((ITEM_HEIGHT_SPACE + ITEM_HEIGHT)*rowCountIndex + 8))
            let itemRect = CGRect(x: CGFloat(self.backView.frame.minX + CGFloat(ITEM_WIDTH_SPACE + ITEM_WIDTH * mod_number + initMargin)), y: CGFloat(itemY2), width: CGFloat(LABEL_WIDTH), height: CGFloat(ITEM_HEIGHT))
            
            // Add the "Add" button as the last item of this recipe category
            if index == recipe_data.recipeItems!.count {
                if !self.isSelectRecipeMode {
                    if mod_number == 0 {
                        totalRowCount = totalRowCount + 1
                    }
                    rowCountIndex = totalRowCount
                    itemY2 = CGFloat(self.backView.frame.maxY + CGFloat((ITEM_HEIGHT_SPACE + ITEM_HEIGHT)*rowCountIndex + 8))
                    let buttonRect = CGRect(x: CGFloat(self.backView.frame.minX + CGFloat(ITEM_WIDTH_SPACE + ITEM_WIDTH * mod_number + initMargin)), y: CGFloat(itemY2), width: CGFloat(BUTTON_WIDTH), height: CGFloat(ITEM_HEIGHT))

                    let addButton = UIButton(frame: buttonRect)
                    addButton.setImage(UIImage(named: "Icon_Add_Group.png")!, for: .normal)
                    //addButton.setImage(UIImage(named: "Add_Icon.png.png")!, for: .normal)
                    addButton.imageView?.contentMode = .scaleAspectFit
                    if let tintImageAdd = addButton.imageView?.image {
                        let colorlessImage = tintImageAdd.withRenderingMode(.alwaysTemplate)
                        addButton.imageView?.image = colorlessImage
                        addButton.imageView?.tintColor = UIColor.lightGray
                    }

                    self.addSubview(addButton)
                    
                    let tapGesture = UITapGestureRecognizer(target: self, action:#selector(self.addItemClicked(_:)))
                    addButton.addGestureRecognizer(tapGesture)
                    
                    if (mod_number == (number_for_row - 1)) {
                        if !(index == (recipe_data.recipeItems!.count)) {
                            totalRowCount = totalRowCount + 1
                        }
                    }
                }
                continue
            }
            
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

    @objc func addItemClicked(_ sender: UITapGestureRecognizer) {
        print("Click add button !!")
        var alertWindow: UIWindow!
        var sequenceNumber: Int = 0
        
        let controller = UIAlertController(title: "請輸入配方項目名稱", message: nil, preferredStyle: .alert)
        controller.addTextField { (textField) in
            textField.placeholder = "輸入項目名稱"
        }
        
        let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
            let itemName = controller.textFields?[0].text
            if itemName == nil || itemName! == "" {
                presentSimpleAlertMessage(title: "錯誤訊息", message: "輸入的配方項目名稱不能為空白，請重新輸入")
                alertWindow.isHidden = true
                return
            }
            
            var recipeItem: RecipeItem = RecipeItem()
            recipeItem.recipeName = itemName!
            recipeItem.checkedFlag = true
            
            //if !self.menuRecipe.recipeItems!.isEmpty {
            if self.menuRecipe.recipeItems != nil {
                for i in 0...self.menuRecipe.recipeItems!.count - 1 {
                    if self.menuRecipe.recipeItems![i].sequenceNumber > sequenceNumber {
                        sequenceNumber = self.menuRecipe.recipeItems![i].sequenceNumber
                    }
                }
                sequenceNumber = sequenceNumber + 1
            } else {
                self.menuRecipe.recipeItems = [RecipeItem]()
                sequenceNumber = 1
            }
            
            recipeItem.sequenceNumber = sequenceNumber
            self.menuRecipe.recipeItems!.append(recipeItem)
            self.savedMenuRecipe = self.menuRecipe
            self.setData(recipe_data: self.savedMenuRecipe, number_for_row: self.numberForRow)
            self.delegate?.addRecipeItem(cell: self, menu_recipe: self.savedMenuRecipe, data_index: self.tag)
            alertWindow.isHidden = true
        }
        controller.addAction(okAction)
        
        //let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (_) in
            print("Cancel the action")
            alertWindow.isHidden = true
        }
        controller.addAction(cancelAction)
        alertWindow = presentAlert(controller)
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
            
            if !self.menuRecipe.allowedMultiFlag {  //Allow to Select only one recipe item
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
                if self.menuRecipe.recipeItems![index].checkedFlag {
                    selectedItem.setSelected()
                } else {
                    selectedItem.setUnSelected()
                }
            }
        }
    }

}
