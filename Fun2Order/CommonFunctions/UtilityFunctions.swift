//
//  UtilityFunctions.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/31.
//  Copyright © 2019 JStudio. All rights reserved.
//

import Foundation
import UIKit


func getFirebaseUrlForRequest(uri: String) -> String {
    let path = NSHomeDirectory() + "/Documents/GoogleService-Info.plist"
    let plist = NSMutableDictionary(contentsOfFile: path)
    let databaseUrl = plist!["DATABASE_URL"] as! String
    var url : String

    url = databaseUrl + "/\(uri).json"

    return url
}

func getLastQueryTime() -> Date {
    let path = NSHomeDirectory() + "/Documents/AppConfig.plist"
    let plist = NSMutableDictionary(contentsOfFile: path)
    let lastTime = plist!["LastSystemQueryTime"] as! Date
    
    return lastTime
}

func updateLastQueryTime() {
    let path = NSHomeDirectory() + "/Documents/AppConfig.plist"
    if let plist = NSMutableDictionary(contentsOfFile: path) {
        plist["LastSystemQueryTime"] = Date()
        if plist.write(toFile: path, atomically: true) {
            print("Write LastSystemQueryTime to AppConfig.plist successfule.")
        } else {
            print("Write LastSystemQueryTime to AppConfig.plist failed.")
        }
    }
}

func getSelectedBrandID() -> Int {
    let path = NSHomeDirectory() + "/Documents/AppConfig.plist"
    let plist = NSMutableDictionary(contentsOfFile: path)
    let selectedBrandID = plist!["SelectedBrandID"] as! Int
    
    return selectedBrandID
}

func updateSelectedBrandID(brand_id: Int) {
    let path = NSHomeDirectory() + "/Documents/AppConfig.plist"
    if let plist = NSMutableDictionary(contentsOfFile: path) {
        plist["SelectedBrandID"] = brand_id
        if plist.write(toFile: path, atomically: true) {
            print("Write SelectedBrandID to AppConfig.plist successfule.")
        } else {
            print("Write SelectedBrandID to AppConfig.plist failed.")
        }
    }
}

func generateOrderNumber(type: String, day_code: String, brand_id: Int, store_id: Int, serial: Int) -> String{
    let formattedBrandID = String(format: "%04d", brand_id)
    let formattedStoreID = String(format: "%04d", store_id)
    let formattedSerial = String(format: "%06d", serial)
    
    let orderNumber = "\(type)\(day_code)\(formattedBrandID)\(formattedStoreID)-\(formattedSerial)"
    
    return orderNumber
}

func alert(message: String, title: String )-> UIAlertController {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(OKAction)
    //self.present(alertController, animated: true, completion: nil)
    return alertController
}

func Activityalert( title: String )-> UIAlertController {
    
    let _Activityalert = UIAlertController(title: title, message: "\n\n\n",preferredStyle: .alert)
    let _loadingIndicator =  UIActivityIndicatorView(frame: _Activityalert.view.bounds)
    _loadingIndicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    _loadingIndicator.color = UIColor.blue
    _loadingIndicator.startAnimating()
    _Activityalert.view.addSubview(_loadingIndicator)
    
    return _Activityalert
}

func getOrderStatusDescription(status_code: String) -> String {
    switch status_code {
    case ORDER_STATUS_INIT:
        return "初始狀態"
        
    case ORDER_STATUS_CREATE:
        return "訂單成立"
        
    case ORDER_STATUS_CONFIRM:
        return "已接單"

    case ORDER_STATUS_MAKE:
        return "製作中"
        
    case ORDER_STATUS_READY:
        return "製作完畢"
        
    case ORDER_STATUS_DELIVERY:
        return "運送中"
        
    case ORDER_STATUS_FINISH:
        return "已取餐"

    default:
        return ""
    }
}

func resizeImage(image: UIImage, width: CGFloat) -> UIImage {
   let widthInPixel: CGFloat = width
   let widthInPoint = widthInPixel / UIScreen.main.scale
   let size = CGSize(width: widthInPoint, height:
      image.size.height * widthInPoint / image.size.width)
   let renderer = UIGraphicsImageRenderer(size: size)
   let newImage = renderer.image { (context) in
      image.draw(in: renderer.format.bounds)
   }
   return newImage
}

func getProfileDatabasePath(u_id: String, key_value: String) -> String {
    let path: String = "USER_PROFILE/\(u_id)/\(key_value)"
    return path
}

func getUserPhotoStoragePath(u_id: String) -> String {
    let path: String = "UserProfile_Photo/\(u_id).png"
    return path
}
