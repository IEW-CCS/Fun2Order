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
        let tabItem = tabItems[1] //Notification tab bar item
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
        
        case NOTIFICATION_TYPE_SHARE_GROUP_FRIEND:
            return true
        
        default:
            return false
    }
}
