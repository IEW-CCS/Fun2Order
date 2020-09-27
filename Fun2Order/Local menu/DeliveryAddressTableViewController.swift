//
//  DeliveryAddressTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/9/20.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

protocol DeliveryAddressDelegate: class {
    func getSelectedDeliveryAddress(sender: DeliveryAddressTableViewController, address: String)
}

class DeliveryAddressTableViewController: UITableViewController {
    var addressList: [FavoriteAddress] = [FavoriteAddress]()
    @IBOutlet weak var barButtonAddAddress: UIBarButtonItem!
    @IBOutlet weak var barButtonConfirmSelect: UIBarButtonItem!
    
    var selectedIndex: Int = -1
    weak var delegate: DeliveryAddressDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let locationNib: UINib = UINib(nibName: "MenuLocationCell", bundle: nil)
        self.tableView.register(locationNib, forCellReuseIdentifier: "MenuLocationCell")

        self.addressList = retrieveFavoriteAddress()
    }
    
    @IBAction func addNewDeliveryAddress(_ sender: UIBarButtonItem) {
        let controller = UIAlertController(title: "請輸入外送地址", message: nil, preferredStyle: .alert)
        controller.addTextField { (textField) in
            textField.placeholder = "外送地址"
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .default) { (_) in
            print("Cancel to add address!")
        }
        
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        controller.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
            let address_string = controller.textFields?[0].text
            if address_string == nil || address_string!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                presentSimpleAlertMessage(title: "錯誤訊息", message: "外送地址不可為空白，請重新輸入")
                return
            }
            
            insertFavoriteAddress(favorite_address: address_string!)
            self.addressList = retrieveFavoriteAddress()

            self.tableView.reloadData()
        }
        okAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        controller.addAction(okAction)
        
        present(controller, animated: true, completion: nil)

    }
    
    @IBAction func confirmSelectedDeliveryAddress(_ sender: UIBarButtonItem) {
        if self.selectedIndex == -1 {
            presentSimpleAlertMessage(title: "錯誤訊息", message: "尚未選取任何外送地址，請重新選取")
            return
        }
        
        self.delegate?.getSelectedDeliveryAddress(sender: self, address: self.addressList[self.selectedIndex].favoriteAddress)
        self.navigationController?.popViewController(animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.addressList.isEmpty {
            return 0
        }
        
        return self.addressList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuLocationCell", for: indexPath) as! MenuLocationCell

        cell.setData(location_id: self.addressList[indexPath.row].favoriteAddress)
        //cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "刪除") { (action, indexPath) in
            self.deleteAddress(index: indexPath.row)
        }
                
        let editAction = UITableViewRowAction(style: .default, title: "編輯") { (action, indexPath) in
            self.editAddress(index: indexPath.row)
        }
        editAction.backgroundColor = UIColor.systemBlue
        
        return [deleteAction, editAction]
    }

    func deleteAddress(index: Int) {
        var alertWindow: UIWindow!
        let controller = UIAlertController(title: "刪除地點", message: "確定要刪除此外送地址嗎？", preferredStyle: .alert)

        let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
            print("Confirm to delete this address")
            if !self.addressList.isEmpty {
                deleteFavoriteAddress(favorite_address: self.addressList[index].favoriteAddress)
                self.addressList.remove(at: index)
            } else {
                alertWindow.isHidden = true
                return
            }
            
            self.tableView.reloadData()
            alertWindow.isHidden = true
        }
        
        controller.addAction(okAction)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (_) in
            print("Cancel to delete this location")
            alertWindow.isHidden = true
        }
        controller.addAction(cancelAction)
        alertWindow = presentAlert(controller)
    }
    
    func editAddress(index: Int) {
        var alertWindow: UIWindow!

        let controller = UIAlertController(title: "請編輯外送地址", message: nil, preferredStyle: .alert)
        controller.addTextField { (textField) in
            textField.placeholder = "外送地址"
            textField.text = self.addressList[index].favoriteAddress
        }

        let cancelAction = UIAlertAction(title: "取消", style: .default) { (_) in
            print("Cancel to update address")
            alertWindow.isHidden = true
        }
        
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        controller.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
            let address_string = controller.textFields?[0].text
            if address_string == nil || address_string!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                presentSimpleAlertMessage(title: "錯誤訊息", message: "輸入的外送地址不能為空白，請重新輸入")
                alertWindow.isHidden = true
                return
            }
            
            if self.addressList.contains(where: { $0.favoriteAddress == address_string! }) {
                presentSimpleAlertMessage(title: "錯誤訊息", message: "編輯的外送地址已重複，請重新輸入外送地址")
                alertWindow.isHidden = true
                return
            }
            
            deleteFavoriteAddress(favorite_address: self.addressList[index].favoriteAddress)
            insertFavoriteAddress(favorite_address: address_string!)
            
            self.addressList = retrieveFavoriteAddress()
            
            self.tableView.reloadData()
            alertWindow.isHidden = true
        }
        okAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        controller.addAction(okAction)
        
        alertWindow = presentAlert(controller)
    }
    
    /*
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let addressData: String = self.addressList[sourceIndexPath.row]
        self.addressList.remove(at: sourceIndexPath.row)
        self.addressList.insert(addressData, at: destinationIndexPath.row)
        
        //self.delegate?.updateMenuLocation(locations: self.locationArray)
    }
    */

}
