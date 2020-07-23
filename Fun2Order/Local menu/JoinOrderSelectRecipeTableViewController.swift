//
//  JoinOrderSelectRecipeTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/2/8.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

protocol JoinOrderSelectRecipeDelegate: class {
    //func setRecipe(menu_recipes: [MenuRecipe])
    func setRecipe(sender: JoinOrderSelectRecipeTableViewController, recipe_items: [MenuRecipe], quantity: Int, single_price: Int, comments: String)
}

class JoinOrderSelectRecipeTableViewController: UITableViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {
    @IBOutlet weak var labelProductName: UILabel!
    @IBOutlet weak var buttonAddToCart: UIButton!
    @IBOutlet weak var labelQuantity: UILabel!
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var textComments: UITextField!
    
    
    var menuInformation: MenuInformation = MenuInformation()
    var menuRecipes: [MenuRecipe] = [MenuRecipe]()
    var cellHeight = [Int]()
    weak var delegate: JoinOrderSelectRecipeDelegate?
    var isSelectRecipeMode: Bool = false
    var productName: String = ""
    var productQuantity: Int = 0
    var singlePrice: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.buttonAddToCart.layer.borderWidth = 1.0
        self.buttonAddToCart.layer.borderColor = UIColor.systemBlue.cgColor
        self.buttonAddToCart.layer.cornerRadius = 6
        
        self.labelProductName.text = self.productName
        
        let menuRecipeCellViewNib: UINib = UINib(nibName: "MenuRecipeCell", bundle: nil)
        self.tableView.register(menuRecipeCellViewNib, forCellReuseIdentifier: "MenuRecipeCell")
        
        self.labelPrice.text = String(self.singlePrice * self.productQuantity)
        self.cellHeight.removeAll()
        if self.menuInformation.menuRecipes != nil {
            self.cellHeight = Array(repeating: 0, count: self.menuInformation.menuRecipes!.count)
            for i in 0...self.menuInformation.menuRecipes!.count - 1 {
                self.menuRecipes.append(self.menuInformation.menuRecipes![i])
                if self.menuRecipes[i].recipeItems != nil {
                    for j in 0...self.menuRecipes[i].recipeItems!.count - 1 {
                        self.menuRecipes[i].recipeItems![j].checkedFlag = false
                    }
                }
            }
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
          textField.resignFirstResponder()
          return true
    }
    
    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }

    @IBAction func changeQuantity(_ sender: UIStepper) {
        self.productQuantity = Int(sender.value)
        self.labelQuantity.text = String(self.productQuantity)
    }
    
    @IBAction func confirmToCart(_ sender: UIButton) {
        if self.productQuantity == 0 {
            presentSimpleAlertMessage(title: "錯誤訊息", message: "尚未指定產品數量，請重新指定")
            return
        }
                
        var comments: String = ""
        if self.textComments.text != nil {
            comments = self.textComments.text!
        }
        
        self.delegate?.setRecipe(sender: self, recipe_items: self.menuRecipes, quantity: self.productQuantity, single_price: self.singlePrice, comments: comments)
        self.navigationController?.popViewController(animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            if self.menuInformation.menuRecipes == nil {
                return 0
            }
            
            return self.menuInformation.menuRecipes!.count
        }
        
        return super.tableView(tableView, numberOfRowsInSection: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*
        if indexPath.row == self.menuInformation.menuRecipes!.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BasicButtonCell", for: indexPath) as! BasicButtonCell
            
            let iconImage: UIImage = UIImage(named: "Icon_Menu_Recipe.png")!.withRenderingMode(.alwaysTemplate)
            cell.setData(icon: iconImage, button_text: "設定配方", action_type: BUTTON_ACTION_JOINORDER_SELECT_RECIPE)
            
            cell.delegate = self
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
        */

        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuRecipeCell", for: indexPath) as! MenuRecipeCell

            //cell.setData(recipe_data: self.menuInformation.menuRecipes![indexPath.row], number_for_row: 3)
            cell.isSelectRecipeMode = self.isSelectRecipeMode
            //cell.isSelectRecipeMode = true
            cell.setData(recipe_data: self.menuRecipes[indexPath.row], number_for_row: 3)
            cellHeight[indexPath.row] = cell.getCellHeight()
            cell.tag = indexPath.row
            cell.delegate = self
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return CGFloat(cellHeight[indexPath.row])
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }

    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        if indexPath.section == 1 {
            let newIndexPath = IndexPath(row: 0, section: indexPath.section)
            return super.tableView(tableView, indentationLevelForRowAt: newIndexPath)
        } else {
            return super.tableView(tableView, indentationLevelForRowAt: indexPath)
        }
    }
}

extension JoinOrderSelectRecipeTableViewController: MenuRecipeCellDelegate {
    func setMenuRecipe(cell: UITableViewCell, menu_recipe: MenuRecipe, data_index: Int) {
        self.menuRecipes[data_index] = menu_recipe
    }

    func addRecipeItem(cell: UITableViewCell, menu_recipe: MenuRecipe, data_index: Int) {
        self.menuRecipes[data_index] = menu_recipe
        self.tableView.reloadData()
    }
}
