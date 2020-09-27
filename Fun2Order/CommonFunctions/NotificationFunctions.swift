//
//  NotificationFunctions.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/1/31.
//  Copyright © 2020 JStudio. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Firebase

func getNotifications(func_id: String, completion: @escaping () -> Void) {
    var nCount: Int = 0
    let notifications = UNUserNotificationCenter.current()
    print("[\(func_id)] calls getNotifications")
    //let deliveredNotifications = notifications.getDeliveredNotifications
    
    notifications.getDeliveredNotifications { (delivered_notifications) in
        for delivered_notification in delivered_notifications {
            //print("getNotifications -> setupNotification")
            print("&&&&&&&&&&&&&  getNotifications setupNotification")
            setupNotification(notity: delivered_notification)
            nCount = nCount + 1
        }
        print("getNotifications -> Get [\(nCount)] notifications from Notification Center")
        notifications.removeAllDeliveredNotifications()
        DispatchQueue.main.async {
            setNotificationBadgeNumber()
        }
        completion()
    }
}

func getLaunchNotification(user_infos: [String: Any]) {
    var notificationData: NotificationData = NotificationData()

    guard let tmpMessageTtile = user_infos["messageTitle"] as? String,
        let tmpMessageBody = user_infos["messageBody"] as? String,
        let tmpMessageID = user_infos["gcm.message_id"] as? String,
        let tmpNotificationType = user_infos["notificationType"] as? String,
        let tmpReceiveTime = user_infos["receiveTime"] as? String,
        let tmpOrderOwnerID = user_infos["orderOwnerID"] as? String,
        let tmpOrderOwnerName = user_infos["orderOwnerName"] as? String,
        let tmpMenuNumber = user_infos["menuNumber"] as? String,
        let tmpOrderNumber = user_infos["orderNumber"] as? String,
        let tmpDueTime = user_infos["dueTime"] as? String,
        let tmpBrandName = user_infos["brandName"] as? String,
        let tmpAttendedMemberCount = user_infos["attendedMemberCount"] as? String,
        let tmpMessageDetail = user_infos["messageDetail"] as? String,
        let tmpIsRead = user_infos["isRead"] as? String
    else {
        presentSimpleAlertMessage(title: "資料錯誤", message: "收到的通知資料格式錯誤")
        return
    }
    
    let tmpShippingDate = user_infos["shippingDate"] as? String
    let tmpShippingLocation = user_infos["shippingLocation"] as? String

    if !verifyNotificationType(type: tmpNotificationType) {
        presentSimpleAlertMessage(title: "資料錯誤", message: "收到的通知類別錯誤，無法處理")
        return
    }

    switch tmpNotificationType {
        case NOTIFICATION_TYPE_NEW_FRIEND:
            addNewFriendRequestNotification(message: tmpMessageBody, friend_id: tmpOrderOwnerID, friend_name: tmpOrderOwnerName)
            return
                    
        case NOTIFICATION_TYPE_SHARE_MENU:
            shareMenuInformationNotification(message: tmpMessageBody, user_id: tmpOrderOwnerID, menu_number: tmpMenuNumber)
            return

        case NOTIFICATION_TYPE_CHANGE_DUETIME:
            changeNewDueTimeNotification(message: tmpMessageDetail, owner_id: tmpOrderOwnerID, order_number: tmpOrderNumber, new_due_time: tmpDueTime)
            return

        default:
            break
    }

    notificationData.messageTitle = tmpMessageTtile
    notificationData.messageBody = tmpMessageBody
    notificationData.messageID = tmpMessageID
    notificationData.notificationType = tmpNotificationType
    notificationData.receiveTime = tmpReceiveTime
    notificationData.orderOwnerID = tmpOrderOwnerID
    notificationData.orderOwnerName = tmpOrderOwnerName
    notificationData.menuNumber = tmpMenuNumber
    notificationData.orderNumber = tmpOrderNumber
    notificationData.dueTime = tmpDueTime
    notificationData.brandName = tmpBrandName
    notificationData.attendedMemberCount = Int(tmpAttendedMemberCount) ?? 0
    notificationData.messageDetail = tmpMessageDetail
    notificationData.isRead = tmpIsRead
    notificationData.shippingDate = tmpShippingDate
    notificationData.shippingLocation = tmpShippingLocation


    print("&&&&&&&&&&&&&  getLaunchNotification insertNotification")
    insertNotification(notification: notificationData)
    DispatchQueue.main.async {
        setNotificationBadgeNumber()
    }
}

func getTappedNotification(notification: UNNotification) {
    print("&&&&&&&&&&&&&  getTappedNotification setupNotification")
    setupNotification(notity: notification)
    UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [notification.request.identifier])
    //UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notification.request.identifier])
    DispatchQueue.main.async {
        setNotificationBadgeNumber()
    }
    //UNUserNotificationCenter.current().removeAllDeliveredNotifications()
}

func setupNotification(notity: UNNotification) {
    //print("Delivered notification userInfo = \(notity.request.content.userInfo)")

    let semaphore = DispatchSemaphore(value: 3)

    var notificationData: NotificationData = NotificationData()

    guard let tmpMessageID = notity.request.content.userInfo["gcm.message_id"] as? String,
        let tmpNotificationType = notity.request.content.userInfo["notificationType"] as? String,
        let tmpReceiveTime = notity.request.content.userInfo["receiveTime"] as? String,
        let tmpOrderOwnerID = notity.request.content.userInfo["orderOwnerID"] as? String,
        let tmpOrderOwnerName = notity.request.content.userInfo["orderOwnerName"] as? String,
        let tmpMenuNumber = notity.request.content.userInfo["menuNumber"] as? String,
        let tmpOrderNumber = notity.request.content.userInfo["orderNumber"] as? String,
        let tmpDueTime = notity.request.content.userInfo["dueTime"] as? String,
        let tmpBrandName = notity.request.content.userInfo["brandName"] as? String,
        let tmpAttendedMemberCount = notity.request.content.userInfo["attendedMemberCount"] as? String,
        let tmpMessageDetail = notity.request.content.userInfo["messageDetail"] as? String,
        let tmpIsRead = notity.request.content.userInfo["isRead"] as? String
    else {
        presentSimpleAlertMessage(title: "資料錯誤", message: "收到的通知資料格式錯誤")
        return
    }

    let tmpShippingDate = notity.request.content.userInfo["shippingDate"] as? String
    let tmpShippingLocation = notity.request.content.userInfo["shippingLocation"] as? String

    if !verifyNotificationType(type: tmpNotificationType) {
        presentSimpleAlertMessage(title: "資料錯誤", message: "收到的通知類別錯誤，無法處理")
        return
    }

    switch tmpNotificationType {
        case NOTIFICATION_TYPE_NEW_FRIEND:
            addNewFriendRequestNotification(message: notity.request.content.body, friend_id: tmpOrderOwnerID, friend_name: tmpOrderOwnerName)
            return
                    
        case NOTIFICATION_TYPE_SHARE_MENU:
            shareMenuInformationNotification(message: notity.request.content.body, user_id: tmpOrderOwnerID, menu_number: tmpMenuNumber)
            return

        case NOTIFICATION_TYPE_CHANGE_DUETIME:
            changeNewDueTimeNotification(message: tmpMessageDetail, owner_id: tmpOrderOwnerID, order_number: tmpOrderNumber, new_due_time: tmpDueTime)
            return

        default:
            break
    }

    notificationData.messageTitle = notity.request.content.title
    notificationData.messageBody = notity.request.content.body
    notificationData.messageID = tmpMessageID
    notificationData.notificationType = tmpNotificationType
    notificationData.receiveTime = tmpReceiveTime
    notificationData.orderOwnerID = tmpOrderOwnerID
    notificationData.orderOwnerName = tmpOrderOwnerName
    notificationData.menuNumber = tmpMenuNumber
    notificationData.orderNumber = tmpOrderNumber
    notificationData.dueTime = tmpDueTime
    notificationData.brandName = tmpBrandName
    notificationData.attendedMemberCount = Int(tmpAttendedMemberCount) ?? 0
    notificationData.messageDetail = tmpMessageDetail
    notificationData.isRead = tmpIsRead
    notificationData.shippingDate = tmpShippingDate
    notificationData.shippingLocation = tmpShippingLocation

    //notificationData.isRead = notity.request.content.userInfo["isRead"] as! Bool
    let result = semaphore.wait(timeout: DispatchTime.distantFuture)
    print(result)
    insertNotification(notification: notificationData)
    semaphore.signal()
    //notifications.removeAllDeliveredNotifications()
    DispatchQueue.main.async {
        setNotificationBadgeNumber()
    }
}

func setNotificationBadgeNumber() {
    let badgeCount = retrieveNotificationBadgeNumber()
    
    UIApplication.shared.applicationIconBadgeNumber = badgeCount
    print("setNotificationBadgeNumber badgeCount = \(badgeCount)")
    setTabBarBadgeNumber(badge: badgeCount)
}

func setTabBarBadgeNumber(badge: Int) {
    let app = UIApplication.shared.delegate as! AppDelegate
    
    if let tabItems = app.myTabBar?.items {
        let tabItem = tabItems[2] //Notification tab bar item
        if badge == 0 {
            tabItem.badgeValue = nil
        } else {
            tabItem.badgeValue = String(badge)
        }
    }
}

func addNewFriendRequestNotification(message: String, friend_id: String, friend_name: String) {
    print("Handle addNewFriendRequestNotification!!")
    var alertWindow: UIWindow!

    let controller = UIAlertController(title: "好友邀請", message: message, preferredStyle: .alert)
    controller.view.tintColor = CUSTOM_COLOR_EMERALD_GREEN

    let addAction = UIAlertAction(title: "加入好友", style: .default) { (_) in
        print("Click to add new friend: [\(friend_id)]")

        var isUserDuplicate: Bool = false
        var newFriend: Friend = Friend()
        newFriend.memberID = friend_id
        newFriend.memberName = friend_name
        let friendList = retrieveFriendList()
        if !friendList.isEmpty {
            for i in 0...friendList.count - 1 {
                if friendList[i].memberID == friend_id {
                    isUserDuplicate = true
                    break
                }
            }
        }
 
        if isUserDuplicate {
            print("User ID is duplicate!")
            presentSimpleAlertMessage(title: "警告訊息", message: "[\(friend_name)]已存在於好友列表中")
            return
        } else {
            insertFriend(friend_info: newFriend)
            if Auth.auth().currentUser?.uid != nil {
                let app = UIApplication.shared.delegate as! AppDelegate
                app.newFriendID = friend_id
                downloadFBUserProfile(user_id: Auth.auth().currentUser!.uid, completion: receiveMyProfileToUpdateFriendList)
            }
        }
        alertWindow.isHidden = true
    }
    
    addAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
    controller.addAction(addAction)

    let cancelAction = UIAlertAction(title: "暫不加入", style: .default) { (_) in
        print("Click to cancel new friend: [\(friend_id)]")
        alertWindow.isHidden = true
    }
    
    cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
    controller.addAction(cancelAction)

    alertWindow = presentAlert(controller)
}

func shareMenuInformationNotification(message: String, user_id: String, menu_number: String) {
    print("Handle shareMenuInformationNotification!!")
    var alertWindow: UIWindow!

    let controller = UIAlertController(title: "菜單分享", message: message, preferredStyle: .alert)
    controller.view.tintColor = CUSTOM_COLOR_EMERALD_GREEN

    let addAction = UIAlertAction(title: "接受", style: .default) { (_) in
        print("Click to accept shared menu information [\(menu_number)] from [\(user_id)]")
        var inputAlert: UIWindow!
        downloadFBMenuInformation(user_id: user_id, menu_number: menu_number, completion: { (menu_info) in
            
            var menu = menu_info
            if menu == nil {
                presentSimpleAlertMessage(title: "錯誤訊息", message: "存取菜單資訊錯誤")
                return
            }
            //presentSimpleAlertMessage(title: "菜單分享", message: "Menu Brand = [\(menu_info.brandName)]\nMenu Category = [\(menu_info.brandCategory)]")
            let controller2 = UIAlertController(title: "請修改菜單品牌名稱及分類", message: nil, preferredStyle: .alert)
            controller2.addTextField { (textField) in
                textField.placeholder = "品牌名稱"
                textField.text = menu!.brandName
            }

            controller2.addTextField { (textField) in
                textField.placeholder = "菜單分類"
                textField.text = menu!.brandCategory
            }

            let cancelAction = UIAlertAction(title: "取消", style: .default) { (_) in
                print("Cancel to update brand name & brand category!")
                inputAlert.isHidden = true
            }
            
            cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
            controller2.addAction(cancelAction)
            
            let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
                let name_string = controller2.textFields?[0].text
                if name_string == nil || name_string!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                    presentSimpleAlertMessage(title: "錯誤訊息", message: "輸入的品牌名稱不能為空白，請重新輸入")
                    return
                }

                let category_string = controller2.textFields?[1].text!.trimmingCharacters(in: .whitespacesAndNewlines)
                
                menu!.brandName = name_string!
                menu!.brandCategory = category_string!
                if menu!.multiMenuImageURL != nil {
                    downloadFBMultiMenuImages(images_url: menu!.multiMenuImageURL!, completion: { (images) in
                        uploadFBShareMenuInformation(menu_info: menu!, menu_images: images)
                    })
                }
                inputAlert.isHidden = true
            }
            okAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
            controller2.addAction(okAction)
            
            inputAlert = presentAlert(controller2)
        })
        alertWindow.isHidden = true
    }
    
    addAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
    controller.addAction(addAction)

    let cancelAction = UIAlertAction(title: "不接受", style: .default) { (_) in
        print("Click to reject shared menu information [\(menu_number)] from [\(user_id)]")
        alertWindow.isHidden = true
    }
    
    cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
    controller.addAction(cancelAction)
        
    alertWindow = presentAlert(controller)

}

func changeNewDueTimeNotification(message: String, owner_id: String, order_number: String, new_due_time: String) {
    //presentSimpleAlertMessage(title: "Temp", message: "Receive Change Due Time Notification")
    if Auth.auth().currentUser?.uid == nil {
        print("changeNewDueTimeNotification currentUser?.uid is nil")
        return
    }
    
    if owner_id == Auth.auth().currentUser!.uid {
        updateNotificationNewDueTime(order_number: order_number, due_time: new_due_time)
        return
    }
    
    var alertWindow: UIWindow!

    let controller = UIAlertController(title: "更新訂單截止時間", message: message, preferredStyle: .alert)
    controller.view.tintColor = CUSTOM_COLOR_EMERALD_GREEN

    let addAction = UIAlertAction(title: "確定", style: .default) { (_) in
        updateNotificationNewDueTime(order_number: order_number, due_time: new_due_time)
        alertWindow.isHidden = true
    }
    
    addAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
    controller.addAction(addAction)

    alertWindow = presentAlert(controller)

}

func receiveMyProfileToUpdateFriendList(user_profile: UserProfile?) {
    if user_profile == nil {
        presentSimpleAlertMessage(title: "錯誤訊息", message: "存取好友資訊錯誤")
        return
    }
    
    let app = UIApplication.shared.delegate as! AppDelegate
    let updatedFriendID = app.newFriendID
    var profile = user_profile!
    var friendList = [String]()
    if profile.friendList == nil {
        friendList.append(updatedFriendID)
        profile.friendList = friendList
    } else {
        profile.friendList!.append(updatedFriendID)
    }
    uploadFBUserProfile(user_profile: profile)
}

func verifyNotificationType(type: String) -> Bool {
    switch type {
        case NOTIFICATION_TYPE_MESSAGE_DUETIME:
            return true
            
        case NOTIFICATION_TYPE_MESSAGE_INFORMATION:
            return true
            
        case NOTIFICATION_TYPE_ACTION_JOIN_ORDER:
            return true
            
        case NOTIFICATION_TYPE_NEW_FRIEND:
            return true
            
        case NOTIFICATION_TYPE_SHARE_MENU:
            return true
        
        case NOTIFICATION_TYPE_CHANGE_DUETIME:
            return true
        
        case NOTIFICATION_TYPE_SHIPPING_NOTICE:
            return true
        
        //case NOTIFICATION_TYPE_SHARE_GROUP_FRIEND:
        //    return true
        
        default:
            return false
    }
}

func verifyStoreState(menu_order: MenuOrder) {
    downloadFBStoreInformation(brand_name: menu_order.brandName, store_name: menu_order.storeInfo!.storeName!, completion: {storeData in
        if storeData == nil {
            presentSimpleAlertMessage(title: "錯誤訊息", message: "存取店家資料時發生錯誤")
            return
        }
        
        var processTime: Int = 0
        if storeData!.storeState != nil {
            if storeData!.storeState == STORE_STATE_NORMAL {
                if storeData!.normalProcessTime != nil {
                    processTime = storeData!.normalProcessTime!
                }
            } else if storeData!.storeState == STORE_STATE_BUSY {
                if storeData!.busyProcessTime != nil {
                    processTime = storeData!.busyProcessTime!
                }
            }
        }
        
        var menuOrder: MenuOrder = MenuOrder()
        menuOrder = menu_order
        if processTime == 0 {
            sendOrderToStoreNotification(menu_order: menuOrder)
        } else {
            let timeFormatter = DateFormatter()
            var dateComponent = DateComponents()
            dateComponent.minute = processTime
            let newDate = Calendar.current.date(byAdding: dateComponent, to: Date())
            timeFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            let newTimeString = timeFormatter.string(from: newDate!)
            if newTimeString > menu_order.deliveryInfo!.deliveryTime {
                if storeData!.storeState == STORE_STATE_NORMAL {
                    presentSimpleAlertMessage(title: "提示訊息", message: "因製作餐點需時，因此取餐時間將更新為：\(newTimeString)")
                    menuOrder.deliveryInfo!.deliveryTime = newTimeString
                } else if storeData!.storeState == STORE_STATE_BUSY {
                    presentSimpleAlertMessage(title: "提示訊息", message: "因目前店家忙碌中，因此取餐時間將更新為：\(newTimeString)")
                    menuOrder.deliveryInfo!.deliveryTime = newTimeString
                }
            }
            sendOrderToStoreNotification(menu_order: menuOrder)
        }
    })
}

func sendOrderToStoreNotification(menu_order: MenuOrder) {
    var newOrder: MenuOrder = MenuOrder()
    
    newOrder = menu_order
    newOrder.orderStatus = ORDER_STATUS_NEW
    
    if newOrder.storeInfo == nil {
        presentSimpleAlertMessage(title: "錯誤訊息", message: "店家訊息不存在於訂單資料中，請重新產生訂單")
        return
    }
    
    if newOrder.storeInfo!.storeName == nil || newOrder.storeInfo!.storeName!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
        presentSimpleAlertMessage(title: "錯誤訊息", message: "店家名稱未指定於訂單資料中，請重新產生訂單")
        return
    }

    if newOrder.brandName.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
        presentSimpleAlertMessage(title: "錯誤訊息", message: "訂單資料中之品牌名稱為空白，請重新產生訂單")
        return
    }
    
    var totalOrderQuantity: Int = 0
    var totalOrderPrice: Int = 0
    
    if !menu_order.contentItems.isEmpty {
        for item in menu_order.contentItems {
            totalOrderQuantity = totalOrderQuantity + item.orderContent.itemQuantity
            totalOrderPrice = totalOrderPrice + item.orderContent.itemFinalPrice
        }
    }
    
    newOrder.orderTotalQuantity = totalOrderQuantity
    newOrder.orderTotalPrice = totalOrderPrice
    print("totalOrderQuantity = \(totalOrderQuantity)")
    print("totalOrderPrice = \(totalOrderPrice)")
    
    updateFBUserMenuOrderStatus(user_id: menu_order.orderOwnerID, order_number: menu_order.orderNumber, status_code: ORDER_STATUS_NEW)
    updateFBUserMenuOrderQuantityPrice(user_id: menu_order.orderOwnerID, order_number: menu_order.orderNumber, total_quantity: totalOrderQuantity, total_price: totalOrderPrice)
    updateFBUserMenuOrderDeliveryInfo(user_id: menu_order.orderOwnerID, order_number: menu_order.orderNumber, delivery_time: menu_order.deliveryInfo!.deliveryTime)
    
    uploadFBStoreNewOrder(menu_order: newOrder)

    downloadFBStoreUserControlList(brand_name: newOrder.brandName, completion: { userList in
        if userList == nil {
            print("No users to send notification")
            return
        }
        
        var tokenIDs: [String] = [String]()
        for userData in userList! {
            if userData.storeName == menu_order.storeInfo!.storeName {
                tokenIDs.append(userData.userToken)
            }
        }
        
        if tokenIDs.isEmpty {
            print("No token id found")
            return
        }
        
        var storeNotify: StoreNotificationData = StoreNotificationData()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmssSSS"
        let dateString = formatter.string(from: Date())
        
        storeNotify.createTime = dateString
        storeNotify.notificationType = STORE_NOTIFICATION_TYPE_NEW_ORDER
        
        let sender = PushNotificationSender()
        sender.sendStoreMulticastMessage(to: tokenIDs, title: "新進訂單", body: "來自『\(menu_order.deliveryInfo!.contactName)』的新進訂購單，請儘速閱讀詳細內容", data: storeNotify, ostype: OS_TYPE_IOS)

    })
}
