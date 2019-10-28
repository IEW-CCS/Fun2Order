//
//  RecipeTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/19.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class RecipeTableViewController: UITableViewController {
    let titleArray: [String] = ["Size", "Suger", "Ice", "Ingredient"]
    let itemData: [[String]] = [["小", "中", "大"],
                                ["無糖", "微糖", "半糖", "少糖", "全糖"],
                                ["去冰", "微冰", "少冰", "正常", "去冰", "微冰", "少冰", "正常"],
                                ["珍珠", "波霸", "椰果", "仙草","珍珠", "波霸", "椰果", "仙草"]]

    var itemHeight = [Int]();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let detailCellViewNib: UINib = UINib(nibName: "RecipeCell", bundle: nil)
        self.tableView.register(detailCellViewNib, forCellReuseIdentifier: "RecipeCell")
        
        let quantityCellViewNib: UINib = UINib(nibName: "QuantityCell", bundle: nil)
        self.tableView.register(quantityCellViewNib, forCellReuseIdentifier: "QuantityCell")

        let basicButtonCellViewNib: UINib = UINib(nibName: "BasicButtonCell", bundle: nil)
        self.tableView.register(basicButtonCellViewNib, forCellReuseIdentifier: "BasicButtonCell")
        
        itemHeight = Array(repeating: 0, count: titleArray.count)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count + 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == self.titleArray.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "QuantityCell", for: indexPath) as! QuantityCell
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
        
        if indexPath.row == self.titleArray.count + 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BasicButtonCell", for: indexPath) as! BasicButtonCell
            
            let iconImage: UIImage = UIImage(named: "Icon_Favorite3.png")!
            cell.setData(icon: iconImage, button_text: "Add To Favorite")
 
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
        
        if indexPath.row == self.titleArray.count + 2 {
           let cell = tableView.dequeueReusableCell(withIdentifier: "BasicButtonCell", for: indexPath) as! BasicButtonCell
           
           let iconImage: UIImage = UIImage(named: "Icon_Cart_Red.png")!
           cell.setData(icon: iconImage, button_text: "Add To Car")

           cell.selectionStyle = UITableViewCell.SelectionStyle.none
           return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath) as! RecipeCell
        
        cell.setItemData(title: titleArray[indexPath.row], item_array: itemData[indexPath.row], number_for_row: 3)
        cell.cellHeight = cell.getCellHeight()
        itemHeight[indexPath.row] = cell.getCellHeight()
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
    }

    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row >= self.titleArray.count {
            if indexPath.row == self.titleArray.count  {
                return 74
            }
            
            return 54
        }
        
        return CGFloat(itemHeight[indexPath.row])
    }
    
}
