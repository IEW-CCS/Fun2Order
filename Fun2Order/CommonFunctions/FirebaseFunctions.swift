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
    if Auth.auth().currentUser?.uid == nil {
        print("uploadUserProfileTokenID Auth.auth().currentUser?.uid == nil ")
        return
    }
    
    let pathString = "USER_PROFILE/\(Auth.auth().currentUser!.uid)/tokenID"
    databaseRef.child(pathString).setValue(token_id)

    let pathOSTypeString = "USER_PROFILE/\(Auth.auth().currentUser!.uid)/ostype"
    databaseRef.child(pathOSTypeString).setValue("iOS")
}

func deleteFBMenuInformation(menu_info: MenuInformation) {
    let databaseRef = Database.database().reference()
    if Auth.auth().currentUser?.uid == nil || menu_info.menuNumber == "" {
        print("deleteFBMenuInformation Auth.auth().currentUser?.uid == nil || menu_info.menuNumber is empty")
        return
    }
    
    let pathString = "USER_MENU_INFORMATION/\(Auth.auth().currentUser!.uid)/\(menu_info.menuNumber)"
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
                } else {
                    print("Menu Image delete error: \(error!.localizedDescription)")
                    dispatchGroup.leave()
                }
            })
        }
        
        dispatchGroup.notify(queue: .main) {
            let folderPath = "Menu_Image/\(Auth.auth().currentUser!.uid)/\(menu_info.menuNumber)"
            let storageRef = Storage.storage().reference()
            storageRef.child(folderPath).delete(completion: nil)
        }
    }
}

func deleteFBMenuOrderInformation(user_id: String, order_number: String) {
    let databaseRef = Database.database().reference()
    if Auth.auth().currentUser?.uid == nil || order_number == "" {
        print("deleteFBMenuOrderInformation Auth.auth().currentUser?.uid == nil || order_number is empty")
        return
    }
    let pathString = "USER_MENU_ORDER/\(Auth.auth().currentUser!.uid)/\(order_number)"
    databaseRef.child(pathString).removeValue()
}

func downloadFBMenuInformation(user_id: String, menu_number: String, completion: @escaping(MenuInformation?) -> Void) {
    var menuData: MenuInformation = MenuInformation()

    let databaseRef = Database.database().reference()
    
    let pathString = "USER_MENU_INFORMATION/\(user_id)/\(menu_number)"
    
    databaseRef.child(pathString).observeSingleEvent(of: .value, with: { (snapshot) in
        if snapshot.exists() {
            let menuInfo = snapshot.value
            let jsonData = try? JSONSerialization.data(withJSONObject: menuInfo as Any, options: [])
            //let jsonString = String(data: jsonData!, encoding: .utf8)!
            //print("jsonString = \(jsonString)")

            let decoder: JSONDecoder = JSONDecoder()
            do {
                menuData = try decoder.decode(MenuInformation.self, from: jsonData!)
                //print("menuData decoded successful !!")
                //print("menuData = \(menuData)")
                completion(menuData)
            } catch {
                print("attendGroupOrder menuData jsonData decode failed: \(error.localizedDescription)")
                presentSimpleAlertMessage(title: "資料錯誤", message: "菜單資料讀取錯誤，請團購發起人重發。")
                completion(nil)
            }
        } else {
            print("attendGroupOrder USER_MENU_INFORMATION snapshot doesn't exist!")
            presentSimpleAlertMessage(title: "資料錯誤", message: "菜單資料不存在，請詢問團購發起人相關訊息。")
            completion(nil)
        }
    }) { (error) in
        print(error.localizedDescription)
        presentSimpleAlertMessage(title: "錯誤訊息", message: error.localizedDescription)
        completion(nil)
    }
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

func downloadFBMenuImage(menu_url: String, completion: @escaping(UIImage?) -> Void) {
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
                completion(nil)
            }
            
            completion(UIImage(data: data!)!)
        })
    }
}

func downloadFBMemberImage(member_id: String, completion: @escaping (UIImage?) -> Void) {
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
                    completion(nil)
                }
                
                completion(UIImage(data: data!)!)
            })
        } else {
            print("downloadMemberImage photoURL snapshot doesn't exist!")
            completion(nil)
        }
    })  { (error) in
        print(error.localizedDescription)
        completion(nil)
    }

}

func downloadFBBrandImage(brand_url: String, completion: @escaping(UIImage?) -> Void) {
    var alertWindow: UIWindow!
    if brand_url != "" {
        let storageRef = Storage.storage().reference()
        storageRef.child(brand_url).getData(maxSize: 3 * 2048 * 2048, completion: { (data, error) in
            if let error = error {
                print(error.localizedDescription)
                let controller = UIAlertController(title: "存取品牌影像錯誤", message: error.localizedDescription, preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
                    alertWindow.isHidden = true
                }
                
                controller.addAction(okAction)
                alertWindow = presentAlert(controller)
                completion(nil)
            }
            
            completion(UIImage(data: data!)!)
        })
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
    if Auth.auth().currentUser?.uid == nil {
        print("uploadFBUserProfile Auth.auth().currentUser?.uid == nil ")
        return
    }

    let pathString = "USER_PROFILE/\(Auth.auth().currentUser!.uid)"
    
    databaseRef.child(pathString).setValue(user_profile.toAnyObject())
}

func uploadFBMenuOrderContentItem(item: MenuOrderMemberContent, completion: @escaping () -> Void) {
    let databaseRef = Database.database().reference()

    if item.orderOwnerID == "" {
        print("uploadFBMenuOrderContentItem item.orderOwnerID is empty")
        return
    }
    
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
    if user_id == "" || template.templateName == "" {
        print("uploadFBMenuRecipeTemplate user_id is empty || template.templateName is empty")
        return
    }
    
    let databaseRef = Database.database().reference()
    let pathString = "USER_CUSTOM_RECIPE_TEMPLATE/\(user_id)/\(template.templateName)"
    
    databaseRef.child(pathString).setValue(template.toAnyObject())
}

func uploadFBShareMenuInformation(menu_info: MenuInformation, menu_images: [UIImage]?) {
    // Fill the new Menu Information
    if Auth.auth().currentUser?.uid == nil {
        print("uploadFBShareMenuInformation Auth.auth().currentUser?.uid == nil")
        return
    }
    
    let app = UIApplication.shared.delegate as! AppDelegate
    var upload_menu = menu_info
    var menuIcon: UIImage?
    let nowDate = Date()

    let formatter = DateFormatter()
    formatter.dateFormat = DATETIME_FORMATTER
    let timeString = formatter.string(from: nowDate)

    upload_menu.userID = Auth.auth().currentUser!.uid
    upload_menu.userName = getMyUserName()
    upload_menu.menuNumber = generateMenuNumber(date: nowDate)
    if upload_menu.menuNumber == "" {
        presentSimpleAlertMessage(title: "錯誤訊息", message: "菜單號碼為空白")
        return
    }
    
    upload_menu.createTime = timeString

    if menu_images == nil {
        upload_menu.menuImageURL = ""
        upload_menu.multiMenuImageURL = nil
    } else {
        if !menu_images!.isEmpty {
            upload_menu.menuImageURL = generateMenuImageURL(user_id: Auth.auth().currentUser!.uid, menu_number: upload_menu.menuNumber)
            menuIcon = resizeImage(image: menu_images![0], width: CGFloat(MENU_ICON_WIDTH))
            if upload_menu.multiMenuImageURL == nil {
                upload_menu.multiMenuImageURL = [String]()
            } else {
                upload_menu.multiMenuImageURL!.removeAll()
            }
            
            for i in 0...menu_images!.count - 1 {
                let newPath = "Menu_Image/\(upload_menu.userID)/\(upload_menu.menuNumber)/\(i).jpeg"
                upload_menu.multiMenuImageURL!.append(newPath)
            }
        }
    }
    
    if menuIcon != nil {
        insertMenuIcon(menu_number: upload_menu.menuNumber, menu_icon: menuIcon!)
    }
    
    // Update USER_PROFILE brand category list and CoreData for BrandCategory table
    var isNewCategory: Bool = false
    var categoryList = retrieveMenuBrandCategory()
    if upload_menu.brandCategory != "" {
        var isFound: Bool = false
        if !categoryList.isEmpty {
            for i in 0...categoryList.count - 1 {
                if categoryList[i] == upload_menu.brandCategory {
                    isFound = true
                    break
                }
            }
            if !isFound {
                categoryList.append(upload_menu.brandCategory)
                insertMenuBrandCategory(category: upload_menu.brandCategory)
                isNewCategory = true
            }
        } else {
            categoryList.append(upload_menu.brandCategory)
            insertMenuBrandCategory(category: upload_menu.brandCategory)
            isNewCategory = true
        }
    }
    
    if isNewCategory {
        downloadFBUserProfile(user_id: Auth.auth().currentUser!.uid, completion: {(profile) in
            if profile == nil {
                presentSimpleAlertMessage(title: "錯誤訊息", message: "使用者資料存取失敗")
                return
            }
            var new_profile = profile!
            new_profile.brandCategoryList = categoryList
            uploadFBUserProfile(user_profile: new_profile)
        })
    }

    let databaseRef = Database.database().reference()
    let pathString = "USER_MENU_INFORMATION/\(Auth.auth().currentUser!.uid)/\(upload_menu.menuNumber)"
    databaseRef.child(pathString).setValue(upload_menu.toAnyObject()) { (error, _) in
        if error == nil {
            if menu_images == nil {
                presentSimpleAlertMessage(title: "訊息", message: "分享菜單加入成功。")
                return
            } else {
                if menu_images!.isEmpty {
                    presentSimpleAlertMessage(title: "訊息", message: "分享菜單加入成功。")
                    return
                }
                
                let dispatchGroup = DispatchGroup()

                let newRef = Storage.storage().reference()

                for i in 0...menu_images!.count - 1 {
                    dispatchGroup.enter()
                    let newImage = resizeImage(image: menu_images![i], width: 1440)
                    let uploadData = newImage.jpegData(compressionQuality: 0.5)
                    let imagePath = upload_menu.multiMenuImageURL![i]
                    if uploadData != nil {
                        newRef.child(imagePath).putData(uploadData!, metadata: nil, completion: { (data, error) in
                            if error != nil {
                                print(error!.localizedDescription)
                                dispatchGroup.leave()
                                return
                            }
                            dispatchGroup.leave()
                        })
                    }
                }
                
                if upload_menu.menuImageURL != "" {
                    dispatchGroup.enter()
                    let newImage = resizeImage(image: menu_images![0], width: 1440)
                    let uploadData = newImage.jpegData(compressionQuality: 0.5)
                    let imagePath = upload_menu.menuImageURL
                    if uploadData != nil {
                        newRef.child(imagePath).putData(uploadData!, metadata: nil, completion: { (data, error) in
                            if error != nil {
                                print(error!.localizedDescription)
                                dispatchGroup.leave()
                                return
                            }
                            dispatchGroup.leave()
                        })
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    presentSimpleAlertMessage(title: "訊息", message: "分享菜單加入成功。")
                    app.menuListDelegate?.refreshMenuListFunction()
                    return
                }
            }
        }
    }
}

func monitorFBProductQuantityLimit(owner_id: String, order_number: String, completion: @escaping([MenuItem]?) -> Void) {
    let databaseRef = Database.database().reference()
    let pathString = "USER_MENU_ORDER/\(owner_id)/\(order_number)/limitedMenuItems"

    //databaseRef.child(pathString).observeSingleEvent(of: .value, with: { (snapshot) in
    databaseRef.child(pathString).observe(.value, with: { (snapshot) in
        if snapshot.exists() {
            var menuItems: [MenuItem] = [MenuItem]()
            let childEnumerator = snapshot.children
            
            let childDecoder: JSONDecoder = JSONDecoder()
            while let childData = childEnumerator.nextObject() as? DataSnapshot {
                //print("child = \(childData)")
                do {
                    let childJsonData = try? JSONSerialization.data(withJSONObject: childData.value as Any, options: [])
                    let realData = try childDecoder.decode(MenuItem.self, from: childJsonData!)
                    menuItems.append(realData)
                    print("Success: \(realData.itemName)")
                } catch {
                    print("monitorFBProductQuantityLimit jsonData decode failed: \(error.localizedDescription)")
                    continue
                }
            }

            if menuItems.isEmpty {
                completion(nil)
            } else {
                completion(menuItems)
            }
        } else {
            print("monitorFBProductQuantityLimit [MenuItem] snapshot doesn't exist!")
            completion(nil)
        }
    })  { (error) in
        print("monitorFBProductQuantityLimit Firebase error = \(error.localizedDescription)")
        completion(nil)
    }
}

func downloadFBDetailBrandProfile(brand_name: String, completion: @escaping (DetailBrandProfile?) -> Void) {
    var brandData: DetailBrandProfile = DetailBrandProfile()
    let databaseRef = Database.database().reference()
    let pathString = "DETAIL_BRAND_PROFILE/\(brand_name)"

    databaseRef.child(pathString).observeSingleEvent(of: .value, with: { (snapshot) in
        if snapshot.exists() {
            let brandProfile = snapshot.value
            let jsonData = try? JSONSerialization.data(withJSONObject: brandProfile as Any, options: [])
            //let jsonString = String(data: jsonData!, encoding: .utf8)!
            //print("brandProfile jsonString = \(jsonString)")

            let decoder: JSONDecoder = JSONDecoder()
            do {
                brandData = try decoder.decode(DetailBrandProfile.self, from: jsonData!)
                print("brandData decoded successful !!")
                print("brandData = \(brandData)")
                completion(brandData)
            } catch {
                print("downloadFBDetailBrandProfile brandData jsonData decode failed: \(error.localizedDescription)")
                completion(nil)
            }
        } else {
            print("downloadFBDetailBrandProfile DETAIL_BRAND_PROFILE snapshot doesn't exist!")
            completion(nil)
        }
    })  { (error) in
        print("downloadFBDetailBrandProfile Firebase error = \(error.localizedDescription)")
        completion(nil)
    }
}

func downloadFBDetailMenuInformation(menu_number: String, completion: @escaping (DetailMenuInformation?) -> Void) {
    var menuData: DetailMenuInformation = DetailMenuInformation()
    let databaseRef = Database.database().reference()
    let pathString = "DETAIL_MENU_INFORMATION/\(menu_number)"

    databaseRef.child(pathString).observeSingleEvent(of: .value, with: { (snapshot) in
        if snapshot.exists() {
            let menuInfo = snapshot.value
            let jsonData = try? JSONSerialization.data(withJSONObject: menuInfo as Any, options: [])
            //let jsonString = String(data: jsonData!, encoding: .utf8)!
            //print("menuInfo jsonString = \(jsonString)")

            let decoder: JSONDecoder = JSONDecoder()
            do {
                menuData = try decoder.decode(DetailMenuInformation.self, from: jsonData!)
                print("menuData decoded successful !!")
                print("menuData = \(menuData)")
                completion(menuData)
            } catch {
                print("downloadFBDetailMenuInformation menuData jsonData decode failed: \(error.localizedDescription)")
                completion(nil)
            }
        } else {
            print("downloadFBDetailMenuInformation DETAIL_MENU_INFORMATION snapshot doesn't exist!")
            completion(nil)
        }
    })  { (error) in
        print("downloadFBDetailMenuInformation Firebase error = \(error.localizedDescription)")
        completion(nil)
    }
}
