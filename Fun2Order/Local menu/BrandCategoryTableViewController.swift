//
//  BrandCategoryTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/5/30.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
import Firebase

protocol BrandCategoryDelegate: class {
    func deleteBrandCategoryComplete(sender: BrandCategoryTableViewController)
}

class BrandCategoryTableViewController: UITableViewController {
    var brandCategoryList: [String] = [String]()
    var menuList: [MenuInformation] = [MenuInformation]()
    weak var delegate: BrandCategoryDelegate?
    var deleteFlag: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let titleCellViewNib: UINib = UINib(nibName: "BasicTitleCell", bundle: nil)
        self.tableView.register(titleCellViewNib, forCellReuseIdentifier: "BasicTitleCell")
    }
    
    func deleteBrandCategory(category: String) {
        if self.menuList.isEmpty {
            return
        }
        let dispatchGroup: DispatchGroup = DispatchGroup()
        
        let databaseRef = Database.database().reference()

        for i in 0...self.menuList.count - 1 {
            if self.menuList[i].brandCategory == category {
                self.menuList[i].brandCategory = ""
                if self.menuList[i].userID == "" {
                    print("deleteBrandCategory elf.menuList[i].userID is empty")
                    continue
                }
                let pathString = "USER_MENU_INFORMATION/\(self.menuList[i].userID)/\(self.menuList[i].menuNumber)"
                dispatchGroup.enter()
                databaseRef.child(pathString).setValue(self.menuList[i].toAnyObject()) { (_, _) in
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            deleteMenuBrandCategory(category: category)
            if self.deleteFlag != -1 {
                self.brandCategoryList.remove(at: self.deleteFlag)
                self.updateBrandCatogory()
            }
            presentSimpleAlertMessage(title: "訊息", message: "菜單資料已成功儲存")
            self.delegate?.deleteBrandCategoryComplete(sender: self)
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }

    }

    func updateBrandCatogory() {
        if Auth.auth().currentUser?.uid != nil {
            downloadFBUserProfile(user_id: Auth.auth().currentUser!.uid, completion: receiveMyProfile)
        }
    }
    
    func receiveMyProfile(user_profile: UserProfile?) {
        if user_profile == nil {
            presentSimpleAlertMessage(title: "錯誤訊息", message: "存取使用者資料發生錯誤")
            return
        }
        
        var profile = user_profile!
        profile.brandCategoryList = self.brandCategoryList
        //var brandList = [String]()
        //if profile.brandCategoryList == nil {
        //    brandList.append(contentsOf: self.brandCategoryList)
        //    profile.brandCategoryList = brandList
        //} else {
        //    profile.brandCategoryList! = self.brandCategoryList
        //}
        uploadFBUserProfile(user_profile: profile)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !self.brandCategoryList.isEmpty {
            return self.brandCategoryList.count
        }
        
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicTitleCell", for: indexPath) as! BasicTitleCell
                
        cell.setData(title: self.brandCategoryList[indexPath.row])
        cell.selectionStyle = UITableViewCell.SelectionStyle.none

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "刪除"
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        var alertWindow: UIWindow!
        if editingStyle == .delete {
            let controller = UIAlertController(title: "刪除分類", message: "若刪除此分類，則所有與此分類相同的菜單將會全部變更成“未分類”，確定要刪除此分類資訊嗎？", preferredStyle: .alert)

            let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
                print("Confirm to delete this brand category")
                self.deleteBrandCategory(category: self.brandCategoryList[indexPath.row])
                self.deleteFlag = indexPath.row
                alertWindow.isHidden = true
            }
            
            controller.addAction(okAction)
            let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (_) in
                print("Cancel to delete this brand category")
                alertWindow.isHidden = true
            }
            controller.addAction(cancelAction)
            alertWindow = presentAlert(controller)
        }
    }

}
