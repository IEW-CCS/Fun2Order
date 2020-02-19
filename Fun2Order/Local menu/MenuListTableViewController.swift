//
//  MenuListTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/1/8.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
import Firebase

class MenuListTableViewController: UITableViewController {

    @IBOutlet weak var categorySegment: UISegmentedControl!
    
    var menuBrandCategory:[String] = [String]()
    var menuInfos:[MenuInformation] = [MenuInformation]()
    var menuInfosByCategory:[MenuInformation] = [MenuInformation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let favoriteCellViewNib: UINib = UINib(nibName: "FavoriteStoreCell", bundle: nil)
        self.tableView.register(favoriteCellViewNib, forCellReuseIdentifier: "FavoriteStoreCell")
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.receiveRefreshMenuList(_:)),
            name: NSNotification.Name(rawValue: "RefreshMenuList"),
            object: nil
        )

        print("MenuListTableViewController viewDidLoad downloadFBMenuInformation")
        downloadFBMenuInformation(select_index: 0)
   }

    func downloadFBMenuInformation(select_index: Int) {
        guard let user_id = Auth.auth().currentUser?.uid else {
            print("Not authorized user, cannot get Menu Information List")
            return
        }
        
        self.menuInfos.removeAll()
        
        let databaseRef = Database.database().reference()
        let pathString = "USER_MENU_INFORMATION/\(user_id)"
        
        databaseRef.child(pathString).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let rawData = snapshot.value
                let jsonData = try? JSONSerialization.data(withJSONObject: rawData as Any, options: [])
                //let jsonString = String(data: jsonData!, encoding: .utf8)!
                //print("jsonString = \(jsonString)")

                let decoder: JSONDecoder = JSONDecoder()
                do {
                    let listData = try decoder.decode([String:MenuInformation].self, from: jsonData!)
                    print("downloadFBMenuInformation jason decoded successful")
                    for keyValuePair in listData {
                        self.menuInfos.append(keyValuePair.value)
                    }
                    self.menuBrandCategory = retrieveMenuBrandCategory()
                    self.setupCategorySegment()
                    self.categorySegment.selectedSegmentIndex = select_index
                    self.filterMenuInfosByCategory()
                    self.tableView.reloadData()
                } catch {
                    print("jsonData decode failed: \(error.localizedDescription)")
                    return
                }
            } else {
                self.tableView.reloadData()
                print("queryMenuOrder snapshot doesn't exist!")
                return
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    @objc func receiveRefreshMenuList(_ notification: Notification) {
        print("MenuListTableViewController receiveRefreshMenuList downloadFBMenuInformation")
        downloadFBMenuInformation(select_index: 0)
    }
    
    func setupCategorySegment() {
        self.categorySegment.removeAllSegments()
        if self.menuBrandCategory.isEmpty {
            self.categorySegment.insertSegment(withTitle: "未分類", at: 0, animated: false)
            self.categorySegment.selectedSegmentIndex = 0
        } else {
            for i in 0...(self.menuBrandCategory.count - 1) {
                self.categorySegment.insertSegment(withTitle: self.menuBrandCategory[i], at: i, animated: false)
            }
            self.categorySegment.insertSegment(withTitle: "未分類", at: self.menuBrandCategory.count, animated: false)
            self.categorySegment.selectedSegmentIndex = 0
        }
    }
    
    func filterMenuInfosByCategory() {
        self.menuInfosByCategory.removeAll()
        if !self.menuInfos.isEmpty {
            var categoryString: String = ""
            if self.categorySegment.selectedSegmentIndex != self.menuBrandCategory.count {
                categoryString = self.menuBrandCategory[self.categorySegment.selectedSegmentIndex]
            }
            
            for i in 0...self.menuInfos.count - 1 {
                if self.menuInfos[i].brandCategory == categoryString {
                    self.menuInfosByCategory.append(self.menuInfos[i])
                }
            }
        }
    }
    
    func getMenuCountForCategory() -> Int {
        var returnCount: Int = 0
        
        if self.menuBrandCategory.isEmpty {
            return self.menuInfos.count
        } else {
            var categoryString: String = ""
            if self.categorySegment.selectedSegmentIndex != self.menuBrandCategory.count {
                categoryString = self.menuBrandCategory[self.categorySegment.selectedSegmentIndex]
            }

            for i in 0...self.menuInfos.count - 1 {
                if self.menuInfos[i].brandCategory == categoryString {
                    returnCount = returnCount + 1
                }
            }
        }
        
        print("getMenuCountForCategory returnCount = \(returnCount)")
        return returnCount
    }

    func deleteMenuInfo(index: IndexPath) {
        let selectedIndex = self.categorySegment.selectedSegmentIndex
        
        //deleteMenuInformation(menu_info: self.menuInfosByCategory[index.row])
        deleteMenuIcon(menu_number: self.menuInfosByCategory[index.row].menuNumber)
        deleteFBMenuInformation(user_id: self.menuInfosByCategory[index.row].userID, menu_number: self.menuInfosByCategory[index.row].menuNumber, image_url: self.menuInfosByCategory[index.row].menuImageURL)

        print("MenuListTableViewController deleteMenuInfo downloadFBMenuInformation")
        downloadFBMenuInformation(select_index: selectedIndex)
    }
    
    @IBAction func changeBrandCategory(_ sender: UISegmentedControl) {
        print("Selected Segment Index = \(self.categorySegment.selectedSegmentIndex)")
        filterMenuInfosByCategory()
        self.tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.menuInfos.isEmpty {
            return 0
        }
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.menuInfos.isEmpty {
            return 0
        }
        
        if self.menuInfosByCategory.isEmpty {
            return 0
        } else {
            return self.menuInfosByCategory.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteStoreCell", for: indexPath) as! FavoriteStoreCell
        
        let menuIcon = retrieveMenuIcon(menu_number: self.menuInfosByCategory[indexPath.row].menuNumber)
        cell.setData(brand_image: menuIcon,
                     title: self.menuInfosByCategory[indexPath.row].brandName,
                     sub_title: self.menuInfosByCategory[indexPath.row].menuDescription)

        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.delegate = self
        cell.indexPath = indexPath

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath) as! FavoriteStoreCell

        let dataIndex = cell.indexPath
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        guard let menuCreateController = storyBoard.instantiateViewController(withIdentifier: "CREATEMENU_VC") as? CreateMenuTableViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: CREATEMENU_VC can't find!! (QRCodeViewController)")
            return
        }
        menuCreateController.isEditedMode = true
        menuCreateController.menuInformation = menuInfosByCategory[dataIndex!.row]
        
        navigationController?.show(menuCreateController, sender: self)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        var alertWindow: UIWindow!
        if editingStyle == .delete {
            let controller = UIAlertController(title: "刪除菜單", message: "確定要刪除此菜單嗎？", preferredStyle: .alert)

            let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
                print("Confirm to delete this menu")
                self.deleteMenuInfo(index: indexPath)
                alertWindow.isHidden = true
            }
            
            controller.addAction(okAction)
            let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (_) in
                print("Cancel to delete the menu")
                alertWindow.isHidden = true
            }
            controller.addAction(cancelAction)
            alertWindow = presentAlert(controller)
        }
    }

}

extension MenuListTableViewController: DisplayGroupOrderDelegate {
    func didGroupButtonPressed(at index: IndexPath) {
        guard let groupOrderController = self.storyboard?.instantiateViewController(withIdentifier: "GroupOrder_VC") as? GroupOrderViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: QRCode_VC can't find!! (MenuListTableViewController)")
            return
        }
        groupOrderController.orderType = ORDER_TYPE_MENU
        groupOrderController.menuInformation = self.menuInfosByCategory[index.row]
        navigationController?.show(groupOrderController, sender: self)
    }
}
