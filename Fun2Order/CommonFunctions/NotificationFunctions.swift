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

func getNotifications() {
    let notifications = UNUserNotificationCenter.current()
    notifications.getDeliveredNotifications { (delivered_notifications) in
        //print("*********************************************")
        //print("Display all delivered notifications:")
        for delivered_notification in delivered_notifications {
            //print(delivered_notification)
            //print("Delivered notification request content = \(delivered_notification.request.content)")
/*
             print("Delivered notification userInfo = \(delivered_notification.request.content.userInfo)")

             var notificationData: NotificationData = NotificationData()

             notificationData.messageID = delivered_notification.request.content.userInfo["gcm.message_id"] as! String
             notificationData.messageTitle = delivered_notification.request.content.title
             notificationData.messageBody = delivered_notification.request.content.body
             notificationData.notificationType = delivered_notification.request.content.userInfo["notificationType"] as! String
             notificationData.receiveTime = delivered_notification.request.content.userInfo["receiveTime"] as! String
             notificationData.orderOwnerID = delivered_notification.request.content.userInfo["orderOwnerID"] as! String
             notificationData.orderOwnerName = delivered_notification.request.content.userInfo["orderOwnerName"] as! String
             notificationData.orderNumber = delivered_notification.request.content.userInfo["orderNumber"] as! String
             notificationData.dueTime = delivered_notification.request.content.userInfo["dueTime"] as! String
             notificationData.brandName = delivered_notification.request.content.userInfo["brandName"] as! String
             notificationData.attendedMemberCount = Int(delivered_notification.request.content.userInfo["attendedMemberCount"] as! String)!
             notificationData.messageDetail = delivered_notification.request.content.userInfo["messageDetail"] as! String
             notificationData.isRead = false
             insertNotification(notification: notificationData)
*/
            setupNotification(notity: delivered_notification)
        }
        
        notifications.removeAllDeliveredNotifications()
        setNotificationBadgeNumber()
    }
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
    notificationData.isRead = false
    insertNotification(notification: notificationData)
    //notifications.removeAllDeliveredNotifications()
    //setNotificationBadgeNumber()
}

func setNotificationBadgeNumber() {
    let badgeCount = retrieveNotificationBadgeNumber()
    
    UIApplication.shared.applicationIconBadgeNumber = badgeCount
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
