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
