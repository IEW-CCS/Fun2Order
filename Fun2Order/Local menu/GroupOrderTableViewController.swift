//
//  GroupOrderTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/7/6.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class GroupOrderTableViewController: UITableViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var collectionGroup: UICollectionView!
    @IBOutlet weak var memberTableView: UITableView!
    @IBOutlet weak var textViewMessage: UITextView!
    @IBOutlet weak var buttonDueDate: UIButton!
    @IBOutlet weak var labelDueDate: UILabel!
    @IBOutlet weak var myCheckStatus: Checkbox!
    @IBOutlet weak var buttonCreateOrder: UIButton!
    @IBOutlet weak var labelLocationCount: UILabel!
    @IBOutlet weak var checkboxContactInfo: Checkbox!
    
    var groupList: [Group] = [Group]()
    var memberList: [GroupMember] = [GroupMember]()
    var selectedGroupIndex: Int = 0
    var isAttended: Bool = true
    var favoriteStoreInfo: FavoriteStoreInfo = FavoriteStoreInfo()
    var menuInformation: MenuInformation = MenuInformation()
    var detailMenuInformation: DetailMenuInformation = DetailMenuInformation()
    var brandName: String = ""
    var orderType: String = ""
    var menuOrder: MenuOrder = MenuOrder()
    var isNeedContactInfo: Bool = false

    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        vc = app.persistentContainer.viewContext
        
        //let iconImage: UIImage? = UIImage(named: "Icon_Clock.png")
        //self.buttonDueDate.setImage(iconImage, for: UIControl.State.normal)
        self.buttonDueDate.layer.borderWidth = 1.0
        self.buttonDueDate.layer.borderColor = UIColor.systemBlue.cgColor
        self.buttonDueDate.layer.cornerRadius = 6
        
        self.labelDueDate.layer.borderWidth = 1.0
        self.labelDueDate.layer.borderColor = COLOR_PEPPER_RED.cgColor
        self.labelDueDate.layer.cornerRadius = 6
        self.labelDueDate.isHidden = true

        self.buttonCreateOrder.layer.borderWidth = 1.0
        self.buttonCreateOrder.layer.borderColor = UIColor.systemBlue.cgColor
        self.buttonCreateOrder.layer.cornerRadius = 6

        self.labelTitle.layer.borderWidth = 1.0
        self.labelTitle.layer.borderColor = UIColor.systemTeal.cgColor
        self.labelTitle.layer.cornerRadius = 6
        
        self.collectionGroup.layer.borderWidth = 1.0
        self.collectionGroup.layer.borderColor = UIColor.systemBlue.cgColor
        self.collectionGroup.layer.cornerRadius = 6

        self.textViewMessage.layer.borderWidth = 1.0
        self.textViewMessage.layer.borderColor = UIColor.lightGray.cgColor
        self.textViewMessage.layer.cornerRadius = 6

        let groupCellViewNib: UINib = UINib(nibName: "GroupCell", bundle: nil)
        self.collectionGroup.register(groupCellViewNib, forCellWithReuseIdentifier: "GroupCell")
        collectionGroup.dataSource = self
        collectionGroup.delegate = self

        let memberCellViewNib: UINib = UINib(nibName: "SelectMemberCell", bundle: nil)
        self.memberTableView.register(memberCellViewNib, forCellReuseIdentifier: "SelectMemberCell")
        self.memberTableView.delegate = self
        self.memberTableView.dataSource = self
        self.memberTableView.layer.borderWidth = 1.0
        self.memberTableView.layer.borderColor = UIColor.systemBlue.cgColor
        self.memberTableView.layer.cornerRadius = 6

        self.tabBarController?.title = self.title
        
        self.myCheckStatus.isChecked = true
        self.myCheckStatus.valueChanged = { (isChecked) in
            print("checkbox is checked: \(isChecked)")
            self.isAttended = isChecked
        }

        self.checkboxContactInfo.valueChanged = { (isChecked) in
            print("checkbox is checked: \(isChecked)")
            self.isNeedContactInfo = isChecked
        }

        self.labelDueDate.text = nil

        self.groupList = retrieveGroupList()
        if self.groupList.count > 0 {
            self.memberList = retrieveMemberList(group_id: self.groupList[self.selectedGroupIndex].groupID)
            if !self.memberList.isEmpty {
                for i in 0...self.memberList.count - 1 {
                    self.memberList[i].isSelected = true
                }
            }
            self.memberTableView.reloadData()
        }

        if self.orderType == ORDER_TYPE_MENU {
            self.labelTitle.text = self.menuInformation.brandName
        } else if self.orderType == ORDER_TYPE_OFFICIAL_MENU {
            self.labelTitle.text = self.brandName
        } else {
            self.labelTitle.text = "\(self.favoriteStoreInfo.brandName)  \(self.favoriteStoreInfo.storeName)"
        }

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.title = "設定揪團訂單"
        self.navigationController?.title = "設定揪團訂單"
        self.tabBarController?.title = "設定揪團訂單"
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
          textField.resignFirstResponder()
          return true
    }
    
    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
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
    
    func createMenuOrder() {
        let timeZone = TimeZone.init(identifier: "UTC+8")
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.locale = Locale.init(identifier: "zh_TW")
        formatter.dateFormat = DATETIME_FORMATTER
        
        let tmpOrderNumber = "M\(formatter.string(from: Date()))"
      
        self.menuOrder.orderNumber = tmpOrderNumber
        self.menuOrder.menuNumber = self.menuInformation.menuNumber
        self.menuOrder.orderType = ORDER_TYPE_MENU
        self.menuOrder.orderStatus = ORDER_STATUS_READY
        self.menuOrder.orderOwnerID = self.menuInformation.userID
        //self.menuOrder.orderOwnerName = (Auth.auth().currentUser?.displayName)!
        self.menuOrder.orderOwnerName = getMyUserName()
        self.menuOrder.orderTotalQuantity = 0
        self.menuOrder.orderTotalPrice = 0
        self.menuOrder.brandName = self.menuInformation.brandName
        self.menuOrder.needContactInfoFlag = self.isNeedContactInfo
        //if !self.menuInformation.locations!.isEmpty {
        //if self.menuInformation.locations != nil {
        //    self.menuOrder.locations = [String]()
        //    for i in 0...self.menuInformation.locations!.count - 1 {
        //        self.menuOrder.locations!.append(self.menuInformation.locations![i])
        //    }
        //}
        
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
        
        self.menuOrder.storeInfo = self.menuInformation.storeInfo
        if self.menuInformation.menuItems != nil {
            for i in 0...self.menuInformation.menuItems!.count - 1 {
                if self.menuInformation.menuItems![i].quantityLimitation != nil {
                    if self.menuOrder.limitedMenuItems == nil {
                        self.menuOrder.limitedMenuItems = [MenuItem]()
                        self.menuOrder.limitedMenuItems!.append(self.menuInformation.menuItems![i])
                    } else {
                        self.menuOrder.limitedMenuItems!.append(self.menuInformation.menuItems![i])
                    }
                }
            }
        }
        
        if self.isAttended {
            var myContent: MenuOrderMemberContent = MenuOrderMemberContent()
            var myItem: MenuOrderContentItem = MenuOrderContentItem()

            myContent.memberID = self.menuInformation.userID
            myContent.orderOwnerID = self.menuOrder.orderOwnerID
            myContent.memberTokenID = getMyTokenID()
            myItem.orderNumber = self.menuOrder.orderNumber
            myItem.itemOwnerID = self.menuInformation.userID
            //myItem.itemOwnerName = self.menuInformation.userName
            myItem.itemOwnerName = getMyUserName()
            myItem.replyStatus = MENU_ORDER_REPLY_STATUS_WAIT
            myItem.createTime = self.menuOrder.createTime
            myContent.orderContent = myItem
            myItem.ostype = "iOS"

            self.menuOrder.contentItems.append(myContent)
        }
        
        let contentGroup = DispatchGroup()
                
        for i in 0...self.memberList.count - 1 {
            if self.memberList[i].isSelected {
                var memberContent: MenuOrderMemberContent = MenuOrderMemberContent()
                var contentItem: MenuOrderContentItem = MenuOrderContentItem()
                
                let databaseRef = Database.database().reference()
                //let pathString = "USER_PROFILE/\(self.memberList[i].memberID)/tokenID"
                let pathString = "USER_PROFILE/\(self.memberList[i].memberID)"
                contentGroup.enter()
                databaseRef.child(pathString).observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists() {
                        var userProfile: UserProfile = UserProfile()
                        let profileData = snapshot.value
                        let jsonData = try? JSONSerialization.data(withJSONObject: profileData as Any, options: [])
                        //let jsonString = String(data: jsonData!, encoding: .utf8)!
                        //print("jsonString = \(jsonString)")

                        let decoder: JSONDecoder = JSONDecoder()
                        do {
                            userProfile = try decoder.decode(UserProfile.self, from: jsonData!)
                            //print("menuData decoded successful !!")
                            //print("menuData = \(menuData)")
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
        
        contentGroup.notify(queue: .main) {
            print("self.menuOrder.contentItems = \(self.menuOrder.contentItems)")
            //self.app.saveContext()

            self.uploadMenuOrder()
            self.sendGroupOrderNotification()
            if self.isAttended {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let join_vc = storyboard.instantiateViewController(withIdentifier: "JOIN_ORDER_VC") as? JoinGroupOrderTableViewController else{
                    assertionFailure("[AssertionFailure] StoryBoard: JOIN_ORDER_VC can't find!! (GroupOrderViewController)")
                    return
                }

                join_vc.menuInformation = self.menuInformation
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
    
    func uploadMenuOrder() {
        let databaseRef = Database.database().reference()
        
        if Auth.auth().currentUser?.uid == nil {
            print("uploadMenuOrder Auth.auth().currentUser?.uid == nil")
            return
        }
        
        //let pathString = "USER_MENU_ORDER/\(self.menuInformation.userID)/\(self.menuOrder.orderNumber)"
        //print("pathString = \(pathString)")
        //print("menuOrder transformed object = \(self.menuOrder.toAnyObject())")

        let pathString = "USER_MENU_ORDER/\(Auth.auth().currentUser!.uid)/\(self.menuOrder.orderNumber)"
        databaseRef.child(pathString).setValue(self.menuOrder.toAnyObject()) { (error, reference) in
            if let error = error {
                print("uploadMenuOrder error = \(error.localizedDescription)")
                return
            } else {
                // Send notification to refresh HistoryList function
                print("GroupOrderViewController sends notification to refresh History List function")
                NotificationCenter.default.post(name: NSNotification.Name("RefreshHistory"), object: nil)
            }
        }
    }

    func sendGroupOrderNotification() {
        if !self.menuOrder.contentItems.isEmpty {
            let myTokenID = getMyTokenID()
            let dateNow = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = DATETIME_FORMATTER
            let dateTimeString = formatter.string(from: dateNow)
            
            for i in 0...self.menuOrder.contentItems.count - 1 {
                
                print("\(self.menuOrder.contentItems[i].orderContent.itemOwnerName)'s tokenID = \(self.menuOrder.contentItems[i].memberTokenID)")
                
                let tokenID = self.menuOrder.contentItems[i].memberTokenID
                
                var orderNotify: NotificationData = NotificationData()
                let title: String = "團購邀請"
                var body: String = ""
                body = "來自『 \(self.menuOrder.orderOwnerName)』 發起的團購邀請，請點擊通知以查看詳細資訊。"
                //if self.textViewMessage.text == nil || self.textViewMessage.text == "" {
                //    body = "來自 \(self.menuOrder.orderOwnerName) 發起的團購邀請，請點擊通知以查看詳細資訊。"
                //} else {
                //    body = "來自 \(self.menuOrder.orderOwnerName) 的團購邀請：\n" + textViewMessage.text!
                //}

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

                let sender = PushNotificationSender()

                if tokenID == myTokenID {
                    orderNotify.messageBody = "自己發起並參與的團購單"
                    orderNotify.isRead = "Y"
                    //insertNotification(notification: orderNotify)
                    sender.sendPushNotification(to: tokenID, title: title, body: orderNotify.messageBody, data: orderNotify, ostype: self.menuOrder.contentItems[i].orderContent.ostype)
                    continue
                }
                
                sender.sendPushNotification(to: tokenID, title: title, body: body, data: orderNotify, ostype: self.menuOrder.contentItems[i].orderContent.ostype)
            }
        }
    }

    @IBAction func sendGroupOrder(_ sender: UIButton) {
        let friendList = retrieveFriendList()
        print("\(friendList)")
        
        if self.memberList.isEmpty && !self.isAttended {
            print("Selected Group's member list is empty")
            presentSimpleAlertMessage(title: "錯誤訊息", message: "此團購訂單尚未指定任何參與者，請重新選取參與者")
            return
        }
        
        if labelDueDate.text == nil {
            presentSimpleAlertMessage(title: "錯誤訊息", message: "訂單截止時間為必填資訊，請重新指定截止時間。")
            return
        }

        self.buttonCreateOrder.isEnabled = false
        createMenuOrder()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.memberTableView {
            return 1
        }
        
        return 1
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowLocation" {
            if let controllerLocation = segue.destination as? MenuLocationTableViewController {
                controllerLocation.locationArray = self.menuOrder.locations
                controllerLocation.delegate = self
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.memberTableView {
            if self.memberList.isEmpty {
                return 0
            }
            
            return self.memberList.count
        }
        
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.memberTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectMemberCell", for: indexPath) as! SelectMemberCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none

            cell.setData(member_id: self.memberList[indexPath.row].memberID, member_name: self.memberList[indexPath.row].memberName, ini_status: self.memberList[indexPath.row].isSelected)
            cell.delegate = self
            cell.tag = indexPath.row
            
            return cell
        }
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.memberTableView {
            return 50
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if tableView == self.memberTableView {
            let header = view as! UITableViewHeaderFooterView
            header.backgroundView?.layer.backgroundColor = UIColor.clear.cgColor
            header.textLabel?.textAlignment = .center
            if !self.groupList.isEmpty {
                header.textLabel?.text = "\(self.groupList[self.selectedGroupIndex].groupName)  好友列表"
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == self.memberTableView {
            return 44
        }
        
        return super.tableView(tableView, heightForHeaderInSection: section)
    }

}

extension GroupOrderTableViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.groupList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupCell", for: indexPath) as! GroupCell
        cell.setData(group_image: self.groupList[indexPath.row].groupImage, group_name: self.groupList[indexPath.row].groupName, index: indexPath)
        //cell.setTitleColor(title_color: UIColor.black)
        cell.tag = indexPath.row
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Select group name = [\(self.groupList[indexPath.row].groupName)]")
        self.selectedGroupIndex = indexPath.row
        //List the members information in the group
        self.memberList.removeAll()
        self.memberList = retrieveMemberList(group_id: self.groupList[indexPath.row].groupID)
        if !self.memberList.isEmpty {
            for i in 0...self.memberList.count - 1 {
                self.memberList[i].isSelected = true
            }
        }
        self.memberTableView.reloadData()
    }
}


extension GroupOrderTableViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
}

extension GroupOrderTableViewController: SetMemberSelectedStatusDelegate {
    func setMemberSelectedStatus(cell: UITableViewCell, status: Bool, data_index: Int) {
        self.memberList[data_index].isSelected = status
    }
}

extension GroupOrderTableViewController: MenuLocationDelegate {
    func updateMenuLocation(locations: [String]?) {
        var locationCount: Int = 0

        self.menuOrder.locations = locations
        if self.menuOrder.locations != nil {
            locationCount = self.menuOrder.locations!.count
        }
        self.labelLocationCount.text = "\(locationCount) 項"
    }
}
