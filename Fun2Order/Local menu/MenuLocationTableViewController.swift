//
//  MenuLocationTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/1/9.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

protocol MenuLocationDelegate: class {
    func updateMenuLocation(locations: [String]?)
}

class MenuLocationTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    //var locationArray: [String] = [String]()
    var locationArray: [String]?
    weak var delegate: MenuLocationDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        let locationNib: UINib = UINib(nibName: "MenuLocationCell", bundle: nil)
        self.tableView.register(locationNib, forCellReuseIdentifier: "MenuLocationCell")
        
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
        if self.locationArray == nil {
            return 0
        }
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //if self.locationArray.isEmpty {
        if self.locationArray == nil {
            return 0
        }
        
        return self.locationArray!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuLocationCell", for: indexPath) as! MenuLocationCell

        cell.setData(location_id: self.locationArray![indexPath.row])
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
            self.deleteLocation(index: indexPath.row)
        }
        
        let copyAction = UITableViewRowAction(style: .default, title: "複製") { (action, indexPath) in
            self.copyLocation(index: indexPath.row)
        }
        copyAction.backgroundColor = UIColor.systemPurple
        
        let editAction = UITableViewRowAction(style: .default, title: "編輯") { (action, indexPath) in
            //presentSimpleAlertMessage(title: "Test", message: "Press Edit Action")
            self.editLocation(index: indexPath.row)
        }
        editAction.backgroundColor = UIColor.systemBlue
        
        return [deleteAction, copyAction, editAction]
    }

    func deleteLocation(index: Int) {
        var alertWindow: UIWindow!
        let controller = UIAlertController(title: "刪除地點", message: "確定要刪除此地點資訊嗎？", preferredStyle: .alert)

        let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
            print("Confirm to delete this location")
            if self.locationArray != nil {
                self.locationArray!.remove(at: index)
            } else {
                alertWindow.isHidden = true
                return
            }
            
            if self.locationArray!.isEmpty {
                self.delegate?.updateMenuLocation(locations: nil)
            } else {
                self.delegate?.updateMenuLocation(locations: self.locationArray)
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
    
    func copyLocation(index: Int) {
        var alertWindow: UIWindow!

        let controller = UIAlertController(title: "請輸入地點名稱", message: nil, preferredStyle: .alert)
        controller.addTextField { (textField) in
            textField.placeholder = "地點名稱"
            textField.text = self.locationArray![index]
        }

        let cancelAction = UIAlertAction(title: "取消", style: .default) { (_) in
            print("Cancel to update product & price!")
            alertWindow.isHidden = true
        }
        
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        controller.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
            let location_string = controller.textFields?[0].text
            if location_string == nil || location_string!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                presentSimpleAlertMessage(title: "錯誤訊息", message: "輸入的地點名稱不能為空白，請重新輸入")
                alertWindow.isHidden = true
                return
            }
            
            if !self.locationArray!.isEmpty {
                for i in 0...self.locationArray!.count - 1 {
                    if self.locationArray![i] == location_string! {
                        presentSimpleAlertMessage(title: "錯誤訊息", message: "地點名稱不能重複，請重新輸入新地點名稱")
                        alertWindow.isHidden = true
                        return
                    }
                }
            }

            self.locationArray?.insert(location_string!, at: index + 1)
            self.delegate?.updateMenuLocation(locations: self.locationArray)
            self.tableView.reloadData()
            alertWindow.isHidden = true
        }
        okAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        controller.addAction(okAction)
        
        alertWindow = presentAlert(controller)
    }
    
    func editLocation(index: Int) {
        var alertWindow: UIWindow!

        let controller = UIAlertController(title: "請輸入地點名稱", message: nil, preferredStyle: .alert)
        controller.addTextField { (textField) in
            textField.placeholder = "地點名稱"
            textField.text = self.locationArray![index]
        }

        let cancelAction = UIAlertAction(title: "取消", style: .default) { (_) in
            print("Cancel to update location")
            alertWindow.isHidden = true
        }
        
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        controller.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
            let location_string = controller.textFields?[0].text
            if location_string == nil || location_string!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                presentSimpleAlertMessage(title: "錯誤訊息", message: "輸入的地點名稱不能為空白，請重新輸入")
                alertWindow.isHidden = true
                return
            }
            
            if !self.locationArray!.isEmpty {
                for i in 0...self.locationArray!.count - 1 {
                    if i == index {
                        continue
                    }
                    
                    if self.locationArray![i] == location_string {
                        presentSimpleAlertMessage(title: "錯誤訊息", message: "產品名稱不能重複，請重新輸入新產品名稱")
                        alertWindow.isHidden = true
                        return
                    }
                }
            }

            self.locationArray![index] = location_string!
            self.delegate?.updateMenuLocation(locations: self.locationArray)
            self.tableView.reloadData()
            alertWindow.isHidden = true
        }
        okAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        controller.addAction(okAction)
        
        alertWindow = presentAlert(controller)
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let locationData: String = self.locationArray![sourceIndexPath.row]
        self.locationArray!.remove(at: sourceIndexPath.row)
        self.locationArray!.insert(locationData, at: destinationIndexPath.row)
        
        self.delegate?.updateMenuLocation(locations: self.locationArray)
    }

}
