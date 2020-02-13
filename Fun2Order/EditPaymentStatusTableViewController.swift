//
//  EditPaymentStatusTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/1/20.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

class EditPaymentStatusTableViewController: UITableViewController {
    var menuOrder: MenuOrder = MenuOrder()
    var acceptedItems: [MenuOrderMemberContent] = [MenuOrderMemberContent]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        let editPaymentCellViewNib: UINib = UINib(nibName: "EditPaymentCell", bundle: nil)
        self.tableView.register(editPaymentCellViewNib, forCellReuseIdentifier: "EditPaymentCell")

        getAcceptedItems()
    }

    func getAcceptedItems() {
        if !self.menuOrder.contentItems.isEmpty {
            for i in 0...self.menuOrder.contentItems.count - 1 {
                if self.menuOrder.contentItems[i].orderContent.replyStatus == MENU_ORDER_REPLY_STATUS_ACCEPT {
                    self.acceptedItems.append(self.menuOrder.contentItems[i])
                }
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !self.acceptedItems.isEmpty {
            return self.acceptedItems.count
        }
        
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditPaymentCell", for: indexPath) as! EditPaymentCell
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.AdjustAutoLayout()

        cell.setData(item_content: self.acceptedItems[indexPath.row])
        
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 115
    }

}
