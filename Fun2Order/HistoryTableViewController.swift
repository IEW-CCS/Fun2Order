//
//  HistoryTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/22.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import GoogleMobileAds

class HistoryTableViewController: UITableViewController {
    @IBOutlet weak var segmentType: UISegmentedControl!
    
    var menuOrderList: [MenuOrder] = [MenuOrder]()
    var invitationList: [NotificationData] = [NotificationData]()
    var interstitialAd: GADInterstitial!
    
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    weak var refreshNotificationDelegate: ApplicationRefreshNotificationDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        vc = app.persistentContainer.viewContext
        refreshNotificationDelegate = app.notificationDelegate
        
        let historyCellViewNib: UINib = UINib(nibName: "OrderHistoryCell", bundle: nil)
        self.tableView.register(historyCellViewNib, forCellReuseIdentifier: "OrderHistoryCell")

        let joinCellViewNib: UINib = UINib(nibName: "JoinInvitationCell", bundle: nil)
        self.tableView.register(joinCellViewNib, forCellReuseIdentifier: "JoinInvitationCell")

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.receiveRefreshHistory(_:)),
            name: NSNotification.Name(rawValue: "RefreshHistory"),
            object: nil
        )

        self.segmentType.selectedSegmentIndex = 0
        queryMenuOrder()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.title = "歷史紀錄"
        self.navigationController?.title = "歷史紀錄"
        self.tabBarController?.title = "歷史紀錄"
        navigationController?.navigationBar.backItem?.setHidesBackButton(true, animated: false)
    }
    
    func setupInterstitialAd() {
        // Test Interstitla Video Ad
        self.interstitialAd = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/5135589807")

        // My real Interstitial Ad
        //self.interstitialAd = GADInterstitial(adUnitID: "ca-app-pub-9511677579097261/6069385370")

        let adRequest = GADRequest()
        self.interstitialAd.load(adRequest)
        self.interstitialAd.delegate = self
    }
    
    @IBAction func changeHistoryType(_ sender: UISegmentedControl) {
        if self.segmentType.selectedSegmentIndex == 0 {
            queryMenuOrder()
        } else {
            self.invitationList = retrieveInvitationNotificationList()
            self.tableView.reloadData()
        }
    }
    
    func refreshInvitationList() {
        self.segmentType.selectedSegmentIndex = 1
        self.invitationList = retrieveInvitationNotificationList()
        self.tableView.reloadData()
    }
    
    func queryMenuOrder() {
        var pathString: String = ""
        let databaseRef = Database.database().reference()
        //let pathString = "USER_MENU_ORDER/\(order_info.orderOwnerID)/\(order_info.orderNumber)"
        if let userID = Auth.auth().currentUser?.uid {
            pathString = "USER_MENU_ORDER/\(userID)"
            print("pathString = \(pathString)")
        } else {
            print("HistoryTableViewController queryMenuOrder: Auth.auth().currentUser?.uid is nil, just return")
        }
        
        self.menuOrderList.removeAll()
        databaseRef.child(pathString).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let rawData = snapshot.value
                let jsonData = try? JSONSerialization.data(withJSONObject: rawData as Any, options: [])
                let jsonString = String(data: jsonData!, encoding: .utf8)!
                print("jsonString = \(jsonString)")

                let decoder: JSONDecoder = JSONDecoder()
                do {
                    let listData = try decoder.decode([String:MenuOrder].self, from: jsonData!)
                    print("queryMenuOrder jason decoded successful")
                    for keyValuePair in listData {
                        self.menuOrderList.append(keyValuePair.value)
                    }
                    self.menuOrderList.sort(by: {$0.createTime > $1.createTime })
                    
                    self.tableView.reloadData()
                } catch {
                    self.tableView.reloadData()
                    print("jsonData decode failed: \(error.localizedDescription)")
                    return
                }
            } else {
                self.tableView.reloadData()
                print("queryMenuOrder snapshot doesn't exist!")
                return
            }
        }) { (error) in
            print(error.localizedDescription)
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
    
    @objc func receiveRefreshHistory(_ notification: Notification) {
        queryMenuOrder()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentType.selectedSegmentIndex == 0 {
            if self.menuOrderList.isEmpty {
                return 0
            }
            
            return self.menuOrderList.count
        } else {
            if self.invitationList.isEmpty {
                return 0
            }
            
            return self.invitationList.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if segmentType.selectedSegmentIndex == 0 {
            if self.menuOrderList.isEmpty {
                return super.tableView(tableView, cellForRowAt: indexPath)
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderHistoryCell", for: indexPath) as! OrderHistoryCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.setMenuData(menu_order: self.menuOrderList[indexPath.row])

            cell.delegate = self
            cell.indexPath = indexPath
            return cell

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "JoinInvitationCell", for: indexPath) as! JoinInvitationCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.setData(notify_data: self.invitationList[indexPath.row])
            cell.AdjustAutoLayout()
            cell.delegate = self
            cell.tag = indexPath.row
            return cell
        }

    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if segmentType.selectedSegmentIndex == 0 {
            let databaseRef = Database.database().reference()
            let pathString = "USER_MENU_ORDER/\(self.menuOrderList[indexPath.row].orderOwnerID)/\(self.menuOrderList[indexPath.row].orderNumber)"

            databaseRef.child(pathString).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    let rawData = snapshot.value
                    let jsonData = try? JSONSerialization.data(withJSONObject: rawData as Any, options: [])
                    let jsonString = String(data: jsonData!, encoding: .utf8)!
                    print("jsonString = \(jsonString)")

                    let decoder: JSONDecoder = JSONDecoder()
                    do {
                        var orderData = try decoder.decode(MenuOrder.self, from: jsonData!)
                        print("queryMenuOrder jason decoded successful")
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        guard let history_vc = storyboard.instantiateViewController(withIdentifier: "HISTORY_DETAIL_VC") as? HistoryDetailViewController else {
                            assertionFailure("[AssertionFailure] StoryBoard: HISTORY_DETAIL_VC can't find!! (ViewController)")
                            return
                        }

                        orderData = self.checkOrderExpire(order_data: orderData)
                        history_vc.menuOrder = orderData

                        self.show(history_vc, sender: self)

                    } catch {
                        print("jsonData decode failed: \(error.localizedDescription)")
                        return
                    }
                } else {
                    print("HistoryTableViewController didSelectRowAt snapshot doesn't exist!")
                    return
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        } else {
            
        }

    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.segmentType.selectedSegmentIndex == 0 {
            return 180
        } else {
            return 135
        }
    }

    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "刪除"
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        var alertWindow: UIWindow!
        if self.segmentType.selectedSegmentIndex == 0 {
            if editingStyle == .delete {
                let controller = UIAlertController(title: "刪除訂單資料", message: "確定要刪除此訂單資料嗎？", preferredStyle: .alert)

                let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
                    print("Confirm to delete this order information")
                    alertWindow.isHidden = true
                    let databaseRef = Database.database().reference()
                    let pathString = "USER_MENU_ORDER/\(self.menuOrderList[indexPath.row].orderOwnerID)/\(self.menuOrderList[indexPath.row].orderNumber)"
                    databaseRef.child(pathString).removeValue() { (error, reference) in
                        if let error = error {
                            print("Delete Menu Order error = \(error.localizedDescription)")
                            return
                        }
                        self.queryMenuOrder()
                    }
                }
                
                controller.addAction(okAction)
                let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (_) in
                    print("Cancel to delete the order information")
                    alertWindow.isHidden = true
                }
                controller.addAction(cancelAction)
                //app.window?.rootViewController!.present(controller, animated: true, completion: nil)
                alertWindow = presentAlert(controller)
            }
        } else {
            if editingStyle == .delete {
                let controller = UIAlertController(title: "刪除通知", message: "確定要刪除此通知嗎？", preferredStyle: .alert)

                let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
                    print("Confirm to delete this notification")
                    deleteNotificationByID(message_id: self.invitationList[indexPath.row].messageID)
                    alertWindow.isHidden = true
                    self.invitationList = retrieveInvitationNotificationList()
                    setNotificationBadgeNumber()
                    self.tableView.reloadData()
                    self.refreshNotificationDelegate?.refreshNotificationList()
                }
                
                controller.addAction(okAction)
                let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (_) in
                    print("Cancel to delete the notification")
                    alertWindow.isHidden = true
                }
                controller.addAction(cancelAction)
                //app.window?.rootViewController!.present(controller, animated: true, completion: nil)
                alertWindow = presentAlert(controller)
            }
        }
        
    }
}

extension HistoryTableViewController: DisplayQRCodeDelegate {
    func didQRCodeButtonPressed(at index: IndexPath) {
        guard let qrCodeController = self.storyboard?.instantiateViewController(withIdentifier: "QRCode_VC") as? QRCodeViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: QRCode_VC can't find!! (QRCodeViewController)")
            return
        }
        
        qrCodeController.setQRCodeText(code: self.menuOrderList[index.row].orderNumber)
        qrCodeController.modalTransitionStyle = .crossDissolve
        qrCodeController.modalPresentationStyle = .overFullScreen
        navigationController?.present(qrCodeController, animated: true, completion: nil)
    }
}

extension HistoryTableViewController: JoinInvitationCellDelegate {
    func attendOrderInvitation(data_index: Int) {
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

        self.setupInterstitialAd()
        
        let databaseRef = Database.database().reference()
        
        let pathString = "USER_MENU_INFORMATION/\(self.invitationList[data_index].orderOwnerID)/\(self.invitationList[data_index].menuNumber)"

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
                    print("attendOrderInvitation jsonData decode failed: \(error.localizedDescription)")
                    presentSimpleAlertMessage(title: "資料錯誤", message: "菜單資料讀取錯誤，請團購發起人重發。")
                    return
                }
            } else {
                dispatchGroup.leave()
                print("attendOrderInvitation snapshot doesn't exist!")
                presentSimpleAlertMessage(title: "資料錯誤", message: "菜單資料不存在，請詢問團購發起人相關訊息。")
                return
            }
        }) { (error) in
            dispatchGroup.leave()
            print(error.localizedDescription)
            presentSimpleAlertMessage(title: "錯誤訊息", message: error.localizedDescription)
            return
        }

        let orderString = "USER_MENU_ORDER/\(self.invitationList[data_index].orderOwnerID)/\(self.invitationList[data_index].orderNumber)/contentItems"
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
                    print("attendOrderInvitation MenuOrder jsonData decode failed: \(error.localizedDescription)")
                    presentSimpleAlertMessage(title: "資料錯誤", message: "訂單資料讀取錯誤，請團購發起人重發。")
                    dispatchGroup.leave()
                    return
                }
            } else {
                print("attendOrderInvitation MenuOrder snapshot doesn't exist!")
                presentSimpleAlertMessage(title: "資料錯誤", message: "訂單資料不存在，請詢問團購發起人相關訊息。")
                dispatchGroup.leave()
                return
            }
        }) { (error) in
            print(error.localizedDescription)
            presentSimpleAlertMessage(title: "錯誤訊息", message: error.localizedDescription)
            dispatchGroup.leave()
            return
        }
        
        dispatchGroup.notify(queue: .main) {
            if downloadMenuInformation == true && downloadMenuOrder == true && memberIndex >= 0 {
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                guard let joinController = storyBoard.instantiateViewController(withIdentifier: "JOIN_ORDER_VC") as? JoinGroupOrderTableViewController else{
                    assertionFailure("[AssertionFailure] StoryBoard: JOIN_ORDER_VC can't find!! (HistoryTableViewController)")
                    return
                }

                joinController.menuInformation = menuData
                joinController.memberContent = memberContent
                joinController.memberIndex = memberIndex
                joinController.delegate = self
                self.navigationController?.show(joinController, sender: self)
            }
        }
    }
    
    func rejectOrderInvitation(data_index: Int) {
        let databaseRef = Database.database().reference()
        let pathString = "USER_MENU_ORDER/\(self.invitationList[data_index].orderOwnerID)/\(self.invitationList[data_index].orderNumber)/contentItems"
        databaseRef.child(pathString).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let itemRawData = snapshot.value
                let jsonData = try? JSONSerialization.data(withJSONObject: itemRawData as Any, options: [])

                let decoder: JSONDecoder = JSONDecoder()
                do {
                    var itemArray = try decoder.decode([MenuOrderMemberContent].self, from: jsonData!)

                    if let user_id = Auth.auth().currentUser?.uid {
                        if let itemIndex = itemArray.firstIndex(where: { $0.memberID == user_id }) {
                            let uploadPathString = pathString + "/\(itemIndex)"

                            itemArray[itemIndex].orderContent.replyStatus = MENU_ORDER_REPLY_STATUS_REJECT
                            databaseRef.child(uploadPathString).setValue(itemArray[itemIndex].toAnyObject())
                        }
                        
                        let formatter = DateFormatter()
                        formatter.dateFormat = DATETIME_FORMATTER
                        let dateString = formatter.string(from: Date())
                        updateNotificationReplyStatus(order_number: self.invitationList[data_index].orderNumber, reply_status: MENU_ORDER_REPLY_STATUS_REJECT, reply_time: dateString)
                        self.refreshNotificationDelegate?.refreshNotificationList()
                        self.refreshInvitationList()
                    }
                } catch {
                    print("rejectOrderInvitation jsonData decode failed: \(error.localizedDescription)")
                }
            } else {
                print("rejectOrderInvitation snapshot doesn't exist!")
                return
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}

extension HistoryTableViewController: JoinGroupOrderDelegate {
    func refreshHistoryInvitationList(sender: JoinGroupOrderTableViewController) {
        refreshInvitationList()
    }
}

extension HistoryTableViewController: GADInterstitialDelegate {
    /// Tells the delegate an ad request succeeded.
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("interstitialDidReceiveAd")
        if self.interstitialAd.isReady {
            self.interstitialAd.present(fromRootViewController: self)
        } else {
            print("Interstitial Ad is not ready !!")
        }
    }

    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    /// Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        print("interstitialWillPresentScreen")
    }

    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        print("interstitialWillDismissScreen")
    }

    /// Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("interstitialDidDismissScreen")
    }

    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        print("interstitialWillLeaveApplication")
    }
}
