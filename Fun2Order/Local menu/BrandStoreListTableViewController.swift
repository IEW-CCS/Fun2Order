//
//  BrandStoreListTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/8/20.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
import Firebase

class BrandStoreListTableViewController: UITableViewController {
    var brandBackgroundColor: UIColor!
    var brandTextTintColor: UIColor!
    var brandProfile: DetailBrandProfile = DetailBrandProfile()
    var storeList: [DetailStoreInformation] = [DetailStoreInformation]()
    var menuOrder: MenuOrder = MenuOrder()
    var detailMenuInfo: DetailMenuInformation = DetailMenuInformation()
    var selectedStoreInfo: DetailStoreInformation = DetailStoreInformation()
    var groupOrderFlag: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        print("BrandStoreListTableViewController viewDidLoad")
        
        //testUploadBrandStore()
        let friendNib: UINib = UINib(nibName: "BrandStoreCell", bundle: nil)
        self.tableView.register(friendNib, forCellReuseIdentifier: "BrandStoreCell")
        
        //self.tableView.backgroundColor = TEST_BACKGROUND_COLOR
        //print("brandBackgroundColor = \(String(describing: self.brandBackgroundColor))")
        self.tableView.backgroundColor = self.brandBackgroundColor
        
        //downloadFBBrandStoreList(brand_name: "上宇林", completion: receiveStoreList)
        downloadFBBrandStoreList(brand_name: self.brandProfile.brandName, completion: receiveStoreList)

    }

    override func viewWillAppear(_ animated: Bool) {
        self.title = "分店資訊及訂購"
        self.navigationController?.title = "分店資訊及訂購"
        self.tabBarController?.title = "分店資訊及訂購"
    }

    func receiveStoreList(items: [DetailStoreInformation]?) {
        if items == nil {
            print("No stores exist on the server, just return")
            return
        }
        
        self.storeList = items!.sorted(by: { $0.storeID < $1.storeID })
        self.tableView.reloadData()
    }

    /*
    func createMenuOrder() {
        let timeZone = TimeZone.init(identifier: "UTC+8")
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.locale = Locale.init(identifier: "zh_TW")
        formatter.dateFormat = DATETIME_FORMATTER
        
        let tmpOrderNumber = "M\(formatter.string(from: Date()))"

        self.menuOrder.orderNumber = tmpOrderNumber
        self.menuOrder.menuNumber = self.detailMenuInfo.menuNumber
        self.menuOrder.orderType = ORDER_TYPE_OFFICIAL_MENU
        self.menuOrder.orderStatus = ORDER_STATUS_INIT
        self.menuOrder.orderOwnerID = Auth.auth().currentUser!.uid
        self.menuOrder.orderOwnerName = getMyUserName()
        self.menuOrder.orderTotalQuantity = 0
        self.menuOrder.orderTotalPrice = 0
        self.menuOrder.brandName = self.detailMenuInfo.brandName
        self.menuOrder.needContactInfoFlag = false

        var storeContact: StoreContactInformation = StoreContactInformation()
        storeContact.storeName = self.selectedStoreInfo.storeName
        storeContact.storeAddress = self.selectedStoreInfo.storeAddress
        storeContact.storePhoneNumber = self.selectedStoreInfo.storePhoneNumber
        storeContact.facebookURL = self.selectedStoreInfo.storeFacebookURL
        storeContact.instagramURL = self.selectedStoreInfo.storeInstagramURL

        self.menuOrder.storeInfo = storeContact
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = DATETIME_FORMATTER
        let timeString = timeFormatter.string(from: Date())
        self.menuOrder.createTime = timeString

        var dateComponent = DateComponents()
        dateComponent.day = 1
        let newDate = Calendar.current.date(byAdding: dateComponent, to: Date())
        timeFormatter.dateFormat = "yyyyMMdd"
        let dueTimeString = timeFormatter.string(from: newDate!)
        self.menuOrder.dueTime = "\(dueTimeString)000000000"

        var myContent: MenuOrderMemberContent = MenuOrderMemberContent()
        var myItem: MenuOrderContentItem = MenuOrderContentItem()

        myContent.memberID = Auth.auth().currentUser!.uid
        myContent.orderOwnerID = self.menuOrder.orderOwnerID
        myContent.memberTokenID = getMyTokenID()
        myItem.orderNumber = self.menuOrder.orderNumber
        myItem.itemOwnerID = Auth.auth().currentUser!.uid
        myItem.itemOwnerName = getMyUserName()
        myItem.replyStatus = MENU_ORDER_REPLY_STATUS_WAIT
        myItem.createTime = self.menuOrder.createTime
        myContent.orderContent = myItem
        myItem.ostype = "iOS"

        self.menuOrder.contentItems.append(myContent)
        self.uploadMenuOrder()
        self.sendMulticastNotification()
    }
    
    func uploadMenuOrder() {
        let databaseRef = Database.database().reference()
        
        if Auth.auth().currentUser?.uid == nil {
            print("uploadMenuOrder Auth.auth().currentUser?.uid == nil")
            return
        }
        
        let pathString = "USER_MENU_ORDER/\(Auth.auth().currentUser!.uid)/\(self.menuOrder.orderNumber)"
        databaseRef.child(pathString).setValue(self.menuOrder.toAnyObject()) { (error, reference) in
            if let error = error {
                print("uploadMenuOrder error = \(error.localizedDescription)")
                return
            } else {
                // Send notification to refresh HistoryList function
                print("GroupOrderViewController sends notification to refresh History List function")
                NotificationCenter.default.post(name: NSNotification.Name("RefreshHistory"), object: nil)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let join_vc = storyboard.instantiateViewController(withIdentifier: "DETAIL_JOIN_ORDER_VC") as? DetailJoinGroupOrderTableViewController else{
                    assertionFailure("[AssertionFailure] StoryBoard: JOIN_ORDER_VC can't find!! (GroupOrderViewController)")
                    return
                }

                join_vc.detailMenuInformation = self.detailMenuInfo
                join_vc.memberContent = self.menuOrder.contentItems[0]
                join_vc.memberIndex = 0
                join_vc.menuOrder = self.menuOrder
                DispatchQueue.main.async {
                    self.show(join_vc, sender: self)
                }
            }
        }
    }

    func sendMulticastNotification() {
        var tokenIDs: [String] = [String]()
        
        if !self.menuOrder.contentItems.isEmpty {
            var orderNotify: NotificationData = NotificationData()
            let title: String = "團購邀請"
            var body: String = ""
            let dateNow = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = DATETIME_FORMATTER
            let dateTimeString = formatter.string(from: dateNow)

            body = "來自『 \(self.menuOrder.orderOwnerName)』 發起的團購邀請，請點擊通知以查看詳細資訊。"
            orderNotify.messageTitle = title
            orderNotify.messageBody = body
            orderNotify.notificationType = NOTIFICATION_TYPE_ACTION_JOIN_ORDER
            orderNotify.receiveTime = dateTimeString
            orderNotify.orderOwnerID = self.menuOrder.orderOwnerID
            orderNotify.orderOwnerName = self.menuOrder.orderOwnerName
            orderNotify.menuNumber = self.menuOrder.menuNumber
            orderNotify.orderNumber = self.menuOrder.orderNumber
            orderNotify.dueTime = self.menuOrder.dueTime
            orderNotify.brandName = self.menuOrder.brandName
            orderNotify.attendedMemberCount = self.menuOrder.contentItems.count
            orderNotify.messageDetail = ""
            orderNotify.isRead = "Y"

            // send to iOS type device
            for i in 0...self.menuOrder.contentItems.count - 1 {
                if self.menuOrder.contentItems[i].orderContent.ostype != nil {
                    if self.menuOrder.contentItems[i].orderContent.ostype! == OS_TYPE_IOS {
                        tokenIDs.append(self.menuOrder.contentItems[i].memberTokenID)
                    }
                } else {
                    tokenIDs.append(self.menuOrder.contentItems[i].memberTokenID)
                }
            }
            
            if !tokenIDs.isEmpty {
                let sender = PushNotificationSender()
                sender.sendMulticastMessage(to: tokenIDs, notification_key: "", title: title, body: body, data: orderNotify, ostype: OS_TYPE_IOS)
            }
            
            tokenIDs.removeAll()
            // send to Android type device
            for i in 0...self.menuOrder.contentItems.count - 1 {
                if self.menuOrder.contentItems[i].orderContent.ostype != nil {
                    if self.menuOrder.contentItems[i].orderContent.ostype! == OS_TYPE_ANDROID {
                        tokenIDs.append(self.menuOrder.contentItems[i].memberTokenID)
                    }
                }
            }
            
            if !tokenIDs.isEmpty {
                let sender = PushNotificationSender()
                usleep(100000)
                sender.sendMulticastMessage(to: tokenIDs, notification_key: "", title: title, body: body, data: orderNotify, ostype: OS_TYPE_ANDROID)
            }
        }
    }
    */

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.storeList.isEmpty {
            return 0
        } else {
            return self.storeList.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BrandStoreCell", for: indexPath) as! BrandStoreCell
        
        cell.setData(store_info: self.storeList[indexPath.row])
        //cell.backgroundColor = TEST_BACKGROUND_COLOR
        cell.backgroundColor = self.brandBackgroundColor
        cell.delegate = self
        cell.tag = indexPath.row

        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
}

extension BrandStoreListTableViewController: BrandStoreDelegate {
    func selectedStoreToOrder(sender: BrandStoreCell, index: Int) {
        print("Receive BrandStoreDelegate selectedStoreToOrder for index[\(index)]")
        self.selectedStoreInfo = self.storeList[index]
        downloadFBDetailMenuInformation(menu_number: self.storeList[index].storeMenuNumber, completion: { menu_info in
            if menu_info == nil {
                return
            }
            
            self.detailMenuInfo = menu_info!

            var storeContact: StoreContactInformation = StoreContactInformation()
            storeContact.storeName = self.selectedStoreInfo.storeName
            storeContact.storeAddress = self.selectedStoreInfo.storeAddress
            storeContact.storePhoneNumber = self.selectedStoreInfo.storePhoneNumber
            storeContact.facebookURL = self.selectedStoreInfo.storeFacebookURL
            storeContact.instagramURL = self.selectedStoreInfo.storeInstagramURL

            guard let deliveryController = self.storyboard?.instantiateViewController(withIdentifier: "DELIVERY_INFO_VC") as? DeliveryInformationTableViewController else {
                assertionFailure("[AssertionFailure] StoryBoard: DELIVERY_INFO_VC can't find!! (BrandStoreListTableViewController)")
                return
            }

            deliveryController.orderType = ORDER_TYPE_OFFICIAL_MENU
            deliveryController.brandName = self.detailMenuInfo.brandName
            deliveryController.storeName = self.selectedStoreInfo.storeName
            deliveryController.detailMenuInformation = self.detailMenuInfo
            deliveryController.storeInfo = storeContact
            deliveryController.brandBackgroundColor = self.brandBackgroundColor
            deliveryController.brandTextTintColor = self.brandTextTintColor

            let controller = UIAlertController(title: "選擇訂購方式", message: nil, preferredStyle: .alert)
            
            let groupAction = UIAlertAction(title: "揪團訂購", style: .default) { (_) in
                print("Create GroupOrder for friends")
                self.groupOrderFlag = true
                
                deliveryController.groupOrderFlag = self.groupOrderFlag
                self.navigationController?.show(deliveryController, sender: self)
            }
            
            groupAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
            controller.addAction(groupAction)
            
            let singleAction = UIAlertAction(title: "自己訂購", style: .default) { (_) in
                print("Create GroupOrder for myself")
                self.groupOrderFlag = false
                
                deliveryController.groupOrderFlag = self.groupOrderFlag
                self.navigationController?.show(deliveryController, sender: self)
            }

            singleAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
            controller.addAction(singleAction)
            
            let cancelAction = UIAlertAction(title: "取消", style: .default) { (_) in
               print("Cancel update")
            }
            
            cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
            controller.addAction(cancelAction)
            
            self.present(controller, animated: true, completion: nil)
        })
    }
    
    func displayStoreMap(sender: BrandStoreCell, index: Int) {
        print("Receive BrandStoreDelegate displayStoreMap for index[\(index)]")
        guard let storeMapController = self.storyboard?.instantiateViewController(withIdentifier: "BRAND_MAP_VC") as? BrandStoreMapTableViewController else {
            assertionFailure("[AssertionFailure] StoryBoard: BRAND_MAP_VC can't find!! (BrandStoreMapTableViewController)")
            return
        }
        
        storeMapController.storeInfo = self.storeList[index]
        storeMapController.brandBackgroundColor = self.brandBackgroundColor
        storeMapController.brandTextTintColor = self.brandTextTintColor
        self.navigationController?.show(storeMapController, sender: self)
    }
    
    func dialPhoneNumber(sender: BrandStoreCell, index: Int) {
        print("Receive BrandStoreDelegate dialPhoneNumber for index[\(index)]")
        print("The Store's phone number is [\(String(describing: self.storeList[index].storePhoneNumber))]")
        if self.storeList[index].storePhoneNumber == nil {
            print("Store Phone Number is nil")
            return
        }
                    
        guard let url = URL(string: "tel://\(self.storeList[index].storePhoneNumber!)") else {
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
