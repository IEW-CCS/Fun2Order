//
//  GlobalConstants.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/15.
//  Copyright © 2019 JStudio. All rights reserved.
//

import Foundation
import UIKit

// AdMob Ad Unit ID declaration
/// Test Ad Unit ID
let MENULIST_NATIVE_AD = "ca-app-pub-3940256099942544/3986624511" /// Test Native Unit ID
let NOTIFICATIONLIST_BANNER_AD = "ca-app-pub-3940256099942544/2934735716" /// Test Banner Unit ID
let JOINORDER_INTERSTITIAL_AD = "ca-app-pub-3940256099942544/5135589807" /// Test Interstitial Unit ID

/// IEW Production Ad Unit ID
//let MENULIST_NATIVE_AD = "ca-app-pub-6672968234138119/4619965469" /// IEW Production Native Unit ID 2
//let NOTIFICATIONLIST_BANNER_AD = "ca-app-pub-6672968234138119/9417830726" /// IEW Production Banner Unit ID
//let JOINORDER_INTERSTITIAL_AD = "ca-app-pub-6672968234138119/3517393514" /// IEW Production Interstitial Unit ID

/// Others Ad Unit ID
//let MENULIST_NATIVE_AD = "ca-app-pub-6672968234138119/7456638522" /// IEW Production Native Unit ID 1
//let MENULIST_NATIVE_AD = "ca-app-pub-9511677579097261/2673063242" /// James Production Native Unit ID
//let JOINORDER_INTERSTITIAL_AD = "ca-app-pub-9511677579097261/6069385370" /// James Production Interstitial Unit ID


let DEMO_ACCOUNTS: [String] = ["+886912345678", "+886934123456", "+8613123456789", "+8614123456789","+8615123456789"]
let DEMO_EMAILS: [String] = ["robohood83@gmail.com", "iewccs2019@gmail.com", "fun2order111@gmail.com", "func2order222@gmail.com","fun2order333@gmail.com"]
let DEMO_PASSWD: [String] = ["1234567", "1234567", "1234567", "1234567", "1234567"]

let DATETIME_FORMATTER: String = "yyyyMMddHHmmssSSS"
let DATETIME_FORMATTER2: String = "yyyyMMddHHmmss"
let TAIWAN_DATETIME_FORMATTER: String = "yyyy年MM月dd日 HH:mm:ss"
let TAIWAN_DATETIME_FORMATTER2: String = "yyyy年MM月dd日 HH:mm"
let DATE_FORMATTER: String = "yyyy年MM月dd日"

let HTTP_REQUEST_TIMEOUT: Double = 5.0
let MENU_ICON_WIDTH: Int = 160
let MAX_NEW_PRODUCT_COUNT: Int = 10

let MENU_HOME_BANNER_AD_HEIGHT: Int = 160
let NOTIFICATION_LIST_BANNER_AD_HEIGHT: Int = 90

let MENU_ITEM_CELL_TYPE_LIMIT_HEADER: Int = 0
let MENU_ITEM_CELL_TYPE_REMAINED_HEADER: Int = 1
let MENU_ITEM_CELL_TYPE_LIMIT_BODY: Int = 2
let MENU_ITEM_CELL_TYPE_REMAINED_BODY: Int = 3

let BASIC_FRAME_BORDER_COLOR_GREEN = UIColor(red: 51/255, green: 205/255, blue: 30/255, alpha: 1.0)
let BASIC_FRAME_BORDER_COLOR_CYAN = UIColor(red: 128/255, green: 222/255, blue: 234/255, alpha: 1.0)
let BASIC_FRAME_BORDER_COLOR_BLUE = UIColor(red: 36/255, green: 113/255, blue: 249/255, alpha: 1.0)
let BASIC_FRAME_BORDER_COLOR_ORANGE = UIColor(red: 255/255, green: 112/255, blue: 67/255, alpha: 1.0)
let NAVIGATION_BAR_COLOR_DARK_TEAL = UIColor(red: 100/255, green: 203/255, blue: 196/255, alpha: 1.0)

let COLOR_PEPPER_RED = UIColor(red: 177/255, green: 0/255, blue: 28/255, alpha: 1.0)

let CUSTOM_COLOR_EMERALD_GREEN = UIColor(red: 38/255, green: 166/255, blue: 154/255, alpha: 1.0)
let CUSTOM_COLOR_LIGHT_ORANGE = UIColor(red: 255/255, green: 112/255, blue: 67/255, alpha: 1.0)
let CUSTOM_COLOR_LIGHT_BLUE = UIColor(red: 41/255, green: 182/255, blue: 246/255, alpha: 1.0)
let CUSTOM_COLOR_REPORT_BACKGROUND_LIGHT_YELLOW = UIColor(red: 255/255, green: 255/255, blue: 102/255, alpha: 1.0)

let CODE_STORE_CATEGORY: String = "STORE_CATEGORY"
let CODE_PRODUCT_CATEGORY: String = "PRODUCT_CATEGORY"
let CODE_BRAND_RECIPE: String = "BRAND_RECIPE"

let BUTTON_ACTION_FAVORITE: String = "FAVORITE"
let BUTTON_ACTION_CART: String = "CART"
let BUTTON_ACTION_MENU_LIST: String = "MENU_LIST"
let BUTTON_ACTION_MENU_CREATE: String = "MENU_CREATE"
let BUTTON_ACTION_MENU_CONFIRM: String = "MENU_CONFIRM"
let BUTTON_ACTION_ASSIGN_RECIPE: String = "ASSIGN_RECIPE"
let BUTTON_ACTION_SETUP_RECIPE: String = "SETUP_RECIPE"
let BUTTON_ACTION_ABOUT: String = "ABOUT"
let BUTTON_ACTION_REFRESH_STATUS_SUMMARY: String = "REFRESH_STATUS_SUMMARY"
let BUTTON_ACTION_NOTIFY_MENUORDER_DUETIME: String = "NOTIFY_MENUORDER_DUETIME"
let BUTTON_ACTION_NOTIFY_SEND_MESSAGE: String = "NOTIFY_SEND_MESSAGE"
let BUTTON_ACTION_JOINORDER_SELECT_RECIPE: String = "JOINORDER_SELECT_RECIPE"

let ORDER_TYPE_SINGLE: String = "S"
let ORDER_TYPE_GROUP: String = "G"
let ORDER_TYPE_MENU: String = "M"
let ORDER_TYPE_OFFICIAL_MENU: String = "F"
let ORDER_TYPE_PUBLIC: String = "P"

let DELIVERY_TYPE_TAKEOUT: String = "TAKEOUT"
let DELIVERY_TYPE_DELIVERY: String = "DELIVERY"

let MENU_ORDER_REPLY_STATUS_WAIT: String = "WAIT"
let MENU_ORDER_REPLY_STATUS_ACCEPT: String = "ACCEPT"
let MENU_ORDER_REPLY_STATUS_REJECT: String = "REJECT"
let MENU_ORDER_REPLY_STATUS_EXPIRE: String = "EXPIRE"
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
let ORDER_STATUS_INIT: String = "INIT"          // Initial and editing state of the order
let ORDER_STATUS_NEW: String = "NEW"            // User create the real order and send to store
let ORDER_STATUS_ACCEPT: String = "ACCEPT"      // Store manager confirms to receive the real order
let ORDER_STATUS_REJECT: String = "REJECT"      // Store manager rejects the real order
let ORDER_STATUS_INPROCESS: String = "INPR"     // Store starts making the content of the order
let ORDER_STATUS_PROCESSEND: String = "PREN"        // Store gets the order ready to take out or deliver
let ORDER_STATUS_DELIVERY: String = "DELIVERY"  // Products in delivery
let ORDER_STATUS_CLOSE: String = "CLOSE"        // Customer receives products and finishes this order

let NOTIFICATION_TYPE_MESSAGE_DUETIME = "DUETIME"
let NOTIFICATION_TYPE_MESSAGE_INFORMATION = "INFO"
let NOTIFICATION_TYPE_ACTION_JOIN_ORDER = "JOIN"
let NOTIFICATION_TYPE_SHIPPING_NOTICE = "SHIPPING"
let NOTIFICATION_TYPE_CHANGE_DUETIME = "CHANGE_DUETIME"
let NOTIFICATION_TYPE_NEW_FRIEND = "NEW_FRIEND"
let NOTIFICATION_TYPE_SHARE_MENU = "SHARE_MENU"
let NOTIFICATION_TYPE_ACTIVITY = "ACTIVITY"
let NOTIFICATION_TYPE_VOTE = "VOTE"
let NOTIFICATION_TYPE_INVESTIGATION = "INVESTIGATION"

let REPORT_LAYOUT_TYPE_SECTION_HEADER = "SECTION_HEADER"
let REPORT_LAYOUT_TYPE_COLUMN_HEADER = "COLUMN_HEADER"
let REPORT_LAYOUT_TYPE_CELL = "REPORT_CELL"

let PRODUCT_OPERATION_MODE_ADD = "ADD"
let PRODUCT_OPERATION_MODE_COPY = "COPY"
let PRODUCT_OPERATION_MODE_EDIT = "EDIT"

let OS_TYPE_IOS = "iOS"
let OS_TYPE_ANDROID = "Android"

//let TEST_BACKGROUND_COLOR = UIColor(red: 212/255, green: 187/255, blue: 146/255, alpha: 1.0)
//let TEST_TABBAR_COLOR = UIColor(red: 83/255, green: 41/255, blue: 18/255, alpha: 1.0)
