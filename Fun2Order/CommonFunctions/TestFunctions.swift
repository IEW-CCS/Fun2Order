//
//  TestFunctions.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/4/30.
//  Copyright © 2020 JStudio. All rights reserved.
//

import Foundation
import Firebase

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

func testFirebaseJSONUpload() {
    var tmpData: TestStruct = TestStruct()
    
    let databaseRef = Database.database().reference()
    let pathString = "USER_TEST"
    
    tmpData.messageID = "TTTTTTT"
    
    databaseRef.child(pathString).childByAutoId().setValue(tmpData.toAnyObject())
    print("tmpData.toAnyObject = \(tmpData.toAnyObject())")
}

func testFirebaseJSONDownload() {
    let databaseRef = Database.database().reference()
    let pathString = "USER_TEST"

    databaseRef.child(pathString).observeSingleEvent(of: .value, with: { (snapshot) in
        if snapshot.exists() {
            let itemRawData = snapshot.value
            let jsonData = try? JSONSerialization.data(withJSONObject: itemRawData as Any, options: [])

            let decoder: JSONDecoder = JSONDecoder()
            do {
                let itemArray = try decoder.decode(TestStruct.self, from: jsonData!)
                print("itemArray = \(itemArray)")
                print("itemArray.locations.isEmpty = \(String(describing: itemArray.locations?.isEmpty))")
                
                if itemArray.locations != nil {
                    print("locations nil")
                }
            } catch {
                print("testFirebaseJSONDownload jsonData decode failed: \(error.localizedDescription)")
            }
        } else {
            print("testFirebaseJSONDownload snapshot doesn't exist!")
            return
        }
    }) { (error) in
        print(error.localizedDescription)
    }
    
}

func testFunction1() {
    var item = RecipeItem()
    var category = MenuRecipe()
    var template = MenuRecipeTemplate()
    template.templateName = "飲料類範本一"
    
    category.recipeCategory = "容量"
    category.sequenceNumber = 1
    category.allowedMultiFlag = false
    item.recipeName = "小杯"
    item.sequenceNumber = 1
    category.recipeItems?.append(item)
    item.recipeName = "中杯"
    item.sequenceNumber = 2
    category.recipeItems?.append(item)
    item.recipeName = "大杯"
    item.sequenceNumber = 3
    category.recipeItems?.append(item)
    item.recipeName = "瓶裝"
    item.sequenceNumber = 4
    category.recipeItems?.append(item)
    template.menuRecipes.append(category)

    category.recipeItems?.removeAll()
    category.recipeCategory = "冷飲溫度"
    category.sequenceNumber = 2
    category.allowedMultiFlag = false
    item.recipeName = "完全去冰"
    item.sequenceNumber = 1
    category.recipeItems?.append(item)
    item.recipeName = "去冰"
    item.sequenceNumber = 2
    category.recipeItems?.append(item)
    item.recipeName = "微冰"
    item.sequenceNumber = 3
    category.recipeItems?.append(item)
    item.recipeName = "少冰"
    item.sequenceNumber = 4
    category.recipeItems?.append(item)
    item.recipeName = "正常冰"
    item.sequenceNumber = 5
    category.recipeItems?.append(item)
    template.menuRecipes.append(category)

    category.recipeItems?.removeAll()
    category.recipeCategory = "熱飲溫度"
    category.sequenceNumber = 3
    category.allowedMultiFlag = false
    item.recipeName = "常溫"
    item.sequenceNumber = 1
    category.recipeItems?.append(item)
    item.recipeName = "微溫"
    item.sequenceNumber = 2
    category.recipeItems?.append(item)
    item.recipeName = "熱飲"
    item.sequenceNumber = 3
    category.recipeItems?.append(item)
    template.menuRecipes.append(category)
    
    category.recipeItems?.removeAll()
    category.recipeCategory = "甜度一"
    category.sequenceNumber = 4
    category.allowedMultiFlag = false
    item.recipeName = "無糖"
    item.sequenceNumber = 1
    category.recipeItems?.append(item)
    item.recipeName = "微糖"
    item.sequenceNumber = 2
    category.recipeItems?.append(item)
    item.recipeName = "半糖"
    item.sequenceNumber = 3
    category.recipeItems?.append(item)
    item.recipeName = "少糖"
    item.sequenceNumber = 4
    category.recipeItems?.append(item)
    item.recipeName = "全糖"
    item.sequenceNumber = 5
    category.recipeItems?.append(item)
    template.menuRecipes.append(category)

    category.recipeItems?.removeAll()
    category.recipeCategory = "甜度二"
    category.sequenceNumber = 5
    category.allowedMultiFlag = false
    item.recipeName = "一分糖"
    item.sequenceNumber = 1
    category.recipeItems?.append(item)
    item.recipeName = "二分糖"
    item.sequenceNumber = 2
    category.recipeItems?.append(item)
    item.recipeName = "三分糖"
    item.sequenceNumber = 3
    category.recipeItems?.append(item)
    item.recipeName = "四分糖"
    item.sequenceNumber = 4
    category.recipeItems?.append(item)
    item.recipeName = "五分糖"
    item.sequenceNumber = 5
    category.recipeItems?.append(item)
    item.recipeName = "六分糖"
    item.sequenceNumber = 6
    category.recipeItems?.append(item)
    item.recipeName = "七分糖"
    item.sequenceNumber = 7
    category.recipeItems?.append(item)
    item.recipeName = "八分糖"
    item.sequenceNumber = 8
    category.recipeItems?.append(item)
    item.recipeName = "九分糖"
    item.sequenceNumber = 9
    category.recipeItems?.append(item)
    item.recipeName = "十分糖"
    item.sequenceNumber = 10
    category.recipeItems?.append(item)
    template.menuRecipes.append(category)

    category.recipeItems?.removeAll()
    category.recipeCategory = "配料"
    category.sequenceNumber = 6
    category.allowedMultiFlag = true
    item.recipeName = "波霸"
    item.sequenceNumber = 1
    category.recipeItems?.append(item)
    item.recipeName = "珍珠"
    item.sequenceNumber = 2
    category.recipeItems?.append(item)
    item.recipeName = "仙草凍"
    item.sequenceNumber = 3
    category.recipeItems?.append(item)
    template.menuRecipes.append(category)

    let databaseRef = Database.database().reference()
    let pathString = "MENU_RECIPE_TEMPLATE/\(template.templateName)"
    
    databaseRef.child(pathString).setValue(template.toAnyObject())

}

func testFunction2() {
    var item = RecipeItem()
    var category = MenuRecipe()
    var template = MenuRecipeTemplate()
    template.templateName = "飲料類範本二"
    
    category.recipeCategory = "容量"
    category.sequenceNumber = 1
    category.allowedMultiFlag = false
    item.recipeName = "中杯"
    item.sequenceNumber = 1
    category.recipeItems?.append(item)
    item.recipeName = "大杯"
    item.sequenceNumber = 2
    category.recipeItems?.append(item)
    template.menuRecipes.append(category)

    category.recipeItems?.removeAll()
    category.recipeCategory = "冷飲溫度"
    category.sequenceNumber = 2
    category.allowedMultiFlag = false
    item.recipeName = "完全去冰"
    item.sequenceNumber = 1
    category.recipeItems?.append(item)
    item.recipeName = "去冰"
    item.sequenceNumber = 2
    category.recipeItems?.append(item)
    item.recipeName = "微冰"
    item.sequenceNumber = 3
    category.recipeItems?.append(item)
    item.recipeName = "少冰"
    item.sequenceNumber = 4
    category.recipeItems?.append(item)
    item.recipeName = "正常冰"
    item.sequenceNumber = 5
    category.recipeItems?.append(item)
    template.menuRecipes.append(category)

    category.recipeItems?.removeAll()
    category.recipeCategory = "甜度"
    category.sequenceNumber = 3
    category.allowedMultiFlag = false
    item.recipeName = "無糖"
    item.sequenceNumber = 1
    category.recipeItems?.append(item)
    item.recipeName = "微糖"
    item.sequenceNumber = 2
    category.recipeItems?.append(item)
    item.recipeName = "半糖"
    item.sequenceNumber = 3
    category.recipeItems?.append(item)
    item.recipeName = "少糖"
    item.sequenceNumber = 4
    category.recipeItems?.append(item)
    item.recipeName = "全糖"
    item.sequenceNumber = 5
    category.recipeItems?.append(item)
    template.menuRecipes.append(category)

    category.recipeItems?.removeAll()
    category.recipeCategory = "配料"
    category.sequenceNumber = 4
    category.allowedMultiFlag = true
    item.recipeName = "波霸"
    item.sequenceNumber = 1
    category.recipeItems?.append(item)
    item.recipeName = "珍珠"
    item.sequenceNumber = 2
    category.recipeItems?.append(item)
    template.menuRecipes.append(category)

    let databaseRef = Database.database().reference()
    let pathString = "MENU_RECIPE_TEMPLATE/\(template.templateName)"
    
    databaseRef.child(pathString).setValue(template.toAnyObject())

}
