//
//  JoinOrderSelectRecipeTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/2/8.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

protocol JoinOrderSelectRecipeDelegate: class {
    func setRecipe(menu_recipes: [MenuRecipe])
}

class JoinOrderSelectRecipeTableViewController: UITableViewController {
    var menuInformation: MenuInformation = MenuInformation()
    var menuRecipes: [MenuRecipe] = [MenuRecipe]()
    var cellHeight = [Int]();
    weak var delegate: JoinOrderSelectRecipeDelegate?
    var isSelectRecipeMode: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let menuRecipeCellViewNib: UINib = UINib(nibName: "MenuRecipeCell", bundle: nil)
        self.tableView.register(menuRecipeCellViewNib, forCellReuseIdentifier: "MenuRecipeCell")
        
        let basicButtonCellViewNib: UINib = UINib(nibName: "BasicButtonCell", bundle: nil)
        self.tableView.register(basicButtonCellViewNib, forCellReuseIdentifier: "BasicButtonCell")

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
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.menuInformation.menuRecipes == nil {
            return 0
        }
        
        return self.menuInformation.menuRecipes!.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == self.menuInformation.menuRecipes!.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BasicButtonCell", for: indexPath) as! BasicButtonCell
            
            let iconImage: UIImage = UIImage(named: "Icon_Menu_Recipe.png")!
            cell.setData(icon: iconImage, button_text: "設定配方", action_type: BUTTON_ACTION_JOINORDER_SELECT_RECIPE)
            
            cell.delegate = self
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }

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

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == self.menuInformation.menuRecipes!.count {
            return 54
        }
        
        return CGFloat(cellHeight[indexPath.row])
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

extension JoinOrderSelectRecipeTableViewController: BasicButtonDelegate {
    func joinOrderToSelectRecipe(sender: BasicButtonCell) {
        delegate?.setRecipe(menu_recipes: self.menuRecipes)
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: false, completion: nil)
    }
}
