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
    private let authKey:String  = "AAAAc-l4bjA:APA91bHmg82XTJqzC_ORewYl2DbVDiU-_RQuZ8lm35_6puT3FuKRvFjLnoB89MamtEc31_31HVuPjQ27qwIHCLWjWqS8zXcBb6dBg7YaD_tPlfKRcgPredRO5TlU-JoENtLKx4Og1Qa4"

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

}
