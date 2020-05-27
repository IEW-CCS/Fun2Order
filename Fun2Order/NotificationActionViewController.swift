//
//  NotificationActionViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/2/2.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

class NotificationActionViewController: UIViewController {
    @IBOutlet weak var labelOrderOwner: UILabel!
    @IBOutlet weak var labelReceiveTime: UILabel!
    @IBOutlet weak var labelDueTime: UILabel!
    @IBOutlet weak var labelBrandName: UILabel!
    @IBOutlet weak var labelMemberCount: UILabel!
    @IBOutlet weak var labelNotificationType: UILabel!
    @IBOutlet weak var labelReplyStatus: UILabel!
    @IBOutlet weak var buttonAttend: UIButton!
    @IBOutlet weak var buttonReject: UIButton!
    
    var notificationData: NotificationData = NotificationData()
    var indexPath: IndexPath = IndexPath()

    let app = UIApplication.shared.delegate as! AppDelegate
    weak var refreshNotificationDelegate: ApplicationRefreshNotificationDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshNotificationDelegate = app.notificationDelegate
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setData(notification: self.notificationData)
    }

    @IBAction func attendGroupOrder(_ sender: UIButton) {
        let dispatchGroup = DispatchGroup()
        var menuData: MenuInformation = MenuInformation()
        var memberContent: MenuOrderMemberContent = MenuOrderMemberContent()
        var memberIndex: Int = -1
        var user_id: String = ""
        var downloadMenuInformation: Bool = false
        var downloadMenuOrder: Bool = false

        if Auth.auth().currentUser?.uid != nil {
            user_id = Auth.auth().currentUser!.uid
        } else {
            print("Get Ahthorization uid failed")
            return
        }

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
                    downloadMenuInformation = true
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

        let orderString = "USER_MENU_ORDER/\(self.notificationData.orderOwnerID)/\(self.notificationData.orderNumber)/contentItems"
        print("orderStirng = \(orderString)")
        dispatchGroup.enter()
        databaseRef.child(orderString).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let itemRawData = snapshot.value
                let jsonData = try? JSONSerialization.data(withJSONObject: itemRawData as Any, options: [])

                let decoder: JSONDecoder = JSONDecoder()
                do {
                    let itemArray = try decoder.decode([MenuOrderMemberContent].self, from: jsonData!)

                    if let itemIndex = itemArray.firstIndex(where: { $0.memberID == user_id }) {
                        //let uploadPathString = pathString + "/\(itemIndex)"
                        //databaseRef.child(uploadPathString).setValue(item.toAnyObject())
                        memberContent = itemArray[itemIndex]
                        memberIndex = itemIndex
                        downloadMenuOrder = true
                        dispatchGroup.leave()
                    } else {
                        dispatchGroup.leave()
                    }
                } catch {
                    print("attendGroupOrder MenuOrderMemberContent jsonData decode failed: \(error.localizedDescription)")
                    presentSimpleAlertMessage(title: "資料錯誤", message: "訂單資料讀取錯誤，請團購發起人重發。")
                    dispatchGroup.leave()
                    return
                }
            } else {
                print("attendGroupOrder MenuOrderMemberContent snapshot doesn't exist!")
                presentSimpleAlertMessage(title: "資料錯誤", message: "訂單資料不存在，請詢問團購發起人相關訊息。")
                dispatchGroup.leave()
                return
            }
        }) { (error) in
            print(error.localizedDescription)
            dispatchGroup.leave()
            presentSimpleAlertMessage(title: "錯誤訊息", message: error.localizedDescription)
            return
        }
        
        dispatchGroup.notify(queue: .main) {
            if downloadMenuInformation == true && downloadMenuOrder == true && memberIndex >= 0 {
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                guard let joinController = storyBoard.instantiateViewController(withIdentifier: "JOIN_ORDER_VC") as? JoinGroupOrderTableViewController else{
                    assertionFailure("[AssertionFailure] StoryBoard: JOIN_ORDER_VC can't find!! (NotificationActionViewController)")
                    return
                }
                
                joinController.menuInformation = menuData
                joinController.memberContent = memberContent
                joinController.memberIndex = memberIndex
                //joinController.delegate = self
                self.navigationController?.show(joinController, sender: self)
            }
        }
    }
    
    @IBAction func notAttendGroupOrder(_ sender: UIButton) {
        let databaseRef = Database.database().reference()
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
                    break
                
                case MENU_ORDER_REPLY_STATUS_REJECT:
                    self.labelReplyStatus.text = "已於 \(replyString) 回覆 不參加"
                    break
                    
                default:
                    self.labelReplyStatus.text = "尚未回覆"
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
}

