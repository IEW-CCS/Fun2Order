//
//  CartTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/21.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class CartTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let cartGroupCellViewNib: UINib = UINib(nibName: "CartGroupCell", bundle: nil)
        self.tableView.register(cartGroupCellViewNib, forCellReuseIdentifier: "CartGroupCell")

        let payCellViewNib: UINib = UINib(nibName: "PayCell", bundle: nil)
        self.tableView.register(payCellViewNib, forCellReuseIdentifier: "PayCell")

    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CartGroupCell", for: indexPath) as! CartGroupCell
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PayCell", for: indexPath) as! PayCell
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 360
        }
        
        return 120
    }
}
