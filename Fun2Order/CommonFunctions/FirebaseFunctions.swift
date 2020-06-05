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
    let databaseRef = Database.database().reference()
    let pathString = "USER_CUSTOM_RECIPE_TEMPLATE/\(user_id)/\(template.templateName)"
    
    databaseRef.child(pathString).setValue(template.toAnyObject())
}



