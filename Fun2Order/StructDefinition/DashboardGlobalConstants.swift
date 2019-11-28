//
//  GlobalConstants.swift
//  TestCoreData
//
//  Created by Lo Fang Chou on 2019/9/18.
//  Copyright © 2019 JStudio. All rights reserved.
//

import Foundation
import UIKit

var HTTP_SERVER_ONLINE_STATUS = false

let DASHBOARD_BASIC_CELL_HEIGHT: Int = 50
let DASHBOARD_STATUS_SUMMARY_CELL_HEIGHT = 290
let DASHBOARD_MESSAGE_CELL_HEIGHT = 300
let DASHBOARD_CATEGORY_CELL_WIDTH = 48

let CELL_CORNER_RADIUS: CGFloat = CGFloat(6)
let SHADOW_INNERVIEW_INSET: CGFloat = CGFloat(5)

let STATUS_RUN_COLOR = UIColor(red: 66/255, green: 165/255, blue: 245/255, alpha: 1.0)
let STATUS_DOWN_COLOR = UIColor(red: 239/255, green: 83/255, blue: 80/255, alpha: 1.0)
let STATUS_IDLE_COLOR = UIColor(red: 120/255, green: 144/255, blue: 156/255, alpha: 1.0)
let SERVER_ON_LINE_STATUS = UIColor(red: 0/255, green: 230/255, blue: 118/255, alpha: 1.0)

let GRADIENT_COLOR_RED_TOP = UIColor(red: 255/255, green: 205/255, blue: 210/255, alpha: 1.0)
let GRADIENT_COLOR_RED_BOTTOM = UIColor(red: 239/255, green: 154/255, blue: 154/255, alpha: 1.0)

let GRADIENT_COLOR_GREEN_TOP = UIColor(red: 200/255, green: 230/255, blue: 201/255, alpha: 1.0)
let GRADIENT_COLOR_GREEN_BOTTOM = UIColor(red: 165/255, green: 214/255, blue: 167/255, alpha: 1.0)

let GRADIENT_COLOR_BLUE_TOP = UIColor(red: 187/255, green: 222/255, blue: 251/255, alpha: 1.0)
let GRADIENT_COLOR_BLUE_BOTTOM = UIColor(red: 144/255, green: 202/255, blue: 249/255, alpha: 1.0)

let GRADIENT_COLOR_PINK_TOP = UIColor(red: 248/255, green: 187/255, blue: 208/255, alpha: 1.0)
let GRADIENT_COLOR_PINK_BUTTOM = UIColor(red: 244/255, green: 143/255, blue: 177/255, alpha: 1.0)

let GRADIENT_COLOR_CYAN_TOP = UIColor(red: 178/255, green: 235/255, blue: 242/255, alpha: 1.0)
let GRADIENT_COLOR_CYAN_BOTTOM = UIColor(red: 128/255, green: 222/255, blue: 234/255, alpha: 1.0)

let GRADIENT_COLOR_LIGHTBLUE_TOP = UIColor(red: 179/255, green: 229/255, blue: 252/255, alpha: 1.0)
let GRADIENT_COLOR_LIGHTBLUE_BOTTOM = UIColor(red: 129/255, green: 212/255, blue: 250/255, alpha: 1.0)

let GRADIENT_COLOR_TEAL_TOP = UIColor(red: 178/255, green: 223/255, blue: 219/255, alpha: 1.0)
let GRADIENT_COLOR_TEAL_BOTTOM = UIColor(red: 128/255, green: 203/255, blue: 196/255, alpha: 1.0)

let GRADIENT_COLOR_PURPLE_TOP = UIColor(red: 225/255, green: 190/255, blue: 231/255, alpha: 1.0)
let GRADIENT_COLOR_PURPLE_BOTTOM = UIColor(red: 206/255, green: 147/255, blue: 216/255, alpha: 1.0)

let GRADIENT_COLOR_DEEPORANGE_TOP = UIColor(red: 255/255, green: 204/255, blue: 188/255, alpha: 1.0)
let GRADIENT_COLOR_DEEPORANGE_BOTTOM = UIColor(red: 255/255, green: 171/255, blue: 145/255, alpha: 1.0)

let GRADIENT_COLOR_ORANGE_TOP = UIColor(red: 255/255, green: 224/255, blue: 178/255, alpha: 1.0)
let GRADIENT_COLOR_ORANGE_BOTTOM = UIColor(red: 255/255, green: 204/255, blue: 128/255, alpha: 1.0)

let GRADIENT_COLOR_LIGHTGREEN_TOP = UIColor(red: 220/255, green: 237/255, blue: 200/255, alpha: 1.0)
let GRADIENT_COLOR_LIGHTGREEN_BOTTOM = UIColor(red: 197/255, green: 225/255, blue: 165/255, alpha: 1.0)

let GRADIENT_COLOR_GREY_TOP = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0)
let GRADIENT_COLOR_GREY_BOTTOM = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0)

let GRADIENT_COLOR_BLUEGREY_TOP = UIColor(red: 207/255, green: 216/255, blue: 220/255, alpha: 1.0)
let GRADIENT_COLOR_BLUEGREY_BOTTOM = UIColor(red: 176/255, green: 190/255, blue: 197/255, alpha: 1.0)

let GRADIENT_COLOR_YELLOW_TOP = UIColor(red: 255/255, green: 249/255, blue: 196/255, alpha: 1.0)
let GRADIENT_COLOR_YELLOW_BOTTOM = UIColor(red: 255/255, green: 245/255, blue: 157/255, alpha: 1.0)

let GRADIENT_COLOR_PURE_WHITE:Int = 0
let GRADIENT_COLOR_PURE_LIGHTGRAY:Int = 1
let GRADIENT_COLOR_PURE_DARKGRAY:Int = 2
let GRADIENT_COLOR_RED:Int = 3
let GRADIENT_COLOR_GREEN:Int = 4
let GRADIENT_COLOR_BLUE:Int = 5
let GRADIENT_COLOR_PINK:Int = 6
let GRADIENT_COLOR_CYAN:Int = 7
let GRADIENT_COLOR_LIGHTBLUE:Int = 8
let GRADIENT_COLOR_TEAL:Int = 9
let GRADIENT_COLOR_PURPLE:Int = 10
let GRADIENT_COLOR_DEEPORANGE:Int = 11
let GRADIENT_COLOR_ORANGE:Int = 12
let GRADIENT_COLOR_LIGHTGREEN: Int = 13
let GRADIENT_COLOR_GREY:Int = 14
let GRADIENT_COLOR_BLUEGREY:Int = 15
let GRADIENT_COLOR_YELLOW:Int = 16

let GRADIENT_COLOR_SET = [[UIColor.white.cgColor, UIColor.white.cgColor],
                          [UIColor.lightGray.cgColor, UIColor.lightGray.cgColor],
                          [UIColor.darkGray.cgColor, UIColor.darkGray.cgColor],
                          [GRADIENT_COLOR_RED_TOP.cgColor, GRADIENT_COLOR_RED_BOTTOM.cgColor],
                          [GRADIENT_COLOR_GREEN_TOP.cgColor, GRADIENT_COLOR_GREEN_BOTTOM.cgColor],
                          [GRADIENT_COLOR_BLUE_TOP.cgColor, GRADIENT_COLOR_BLUE_BOTTOM.cgColor],
                          [GRADIENT_COLOR_PINK_TOP.cgColor, GRADIENT_COLOR_PINK_TOP.cgColor],
                          [GRADIENT_COLOR_CYAN_TOP.cgColor, GRADIENT_COLOR_CYAN_BOTTOM.cgColor],
                          [GRADIENT_COLOR_LIGHTBLUE_TOP.cgColor, GRADIENT_COLOR_LIGHTBLUE_BOTTOM.cgColor],
                          [GRADIENT_COLOR_TEAL_TOP.cgColor, GRADIENT_COLOR_TEAL_BOTTOM.cgColor],
                          [GRADIENT_COLOR_PURPLE_TOP.cgColor, GRADIENT_COLOR_PURPLE_BOTTOM.cgColor],
                          [GRADIENT_COLOR_DEEPORANGE_TOP.cgColor, GRADIENT_COLOR_DEEPORANGE_BOTTOM.cgColor],
                          [GRADIENT_COLOR_ORANGE_TOP.cgColor, GRADIENT_COLOR_ORANGE_BOTTOM.cgColor],
                          [GRADIENT_COLOR_LIGHTGREEN_TOP.cgColor, GRADIENT_COLOR_LIGHTGREEN_BOTTOM.cgColor],
                          [GRADIENT_COLOR_GREY_TOP.cgColor, GRADIENT_COLOR_GREY_BOTTOM.cgColor],
                          [GRADIENT_COLOR_BLUEGREY_TOP.cgColor, GRADIENT_COLOR_BLUEGREY_BOTTOM.cgColor],
                          [GRADIENT_COLOR_YELLOW_TOP.cgColor, GRADIENT_COLOR_YELLOW_BOTTOM.cgColor]]

