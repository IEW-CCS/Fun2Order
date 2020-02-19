//
//  MenuLocationTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/1/9.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

protocol MenuLocationDelegate: class {
    func deleteMenuLocation(locations: [String]?)
}

class MenuLocationTableViewController: UITableViewController {
    //var locationArray: [String] = [String]()
    var locationArray: [String]?
    weak var delegate: MenuLocationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let locationNib: UINib = UINib(nibName: "MenuLocationCell", bundle: nil)
        self.tableView.register(locationNib, forCellReuseIdentifier: "MenuLocationCell")
        
        //print("viewDidLoad locationArray = \(self.locationArray)")
        self.tableView.reloadData()
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
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        var alertWindow: UIWindow!
        if editingStyle == .delete {
            let controller = UIAlertController(title: "刪除地點", message: "確定要刪除此地點資訊嗎？", preferredStyle: .alert)

            let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
                print("Confirm to delete this location")
                if self.locationArray != nil {
                    self.locationArray!.remove(at: indexPath.row)
                } else {
                    return
                }
                
                if self.locationArray!.isEmpty {
                    self.delegate?.deleteMenuLocation(locations: nil)
                } else {
                    self.delegate?.deleteMenuLocation(locations: self.locationArray)
                }
                self.tableView.reloadData()
                alertWindow.isHidden = true
            }
            
            controller.addAction(okAction)
            let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (_) in
                print("Cancel to delete the location")
                alertWindow.isHidden = true
            }
            controller.addAction(cancelAction)
            alertWindow = presentAlert(controller)
        }
    }

}
