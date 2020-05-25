//
//  FirebaseFunctions.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/1/27.
//  Copyright © 2020 JStudio. All rights reserved.
//

import Foundation
import Firebase

func uploadUserProfileTokenID(user_id: String, token_id: String) {
    let databaseRef = Database.database().reference()
    let pathString = "USER_PROFILE/\(user_id)/tokenID"
    databaseRef.child(pathString).setValue(token_id)
}

func deleteFBMenuInformation(menu_info: MenuInformation) {
    let databaseRef = Database.database().reference()
    let pathString = "USER_MENU_INFORMATION/\(menu_info.userID)/\(menu_info.menuNumber)"
    databaseRef.child(pathString).removeValue()
    
    if menu_info.menuImageURL != "" {
        let storageRef = Storage.storage().reference()
        let storagePath = menu_info.menuImageURL
        storageRef.child(storagePath).delete(completion: nil)
    }
    
    if menu_info.multiMenuImageURL != nil {
        let dispatchGroup = DispatchGroup()

        for i in 0...menu_info.multiMenuImageURL!.count - 1 {
            let newPath = menu_info.multiMenuImageURL![i]
            let newRef = Storage.storage().reference()
            
            dispatchGroup.enter()
            newRef.child(newPath).delete(completion: {(error) in
                if error == nil {
                    dispatchGroup.leave()
                }
            })
        }
        
        dispatchGroup.notify(queue: .main) {
            let folderPath = "Menu_Image/\(menu_info.userID)/\(menu_info.menuNumber)"
            let storageRef = Storage.storage().reference()
            storageRef.child(folderPath).delete(completion: nil)
        }
    }
}

func deleteFBMenuOrderInformation(user_id: String, order_number: String) {
    let databaseRef = Database.database().reference()
    let pathString = "USER_MENU_ORDER/\(user_id)/\(order_number)"
    databaseRef.child(pathString).removeValue()
}

func downloadTokenID(user_id: String) {
    
}

func downloadFBMultiMenuImages(images_url: [String], completion: @escaping([UIImage]?) -> Void) {
    var returnImages: [UIImage]?
    var returnIndex: [Int] = [Int]()
    let dispatchGroup: DispatchGroup = DispatchGroup()
    
    if images_url.isEmpty {
        completion(nil)
    }
    
    for i in 0...images_url.count - 1 {
        if images_url[i] != "" {
            dispatchGroup.enter()
            let storageRef = Storage.storage().reference()
            storageRef.child(images_url[i]).getData(maxSize: 3 * 2048 * 2048, completion: { (data, error) in
                if let error = error {
                    presentSimpleAlertMessage(title: "存取影像錯誤", message: error.localizedDescription)
                    dispatchGroup.leave()
                    return
                }
                
                if data != nil {
                    if let imageData = UIImage(data: data!) {
                        if returnImages == nil {
                            returnImages = [UIImage]()
                        }
                        returnIndex.append(i)
                        returnImages!.append(imageData)
                    }
                    
                    dispatchGroup.leave()
                } else {
                    dispatchGroup.leave()
                }
            })
        }
    }
    
    dispatchGroup.notify(queue: .main) {
        print("returnIndex = \(returnIndex)")
        if returnImages != nil {
            //self.menuInfos.sort(by: {$0.createTime > $1.createTime})
            if returnImages!.count == returnIndex.count {
                let combinedArray = zip(returnIndex, returnImages!).sorted(by: { $0.0 < $1.0})
                print("Sorted index array = \(combinedArray.map { $0.0 })")
                returnImages = combinedArray.map { $0.1 }
            }
        }
        completion(returnImages)
    }
}

func downloadFBMenuImage(menu_url: String, completion: @escaping(UIImage) -> Void) {
    var alertWindow: UIWindow!
    if menu_url != "" {
        let storageRef = Storage.storage().reference()
        storageRef.child(menu_url).getData(maxSize: 3 * 2048 * 2048, completion: { (data, error) in
            if let error = error {
                print(error.localizedDescription)
                let controller = UIAlertController(title: "存取菜單影像錯誤", message: error.localizedDescription, preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
                    alertWindow.isHidden = true
                }
                
                controller.addAction(okAction)
                alertWindow = presentAlert(controller)
            }
            
            completion(UIImage(data: data!)!)
        })
    }
}

func downloadFBMemberImage(member_id: String, completion: @escaping (UIImage) -> Void) {
    var alertWindow: UIWindow!
    
    let databaseRef = Database.database().reference()
    let storageRef = Storage.storage().reference()
    
    let pathString = "USER_PROFILE/\(member_id)/photoURL"
    databaseRef.child(pathString).observeSingleEvent(of: .value, with: { (snapshot) in
        if snapshot.exists() {
            let imageURL = snapshot.value as! String
            storageRef.child(imageURL).getData(maxSize: 3 * 2048 * 2048, completion: { (data, error) in
                if let error = error {
                    print(error.localizedDescription)
                    let controller = UIAlertController(title: "存取會員影像錯誤", message: error.localizedDescription, preferredStyle: .alert)
                    
                    let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
                        alertWindow.isHidden = true
                    }
                    
                    controller.addAction(okAction)
                    alertWindow = presentAlert(controller)
                }
                
                completion(UIImage(data: data!)!)
            })
        } else {
            print("downloadMemberImage photoURL snapshot doesn't exist!")
            return
        }
    })  { (error) in
        print(error.localizedDescription)
        return
    }

}

func downloadFBUserProfile(user_id: String, completion: @escaping (UserProfile?) -> Void) {
    var userData: UserProfile = UserProfile()
    let databaseRef = Database.database().reference()
    let pathString = "USER_PROFILE/\(user_id)"

    databaseRef.child(pathString).observeSingleEvent(of: .value, with: { (snapshot) in
        if snapshot.exists() {
            let userProfile = snapshot.value
            let jsonData = try? JSONSerialization.data(withJSONObject: userProfile as Any, options: [])
            let jsonString = String(data: jsonData!, encoding: .utf8)!
            print("userProfile jsonString = \(jsonString)")

            let decoder: JSONDecoder = JSONDecoder()
            do {
                userData = try decoder.decode(UserProfile.self, from: jsonData!)
                print("userData decoded successful !!")
                print("userData = \(userData)")
                completion(userData)
            } catch {
                print("downloadFBUserProfile userData jsonData decode failed: \(error.localizedDescription)")
                completion(nil)
            }
        } else {
            print("downloadFBUserProfile USER_PROFILE snapshot doesn't exist!")
            completion(nil)
        }
    })  { (error) in
        print("downloadFBUserProfile Firebase error = \(error.localizedDescription)")
        completion(nil)
    }
}

func uploadFBUserProfile(user_profile: UserProfile) {
    let databaseRef = Database.database().reference()
    let pathString = "USER_PROFILE/\(user_profile.userID)"
    
    databaseRef.child(pathString).setValue(user_profile.toAnyObject())
}

func uploadFBMenuOrderContentItem(item: MenuOrderMemberContent, completion: @escaping () -> Void) {
    let databaseRef = Database.database().reference()
    let pathString = "USER_MENU_ORDER/\(item.orderOwnerID)/\(item.orderContent.orderNumber)/contentItems"
    //print("uploadFBMenuOrderContentItem pathString = \(pathString)")
    databaseRef.child(pathString).observeSingleEvent(of: .value, with: { (snapshot) in
        if snapshot.exists() {
            let itemRawData = snapshot.value
            let jsonData = try? JSONSerialization.data(withJSONObject: itemRawData as Any, options: [])

            let decoder: JSONDecoder = JSONDecoder()
            do {
                let itemArray = try decoder.decode([MenuOrderMemberContent].self, from: jsonData!)

                if let itemIndex = itemArray.firstIndex(where: { $0.memberID == item.memberID }) {
                    //print("itemData = \(itemArray[itemIndex])")
                    //print("itemIndex = \(itemIndex)")
                    let uploadPathString = pathString + "/\(itemIndex)"
                    databaseRef.child(uploadPathString).setValue(item.toAnyObject()) { (error, reference) in
                        if error != nil {
                            presentSimpleAlertMessage(title: "資料更新錯誤", message: error!.localizedDescription)
                            return
                        }
                        completion()
                    }
                }
            } catch {
                print("uploadFBMenuOrderContentItem jsonData decode failed: \(error.localizedDescription)")
            }
        } else {
            print("uploadFBMenuOrderContentItem snapshot doesn't exist!")
            return
        }
    }) { (error) in
        print(error.localizedDescription)
    }
}

func uploadFBMenuRecipeTemplate(user_id: String, template: MenuRecipeTemplate) {
    let databaseRef = Database.database().reference()
    let pathString = "USER_CUSTOM_RECIPE_TEMPLATE/\(user_id)/\(template.templateName)"
    
    databaseRef.child(pathString).setValue(template.toAnyObject())
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
