//
//  DeliveryInformationTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/9/18.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
import Firebase

class DeliveryInformationTableViewController: UITableViewController, UITextFieldDelegate {
    @IBOutlet weak var labelStoreName: UILabel!
    @IBOutlet weak var buttonSendOrder: UIButton!
    @IBOutlet weak var segmentDeliveryType: UISegmentedControl!
    @IBOutlet weak var buttonAddress: UIButton!
    @IBOutlet weak var textAddress: UITextField!
    @IBOutlet weak var textContactName: UITextField!
    @IBOutlet weak var labelContactPhoneNumber: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var brandBackgroundColor: UIColor!
    var brandTextTintColor: UIColor!
    var menuOrder: MenuOrder = MenuOrder()
    var orderType: String = ""
    var brandName: String = ""
    var storeName: String = ""
    var detailMenuInformation: DetailMenuInformation = DetailMenuInformation()
    var storeInfo: StoreContactInformation = StoreContactInformation()
    var deliveryInfo: MenuOrderDeliveryInformation = MenuOrderDeliveryInformation()
    var groupOrderFlag: Bool = false
    var selectedType: Int = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.buttonSendOrder.layer.borderWidth = 1.0
        self.buttonSendOrder.layer.borderColor = UIColor.systemBlue.cgColor
        self.buttonSendOrder.layer.cornerRadius = 6

        //self.tableView.backgroundColor = self.brandBackgroundColor

        if self.groupOrderFlag {
            self.buttonSendOrder.setTitle("下一步", for: .normal)
        } else {
            self.buttonSendOrder.setTitle("訂餐", for: .normal)
        }

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)

        self.labelStoreName.text = self.storeName
        self.segmentDeliveryType.selectedSegmentIndex = self.selectedType
        let myContactInfo = getMyContactInfo()
        self.labelContactPhoneNumber.text = myContactInfo.userPhoneNumber
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

        self.menuOrder.orderNumber = tmpOrderNumber
        self.menuOrder.menuNumber = self.detailMenuInformation.menuNumber
        self.menuOrder.orderType = ORDER_TYPE_OFFICIAL_MENU
        self.menuOrder.orderStatus = ORDER_STATUS_INIT
        self.menuOrder.orderOwnerID = Auth.auth().currentUser!.uid
        self.menuOrder.orderOwnerName = getMyUserName()
        self.menuOrder.orderTotalQuantity = 0
        self.menuOrder.orderTotalPrice = 0
        self.menuOrder.brandName = self.detailMenuInformation.brandName
        self.menuOrder.needContactInfoFlag = false

        self.menuOrder.storeInfo = self.storeInfo
        self.menuOrder.deliveryInfo = self.deliveryInfo
        self.menuOrder.coworkBrandFlag = true
        self.menuOrder.groupOrderFlag = false
        
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

                join_vc.detailMenuInformation = self.detailMenuInformation
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

    @IBAction func changeDeliveryType(_ sender: UISegmentedControl) {
        self.selectedType = self.segmentDeliveryType.selectedSegmentIndex
        self.tableView.reloadData()
    }
    
    @IBAction func confirmToSendOrder(_ sender: UIButton) {
        if self.textContactName.text == nil || self.textContactName.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            presentSimpleAlertMessage(title: "錯誤訊息", message: "聯絡姓名不能為空白，請重新輸入")
            return
        }

        if self.selectedType == 1 {
            if self.textAddress.text == nil || self.textAddress.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                presentSimpleAlertMessage(title: "錯誤訊息", message: "外送地址不能為空白，請重新輸入")
                return
            }
        }
        
        if self.selectedType == 0 {
            self.deliveryInfo.deliveryType = DELIVERY_TYPE_TAKEOUT
        } else {
            self.deliveryInfo.deliveryType = DELIVERY_TYPE_DELIVERY
            self.deliveryInfo.deliveryAddress = self.textAddress.text!
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dayString = formatter.string(from: Date())
        formatter.dateFormat = "HH:mm"
        let timeString = formatter.string(from: self.datePicker.date)
        
        self.deliveryInfo.deliveryTime = "\(dayString) \(timeString)"
        print("self.deliveryInfo.deliveryTime = \(self.deliveryInfo.deliveryTime)")
        self.deliveryInfo.contactName = self.textContactName.text!
        self.deliveryInfo.contactPhoneNumber = self.labelContactPhoneNumber.text!
        
        if self.groupOrderFlag {
            guard let groupOrderController = self.storyboard?.instantiateViewController(withIdentifier: "DETAIL_CREATE_ORDER_VC") as? DetailGroupOrderTableViewController else {
                assertionFailure("[AssertionFailure] StoryBoard: DETAIL_CREATE_ORDER_VC can't find!! (MenuListTableViewController)")
                return
            }
            
            groupOrderController.orderType = ORDER_TYPE_OFFICIAL_MENU
            groupOrderController.brandName = self.detailMenuInformation.brandName
            groupOrderController.detailMenuInformation = self.detailMenuInformation
            groupOrderController.storeInfo = self.storeInfo
            groupOrderController.deliveryInfo = self.deliveryInfo
            self.navigationController?.show(groupOrderController, sender: self)
        } else {
            self.createMenuOrder()
        }
    }
    
    @IBAction func changeDeliveryAddress(_ sender: UIButton) {
        guard let addressController = self.storyboard?.instantiateViewController(withIdentifier: "DELIVERY_ADDRESS_VC") as? DeliveryAddressTableViewController else {
            assertionFailure("[AssertionFailure] StoryBoard: DELIVERY_ADDRESS_VC can't find!! (DeliveryInformationTableViewController)")
            return
        }
        
        addressController.delegate = self
        self.navigationController?.show(addressController, sender: self)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        //cell.backgroundColor = self.brandBackgroundColor
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 2 {
            if self.selectedType == 0 {
                return 0
            }
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }

}

extension DeliveryInformationTableViewController: DeliveryAddressDelegate {
    func getSelectedDeliveryAddress(sender: DeliveryAddressTableViewController, address: String) {
        self.textAddress.text = address
    }
}
