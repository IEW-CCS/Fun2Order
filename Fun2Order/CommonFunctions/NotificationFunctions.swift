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

func getNotifications(completion: @escaping () -> Void) {
    let notifications = UNUserNotificationCenter.current()
    notifications.getDeliveredNotifications { (delivered_notifications) in
        for delivered_notification in delivered_notifications {
            print("getNotifications -> setupNotification")
            setupNotification(notity: delivered_notification)
        }
        
        notifications.removeAllDeliveredNotifications()
        DispatchQueue.main.async {
            setNotificationBadgeNumber()
        }
        completion()
    }
}

func getLaunchNotification(user_infos: [String: Any]) {
    var notificationData: NotificationData = NotificationData()

    notificationData.messageID = user_infos["gcm.message_id"] as! String
    notificationData.messageTitle = user_infos["messageTitle"] as! String
    notificationData.messageBody = user_infos["messageBody"] as! String
    notificationData.notificationType = user_infos["notificationType"] as! String
    notificationData.receiveTime = user_infos["receiveTime"] as! String
    notificationData.orderOwnerID = user_infos["orderOwnerID"] as! String
    notificationData.orderOwnerName = user_infos["orderOwnerName"] as! String
    notificationData.menuNumber = user_infos["menuNumber"] as! String
    notificationData.orderNumber = user_infos["orderNumber"] as! String
    notificationData.dueTime = user_infos["dueTime"] as! String
    notificationData.brandName = user_infos["brandName"] as! String
    notificationData.attendedMemberCount = Int(user_infos["attendedMemberCount"] as! String)!
    notificationData.messageDetail = user_infos["messageDetail"] as! String
    notificationData.isRead = user_infos["isRead"] as! String
    //notificationData.isRead = user_infos["isRead"] as! Bool
    insertNotification(notification: notificationData)
    //notifications.removeAllDeliveredNotifications()
    DispatchQueue.main.async {
        setNotificationBadgeNumber()
    }
}

func getTappedNotification(notification: UNNotification) {
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

    notificationData.messageID = notity.request.content.userInfo["gcm.message_id"] as! String
    notificationData.messageTitle = notity.request.content.title
    notificationData.messageBody = notity.request.content.body
    notificationData.notificationType = notity.request.content.userInfo["notificationType"] as! String
    notificationData.receiveTime = notity.request.content.userInfo["receiveTime"] as! String
    notificationData.orderOwnerID = notity.request.content.userInfo["orderOwnerID"] as! String
    notificationData.orderOwnerName = notity.request.content.userInfo["orderOwnerName"] as! String
    notificationData.menuNumber = notity.request.content.userInfo["menuNumber"] as! String
    notificationData.orderNumber = notity.request.content.userInfo["orderNumber"] as! String
    notificationData.dueTime = notity.request.content.userInfo["dueTime"] as! String
    notificationData.brandName = notity.request.content.userInfo["brandName"] as! String
    notificationData.attendedMemberCount = Int(notity.request.content.userInfo["attendedMemberCount"] as! String)!
    notificationData.messageDetail = notity.request.content.userInfo["messageDetail"] as! String
    notificationData.isRead = notity.request.content.userInfo["isRead"] as! String

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
