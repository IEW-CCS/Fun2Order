//
//  MyFriendTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/2/22.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
import Contacts
import Firebase

class MyFriendTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    var friendList: [Friend] = [Friend]()
    var myProfile: UserProfile = UserProfile()
    var authUserProfile: [UserProfile] = [UserProfile]()
    var newFriendList: [Friend] = [Friend]()
    var updatedFriend: Friend = Friend()
    var updatedFlag: String = ""

    lazy var myContactStore: CNContactStore = {
    let cn:CNContactStore = CNContactStore()
    return cn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let friendNib: UINib = UINib(nibName: "MemberCell", bundle: nil)
        self.tableView.register(friendNib, forCellReuseIdentifier: "MemberCell")

        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "正在更新好友列表")
        self.tableView.refreshControl = refreshControl
        refreshControl?.addTarget(self, action: #selector(pullToRefreshFriendList), for: .valueChanged)

        self.friendList = retrieveFriendList()
    }

    @objc func pullToRefreshFriendList() {
        refreshFriendList()
        //self.refreshControl?.endRefreshing()
    }

    func refreshFriendList() {
        self.friendList.removeAll()
        self.friendList = retrieveFriendList()
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }

    @IBAction func addFriend(_ sender: UIBarButtonItem) {
        let controller = UIAlertController(title: "選擇加入好友方式", message: nil, preferredStyle: .alert)
        
        let photoAction = UIAlertAction(title: "從相機或相簿中加入", style: .default) { (_) in
            print("Add friend from Camera or Photo Library")
            guard let scanController = self.storyboard?.instantiateViewController(withIdentifier: "SCAN_QRCODE_VC") as? ScanQRCodeViewController else {
                assertionFailure("[AssertionFailure] StoryBoard: SCAN_QRCODE_VC can't find!! (MyFriendTableViewController)")
                return
            }
            scanController.delegate = self
            self.navigationController?.show(scanController, sender: self)
        }
        
        photoAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        controller.addAction(photoAction)
        
        let contactAction = UIAlertAction(title: "從通訊錄中加入", style: .default) { (_) in
            print("Add friends from contacts")
            self.checkContactStoreAuthorization()
        }
        
        contactAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        controller.addAction(contactAction)
        
        let cancelAction = UIAlertAction(title: "取消", style: .default) { (_) in
           print("Cancel update")
        }
        
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        controller.addAction(cancelAction)
        
        present(controller, animated: true, completion: nil)
    }
    
    @objc func handleLongPressMemberCell(_ sender: UILongPressGestureRecognizer) {
        if(sender.state == .began) {
            print("Long pressed the member cell [\(sender.view!.tag)]")
            let controller = UIAlertController(title: "編輯好友動作", message: nil, preferredStyle: .actionSheet)
            
            let deleteAction = UIAlertAction(title: "刪除好友", style: .default) { (_) in
                print("Delete Firend[\(sender.view!.tag)] Information")
                let alertController = UIAlertController(title: "刪除好友資訊", message: "確定要刪除此好友資訊嗎？", preferredStyle: .alert)

                let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
                    print("Confirm to delete this friend")
                    deleteFriend(member_id: self.friendList[sender.view!.tag].memberID)
                    if Auth.auth().currentUser?.uid != nil {
                        self.updatedFriend.memberID = self.friendList[sender.view!.tag].memberID
                        self.updatedFriend.memberName = self.friendList[sender.view!.tag].memberName
                        self.updatedFriend.memberNickname = self.friendList[sender.view!.tag].memberNickname
                        self.updatedFlag = "D"
                        downloadFBUserProfile(user_id: Auth.auth().currentUser!.uid, completion: self.receiveMyProfile)
                    }
                    self.refreshFriendList()
                }
                
                alertController.addAction(okAction)
                let cancelDeleteAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                alertController.addAction(cancelDeleteAction)
                self.present(alertController, animated: true, completion: nil)
            }
            
            deleteAction.setValue(UIColor.red, forKey: "titleTextColor")
            controller.addAction(deleteAction)
            
            let cancelAction = UIAlertAction(title: "取消", style: .default) { (_) in
               print("Cancel update")
            }
            cancelAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
            controller.addAction(cancelAction)
            
            present(controller, animated: true, completion: nil)
        }
    }

    func checkContactStoreAuthorization() {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .notDetermined:
            print("Not Authorized")
            requestContactStoreAuthorization(self.myContactStore)
        
        case .authorized:
            print("Authorization granted")
            readContactsFromContactStore(self.myContactStore)
            
        case.denied, .restricted:
            print("No permission")
        
        default:
            break
        }
    }
    
    func requestContactStoreAuthorization(_ contactStore: CNContactStore) {
        contactStore.requestAccess(for: .contacts, completionHandler: { [weak self] (granted, error) in
            if granted {
                print("")
                self?.readContactsFromContactStore(contactStore)
            }
        })
    }
    
    func readContactsFromContactStore(_ contactStore:CNContactStore) {
        var phoneList: [String] = [String]()

        guard CNContactStore.authorizationStatus(for: .contacts) == .authorized else {
            return
        }
        
        let keys = [CNContactFamilyNameKey,CNContactGivenNameKey,CNContactPhoneNumbersKey]
        let fetch = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        do {
            try contactStore.enumerateContacts(with: fetch, usingBlock: { (contact, stop) in
                //姓名
                //let name = "\(contact.familyName)\(contact.givenName)"
                //print(name)
                //電話
                for labeledValue in contact.phoneNumbers {
                    var phoneNumber = (labeledValue.value as CNPhoneNumber).stringValue
                    phoneNumber = phoneNumber.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
                    phoneNumber = phoneNumber.replacingOccurrences(of: "-", with: "", options: .literal, range: nil)
                    phoneNumber = phoneNumber.replacingOccurrences(of: "(", with: "", options: .literal, range: nil)
                    phoneNumber = phoneNumber.replacingOccurrences(of: ")", with: "", options: .literal, range: nil)
                    if self.verifyPhoneNumber(phone_number: phoneNumber) {
                        //print(phoneNumber)
                        phoneList.append(self.convertPhoneNumber(phone_number: phoneNumber))
                    }
                }
                
            })
        } catch let error as NSError {
            print(error)
        }
        
        print("phoneList = \(phoneList)")
        self.queryAuthenticatedUserProfile(phone_list: phoneList)
    }
    
    func verifyPhoneNumber(phone_number: String) -> Bool {
        var verifyResult: Bool = false
        
        if phone_number.lengthOfBytes(using: .utf8) < 10 {
            return false
        }
        
        if String(phone_number.prefix(2)) == "09" {
            verifyResult = true
        }
        
        if String(phone_number.prefix(4)) == "+886" {
            verifyResult = true
        }

        return verifyResult
    }
    
    func convertPhoneNumber(phone_number: String) -> String {
        var result: String = ""
        
        if String(phone_number.prefix(2)) == "09" {
            let index = phone_number.index(phone_number.startIndex, offsetBy: 1)
            let subString = String(phone_number.suffix(from: index))
            //print("convertPhoneNumber subString = \(subString)")
            result = "+886" + subString
        }
        
        if String(phone_number.prefix(4)) == "+886" {
            result = phone_number
        }
        
        print("convertPhoneNumber origin = \(phone_number)")
        print("convertPhoneNumber result = \(result)")
        return result
    }
    
    func queryAuthenticatedUserProfile(phone_list: [String]) {
        if phone_list.isEmpty {
            return
        }

        let dispatchGroup = DispatchGroup()
        let databaseRef = Database.database().reference()
        let pathString = "USER_PROFILE"
        
        self.authUserProfile.removeAll()
        for i in 0...phone_list.count - 1 {
            dispatchGroup.enter()
            let query = (databaseRef.child(pathString).queryOrdered(byChild: "phoneNumber")).queryEqual(toValue: phone_list[i])
            query.observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    var userData: UserProfile = UserProfile()

                    guard let userProfile = snapshot.value as? [String: Any] else {
                        dispatchGroup.leave()
                        return
                    }
                    
                    let tmpData = userProfile.first?.value
                    let jsonData = try? JSONSerialization.data(withJSONObject: tmpData as Any, options: [])
                    let decoder: JSONDecoder = JSONDecoder()
                    do {
                        userData = try decoder.decode(UserProfile.self, from: jsonData!)
                        self.authUserProfile.append(userData)
                        dispatchGroup.leave()
                    } catch {
                        print("downloadFBUserProfile userData jsonData decode failed: \(error.localizedDescription)")
                        dispatchGroup.leave()
                    }
                } else {
                    print("queryAuthenticatedUserProfile snapshot doesn't exist!")
                    dispatchGroup.leave()
                    //return
                }
            }) { (error) in
                print(error.localizedDescription)
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            print("Query complete!")
            if self.authUserProfile.isEmpty {
                presentSimpleAlertMessage(title: "訊息", message: "通訊簿中的聯絡人皆不是揪Fun已認證的使用者")
                return
            }
            
            self.filterFriendsFromContacts()
        }
    }
    
    func filterFriendsFromContacts() {
        var filteredFriendsList: [Friend] = [Friend]()
        var contactList: [UserContactInfo] = [UserContactInfo]()
        let allFriendsList = retrieveFriendList()
        
        if Auth.auth().currentUser?.uid == nil {
            presentSimpleAlertMessage(title: "錯誤訊息", message: "使用者ID不存在")
            return
        }
        
        let myID: String = Auth.auth().currentUser!.uid
        
        if !allFriendsList.isEmpty {
            if !self.authUserProfile.isEmpty {
                for i in 0...self.authUserProfile.count - 1 {
                    if self.authUserProfile[i].userID == myID {
                        continue
                    }
                    
                    if !allFriendsList.contains(where: { $0.memberID == self.authUserProfile[i].userID }) {
                        var friend: Friend = Friend()
                        var contact: UserContactInfo = UserContactInfo()

                        friend.memberID = self.authUserProfile[i].userID
                        friend.memberName = self.authUserProfile[i].userName
                        
                        contact.userID = self.authUserProfile[i].userID
                        contact.userName = self.authUserProfile[i].userName
                        contact.userImageURL = self.authUserProfile[i].photoURL
                        //contact.userContactName = ""
                        //contact.phoneNumber = ""
                        
                        filteredFriendsList.append(friend)
                        contactList.append(contact)
                    }
                }
            }
        } else {
            if !self.authUserProfile.isEmpty {
                for i in 0...self.authUserProfile.count - 1 {
                    if self.authUserProfile[i].userID == myID {
                        continue
                    }

                    var friend: Friend = Friend()
                    var contact: UserContactInfo = UserContactInfo()

                    friend.memberID = self.authUserProfile[i].userID
                    friend.memberName = self.authUserProfile[i].userName

                    contact.userID = self.authUserProfile[i].userID
                    contact.userName = self.authUserProfile[i].userName
                    contact.userImageURL = self.authUserProfile[i].photoURL
                    //contact.userContactName = ""
                    //contact.phoneNumber = ""

                    filteredFriendsList.append(friend)
                    contactList.append(contact)
                }
            }
        }
        
        if filteredFriendsList.isEmpty {
            presentSimpleAlertMessage(title: "訊息", message: "通訊簿中的聯絡人皆不是揪Fun已認證的使用者或是都已成為您的好友")
            return
        }
        
        guard let controllerGroupFriendList = self.storyboard?.instantiateViewController(withIdentifier: "GROUP_FRIEND_VC") as? GroupFriendListTableViewController else {
            assertionFailure("[AssertionFailure] StoryBoard: GROUP_FRIEND_VC can't find!! (GroupFriendListTableViewController)")
            return
        }

        controllerGroupFriendList.friendList = filteredFriendsList
        controllerGroupFriendList.contactList = contactList
        controllerGroupFriendList.delegate = self
        self.navigationController?.show(controllerGroupFriendList, sender: self)
    }

    func receiveMyProfileForContacts(user_profile: UserProfile?) {
        if user_profile == nil {
            presentSimpleAlertMessage(title: "錯誤訊息", message: "擷取使用者資料時發生錯誤")
            return
        }
        
        self.myProfile = user_profile!
        addAuthenticatedFriends(friend_list: self.newFriendList)
    }
    
    func addAuthenticatedFriends(friend_list: [Friend]) {
        var tokenIDs: [String] = [String]()
        
        for i in 0...friend_list.count - 1 {
            if Auth.auth().currentUser!.uid == friend_list[i].memberID {
                presentSimpleAlertMessage(title: "錯誤訊息", message: "不能將自己加入好友中，請重新選擇")
                continue
            }
            
            guard let index = self.authUserProfile.firstIndex(where: { $0.userID == friend_list[i].memberID }) else {
                print("Query self.authUserProfile index failed")
                continue
            }
            
            var newFriend: Friend = Friend()
            newFriend.memberID = friend_list[i].memberID
            newFriend.memberName = friend_list[i].memberName
            insertFriend(friend_info: newFriend)

            if self.myProfile.friendList == nil {
                self.myProfile.friendList = [String]()
                self.myProfile.friendList!.append(friend_list[i].memberID)
            } else {
                self.myProfile.friendList!.append(friend_list[i].memberID)
            }
            tokenIDs.append(self.authUserProfile[index].tokenID)
        }
        
        uploadFBUserProfile(user_profile: self.myProfile)
        //send multicast message for remote notification
        sendMulticastNotification(tokens: tokenIDs)
        refreshFriendList()
    }
    
    func sendMulticastNotification(tokens: [String]) {
        if tokens.isEmpty {
            print("Tokens is empty, just return")
            return
        }
        
        var notifyData: NotificationData = NotificationData()
        let myName: String = getMyUserName()
        var tokenList: [String] = [String]()

        let title: String = "好友邀請"
        let body: String = "『\(myName)』已將您加入好友，請問您願意將『\(myName)』也加入成為您的好友嗎？"

        notifyData.messageTitle = title
        notifyData.messageBody = body
        notifyData.notificationType = NOTIFICATION_TYPE_NEW_FRIEND
        //notifyData.receiveTime = dateTimeString
        notifyData.orderOwnerID = Auth.auth().currentUser!.uid
        notifyData.orderOwnerName = myName
        //notifyData.menuNumber = self.menuOrder.menuNumber
        //notifyData.orderNumber = self.menuOrder.orderNumber
        //notifyData.dueTime = self.menuOrder.dueTime
        //notifyData.brandName = self.menuOrder.brandName
        //notifyData.attendedMemberCount = self.menuOrder.contentItems.count
        notifyData.messageDetail = self.myProfile.userID
        notifyData.isRead = "N"

        // send to iOS type device
        for i in 0...tokens.count - 1 {
            guard let index = self.authUserProfile.firstIndex(where: { $0.tokenID == tokens[i] }) else {
                print("Query self.authUserProfile index failed")
                continue
            }

            if self.authUserProfile[index].ostype != nil {
                if self.authUserProfile[index].ostype == OS_TYPE_IOS {
                    tokenList.append(tokens[i])
                } else {
                    tokenList.append(tokens[i])
                }
            }
        }
        
        if !tokenList.isEmpty {
            let sender = PushNotificationSender()
            sender.sendMulticastMessage(to: tokenList, notification_key: "", title: title, body: body, data: notifyData, ostype: OS_TYPE_IOS)
        }

        
        tokenList.removeAll()
        // send to Android type device
        for i in 0...tokens.count - 1 {
            guard let index = self.authUserProfile.firstIndex(where: { $0.tokenID == tokens[i] }) else {
                print("Query self.authUserProfile index failed")
                continue
            }

            if self.authUserProfile[index].ostype != nil {
                if self.authUserProfile[index].ostype == OS_TYPE_ANDROID {
                    tokenList.append(tokens[i])
                }
            }
        }
        
        if !tokenList.isEmpty {
            let sender = PushNotificationSender()
            sender.sendMulticastMessage(to: tokenList, notification_key: "", title: title, body: body, data: notifyData, ostype: OS_TYPE_ANDROID)
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.friendList.isEmpty {
            return 0
        }
        
        return self.friendList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberCell", for: indexPath) as! MemberCell
        
        cell.setData(member_id: self.friendList[indexPath.row].memberID, member_name: self.friendList[indexPath.row].memberName)
        
        cell.tag = indexPath.row
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPressMemberCell(_:)))
        longPressGesture.delegate = self
        cell.addGestureRecognizer(longPressGesture)

        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

}

extension MyFriendTableViewController: ScanQRCodeDelegate {
    func getQRCodeMemberInfo(sender: ScanQRCodeViewController, member_id: String, member_name: String) {
        var isUserDuplicate: Bool = false
        var newFriend: Friend = Friend()
        newFriend.memberID = member_id
        newFriend.memberName = member_name
        
        if Auth.auth().currentUser?.uid != nil {
            if Auth.auth().currentUser!.uid == member_id {
                presentSimpleAlertMessage(title: "錯誤訊息", message: "不能將自己加入好友中，請重新掃描")
                return
            }
        }
        
        if !self.friendList.isEmpty {
            for i in 0...self.friendList.count - 1 {
                if self.friendList[i].memberID == member_id {
                    isUserDuplicate = true
                    break
                }
            }
        }

        if isUserDuplicate {
            print("User ID is duplicate!")
            presentSimpleAlertMessage(title: "警告訊息", message: "[\(member_name)]已存在於好友列表中")
            return
        } else {
            insertFriend(friend_info: newFriend)
            if Auth.auth().currentUser?.uid != nil {
                self.updatedFriend = newFriend
                self.updatedFlag = "I"
                downloadFBUserProfile(user_id: Auth.auth().currentUser!.uid, completion: receiveMyProfile)
                downloadFBUserProfile(user_id: newFriend.memberID, completion: receiveNewFriendProfile)
            }
            refreshFriendList()
        }
    }
    
    func receiveMyProfile(user_profile: UserProfile?) {
        if user_profile == nil {
            presentSimpleAlertMessage(title: "錯誤訊息", message: "存取使用者資料發生錯誤")
            return
        }

        switch self.updatedFlag {
        case "I":
            var profile = user_profile!
            var friendList = [String]()
            if profile.friendList == nil {
                friendList.append(self.updatedFriend.memberID)
                profile.friendList = friendList
            } else {
                profile.friendList!.append(self.updatedFriend.memberID)
            }
            uploadFBUserProfile(user_profile: profile)
            break
            
        case "D":
            var profile = user_profile!
            if profile.friendList != nil {
                profile.friendList!.removeAll(where: { $0 == self.updatedFriend.memberID })
            }
            uploadFBUserProfile(user_profile: profile)
            break
            
        default:
            break
        }
    }

    func receiveNewFriendProfile(user_profile: UserProfile?) {
        if user_profile == nil {
            presentSimpleAlertMessage(title: "錯誤訊息", message: "存取使用者資料發生錯誤")
            return
        }

        var notifyData: NotificationData = NotificationData()
        let sender = PushNotificationSender()
        let myName: String = getMyUserName()

        let title: String = "好友邀請"
        let body: String = "『\(myName)』已將您加入好友，請問您願意將『\(myName)』也加入成為您的好友嗎？"

        notifyData.messageTitle = title
        notifyData.messageBody = body
        notifyData.notificationType = NOTIFICATION_TYPE_NEW_FRIEND
        //notifyData.receiveTime = dateTimeString
        notifyData.orderOwnerID = Auth.auth().currentUser!.uid
        notifyData.orderOwnerName = myName
        //notifyData.menuNumber = self.menuOrder.menuNumber
        //notifyData.orderNumber = self.menuOrder.orderNumber
        //notifyData.dueTime = self.menuOrder.dueTime
        //notifyData.brandName = self.menuOrder.brandName
        //notifyData.attendedMemberCount = self.menuOrder.contentItems.count
        notifyData.messageDetail = user_profile!.userID
        notifyData.isRead = "N"

        //sender.sendNewFriendActionPushNotification(to: user_profile.tokenID, title: title, body: body, data: notifyData)
        sender.sendPushNotification(to: user_profile!.tokenID, title: title, body: body, data: notifyData, ostype: user_profile!.ostype)

    }
}

extension MyFriendTableViewController: GroupFriendListDelegate {
    func getSelectedFriendList(sender: GroupFriendListTableViewController, friend_list: [Friend]) {
        print("MyFriendTableViewController receive selected friend list")
        print("Friend List = \(friend_list)")
        if !friend_list.isEmpty {
            self.newFriendList = friend_list
            //self.addAuthenticatedFriends(friend_list: friend_list)
            if Auth.auth().currentUser?.uid != nil {
                downloadFBUserProfile(user_id: Auth.auth().currentUser!.uid, completion: receiveMyProfileForContacts)
            }
        }
    }
}
