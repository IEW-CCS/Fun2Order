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
    //@IBOutlet weak var segmentType: UISegmentedControl!
    
    @IBOutlet weak var segmentType: UISegmentedControl!
    var menuOrderList: [MenuOrder] = [MenuOrder]()
    var filteredMenuOrderList: [MenuOrder] = [MenuOrder]()
    var invitationList: [NotificationData] = [NotificationData]()
    
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    weak var refreshNotificationDelegate: ApplicationRefreshNotificationDelegate?
    var selectedType: Int = 0
    var isAdLoadedSuccess: Bool = false
    var adBannerView: GADBannerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        vc = app.persistentContainer.viewContext
        refreshNotificationDelegate = app.notificationDelegate
        
        let historyCellViewNib: UINib = UINib(nibName: "OrderHistoryCell", bundle: nil)
        self.tableView.register(historyCellViewNib, forCellReuseIdentifier: "OrderHistoryCell")

        let adCellViewNib: UINib = UINib(nibName: "BannerAdCell", bundle: nil)
        self.tableView.register(adCellViewNib, forCellReuseIdentifier: "BannerAdCell")

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.receiveRefreshHistory(_:)),
            name: NSNotification.Name(rawValue: "RefreshHistory"),
            object: nil
        )

        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "正在更新揪團紀錄")
        self.tableView.refreshControl = refreshControl
        refreshControl?.addTarget(self, action: #selector(refreshHistoryList), for: .valueChanged)

        self.segmentType.selectedSegmentIndex = 0
        queryMenuOrder()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.title = "揪團紀錄"
        self.navigationController?.title = "揪團紀錄"
        self.tabBarController?.title = "揪團紀錄"
        navigationController?.navigationBar.backItem?.setHidesBackButton(true, animated: false)
        setupBannerAdView()
    }

    @objc func refreshHistoryList() {
        DispatchQueue.main.async {
            self.queryMenuOrder()
        }
    }

    func setupBannerAdView() {
        self.adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        
        // iOS-NotificationList-BannerAd adUnitID
        //self.adBannerView.adUnitID = "ca-app-pub-6672968234138119/9417830726"
        self.adBannerView.adUnitID = NOTIFICATIONLIST_BANNER_AD
        self.adBannerView.delegate = self
        self.adBannerView.rootViewController = self
        self.adBannerView.load(GADRequest())
    }

    @IBAction func changeHistoryType(_ sender: UISegmentedControl) {
        self.selectedType = self.segmentType.selectedSegmentIndex
        filterHistoryDueTime()
        self.tableView.reloadData()
    }

    func filterHistoryDueTime() {
        if self.menuOrderList.isEmpty {
            self.filteredMenuOrderList.removeAll()
            return
        }
        
        self.filteredMenuOrderList.removeAll()
        let formatter = DateFormatter()
        formatter.dateFormat = DATETIME_FORMATTER
        let nowString = formatter.string(from: Date())
        
        for i in 0...self.menuOrderList.count - 1 {
            if self.selectedType == 0 {
                if menuOrderList[i].dueTime > nowString {
                    self.filteredMenuOrderList.append(self.menuOrderList[i])
                }
            } else {
                if menuOrderList[i].dueTime < nowString {
                    self.filteredMenuOrderList.append(self.menuOrderList[i])
                }
            }
        }
    }
    
    func refreshInvitationList() {
        //self.segmentType.selectedSegmentIndex = 1
        self.selectedType = 1
        self.invitationList = retrieveInvitationNotificationList()
        self.tableView.reloadData()
    }
    
    func queryMenuOrder() {
        var pathString: String = ""
        let databaseRef = Database.database().reference()
        //let pathString = "USER_MENU_ORDER/\(order_info.orderOwnerID)/\(order_info.orderNumber)"
        if let userID = Auth.auth().currentUser?.uid {
            pathString = "USER_MENU_ORDER/\(userID)"
            //print("pathString = \(pathString)")
        } else {
            print("HistoryTableViewController queryMenuOrder: Auth.auth().currentUser?.uid is nil, just return")
        }
        
        self.menuOrderList.removeAll()
        databaseRef.child(pathString).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let childEnumerator = snapshot.children
                
                let childDecoder: JSONDecoder = JSONDecoder()
                while let childData = childEnumerator.nextObject() as? DataSnapshot {
                    //print("child = \(childData)")
                    do {
                        let childJsonData = try? JSONSerialization.data(withJSONObject: childData.value as Any, options: [])
                        let realData = try childDecoder.decode(MenuOrder.self, from: childJsonData!)
                        self.menuOrderList.append(realData)
                    } catch {
                        print("queryMenuOrder jsonData decode failed: \(error.localizedDescription)")
                        continue
                    }
               }
                self.menuOrderList.sort(by: {$0.createTime > $1.createTime })
                self.filterHistoryDueTime()
                self.tableView.reloadData()
                //sleep(1)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.refreshControl?.endRefreshing()
                }
            } else {
                //self.filteredMenuOrderList.removeAll()
                self.filterHistoryDueTime()
                self.tableView.reloadData()
                print("queryMenuOrder snapshot doesn't exist!")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.refreshControl?.endRefreshing()
                }
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
                    if returnOrder.orderOwnerID == "" {
                        print("checkOrderExpire returnOrder.orderOwnerID is empty")
                        continue
                    }
                    
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
    
    func downloadMenuOrderContent(owner_id: String, order_number: String, member_id: String) {
        var memberContent: MenuOrderMemberContent = MenuOrderMemberContent()
        //var memberIndex: Int = -1

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
                        memberContent = itemArray[itemIndex]
                        //memberIndex = itemIndex
                        self.displayProductList(content: memberContent)
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
    
    func displayProductList(content: MenuOrderMemberContent) {
        //presentSimpleAlertMessage(title: "Test", message: "Need to Display Product List of \(content.orderContent.orderNumber) for index \(index)")
        if content.orderContent.menuProductItems == nil {
            presentSimpleAlertMessage(title: "提示訊息", message: "這張邀請單未選購任何產品")
            return
        }
        
        let controller = UIAlertController(title: "已回覆 產品列表", message: nil, preferredStyle: .alert)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let orderProductList = storyboard.instantiateViewController(withIdentifier: "ORDER_PRODUCTLIST_VC") as? OrderProductListTableViewController else {
            assertionFailure("[AssertionFailure] StoryBoard: ORDER_PRODUCTLIST_VC can't find!! (ViewController)")
            return
        }

        orderProductList.memberContent = content

        controller.setValue(orderProductList, forKey: "contentViewController")
        orderProductList.preferredContentSize.height = 320
        controller.preferredContentSize.height = 320
        controller.addChild(orderProductList)
        let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
            print("Confirm to dismiss product list")
        }

        okAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        controller.addAction(okAction)
        
        self.present(controller, animated: true, completion: nil)

    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //if segmentType.selectedSegmentIndex == 0 {
        if section == 0 {
            return 1
        } else {
            if self.filteredMenuOrderList.isEmpty {
                return 0
            } else {
                return self.filteredMenuOrderList.count
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if !self.isAdLoadedSuccess {
                return UITableViewCell()
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "BannerAdCell", for: indexPath) as! BannerAdCell
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            let adSize = GADAdSizeFromCGSize(CGSize(width: CGFloat(self.tableView.contentSize.width - 20), height: CGFloat(NOTIFICATION_LIST_BANNER_AD_HEIGHT - 20)))
            self.adBannerView.adSize = adSize
            cell.contentView.addSubview(self.adBannerView)
            self.adBannerView.center = cell.contentView.center

            cell.AdjustAutoLayout()
            return cell
        } else {
            if self.filteredMenuOrderList.isEmpty {
                return super.tableView(tableView, cellForRowAt: indexPath)
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderHistoryCell", for: indexPath) as! OrderHistoryCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.setMenuData(menu_order: self.filteredMenuOrderList[indexPath.row])

            cell.delegate = self
            cell.indexPath = indexPath
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let databaseRef = Database.database().reference()
        let pathString = "USER_MENU_ORDER/\(self.filteredMenuOrderList[indexPath.row].orderOwnerID)/\(self.filteredMenuOrderList[indexPath.row].orderNumber)"

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
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //if self.segmentType.selectedSegmentIndex == 0 {
        if indexPath.section == 0 {
            if self.isAdLoadedSuccess {
                //print("section 0 height return\(NOTIFICATION_LIST_BANNER_AD_HEIGHT)")
                return CGFloat(NOTIFICATION_LIST_BANNER_AD_HEIGHT)
            } else {
                //print("section 0 height return 0")
                return 0
            }
        } else {
            return 180
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        } else {
            return true
        }
    }

    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "刪除"
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        var alertWindow: UIWindow!
        if editingStyle == .delete {
            let controller = UIAlertController(title: "刪除訂單資料", message: "確定要刪除此訂單資料嗎？", preferredStyle: .alert)

            let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
                print("Confirm to delete this order information")
                alertWindow.isHidden = true
                let databaseRef = Database.database().reference()
                if Auth.auth().currentUser?.uid == nil || self.filteredMenuOrderList[indexPath.row].orderNumber == "" {
                    print("Auth currentUser.uid is nil || self.menuOrderList[indexPath.row].orderNumber is empty")
                    return
                }
                
                //let pathString = "USER_MENU_ORDER/\(self.menuOrderList[indexPath.row].orderOwnerID)/\(self.menuOrderList[indexPath.row].orderNumber)"
                let pathString = "USER_MENU_ORDER/\(Auth.auth().currentUser!.uid)/\(self.filteredMenuOrderList[indexPath.row].orderNumber)"
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
    }
}

extension HistoryTableViewController: DisplayQRCodeDelegate {
    func didQRCodeButtonPressed(at index: IndexPath) {
        guard let qrCodeController = self.storyboard?.instantiateViewController(withIdentifier: "QRCode_VC") as? QRCodeViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: QRCode_VC can't find!! (QRCodeViewController)")
            return
        }
        
        qrCodeController.setQRCodeText(code: self.filteredMenuOrderList[index.row].orderNumber)
        qrCodeController.modalTransitionStyle = .crossDissolve
        qrCodeController.modalPresentationStyle = .overFullScreen
        navigationController?.present(qrCodeController, animated: true, completion: nil)
    }
    
    func sendNewOrderToStore(at index: IndexPath) {
        queryMenuOrder()
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
            if downloadMenuInformation && downloadMenuOrder && memberIndex >= 0 {
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
        
        if self.invitationList[data_index].orderOwnerID == "" {
            print("rejectOrderInvitation self.invitationList[data_index].orderOwnerID is empty")
            return
        }
        
        let pathString = "USER_MENU_ORDER/\(self.invitationList[data_index].orderOwnerID)/\(self.invitationList[data_index].orderNumber)/contentItems"
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

                        updateNotificationReplyStatus(order_number: self.invitationList[data_index].orderNumber, reply_status: MENU_ORDER_REPLY_STATUS_REJECT, reply_time: dateString)
                        self.refreshNotificationDelegate?.refreshNotificationList()
                        self.refreshInvitationList()
                    }
                } catch {
                    print("rejectOrderInvitation jsonData decode failed: \(error.localizedDescription)")
                    presentSimpleAlertMessage(title: "資料錯誤", message: "訂單資料讀取錯誤，請團購發起人重發。")
                }
            } else {
                print("rejectOrderInvitation snapshot doesn't exist!")
                presentSimpleAlertMessage(title: "資料錯誤", message: "訂單資料不存在，請詢問團購發起人相關訊息。")
                return
            }
        }) { (error) in
            print(error.localizedDescription)
            presentSimpleAlertMessage(title: "錯誤訊息", message: error.localizedDescription)
        }
    }
}

extension HistoryTableViewController: JoinGroupOrderDelegate {
    func refreshHistoryInvitationList(sender: JoinGroupOrderTableViewController) {
        refreshInvitationList()
    }
}

extension HistoryTableViewController: GADBannerViewDelegate {
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner loaded successfully")
        self.isAdLoadedSuccess = true
        self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
     
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads")
        print(error)
        self.isAdLoadedSuccess = false
        self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        //self.tableView.reloadData()
    }
}
