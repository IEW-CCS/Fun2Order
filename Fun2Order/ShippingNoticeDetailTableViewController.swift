//
//  ShippingNoticeDetailTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/6/22.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
import Firebase

class ShippingNoticeDetailTableViewController: UITableViewController {
    @IBOutlet weak var labelBrandName: UILabel!
    @IBOutlet weak var labelOrderOwner: UILabel!
    @IBOutlet weak var labelShippingDateTime: UILabel!
    @IBOutlet weak var labelShippingLocation: UILabel!
    @IBOutlet weak var textViewShippingNotice: UITextView!
    @IBOutlet weak var labelReplyStatus: UILabel!
    
    var notificationData: NotificationData = NotificationData()
    var memberIndex: Int = -1
    var memberContent: MenuOrderMemberContent = MenuOrderMemberContent()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textViewShippingNotice.layer.borderWidth = 1.0
        self.textViewShippingNotice.layer.borderColor = UIColor.lightGray.cgColor
        self.textViewShippingNotice.layer.cornerRadius = 6
        
        let productCellViewNib: UINib = UINib(nibName: "NewProductCell", bundle: nil)
        self.tableView.register(productCellViewNib, forCellReuseIdentifier: "NewProductCell")

        if Auth.auth().currentUser?.uid != nil {
            let user_id = Auth.auth().currentUser!.uid
            self.downloadMenuOrderContent(owner_id: self.notificationData.orderOwnerID, order_number: self.notificationData.orderNumber, member_id: user_id)
        }
        setupReplyStatus()

    }

    override func viewWillAppear(_ animated: Bool) {
        setData(notification: self.notificationData)
    }

    func setData(notification: NotificationData) {
        self.labelBrandName.text = notification.brandName
        self.labelOrderOwner.text = notification.orderOwnerName
        self.labelShippingDateTime.text = notification.shippingDate
        self.labelShippingLocation.text = notification.shippingLocation
        self.textViewShippingNotice.text = notification.messageDetail
    }

    func setupReplyStatus() {
        if self.memberContent.orderContent.replyStatus != "" {
            var replyString: String = ""
            if self.memberContent.orderContent.createTime != "" {
                let formatter = DateFormatter()
                formatter.dateFormat = DATETIME_FORMATTER
                let replyDate = formatter.date(from: self.memberContent.orderContent.createTime)!
                
                formatter.dateFormat = TAIWAN_DATETIME_FORMATTER
                replyString = formatter.string(from: replyDate)
            }

            switch self.memberContent.orderContent.replyStatus {
                case MENU_ORDER_REPLY_STATUS_ACCEPT:
                    self.labelReplyStatus.text = "已於 \(replyString) 回覆 參加"
                    self.labelReplyStatus.textColor = UIColor.systemBlue
                    break
                
                case MENU_ORDER_REPLY_STATUS_REJECT:
                    self.labelReplyStatus.text = "已於 \(replyString) 回覆 不參加"
                    self.labelReplyStatus.textColor = COLOR_PEPPER_RED
                    break
                    
                default:
                    self.labelReplyStatus.text = "尚未回覆"
                    self.labelReplyStatus.textColor = UIColor.darkGray
                    break
            }
        }
    }

    func downloadMenuOrderContent(owner_id: String, order_number: String, member_id: String) {
        let databaseRef = Database.database().reference()

        let orderString = "USER_MENU_ORDER/\(owner_id)/\(order_number)/contentItems"
        print("orderStirng = \(orderString)")
        databaseRef.child(orderString).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let itemRawData = snapshot.value
                let jsonData = try? JSONSerialization.data(withJSONObject: itemRawData as Any, options: [])

                let decoder: JSONDecoder = JSONDecoder()
                do {
                    let itemArray = try decoder.decode([MenuOrderMemberContent].self, from: jsonData!)

                    if let itemIndex = itemArray.firstIndex(where: { $0.memberID == member_id }) {
                        self.memberContent = itemArray[itemIndex]
                        self.memberIndex = itemIndex
                        self.setupReplyStatus()
                        self.refreshProductList()
                    } else {
                        return
                    }
                } catch {
                    print("downloadMenuOrderContent MenuOrderMemberContent jsonData decode failed: \(error.localizedDescription)")
                    presentSimpleAlertMessage(title: "資料錯誤", message: "訂單資料讀取錯誤，請團購發起人重發。")
                    return
                }
            } else {
                print("downloadMenuOrderContent MenuOrderMemberContent snapshot doesn't exist!")
                presentSimpleAlertMessage(title: "資料錯誤", message: "訂單資料不存在，請詢問團購發起人相關訊息。")
                return
            }
        }) { (error) in
            print(error.localizedDescription)
            presentSimpleAlertMessage(title: "錯誤訊息", message: error.localizedDescription)
            return
        }
    }
    
    func refreshProductList() {
        self.tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            if self.memberContent.orderContent.menuProductItems == nil {
                return 0
            }
            
            if self.memberContent.orderContent.replyStatus != MENU_ORDER_REPLY_STATUS_ACCEPT {
                return 0
            }
            
            return self.memberContent.orderContent.menuProductItems!.count
        }
        
        return super.tableView(tableView, numberOfRowsInSection: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewProductCell", for: indexPath) as! NewProductCell
            if self.memberContent.orderContent.menuProductItems != nil {
                cell.setData(item: self.memberContent.orderContent.menuProductItems![indexPath.row])
                cell.AdjustAutoLayout()
            }
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.tag = indexPath.row
            
            return cell
        }
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 80
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            if self.memberContent.orderContent.menuProductItems == nil {
                return 0
            }

            if self.memberContent.orderContent.replyStatus != MENU_ORDER_REPLY_STATUS_ACCEPT {
                return 0
            }

            return 50
        }
        
        return 0
    }

}
