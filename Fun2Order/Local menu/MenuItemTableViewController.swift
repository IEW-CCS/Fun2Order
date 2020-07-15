//
//  MenuItemTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/1/9.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

protocol MenuItemDelegate: class {
    func updateMenuItem(menu_items: [MenuItem]?)
}

class MenuItemTableViewController: UITableViewController, UIGestureRecognizerDelegate {

    var menuItemArray: [MenuItem]?
    weak var delegate: MenuItemDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let itemNib: UINib = UINib(nibName: "MenuItemCell", bundle: nil)
        self.tableView.register(itemNib, forCellReuseIdentifier: "MenuItemCell")
        
        //print("viewDidLoad menuItemArray = \(self.menuItemArray)")
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPressEditCell(_:)))
        longPressGesture.delegate = self
        self.tableView.addGestureRecognizer(longPressGesture)

        self.tableView.reloadData()

    }

    @objc func handleLongPressEditCell(_ sender: UILongPressGestureRecognizer) {
        if(sender.state == .began) {
            self.tableView.setEditing(!self.tableView.isEditing, animated: true)
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        //if self.menuItemArray.isEmpty {
        if self.menuItemArray == nil {
            return 0
        }
        
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //if self.menuItemArray.isEmpty {
        if section == 0 {
            return 1
        }
        
        if self.menuItemArray == nil {
            return 0
        }
        
        return self.menuItemArray!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell", for: indexPath) as! MenuItemCell

        if indexPath.section == 0 {
            cell.setProductInfo(product_info: MenuItem(), type: MENU_ITEM_CELL_TYPE_LIMIT_HEADER)
        } else {
            cell.setProductInfo(product_info: self.menuItemArray![indexPath.row], type: MENU_ITEM_CELL_TYPE_LIMIT_BODY)
        }
        //cell.setData(name: self.menuItemArray![indexPath.row].itemName, price: String(self.menuItemArray![indexPath.row].itemPrice))
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        }
        
        return true
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "刪除") { (action, indexPath) in
            self.deleteProduct(index: indexPath.row)
        }
        
        let copyAction = UITableViewRowAction(style: .default, title: "複製") { (action, indexPath) in
            self.copyProduct(index: indexPath.row)
        }
        copyAction.backgroundColor = UIColor.systemPurple
        
        let editAction = UITableViewRowAction(style: .default, title: "編輯") { (action, indexPath) in
            //presentSimpleAlertMessage(title: "Test", message: "Press Edit Action")
            self.editProduct(index: indexPath.row)
        }
        editAction.backgroundColor = UIColor.systemBlue
        
        return [deleteAction, copyAction, editAction]
    }

    func deleteProduct(index: Int) {
        var alertWindow: UIWindow!
        let controller = UIAlertController(title: "刪除產品", message: "確定要刪除此產品資訊嗎？", preferredStyle: .alert)

        let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
            print("Confirm to delete this menu item")
            if self.menuItemArray != nil {
                self.menuItemArray!.remove(at: index)
            } else {
                alertWindow.isHidden = true
                return
            }
            
            if self.menuItemArray!.isEmpty {
                self.delegate?.updateMenuItem(menu_items: nil)
            } else {
                self.delegate?.updateMenuItem(menu_items: self.menuItemArray)
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
    
    func copyProduct(index: Int) {
        let controller = UIAlertController(title: "請輸入產品相關資訊", message: nil, preferredStyle: .alert)

        guard let productController = self.storyboard?.instantiateViewController(withIdentifier: "BASIC_PRODUCT_VC") as? BasicProductViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: BASIC_PRODUCT_VC can't find!! (BasicProductViewController)")
            return
        }

        productController.preferredContentSize.height = 250
        controller.preferredContentSize.height = 250
        productController.preferredContentSize.width = 320
        controller.preferredContentSize.width = 320
        controller.setValue(productController, forKey: "contentViewController")
        controller.addChild(productController)
        productController.productIndex = index
        productController.operationMode = PRODUCT_OPERATION_MODE_COPY
        productController.setData(product_item: self.menuItemArray![index])
        productController.delegate = self
        
        present(controller, animated: true, completion: nil)
    }
    
    func editProduct(index: Int) {
        let controller = UIAlertController(title: "請輸入產品相關資訊", message: nil, preferredStyle: .alert)

        guard let productController = self.storyboard?.instantiateViewController(withIdentifier: "BASIC_PRODUCT_VC") as? BasicProductViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: BASIC_PRODUCT_VC can't find!! (BasicProductViewController)")
            return
        }

        productController.preferredContentSize.height = 250
        controller.preferredContentSize.height = 250
        productController.preferredContentSize.width = 320
        controller.preferredContentSize.width = 320
        controller.setValue(productController, forKey: "contentViewController")
        controller.addChild(productController)
        productController.productIndex = index
        productController.operationMode = PRODUCT_OPERATION_MODE_EDIT
        productController.setData(product_item: self.menuItemArray![index])
        productController.delegate = self
        
        present(controller, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        } else {
            return true
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let menuData: MenuItem = self.menuItemArray![sourceIndexPath.row]
        self.menuItemArray!.remove(at: sourceIndexPath.row)
        self.menuItemArray!.insert(menuData, at: destinationIndexPath.row)
        
        for i in 0...self.menuItemArray!.count - 1 {
            self.menuItemArray![i].sequenceNumber = i + 1
        }
        self.delegate?.updateMenuItem(menu_items: self.menuItemArray)
    }
}

extension MenuItemTableViewController: BasicProductDelegate {
    func copyBasicProductInformation(sender: BasicProductViewController, product_info: MenuItem) {
        print("MenuItemTableViewController BasicProductDelegate receive addBasicProductInformation")
        print("product_info = \(product_info)")
        let product = product_info
        if !self.menuItemArray!.isEmpty {
            for i in 0...self.menuItemArray!.count - 1 {
                if self.menuItemArray![i].itemName == product.itemName {
                    presentSimpleAlertMessage(title: "錯誤訊息", message: "產品名稱不能重複，請重新輸入新產品名稱")
                    return
                }
            }
        }

        self.menuItemArray?.insert(product, at: sender.productIndex + 1)
        for i in 0...self.menuItemArray!.count - 1 {
            self.menuItemArray![i].sequenceNumber = i + 1
        }
        self.delegate?.updateMenuItem(menu_items: self.menuItemArray)
        self.tableView.reloadData()
    }
    
    func editBasicProductInformation(sender: BasicProductViewController, product_info: MenuItem) {
        var editItem = product_info
        if !self.menuItemArray!.isEmpty {
            for i in 0...self.menuItemArray!.count - 1 {
                if i == sender.productIndex {
                    continue
                }
                
                if self.menuItemArray![i].itemName == editItem.itemName {
                    presentSimpleAlertMessage(title: "錯誤訊息", message: "產品名稱不能重複，請重新輸入新產品名稱")
                    return
                }
            }
        }
        editItem.sequenceNumber = self.menuItemArray![sender.productIndex].sequenceNumber

        self.menuItemArray![sender.productIndex] = editItem
        self.delegate?.updateMenuItem(menu_items: self.menuItemArray)
        self.tableView.reloadData()
    }
}
