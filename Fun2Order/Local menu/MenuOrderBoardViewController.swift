//
//  MenuOrderBoardViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/2/12.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

protocol MenuOrderBoardDelegate: class {
    func setFollowProductInformation(items: [MenuProductItem])
}

class MenuOrderBoardViewController: UIViewController {
    @IBOutlet weak var labelBrandName: UILabel!
    @IBOutlet weak var labelOwnerName: UILabel!
    @IBOutlet weak var labelStartTime: UILabel!
    @IBOutlet weak var labelDueTime: UILabel!
    @IBOutlet weak var labelTotalMemberCount: UILabel!
    @IBOutlet weak var labelAcceptMemberCount: UILabel!
    @IBOutlet weak var labelWaitMemberCount: UILabel!
    @IBOutlet weak var labelRejectMemberCount: UILabel!
    @IBOutlet weak var tableViewContent: UITableView!
    @IBOutlet weak var backView: UIView!
    
    var menuOrder: MenuOrder = MenuOrder()
    var memberContent: [MenuOrderMemberContent] = [MenuOrderMemberContent]()
    var followStatus: [Bool] = [Bool]()
    weak var delegate: MenuOrderBoardDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.backView.layer.borderWidth = CGFloat(2.0)
        self.backView.layer.borderColor = CUSTOM_COLOR_LIGHT_ORANGE.cgColor
        self.backView.layer.cornerRadius = 6

        self.tableViewContent.layer.borderWidth = CGFloat(1.0)
        self.tableViewContent.layer.borderColor = UIColor.darkGray.cgColor
        self.tableViewContent.layer.cornerRadius = 6

        let followCellViewNib: UINib = UINib(nibName: "FollowCell", bundle: nil)
        self.tableViewContent.register(followCellViewNib, forCellReuseIdentifier: "FollowCell")

        self.tableViewContent.delegate = self
        self.tableViewContent.dataSource = self
        setupInformation()
    }
    
    func setupInformation() {
        var startDate: Date = Date()
        var dueDate: Date = Date()
        var acceptCount: Int = 0
        var waitCount: Int = 0
        var rejectCount: Int = 0
        
        self.labelBrandName.text = self.menuOrder.brandName
        self.labelOwnerName.text = self.menuOrder.orderOwnerName
        let formatter = DateFormatter()
        formatter.dateFormat = DATETIME_FORMATTER
        startDate = formatter.date(from: self.menuOrder.createTime)!

        if self.menuOrder.dueTime == "" {
            self.labelDueTime.text = "無逾期時間"
        } else {
            dueDate = formatter.date(from: self.menuOrder.dueTime)!
            formatter.dateFormat = TAIWAN_DATETIME_FORMATTER
            let dueTimeString = formatter.string(from: dueDate)
            self.labelDueTime.text = dueTimeString
        }
        
        formatter.dateFormat = TAIWAN_DATETIME_FORMATTER
        let startTimeString = formatter.string(from: startDate)
        self.labelStartTime.text = startTimeString

        if !self.menuOrder.contentItems.isEmpty {
            self.labelTotalMemberCount.text = String(self.menuOrder.contentItems.count)
            for i in 0...self.menuOrder.contentItems.count - 1 {
                switch self.menuOrder.contentItems[i].orderContent.replyStatus {
                case MENU_ORDER_REPLY_STATUS_ACCEPT:
                    acceptCount = acceptCount + 1
                    self.memberContent.append(self.menuOrder.contentItems[i])
                    break
                    
                case MENU_ORDER_REPLY_STATUS_WAIT:
                    waitCount = waitCount + 1
                    break
                    
                case MENU_ORDER_REPLY_STATUS_REJECT:
                    rejectCount = rejectCount + 1
                    break
                    
                default:
                    break
                }
            }
        }
        
        if acceptCount > 0 {
            self.followStatus = Array(repeating: false, count: acceptCount)
        }
        
        self.labelAcceptMemberCount.text = String(acceptCount)
        self.labelWaitMemberCount.text = String(waitCount)
        self.labelRejectMemberCount.text = String(rejectCount)
    }
    
    @IBAction func clickFollowAction(_ sender: UIButton) {
        var items: [MenuProductItem] = [MenuProductItem]()
        
        if !self.followStatus.isEmpty {
            for i in 0...self.followStatus.count - 1 {
                if self.followStatus[i] {
                    if self.memberContent[i].orderContent.menuProductItems != nil {
                        for j in 0...self.memberContent[i].orderContent.menuProductItems!.count - 1 {
                            items.append(self.memberContent[i].orderContent.menuProductItems![j])
                        }
                    }
                }
            }
            
            delegate?.setFollowProductInformation(items: items)
            navigationController?.popViewController(animated: true)
        }
    }
    
}

extension MenuOrderBoardViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.memberContent.isEmpty {
            return 0
        }
        
        return self.memberContent.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowCell", for: indexPath) as! FollowCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.setData(member_content: self.memberContent[indexPath.row])
        cell.AdjustAutoLayout()
        cell.delegate = self
        cell.tag = indexPath.row
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

}

extension MenuOrderBoardViewController: FollowCellDelegate {
    func setFollowStatus(cell: UITableViewCell, follow_flag: Bool, data_index: Int) {
        print("Follow flag = \(follow_flag)")
        print("Data index = \(data_index)")
        if !self.followStatus.isEmpty {
            self.followStatus[data_index] = follow_flag
        }
    }
}
