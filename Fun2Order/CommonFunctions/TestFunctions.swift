//
//  TestFunctions.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/4/30.
//  Copyright © 2020 JStudio. All rights reserved.
//

import Foundation

func testResetCreateMenuToolTip() {
    let path = NSHomeDirectory() + "/Documents/GuideToolTip.plist"

    if let writePlist = NSMutableDictionary(contentsOfFile: path) {
        writePlist["showedCreateMenuToolTip"] = false
        if writePlist.write(toFile: path, atomically: true) {
            print("Write showedCreateMenuToolTip to GuideToolTip.plist successfule.")
        } else {
            print("Write showedCreateMenuToolTip to GuideToolTip.plist failed.")
        }
    }
}


func testResetMyProfileToolTip() {
    let path = NSHomeDirectory() + "/Documents/GuideToolTip.plist"

    if let writePlist = NSMutableDictionary(contentsOfFile: path) {
        writePlist["showedMyProfileToolTip"] = false
        if writePlist.write(toFile: path, atomically: true) {
            print("Write showedMyProfileToolTip to GuideToolTip.plist successfule.")
        } else {
            print("Write showedMyProfileToolTip to GuideToolTip.plist failed.")
        }
    }
}

func testResetMyFriendToolTip() {
    let path = NSHomeDirectory() + "/Documents/GuideToolTip.plist"

    if let writePlist = NSMutableDictionary(contentsOfFile: path) {
        writePlist["showedMyFriendToolTip"] = false
        if writePlist.write(toFile: path, atomically: true) {
            print("Write showedMyFriendToolTip to GuideToolTip.plist successfule.")
        } else {
            print("Write showedMyFriendToolTip to GuideToolTip.plist failed.")
        }
    }
}


func testResetMyGroupToolTip() {
    let path = NSHomeDirectory() + "/Documents/GuideToolTip.plist"

    if let writePlist = NSMutableDictionary(contentsOfFile: path) {
        writePlist["showedMyGroupToolTip"] = false
        if writePlist.write(toFile: path, atomically: true) {
            print("Write showedMyGroupToolTip to GuideToolTip.plist successfule.")
        } else {
            print("Write showedMyGroupToolTip to GuideToolTip.plist failed.")
        }
    }
}

func testResetGroupOrderToolTip() {
    let path = NSHomeDirectory() + "/Documents/GuideToolTip.plist"

    if let writePlist = NSMutableDictionary(contentsOfFile: path) {
        writePlist["showedGroupOrderToolTip"] = false
        if writePlist.write(toFile: path, atomically: true) {
            print("Write showedGroupOrderToolTip to GuideToolTip.plist successfule.")
        } else {
            print("Write showedGroupOrderToolTip to GuideToolTip.plist failed.")
        }
    }
}
