//
//  OrderItemSummaryTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/1/20.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

class OrderItemSummaryTableViewController: UITableViewController {
    @IBOutlet weak var segmentStatus: UISegmentedControl!
    
    var menuOrder: MenuOrder = MenuOrder()
    var filterItems: [MenuOrderMemberContent] = [MenuOrderMemberContent]()
    var statusArray = ["已回覆", "其他"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let memberCellViewNib: UINib = UINib(nibName: "MenuOrderMemberCell", bundle: nil)
        self.tableView.register(memberCellViewNib, forCellReuseIdentifier: "MenuOrderMemberCell")

        let memberNGCellViewNib: UINib = UINib(nibName: "MenuOrderMemberNGCell", bundle: nil)
        self.tableView.register(memberNGCellViewNib, forCellReuseIdentifier: "MenuOrderMemberNGCell")

        setupStatusSegment()
        filterItemInfosByStatus()
    }

    override func viewWillAppear(_ animated: Bool) {
        refreshMenuOrder()
    }

    func setupStatusSegment() {
        self.segmentStatus.removeAllSegments()
        for i in 0...(self.statusArray.count - 1) {
            self.segmentStatus.insertSegment(withTitle: self.statusArray[i], at: i, animated: true)
        }
        self.segmentStatus.selectedSegmentIndex = 0
    }

    func filterItemInfosByStatus() {
        self.filterItems.removeAll()
        if !self.menuOrder.contentItems.isEmpty {
            if self.segmentStatus.selectedSegmentIndex == 0 {
                for i in 0...self.menuOrder.contentItems.count - 1 {
                    if self.menuOrder.contentItems[i].orderContent.replyStatus == MENU_ORDER_REPLY_STATUS_ACCEPT {
                        self.filterItems.append(self.menuOrder.contentItems[i])
                    }
                }
            } else {
                for i in 0...self.menuOrder.contentItems.count - 1 {
                    if self.menuOrder.contentItems[i].orderContent.replyStatus != MENU_ORDER_REPLY_STATUS_ACCEPT {
                        self.filterItems.append(self.menuOrder.contentItems[i])
                    }
                }
            }
        }
    }

    func refreshMenuOrder() {
        setupStatusSegment()
        filterItemInfosByStatus()
        self.tableView.reloadData()
    }
    
    @IBAction func changeStatus(_ sender: UISegmentedControl) {
        filterItemInfosByStatus()
        self.tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return self.menuOrder.contentItems.count
        return self.filterItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.filterItems[indexPath.row].orderContent.replyStatus == MENU_ORDER_REPLY_STATUS_ACCEPT {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuOrderMemberCell", for: indexPath) as! MenuOrderMemberCell
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.AdjustAutoLayout()
            cell.setData(item_content: self.filterItems[indexPath.row])

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuOrderMemberNGCell", for: indexPath) as! MenuOrderMemberNGCell

            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.AdjustAutoLayout()
            cell.setData(item_content: self.filterItems[indexPath.row])

            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if segmentStatus.selectedSegmentIndex == 0 {
            return 130
        }
        
        return 70
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowNotebook" {
            if let notebookController = segue.destination as? MenuOrderNotebookViewController {
                notebookController.menuOrder = self.menuOrder
            }
        }
    }

}
