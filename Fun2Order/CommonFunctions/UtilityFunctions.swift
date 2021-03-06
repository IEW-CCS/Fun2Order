//
//  UtilityFunctions.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/31.
//  Copyright © 2019 JStudio. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import MessageUI

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

func generateMenuNumber(date: Date) -> String {
    let timeZone = TimeZone.init(identifier: "UTC+8")
    let formatter = DateFormatter()
    formatter.timeZone = timeZone
    formatter.locale = Locale.init(identifier: "zh_TW")
    formatter.dateFormat = DATETIME_FORMATTER
    
    var tmpMenuNumber = formatter.string(from: date)
    if(Auth.auth().currentUser?.uid != nil) {
        tmpMenuNumber = "\(Auth.auth().currentUser!.uid)-MENU-\(tmpMenuNumber)"
    } else {
        tmpMenuNumber = "Guest-MENU-\(tmpMenuNumber)"
    }

    return tmpMenuNumber
}

func generateMenuImageURL(user_id: String, menu_number: String) -> String {
    let pathString = "Menu_Image/\(user_id)/\(menu_number).jpeg"
    
    return pathString
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


/*
 let ORDER_STATUS_INIT: String = "INIT"          // Initial and editing state of the order
 let ORDER_STATUS_NEW: String = "NEW"            // User create the real order and send to store
 let ORDER_STATUS_ACCEPT: String = "ACCEPT"      // Store manager confirms to receive the real order
 let ORDER_STATUS_REJECT: String = "REJECT"      // Store manager rejects the real order
 let ORDER_STATUS_INPROCESS: String = "INPR"     // Store starts making the content of the order
 let ORDER_STATUS_READY: String = "READY"        // Store gets the order ready to take out or deliver
 let ORDER_STATUS_DELIVERY: String = "DELIVERY"  // Products in delivery
 let ORDER_STATUS_CLOSE: String = "CLOSE"        // Customer receives products and finishes this order
*/
func getOrderStatusDescription(status_code: String) -> String {
    switch status_code {
    case ORDER_STATUS_INIT:
        return "訂單建立"
        
    case ORDER_STATUS_NEW:
        return "新訂單"
        
    case ORDER_STATUS_ACCEPT:
        return "已接單"

    case ORDER_STATUS_REJECT:
        return "已拒絕"
        
    case ORDER_STATUS_INPROCESS:
        return "製作中"
        
    case ORDER_STATUS_PROCESSEND:
        return "製作完畢"

    case ORDER_STATUS_DELIVERY:
        return "運送中"
        
    case ORDER_STATUS_CLOSE:
        return "已結單"

    default:
        return ""
    }
}

func resizeImage(image: UIImage, width: CGFloat) -> UIImage {
    let widthInPixel: CGFloat = width
    let widthInPoint = widthInPixel / UIScreen.main.scale
    let size = CGSize(width: widthInPoint, height: image.size.height * widthInPoint / image.size.width)
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

func getMenuInfoDatabasePath(u_id: String, menu_number: String, key_value: String) -> String {
    let path: String = "USER_MENU_INFORMATION/\(u_id)/\(menu_number)/\(key_value)"
    return path
}

func presentAlert(_ alertController: UIAlertController) -> UIWindow {
 
    // 創造一個 UIWindow 的實例。
    let alertWindow = UIWindow()
    
    if #available(iOS 13.0, *) {
        // 取得 view 所屬的 windowScene，並指派給 alertWindow。
        //guard let windowScene = alertController.view.window?.windowScene else { return }
        let windowScene = UIApplication.shared.connectedScenes.first { $0.activationState == .foregroundActive }
        alertWindow.windowScene = windowScene as? UIWindowScene
    }
 
    // UIWindow 預設的背景色是黑色，但我們想要 alertWindow 的背景是透明的。
    alertWindow.backgroundColor = nil
 
    // 將 alertWindow 的顯示層級提升到最上方，不讓它被其它視窗擋住。
    alertWindow.windowLevel = .alert
 
    // 指派一個空的 UIViewController 給 alertWindow 當 rootViewController。
    DispatchQueue.main.async {
       alertWindow.rootViewController = UIViewController()
    
       // 將 alertWindow 顯示出來。由於我們不需要使 alertWindow 變成主視窗，所以沒有必要用 alertWindow.makeKeyAndVisible()。
       alertWindow.isHidden = false
    
       // 使用 alertWindow 的 rootViewController 來呈現警告。
       alertWindow.rootViewController?.present(alertController, animated: true)
    }
    
    return alertWindow
}

func presentSimpleAlertMessage(title: String, message: String) {
    var alertWindow: UIWindow!
    let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)

    let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
        alertWindow.isHidden = true
    }
    
    controller.addAction(okAction)
    alertWindow = presentAlert(controller)
}

func getMyTokenID() -> String {
    let path = NSHomeDirectory() + "/Documents/AppConfig.plist"
    let plist = NSMutableDictionary(contentsOfFile: path)
    let tokenID = plist!["FirebaseInstanceID"] as! String
    
    return tokenID
}

func getMyUserName() -> String {
    let path = NSHomeDirectory() + "/Documents/MyProfile.plist"
    let plist = NSMutableDictionary(contentsOfFile: path)
    let userName = plist!["UserName"] as! String
    
    return userName
}

func getMyContactInfo() -> UserContactInformation {
    var userContact: UserContactInformation = UserContactInformation()
    
    let path = NSHomeDirectory() + "/Documents/MyProfile.plist"
    let plist = NSMutableDictionary(contentsOfFile: path)
    let userName = plist!["UserName"] as! String
    let userPhoneNumber = plist!["PhoneNumber"] as! String
    let userAddress = plist!["Address"] as? String
    
    userContact.userName = userName
    userContact.userPhoneNumber = userPhoneNumber
    userContact.userAddress = userAddress

    return userContact
}

func showGuideToolTip(text: String, dir: PopTipDirection, parent: UIView, target: CGRect, duration: TimeInterval) {
    let popTip = PopTip()
    popTip.font = UIFont(name: "Avenir-Medium", size: 15)!
    popTip.shouldDismissOnTap = true
    popTip.shouldDismissOnTapOutside = true
    popTip.shouldDismissOnSwipeOutside = true
    popTip.edgeMargin = 5
    popTip.offset = 2
    popTip.bubbleOffset = 0
    popTip.edgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    popTip.arrowRadius = 1
    //popTip.bubbleColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
    //popTip.bubbleColor = UIColor.systemRed
    popTip.bubbleColor = UIColor.systemBlue

    //popTip.bubbleColor = UIColor(red: 0.31, green: 0.57, blue: 0.87, alpha: 1)
    popTip.show(text: text, direction: dir, maxWidth: 200, in: parent, from: target, duration: duration)
}

func getRecipeTemplateLastSequenceNumber() -> Int {
    var sequenceNumber: Int = 0

    let path = NSHomeDirectory() + "/Documents/AppConfig.plist"
    if let plist = NSMutableDictionary(contentsOfFile: path) {
        guard let serialID = plist["RecipeTemplateSerial"] as? Int else {
            print("RecipeTemplateSerial key did not exist in AppConfig.plist, insert this key")
            plist.addEntries(from: ["RecipeTemplateSerial": 1])
            sequenceNumber = 1
            plist["RecipeTemplateSerial"] = sequenceNumber
            if !plist.write(toFile: path, atomically: true) {
                print("Save AppConfig.plist failed")
            }
            return sequenceNumber
        }
        
        sequenceNumber = serialID + 1
        plist["RecipeTemplateSerial"] = sequenceNumber
        if !plist.write(toFile: path, atomically: true) {
            print("Save AppConfig.plist failed")
        }
    }

    return sequenceNumber
}

class RuntimeUtils{
    class func delay(seconds delay:Double, closure:@escaping ()->()){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay*Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
}

func checkLimitedMenuItemsRemainedQuantity(limited_items: [MenuItem]?,  product_name: String, product_quantity: Int) -> Bool {
    if limited_items != nil {
        var remainedQuantity: Int = 0
        for i in 0...limited_items!.count - 1 {
            if product_name == limited_items![i].itemName {
                if limited_items![i].quantityLimitation == nil {
                    continue
                }
                
                if limited_items![i].quantityRemained != nil {
                    remainedQuantity = Int(limited_items![i].quantityRemained!)
                }
                
                if product_quantity > remainedQuantity {
                    presentSimpleAlertMessage(title: "錯誤訊息", message: "此產品為限量商品，目前訂購的數量已超過剩餘的數量，請修改數量或選擇其他產品後再重新送出")
                    return false
                }
            }
        }
    }
    
    return true
}
