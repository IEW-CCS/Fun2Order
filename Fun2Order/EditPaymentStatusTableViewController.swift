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
    var originalIndex: [Int] = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        let editPaymentCellViewNib: UINib = UINib(nibName: "EditPaymentCell", bundle: nil)
        self.tableView.register(editPaymentCellViewNib, forCellReuseIdentifier: "EditPaymentCell")

        getAcceptedItems()
    }

    override func viewWillAppear(_ animated: Bool) {
        refreshMenuOrder()
    }
    
    func getAcceptedItems() {
        self.acceptedItems.removeAll()
        if !self.menuOrder.contentItems.isEmpty {
            for i in 0...self.menuOrder.contentItems.count - 1 {
                if self.menuOrder.contentItems[i].orderContent.replyStatus == MENU_ORDER_REPLY_STATUS_ACCEPT {
                    self.acceptedItems.append(self.menuOrder.contentItems[i])
                    self.originalIndex.append(i)
                }
            }
        }
    }
    
    func refreshMenuOrder() {
        getAcceptedItems()
        self.tableView.reloadData()
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
        cell.tag = indexPath.row
        cell.delegate = self
        cell.AdjustAutoLayout()

        cell.setData(item_content: self.acceptedItems[indexPath.row])
        
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 115
    }
}

extension EditPaymentStatusTableViewController: EditPaymentDelegate {
    func updatePaymentInformation(sender: EditPaymentCell, index: Int, new_content: MenuOrderMemberContent) {
        self.menuOrder.contentItems[self.originalIndex[index]].orderContent.payCheckedFlag = true
        self.menuOrder.contentItems[self.originalIndex[index]].orderContent.payNumber = new_content.orderContent.payNumber
        self.menuOrder.contentItems[self.originalIndex[index]].orderContent.payTime = new_content.orderContent.payTime
        refreshMenuOrder()
    }
}
