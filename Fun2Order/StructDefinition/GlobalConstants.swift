//
//  GlobalConstants.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/15.
//  Copyright © 2019 JStudio. All rights reserved.
//

import Foundation
import UIKit

let DATETIME_FORMATTER: String = "yyyyMMddHHmmssSSS"
let DATETIME_FORMATTER2: String = "yyyyMMddHHmmss"
let TAIWAN_DATETIME_FORMATTER: String = "yyyy年MM月dd日 HH:mm:ss"

let HTTP_REQUEST_TIMEOUT: Double = 5.0

let BASIC_FRAME_BORDER_COLOR_GREEN = UIColor(red: 51/255, green: 205/255, blue: 30/255, alpha: 1.0)
let BASIC_FRAME_BORDER_COLOR_CYAN = UIColor(red: 128/255, green: 222/255, blue: 234/255, alpha: 1.0)
let BASIC_FRAME_BORDER_COLOR_BLUE = UIColor(red: 36/255, green: 113/255, blue: 249/255, alpha: 1.0)
let BASIC_FRAME_BORDER_COLOR_ORANGE = UIColor(red: 255/255, green: 112/255, blue: 67/255, alpha: 1.0)

let COLOR_PEPPER_RED = UIColor(red: 177/255, green: 0/255, blue: 28/255, alpha: 1.0)

let CUSTOM_COLOR_EMERALD_GREEN = UIColor(red: 38/255, green: 166/255, blue: 154/255, alpha: 1.0)
let CUSTOM_COLOR_LIGHT_ORANGE = UIColor(red: 255/255, green: 112/255, blue: 67/255, alpha: 1.0)

let CODE_STORE_CATEGORY: String = "STORE_CATEGORY"
let CODE_PRODUCT_CATEGORY: String = "PRODUCT_CATEGORY"
let CODE_BRAND_RECIPE: String = "BRAND_RECIPE"

let BUTTON_ACTION_FAVORITE: String = "FAVORITE"
let BUTTON_ACTION_CART: String = "CART"

let ORDER_TYPE_SINGLE: String = "S"
let ORDER_TYPE_GROUP: String = "G"
let DELIVERY_TYPE_TAKEOUT: String = "TAKEOUT"
let DELIVERY_TYPE_DELIVERY: String = "DELIVERY"

let ORDER_STATUS_INIT: String = "INIT"    //Initial and editing state of the order
let ORDER_STATUS_CREATE: String = "CREATE"    // User create the real order and send to store
let ORDER_STATUS_CONFIRM: String = "CONFIRM"    // Store manager confirms to receive the real order
let ORDER_STATUS_MAKE: String = "MAKE"    // Store starts making the content of the order
let ORDER_STATUS_READY: String = "READY"    // Store gets the order ready to take out or deliver
let ORDER_STATUS_DELIVERY: String = "DELIVERY"
let ORDER_STATUS_FINISH: String = "FINISH"    // Customer receives products and finishes this order

