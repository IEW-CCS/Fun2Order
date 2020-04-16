//
//  MenuItemTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/1/9.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

protocol MenuItemDelegate: class {
    func deleteMenuItem(menu_items: [MenuItem]?)
}

class MenuItemTableViewController: UITableViewController {

    var menuItemArray: [MenuItem]?
    weak var delegate: MenuItemDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let itemNib: UINib = UINib(nibName: "MenuItemCell", bundle: nil)
        self.tableView.register(itemNib, forCellReuseIdentifier: "MenuItemCell")
        
        //print("viewDidLoad menuItemArray = \(self.menuItemArray)")
        self.tableView.reloadData()

    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        //if self.menuItemArray.isEmpty {
        if self.menuItemArray == nil {
            return 0
        }
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //if self.menuItemArray.isEmpty {
        if self.menuItemArray == nil {
            return 0
        }
        
        return self.menuItemArray!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell", for: indexPath) as! MenuItemCell

        cell.setData(name: self.menuItemArray![indexPath.row].itemName, price: String(self.menuItemArray![indexPath.row].itemPrice))
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }

    /*
        override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
            let delete = UITableViewRowAction(style: .default, title: "刪除") { (action, indexPath) in

            }

            return [delete]
        }
    */

    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "刪除"
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        var alertWindow: UIWindow!
        if editingStyle == .delete {
            let controller = UIAlertController(title: "刪除產品", message: "確定要刪除此產品資訊嗎？", preferredStyle: .alert)

            let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
                print("Confirm to delete this menu item")
                if self.menuItemArray != nil {
                    self.menuItemArray!.remove(at: indexPath.row)
                } else {
                    return
                }
                
                if self.menuItemArray!.isEmpty {
                    self.delegate?.deleteMenuItem(menu_items: nil)
                } else {
                    self.delegate?.deleteMenuItem(menu_items: self.menuItemArray)
                }
                self.tableView.reloadData()
                alertWindow.isHidden = true
            }
            
            controller.addAction(okAction)
            let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (_) in
                print("Cancel to delete the menu item")
                alertWindow.isHidden = true
            }
            controller.addAction(cancelAction)
            alertWindow = presentAlert(controller)
        }
    }
    
}
