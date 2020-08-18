//
//  PushNotificationSender.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/1/29.
//  Copyright © 2020 JStudio. All rights reserved.
//

import Foundation
import UIKit

class PushNotificationSender {
    private let authKey: String  = "AAAAc-l4bjA:APA91bHmg82XTJqzC_ORewYl2DbVDiU-_RQuZ8lm35_6puT3FuKRvFjLnoB89MamtEc31_31HVuPjQ27qwIHCLWjWqS8zXcBb6dBg7YaD_tPlfKRcgPredRO5TlU-JoENtLKx4Og1Qa4"
    private let projectID: String = "497838222896"

    func sendPushNotification(to token: String, title: String, body: String, data: Any) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let dataDict = data as! NotificationData
        
        let paramString: [String: Any] =
            ["to" : token,
             "notification" : ["title" : title, "body" : body],
             "data": dataDict.toAnyObject()]

        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        //request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(self.authKey)", forHTTPHeaderField: "Authorization")

        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    //print("jsonData = \(jsonData)")
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any] {
                        print("----------------------------------------------------------------")
                        print("PushNotificationSender sendPushNotification decode data from FCM server successfule!")
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                    
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }

    func sendPushNotification(to token: String, title: String, body: String, data: Any, ostype: String?) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let dataDict = data as! NotificationData
        
        var paramString: [String: Any] =
            ["to" : token,
             "notification" : ["title" : title, "body" : body],
             "data": dataDict.toAnyObject()]

        if ostype != nil {
            if ostype! == "Android" {
                paramString.removeValue(forKey: "notification")
            }
        }
        
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        //request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.httpBody = try? JSONSerialization.data(withJSONObject: paramString, options: [])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(self.authKey)", forHTTPHeaderField: "Authorization")

        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    //print("jsonData = \(jsonData)")
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any] {
                        print("----------------------------------------------------------------")
                        print("PushNotificationSender sendPushNotification decode data from FCM server successfule!")
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
                
                if error != nil {
                    print("error = \(String(describing: error?.localizedDescription))")
                }
                
                print("response = \(String(describing: response?.description))")
                
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }

    func sendNewFriendActionPushNotification(to token: String, title: String, body: String, data: Any) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let dataDict = data as! NotificationData
        
        let paramString: [String: Any] =
            ["to" : token,
             "notification" : ["title" : title, "body" : body, "click_action" : "newFriendCategory"],
             "data": dataDict.toAnyObject()]

        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        //request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.httpBody = try? JSONSerialization.data(withJSONObject: paramString, options: [])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(self.authKey)", forHTTPHeaderField: "Authorization")

        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    //print("jsonData = \(jsonData)")
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any] {
                        print("----------------------------------------------------------------")
                        print("PushNotificationSender sendPushNotification decode data from FCM server successfule!")
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }

    func sendDeviceGroupPushNotification(to tokens: [String], title: String, body: String, data: Any, ostype: String?) {
        let urlString = "https://fcm.googleapis.com/fcm/notification"
        let url = NSURL(string: urlString)!
                
        let requestKeyString: [String: Any] =
            ["operation": "remove",
             "notification_key_name": getMyTokenID(),
             "notification_key": "",
             "registration_ids": tokens]
        
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestKeyString, options: [])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(self.authKey)", forHTTPHeaderField: "Authorization")
        request.setValue(self.projectID, forHTTPHeaderField: "project_id")

        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    //print("jsonData = \(jsonData)")
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any] {
                        print("----------------------------------------------------------------")
                        print("PushNotificationSender sendDeviceGroupPushNotification decode data from FCM server successfule!")
                        NSLog("Received data:\n\(jsonDataDict))")
                        //print("Notification Key = \(jsonDataDict["notification_key"] as! String)")
                        guard let notification_key = jsonDataDict["notification_key"] as? String else {
                            presentSimpleAlertMessage(title: "資料錯誤", message: "Notification Key錯誤")
                            return
                        }

                        //self.sendDownStreamMessage(to: tokens, notification_key: notification_key, title: title, body: body, data: data as Any, ostype: ostype)
                    }
                }
                
                if error != nil {
                    print("error = \(String(describing: error?.localizedDescription))")
                }
                
                print("response = \(String(describing: response?.description))")
                
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
    
    func sendMulticastMessage(to tokens: [String], notification_key: String, title: String, body: String, data: Any, ostype: String?) {
        let dataDict = data as! NotificationData
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        
        var paramString: [String: Any] =
            [//"to" : notification_key,
             "registration_ids": tokens,
             "notification" : ["title" : title, "body" : body],
             "data": dataDict.toAnyObject()]

        if ostype != nil {
            if ostype! == "Android" {
                paramString.removeValue(forKey: "notification")
            }
        }

        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: paramString, options: [])
        let jsonString = try? JSONSerialization.data(withJSONObject: paramString, options: [])
        print("jsonString = \(String(describing: jsonString))")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(self.authKey)", forHTTPHeaderField: "Authorization")

        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    //print("jsonData = \(jsonData)")
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any] {
                        print("----------------------------------------------------------------")
                        print("PushNotificationSender sendPushNotification decode data from FCM server successfule!")
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
                
                if error != nil {
                    print("error = \(String(describing: error?.localizedDescription))")
                }
                
                print("response = \(String(describing: response?.description))")
                
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
}
