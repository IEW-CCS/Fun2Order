//
//  OrderProductListTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/5/31.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

class OrderProductListTableViewController: UITableViewController {
    var memberContent: MenuOrderMemberContent = MenuOrderMemberContent()

    override func viewDidLoad() {
        super.viewDidLoad()

        let productCellViewNib: UINib = UINib(nibName: "NewProductCell", bundle: nil)
        self.tableView.register(productCellViewNib, forCellReuseIdentifier: "NewProductCell")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.memberContent.orderContent.menuProductItems == nil {
            return 0
        } else {
            return self.memberContent.orderContent.menuProductItems!.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewProductCell", for: indexPath) as! NewProductCell
        if self.memberContent.orderContent.menuProductItems != nil {
            cell.setData(item: self.memberContent.orderContent.menuProductItems![indexPath.row])
            cell.AdjustAutoLayout()
        }
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.tag = indexPath.row
        
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

}
