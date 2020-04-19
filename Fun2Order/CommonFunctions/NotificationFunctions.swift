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
    insertNotification(notification: notificationData)
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
