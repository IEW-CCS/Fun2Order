//
//  MenuLocationTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/1/9.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

class MenuLocationTableViewController: UITableViewController {
    //var locationArray: [String] = [String]()
    var locationArray: [String]?
    
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

}
