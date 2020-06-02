//
//  NotificationActionTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/5/30.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

class NotificationActionTableViewController: UITableViewController {

    @IBOutlet weak var labelNotificationType: UILabel!
    @IBOutlet weak var labelBrandName: UILabel!
    @IBOutlet weak var labelOrderOwner: UILabel!
    @IBOutlet weak var labelReceiveTime: UILabel!
    @IBOutlet weak var labelDueTime: UILabel!
    @IBOutlet weak var labelMemberCount: UILabel!
    @IBOutlet weak var labelReplyStatus: UILabel!
    @IBOutlet weak var buttonAttend: UIButton!
    @IBOutlet weak var buttonReject: UIButton!
    
    var notificationData: NotificationData = NotificationData()
    var indexPath: IndexPath = IndexPath()
    var downloadMenuOrderFlag: Bool = false
    var downloadMenuInformationFlag: Bool = false
    var memberIndex: Int = -1
    var memberContent: MenuOrderMemberContent = MenuOrderMemberContent()

    let app = UIApplication.shared.delegate as! AppDelegate
    weak var refreshNotificationDelegate: ApplicationRefreshNotificationDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Auth.auth().currentUser?.uid != nil {
            let user_id = Auth.auth().currentUser!.uid
            downloadMenuOrderContent(owner_id: self.notificationData.orderOwnerID, order_number: self.notificationData.orderNumber, member_id: user_id)
        }
        
        let productCellViewNib: UINib = UINib(nibName: "NewProductCell", bundle: nil)
        self.tableView.register(productCellViewNib, forCellReuseIdentifier: "NewProductCell")

        refreshNotificationDelegate = app.notificationDelegate
    }

    override func viewWillAppear(_ animated: Bool) {
        setData(notification: self.notificationData)
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
                        self.downloadMenuOrderFlag = true
                        self.refreshProductList()
                    } else {
                        return
                    }
                } catch {
                    print("downloadMenuOrderContent MenuOrderMemberContent jsonData decode failed: \(error.localizedDescription)")
                    presentSimpleAlertMessage(title: "資料錯誤", message: "訂單資料讀取錯誤，請團購發起人重發。")
                    self.buttonAttend.isEnabled = false
                    self.buttonReject.isEnabled = false
                    return
                }
            } else {
                print("downloadMenuOrderContent MenuOrderMemberContent snapshot doesn't exist!")
                presentSimpleAlertMessage(title: "資料錯誤", message: "訂單資料不存在，請詢問團購發起人相關訊息。")
                self.buttonAttend.isEnabled = false
                self.buttonReject.isEnabled = false
                return
            }
        }) { (error) in
            print(error.localizedDescription)
            presentSimpleAlertMessage(title: "錯誤訊息", message: error.localizedDescription)
            self.buttonAttend.isEnabled = false
            self.buttonReject.isEnabled = false
            return
        }
    }
    
    func refreshProductList() {
        self.tableView.reloadData()
    }
    
    @IBAction func attendGroupOrder(_ sender: UIButton) {
        let dispatchGroup = DispatchGroup()
        var menuData: MenuInformation = MenuInformation()

        let databaseRef = Database.database().reference()
        
        let pathString = "USER_MENU_INFORMATION/\(self.notificationData.orderOwnerID)/\(self.notificationData.menuNumber)"
        
        dispatchGroup.enter()
        databaseRef.child(pathString).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let menuInfo = snapshot.value
                let jsonData = try? JSONSerialization.data(withJSONObject: menuInfo as Any, options: [])
                let jsonString = String(data: jsonData!, encoding: .utf8)!
                print("jsonString = \(jsonString)")

                let decoder: JSONDecoder = JSONDecoder()
                do {
                    menuData = try decoder.decode(MenuInformation.self, from: jsonData!)
                    self.downloadMenuInformationFlag = true
                    print("menuData decoded successful !!")
                    print("menuData = \(menuData)")
                    dispatchGroup.leave()

                } catch {
                    dispatchGroup.leave()
                    print("attendGroupOrder menuData jsonData decode failed: \(error.localizedDescription)")
                    presentSimpleAlertMessage(title: "資料錯誤", message: "菜單資料讀取錯誤，請團購發起人重發。")
                    return
                }
            } else {
                dispatchGroup.leave()
                print("attendGroupOrder USER_MENU_INFORMATION snapshot doesn't exist!")
                presentSimpleAlertMessage(title: "資料錯誤", message: "菜單資料不存在，請詢問團購發起人相關訊息。")
                return
            }
        }) { (error) in
            dispatchGroup.leave()
            print(error.localizedDescription)
            presentSimpleAlertMessage(title: "錯誤訊息", message: error.localizedDescription)
            return
        }

        dispatchGroup.notify(queue: .main) {
            if self.downloadMenuInformationFlag && self.downloadMenuOrderFlag && self.memberIndex >= 0 {
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                guard let joinController = storyBoard.instantiateViewController(withIdentifier: "JOIN_ORDER_VC") as? JoinGroupOrderTableViewController else{
                    assertionFailure("[AssertionFailure] StoryBoard: JOIN_ORDER_VC can't find!! (NotificationActionViewController)")
                    return
                }
                joinController.menuInformation = menuData
                joinController.memberContent = self.memberContent
                joinController.memberIndex = self.memberIndex
                //joinController.delegate = self
                self.navigationController?.show(joinController, sender: self)
            }
        }
    }
    
    @IBAction func notAttendGroupOrder(_ sender: UIButton) {
        let databaseRef = Database.database().reference()
        if self.notificationData.orderOwnerID == "" {
            print("notAttendGroupOrder self.notificationData.orderOwnerID is empty")
            return
        }
        
        let pathString = "USER_MENU_ORDER/\(self.notificationData.orderOwnerID)/\(self.notificationData.orderNumber)/contentItems"
        databaseRef.child(pathString).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let itemRawData = snapshot.value
                let jsonData = try? JSONSerialization.data(withJSONObject: itemRawData as Any, options: [])

                let decoder: JSONDecoder = JSONDecoder()
                do {
                    var itemArray = try decoder.decode([MenuOrderMemberContent].self, from: jsonData!)
                    let formatter = DateFormatter()
                    formatter.dateFormat = DATETIME_FORMATTER
                    let dateString = formatter.string(from: Date())

                    if let user_id = Auth.auth().currentUser?.uid {
                        if let itemIndex = itemArray.firstIndex(where: { $0.memberID == user_id }) {
                            let uploadPathString = pathString + "/\(itemIndex)"

                            itemArray[itemIndex].orderContent.createTime = dateString
                            itemArray[itemIndex].orderContent.replyStatus = MENU_ORDER_REPLY_STATUS_REJECT
                            databaseRef.child(uploadPathString).setValue(itemArray[itemIndex].toAnyObject())
                        }
                    }
                    
                    updateNotificationReplyStatus(order_number: self.notificationData.orderNumber, reply_status: MENU_ORDER_REPLY_STATUS_REJECT, reply_time: dateString)
                    self.refreshNotificationDelegate?.refreshNotificationList()

                } catch {
                    print("notAttendGroupOrder jsonData decode failed: \(error.localizedDescription)")
                }
            } else {
                print("notAttendGroupOrder snapshot doesn't exist!")
                return
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: false, completion: nil)
    }
    
    func setData(notification: NotificationData) {
        self.labelOrderOwner.text = notification.orderOwnerName
        let formatter = DateFormatter()
        formatter.dateFormat = DATETIME_FORMATTER
        let receiveDate = formatter.date(from: notification.receiveTime)
        let dueDate = formatter.date(from: notification.dueTime)
        formatter.dateFormat = TAIWAN_DATETIME_FORMATTER
        let receiveTimeString = formatter.string(from: receiveDate!)
        let dueTimeString = formatter.string(from: dueDate!)

        self.labelReceiveTime.text = receiveTimeString
        if notification.dueTime == "" {
            self.labelDueTime.text = "無逾期時間"
        } else {
            self.labelDueTime.text = dueTimeString
        }
        
        self.labelBrandName.text = notification.brandName
        self.labelMemberCount.text = String(notification.attendedMemberCount)
        switch notification.notificationType {
            case NOTIFICATION_TYPE_MESSAGE_DUETIME:
                self.labelNotificationType.text = "團購催訂"
                self.labelNotificationType.textColor = COLOR_PEPPER_RED
                break
                
            case NOTIFICATION_TYPE_MESSAGE_INFORMATION:
                self.labelNotificationType.text = "團購訊息"
                break
                
            case NOTIFICATION_TYPE_ACTION_JOIN_ORDER:
                self.labelNotificationType.text = "團購邀請"
                break
                
            default:
                break
        }

        setupReplyStatus()
        checkExpire()
    }

    func setupReplyStatus() {
        if self.notificationData.replyStatus != "" {
            var replyString: String = ""
            if self.notificationData.replyTime != "" {
                let formatter = DateFormatter()
                formatter.dateFormat = DATETIME_FORMATTER
                let replyDate = formatter.date(from: self.notificationData.replyTime)!
                
                formatter.dateFormat = TAIWAN_DATETIME_FORMATTER
                replyString = formatter.string(from: replyDate)
            }
            
            switch self.notificationData.replyStatus {
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
    
    func checkExpire() {
        if self.notificationData.dueTime == "" {
            return
        }
        
        let nowDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = DATETIME_FORMATTER
        let nowString = formatter.string(from: nowDate)
        
        print("------  checkExpire ------")
        print("self.notificationData.dueTime string = \(self.notificationData.dueTime)")
        print("now date string = \(nowString)")
        
        if nowString > self.notificationData.dueTime {
            self.buttonAttend.isEnabled = false
            self.buttonReject.isEnabled = false
            
            self.labelNotificationType.text = self.labelNotificationType.text! + " -- 團購單已逾期"
            self.labelNotificationType.textColor = COLOR_PEPPER_RED
        } else {
            self.buttonAttend.isEnabled = true
            self.buttonReject.isEnabled = true
        }
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            if self.memberContent.orderContent.menuProductItems == nil {
                return 0
            } else {
                return self.memberContent.orderContent.menuProductItems!.count
            }
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
            } else {
                return 50
            }
        }
        
        return 50
    }

}
