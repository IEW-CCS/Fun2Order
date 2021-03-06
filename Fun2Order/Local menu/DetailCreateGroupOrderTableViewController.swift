//
//  DetailCreateGroupOrderTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/7/12.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
//import CoreData
import Firebase

class DetailCreateGroupOrderTableViewController: UITableViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {
    @IBOutlet weak var labelBrandName: UILabel!
    @IBOutlet weak var buttonConfirm: UIButton!
    @IBOutlet weak var textViewMessage: UITextView!
    @IBOutlet weak var buttonDueDate: UIButton!
    @IBOutlet weak var labelDueDate: UILabel!
    @IBOutlet weak var labelLocationCount: UILabel!
    @IBOutlet weak var myCheckStatus: Checkbox!
    @IBOutlet weak var checkboxContactInfo: Checkbox!
    @IBOutlet weak var checkboxSeparatePackage: Checkbox!
    
    
    var isAttended: Bool = true
    var isNeedContactInfo: Bool = false
    var memberList: [GroupMember] = [GroupMember]()
    var detailMenuInformation: DetailMenuInformation = DetailMenuInformation()
    var deliveryInfo: MenuOrderDeliveryInformation = MenuOrderDeliveryInformation()
    var brandName: String = ""
    var orderType: String = ""
    var menuOrder: MenuOrder = MenuOrder()
    var storeInfo: StoreContactInformation?
    var coworkBrandFlag: Bool = false
    var packageFlag: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.buttonDueDate.layer.borderWidth = 1.0
        self.buttonDueDate.layer.borderColor = UIColor.systemBlue.cgColor
        self.buttonDueDate.layer.cornerRadius = 6

        self.labelDueDate.layer.borderWidth = 1.0
        self.labelDueDate.layer.borderColor = COLOR_PEPPER_RED.cgColor
        self.labelDueDate.layer.cornerRadius = 6
        self.labelDueDate.isHidden = true

        self.buttonConfirm.layer.borderWidth = 1.0
        self.buttonConfirm.layer.borderColor = UIColor.systemBlue.cgColor
        self.buttonConfirm.layer.cornerRadius = 6

        self.textViewMessage.layer.borderWidth = 1.0
        self.textViewMessage.layer.borderColor = UIColor.lightGray.cgColor
        self.textViewMessage.layer.cornerRadius = 6

        self.labelBrandName.text = self.detailMenuInformation.brandName
        self.labelDueDate.text = nil
        
        self.myCheckStatus.isChecked = true
        self.myCheckStatus.valueChanged = { (isChecked) in
            print("myCheckStatus is checked: \(isChecked)")
            self.isAttended = isChecked
        }

        self.checkboxContactInfo.valueChanged = { (isChecked) in
            print("checkboxContactInfo is checked: \(isChecked)")
            self.isNeedContactInfo = isChecked
        }
        
        self.checkboxSeparatePackage.valueChanged = { (isChecked) in
            print("checkboxSeparatePackage is checked: \(isChecked)")
            self.packageFlag = isChecked
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
          textField.resignFirstResponder()
          return true
    }
    
    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }

    func createMenuOrder() {
        let timeZone = TimeZone.init(identifier: "UTC+8")
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.locale = Locale.init(identifier: "zh_TW")
        formatter.dateFormat = DATETIME_FORMATTER
        
        let tmpOrderNumber = "M\(formatter.string(from: Date()))"
      
        self.deliveryInfo.separatePackageFlag = self.packageFlag
        
        self.menuOrder.orderNumber = tmpOrderNumber
        self.menuOrder.menuNumber = self.detailMenuInformation.menuNumber
        self.menuOrder.orderType = ORDER_TYPE_OFFICIAL_MENU
        self.menuOrder.orderStatus = ORDER_STATUS_INIT
        self.menuOrder.orderOwnerID = Auth.auth().currentUser!.uid
        self.menuOrder.orderOwnerName = getMyUserName()
        self.menuOrder.orderTotalQuantity = 0
        self.menuOrder.orderTotalPrice = 0
        self.menuOrder.brandName = self.detailMenuInformation.brandName
        self.menuOrder.needContactInfoFlag = self.isNeedContactInfo
        self.menuOrder.storeInfo = self.storeInfo
        self.menuOrder.deliveryInfo = self.deliveryInfo
        self.menuOrder.coworkBrandFlag = self.coworkBrandFlag
        self.menuOrder.groupOrderFlag = true

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = DATETIME_FORMATTER
        let timeString = timeFormatter.string(from: Date())
        self.menuOrder.createTime = timeString

        if self.labelDueDate.text != nil {
            let formatter1 = DateFormatter()
            formatter1.dateFormat = TAIWAN_DATETIME_FORMATTER2
            let timeData = formatter1.date(from: self.labelDueDate.text!)
            
            let formatter2 = DateFormatter()
            formatter2.dateFormat = DATETIME_FORMATTER
            self.menuOrder.dueTime = formatter2.string(from: timeData!)
        }

        if self.isAttended {
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
        }

        let contentGroup = DispatchGroup()
        if self.memberList.isEmpty {
            self.uploadMenuOrder()
            //self.sendGroupOrderNotification()
            self.sendMulticastNotification()
            return
        } else {
            for i in 0...self.memberList.count - 1 {
                if self.memberList[i].isSelected {
                    var memberContent: MenuOrderMemberContent = MenuOrderMemberContent()
                    var contentItem: MenuOrderContentItem = MenuOrderContentItem()
                    
                    let databaseRef = Database.database().reference()
                    let pathString = "USER_PROFILE/\(self.memberList[i].memberID)"
                    contentGroup.enter()
                    databaseRef.child(pathString).observeSingleEvent(of: .value, with: { (snapshot) in
                        if snapshot.exists() {
                            var userProfile: UserProfile = UserProfile()
                            let profileData = snapshot.value
                            let jsonData = try? JSONSerialization.data(withJSONObject: profileData as Any, options: [])

                            let decoder: JSONDecoder = JSONDecoder()
                            do {
                                userProfile = try decoder.decode(UserProfile.self, from: jsonData!)
                            } catch {
                                print("createMenuOrder userProfile jsonData decode failed: \(error.localizedDescription)")
                                return
                                //presentSimpleAlertMessage(title: "資料錯誤", message: "")
                            }
                            //let token_id = snapshot.value as! String
                            let token_id = userProfile.tokenID
                            var ostype = userProfile.ostype
                            if ostype == nil || ostype! == "" {
                                ostype = "iOS"
                            }
                            
                            memberContent.memberID = self.memberList[i].memberID
                            memberContent.orderOwnerID = self.menuOrder.orderOwnerID
                            memberContent.memberTokenID = token_id
                            contentItem.orderNumber = self.menuOrder.orderNumber
                            contentItem.itemOwnerID = self.memberList[i].memberID
                            contentItem.itemOwnerName = self.memberList[i].memberName
                            contentItem.replyStatus = MENU_ORDER_REPLY_STATUS_WAIT
                            contentItem.createTime = self.menuOrder.createTime
                            contentItem.ostype = ostype
                            memberContent.orderContent = contentItem

                            self.menuOrder.contentItems.append(memberContent)
                            contentGroup.leave()
                        }
                    })  { (error) in
                        print(error.localizedDescription)
                        contentGroup.leave()
                    }
                }
            }
        }
        
        contentGroup.notify(queue: .main) {
            print("self.menuOrder.contentItems = \(self.menuOrder.contentItems)")
            //self.app.saveContext()

            self.uploadMenuOrder()
            self.sendMulticastNotification()
        }
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
                //NotificationCenter.default.post(name: NSNotification.Name("RefreshHistory"), object: nil)
                if self.isAttended {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    guard let join_vc = storyboard.instantiateViewController(withIdentifier: "DETAIL_JOIN_ORDER_VC") as? DetailJoinGroupOrderTableViewController else{
                        assertionFailure("[AssertionFailure] StoryBoard: JOIN_ORDER_VC can't find!! (GroupOrderViewController)")
                        return
                    }

                    join_vc.detailMenuInformation = self.detailMenuInformation
                    join_vc.memberContent = self.menuOrder.contentItems[0]
                    join_vc.memberIndex = 0
                    join_vc.menuOrder = self.menuOrder
                    DispatchQueue.main.async {
                        self.show(join_vc, sender: self)
                    }
                } else {
                    self.navigationController?.popToRootViewController(animated: true)
                    self.dismiss(animated: false, completion: nil)
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
            orderNotify.messageDetail = self.textViewMessage.text
            orderNotify.isRead = "N"

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
                sender.sendMulticastMessage(to: tokenIDs, title: title, body: body, data: orderNotify, ostype: OS_TYPE_IOS)
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
                sender.sendMulticastMessage(to: tokenIDs, title: title, body: body, data: orderNotify, ostype: OS_TYPE_ANDROID)
            }
        }
    }

    @IBAction func setupOrderDueDate(_ sender: UIButton) {
        let controller = UIAlertController(title: "請設定截止時間", message: nil, preferredStyle: .actionSheet)

        guard let dateTimeController = self.storyboard?.instantiateViewController(withIdentifier: "DATETIME_VC") as? DateTimeViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: DATETIME_VC can't find!! (QRCodeViewController)")
            return
        }

        controller.setValue(dateTimeController, forKey: "contentViewController")
        //birthdayController.preferredContentSize.height = 150
        controller.addChild(dateTimeController)
        
        let cancelAction = UIAlertAction(title: "取消", style: .default) { (_) in
            print("Cancel to update due date!")
        }
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        controller.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
            let datetime_controller = controller.children[0] as! DateTimeViewController
            let dueTime: String = datetime_controller.getDueDate()
            if dueTime == "" {
                presentSimpleAlertMessage(title: "提示訊息", message: "尚未指定團購單截止時間")
                return
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = TAIWAN_DATETIME_FORMATTER2
            let nowDate = formatter.string(from: Date())
            if nowDate > dueTime {
                presentSimpleAlertMessage(title: "錯誤訊息", message: "團購單截止時間不得早於現在時間")
                return
            }
            
            self.labelDueDate.text = datetime_controller.getDueDate()
            self.labelDueDate.isHidden = false
        }
        
        okAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        controller.addAction(okAction)
        
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func addLocations(_ sender: UIButton) {
        let controller = UIAlertController(title: "請輸入地點", message: nil, preferredStyle: .alert)
        controller.addTextField { (textField) in
            textField.placeholder = "輸入地點"
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .default) { (_) in
            print("Cancel to update location!")
        }
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        controller.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
            let location_string = controller.textFields?[0].text
            if location_string == nil || location_string!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                presentSimpleAlertMessage(title: "錯誤訊息", message: "輸入的地點不能為空白，請重新輸入")
                return
            }

            if location_string != "" {
                if self.menuOrder.locations == nil {
                    self.menuOrder.locations = [String]()
                }
                if !self.menuOrder.locations!.isEmpty {
                    for i in 0...self.menuOrder.locations!.count - 1 {
                        if self.menuOrder.locations![i] == location_string {
                            presentSimpleAlertMessage(title: "錯誤訊息", message: "地點不能重覆，請重新輸入新地點")
                            return
                        }
                    }
                }
                self.menuOrder.locations!.append(location_string!)
                self.labelLocationCount.text = "\(self.menuOrder.locations!.count) 項"
            }
        }
        okAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        controller.addAction(okAction)
        
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func sendOrderGroup(_ sender: UIButton) {
       if self.memberList.isEmpty && !self.isAttended {
            print("Selected Group's member list is empty")
            presentSimpleAlertMessage(title: "錯誤訊息", message: "此團購訂單尚未指定任何參與者，請重新選取參與者")
            return
        }
        
        if labelDueDate.text == nil {
            presentSimpleAlertMessage(title: "錯誤訊息", message: "訂單截止時間為必填資訊，請重新指定截止時間。")
            return
        }

        self.buttonConfirm.isEnabled = false
        downloadFBDetailBrandProfile(brand_name: self.detailMenuInformation.brandName, completion: { brandProfile in
            if brandProfile == nil {
                presentSimpleAlertMessage(title: "錯誤訊息", message: "存取品牌資料時發生錯誤")
                return
            }
            
            if brandProfile!.coworkBrandFlag == nil {
                self.coworkBrandFlag = false
            } else {
                self.coworkBrandFlag =  brandProfile!.coworkBrandFlag!
            }
            self.createMenuOrder()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowLocation" {
            if let controllerLocation = segue.destination as? MenuLocationTableViewController {
                controllerLocation.locationArray = self.menuOrder.locations
                controllerLocation.delegate = self
            }
        }
    }
}

extension DetailCreateGroupOrderTableViewController: MenuLocationDelegate {
    func updateMenuLocation(locations: [String]?) {
        var locationCount: Int = 0

        self.menuOrder.locations = locations
        if self.menuOrder.locations != nil {
            locationCount = self.menuOrder.locations!.count
        }
        self.labelLocationCount.text = "\(locationCount) 項"
    }
}
