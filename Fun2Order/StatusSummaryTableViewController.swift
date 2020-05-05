//
//  StatusSummaryTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/1/20.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
import Firebase

protocol StatusSummaryDelegate: class {
    func updateMenuOrderInformation(sender: StatusSummaryTableViewController, menu_order: MenuOrder)
}

class StatusSummaryTableViewController: UITableViewController {
    var menuOrder: MenuOrder = MenuOrder()
    var summaryData: [Int] = [Int]()
    var isOrderExpired: Bool = false
    weak var delegate: StatusSummaryDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let statusSummaryCellViewNib: UINib = UINib(nibName: "DashboardStatusSummaryCell", bundle: nil)
        self.tableView.register(statusSummaryCellViewNib, forCellReuseIdentifier: "DashboardStatusSummaryCell")
        
        let basicButtonCellViewNib: UINib = UINib(nibName: "BasicButtonCell", bundle: nil)
        self.tableView.register(basicButtonCellViewNib, forCellReuseIdentifier: "BasicButtonCell")

        setExpireFlag()
        getSummaryData()
    }
    
    func getSummaryData() {
        var waitCount: Int = 0
        var acceptCount: Int = 0
        var rejectCount: Int = 0
        var expireCount: Int = 0
        
        if self.menuOrder.contentItems.isEmpty {
            return
        }
        
        summaryData.removeAll()
        for i in 0...self.menuOrder.contentItems.count - 1 {
            switch self.menuOrder.contentItems[i].orderContent.replyStatus {
            case MENU_ORDER_REPLY_STATUS_WAIT:
                waitCount = waitCount + 1
                
            case MENU_ORDER_REPLY_STATUS_ACCEPT:
                acceptCount = acceptCount + 1
                
            case MENU_ORDER_REPLY_STATUS_REJECT:
                rejectCount = rejectCount + 1
                
            case MENU_ORDER_REPLY_STATUS_EXPIRE:
                expireCount = expireCount + 1
                
            default:
                break
            }
        }
        
        summaryData.append(waitCount)
        summaryData.append(acceptCount)
        summaryData.append(rejectCount)
        summaryData.append(expireCount)
    }
    
    func setExpireFlag() {
        if self.menuOrder.dueTime == "" {
            return
        }
        
        let nowDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = DATETIME_FORMATTER
        let nowString = formatter.string(from: nowDate)
        if nowString > self.menuOrder.dueTime {
            self.isOrderExpired = true
        }
    }
    
    func checkOrderExpire(order_data: MenuOrder) -> MenuOrder {
        var returnOrder: MenuOrder = MenuOrder()

        returnOrder = order_data

        if returnOrder.dueTime == "" {
            return returnOrder
        }

        let nowDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = DATETIME_FORMATTER
        let nowString = formatter.string(from: nowDate)

        let databaseRef = Database.database().reference()
        if !returnOrder.contentItems.isEmpty {
            for i in 0...returnOrder.contentItems.count - 1 {
                if (returnOrder.contentItems[i].orderContent.replyStatus == MENU_ORDER_REPLY_STATUS_WAIT) && (nowString > returnOrder.dueTime) {
                    print("User[\(returnOrder.contentItems[i].orderContent.itemOwnerName)] is expired")
                    returnOrder.contentItems[i].orderContent.replyStatus = MENU_ORDER_REPLY_STATUS_EXPIRE
                    let pathString = "USER_MENU_ORDER/\(returnOrder.orderOwnerID)/\(returnOrder.orderNumber)/contentItems/\(i)"
                    databaseRef.child(pathString).setValue(returnOrder.contentItems[i].toAnyObject())
                }
            }
        }

        return returnOrder
    }

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardStatusSummaryCell", for: indexPath) as! DashboardStatusSummaryCell

            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.AdjustAutoLayout()
            cell.setMenuInfo(brand: self.menuOrder.brandName, start_time: self.menuOrder.createTime, member_count: self.menuOrder.contentItems.count, due_time: self.menuOrder.dueTime)
            cell.setupChartData(data_array: self.summaryData)
            return cell
        }

        if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BasicButtonCell", for: indexPath) as! BasicButtonCell
            
            let iconImage: UIImage = UIImage(named: "Icon_Refresh.png")!.withRenderingMode(.alwaysTemplate)
            cell.setData(icon: iconImage, button_text: "更新狀態", action_type: BUTTON_ACTION_REFRESH_STATUS_SUMMARY)

            cell.delegate = self
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }

        if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BasicButtonCell", for: indexPath) as! BasicButtonCell
            
            let iconImage: UIImage = UIImage(named: "Icon_Notify_Menu.png")!.withRenderingMode(.alwaysTemplate)
            cell.setData(icon: iconImage, button_text: "發出催訂通知", action_type: BUTTON_ACTION_NOTIFY_MENUORDER_DUETIME)

            if self.isOrderExpired {
                cell.setDisable()
            } else {
                cell.setEnable()
            }
            
            cell.delegate = self
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }

        if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BasicButtonCell", for: indexPath) as! BasicButtonCell
            
            let iconImage: UIImage = UIImage(named: "Icon_Notify_Menu.png")!.withRenderingMode(.alwaysTemplate)
            cell.setData(icon: iconImage, button_text: "訊息通知", action_type: BUTTON_ACTION_NOTIFY_SEND_MESSAGE)
            
            cell.delegate = self
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }

        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 455
        }
        
        return 54
    }

}

extension StatusSummaryTableViewController: BasicButtonDelegate {
    func refreshStatusSummary(sender: BasicButtonCell) {
        print("StatusSummaryTableViewController receives BasicButtonDelegate.refreshStatusSummary")
        let databaseRef = Database.database().reference()
        let pathString =  "USER_MENU_ORDER/\(self.menuOrder.orderOwnerID)/\(self.menuOrder.orderNumber)"
        databaseRef.child(pathString).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let menuDictionary = snapshot.value
                let jsonData = try? JSONSerialization.data(withJSONObject: menuDictionary as Any, options: [])
                let jsonString = String(data: jsonData!, encoding: .utf8)!
                print("jsonString = \(jsonString)")

                let decoder: JSONDecoder = JSONDecoder()
                do {
                    var menuData = try decoder.decode(MenuOrder.self, from: jsonData!)
                    menuData = self.checkOrderExpire(order_data: menuData)
                    self.menuOrder = menuData
                    self.getSummaryData()
                    self.tableView.reloadData()
                    self.delegate?.updateMenuOrderInformation(sender: self, menu_order: self.menuOrder)
                } catch {
                    print("jsonData decode failed: \(error.localizedDescription)")
                }
            } else {
                print("StatusSummaryTableViewController refreshStatusSummary snapshot doesn't exist!")
                return
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func notifyMenuOrderDueTime(sender: BasicButtonCell) {
        print("StatusSummaryTableViewController receives BasicButtonDelegate.notifyMenuOrderDueTime")

        if !self.menuOrder.contentItems.isEmpty {
            let tokenID = getMyTokenID()
            for memberContent in self.menuOrder.contentItems {
                if memberContent.memberTokenID == tokenID {
                    continue
                }

                if memberContent.orderContent.replyStatus != MENU_ORDER_REPLY_STATUS_WAIT {
                    continue
                }

                let sender = PushNotificationSender()

                var dueTimeNotify: NotificationData = NotificationData()
                let title: String = "團購相關訊息"
                let body: String = "團購訂單的訂購時間即將截止，請儘速決定是否參與團購，謝謝。"

                let formatter = DateFormatter()
                formatter.dateFormat = DATETIME_FORMATTER
                let dateNow = Date()
                let dateTimeString = formatter.string(from: dateNow)

                dueTimeNotify.messageTitle = title
                dueTimeNotify.messageBody = body
                dueTimeNotify.notificationType = NOTIFICATION_TYPE_MESSAGE_DUETIME
                dueTimeNotify.receiveTime = dateTimeString
                dueTimeNotify.orderOwnerID = self.menuOrder.orderOwnerID
                dueTimeNotify.orderOwnerName = self.menuOrder.orderOwnerName
                dueTimeNotify.menuNumber = self.menuOrder.menuNumber
                dueTimeNotify.orderNumber = self.menuOrder.orderNumber
                dueTimeNotify.dueTime = self.menuOrder.dueTime
                dueTimeNotify.brandName = self.menuOrder.brandName
                dueTimeNotify.attendedMemberCount = self.menuOrder.contentItems.count
                dueTimeNotify.messageDetail = " "
                dueTimeNotify.isRead = "N"

                sender.sendPushNotification(to: memberContent.memberTokenID, title: title, body: body, data: dueTimeNotify)
            }
            presentSimpleAlertMessage(title: "訊息", message: "已對尚未回覆者發出催訂通知")
        }
    }
    
    func notifySendMessage(sender: BasicButtonCell) {
        print("StatusSummaryTableViewController receives BasicButtonDelegate.notifySendMessage")

        let controller = UIAlertController(title: "請輸入訊息", message: nil, preferredStyle: .alert)

        guard let messageController = self.storyboard?.instantiateViewController(withIdentifier: "NOTIFY_MESSAGE_INPUT_VC") as? NotificationMessageViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: NOTIFY_MESSAGE_INPUT_VC can't find!! (QRCodeViewController)")
            return
        }

        controller.setValue(messageController, forKey: "contentViewController")
        messageController.preferredContentSize.height = 200
        controller.preferredContentSize.height = 200
        controller.addChild(messageController)
        messageController.delegate = self
        
        present(controller, animated: true, completion: nil)
    }
}

extension StatusSummaryTableViewController: NotificationMessageDelegate {
    func getNotificationMessage(sender: NotificationMessageViewController, message: String) {
        let message_string = message
        if !self.menuOrder.contentItems.isEmpty {
            let tokenID = getMyTokenID()
            for memberContent in self.menuOrder.contentItems {
                if memberContent.memberTokenID == tokenID {
                    continue
                }

                let sender = PushNotificationSender()
                
                var messageNotify: NotificationData = NotificationData()
                let title: String = "團購相關訊息"
                let body: String = "來自團購主的訂單訊息，請點擊觀看詳細訊息內容。"
                
                let formatter = DateFormatter()
                formatter.dateFormat = DATETIME_FORMATTER
                let dateNow = Date()
                let dateTimeString = formatter.string(from: dateNow)
                
                messageNotify.messageTitle = title
                messageNotify.messageBody = body
                messageNotify.notificationType = NOTIFICATION_TYPE_MESSAGE_INFORMATION
                messageNotify.receiveTime = dateTimeString
                messageNotify.orderOwnerID = self.menuOrder.orderOwnerID
                messageNotify.orderOwnerName = self.menuOrder.orderOwnerName
                messageNotify.menuNumber = self.menuOrder.menuNumber
                messageNotify.orderNumber = self.menuOrder.orderNumber
                messageNotify.dueTime = self.menuOrder.dueTime
                messageNotify.brandName = self.menuOrder.brandName
                messageNotify.attendedMemberCount = self.menuOrder.contentItems.count
                messageNotify.messageDetail = message_string
                messageNotify.isRead = "N"

                sender.sendPushNotification(to: memberContent.memberTokenID, title: title, body: body, data: messageNotify)
            }
        }
    }
}
