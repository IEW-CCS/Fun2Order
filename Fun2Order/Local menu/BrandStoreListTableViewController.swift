//
//  BrandStoreListTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/8/20.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
import Firebase

class BrandStoreListTableViewController: UITableViewController {
    var brandBackgroundColor: UIColor!
    var brandTextTintColor: UIColor!
    var brandProfile: DetailBrandProfile = DetailBrandProfile()
    var storeList: [DetailStoreInformation] = [DetailStoreInformation]()
    var menuOrder: MenuOrder = MenuOrder()
    var detailMenuInfo: DetailMenuInformation = DetailMenuInformation()
    var selectedStoreInfo: DetailStoreInformation = DetailStoreInformation()
    var groupOrderFlag: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        print("BrandStoreListTableViewController viewDidLoad")
        
        //testUploadBrandStore()
        let friendNib: UINib = UINib(nibName: "BrandStoreCell", bundle: nil)
        self.tableView.register(friendNib, forCellReuseIdentifier: "BrandStoreCell")
        
        //self.tableView.backgroundColor = TEST_BACKGROUND_COLOR
        //print("brandBackgroundColor = \(String(describing: self.brandBackgroundColor))")
        self.tableView.backgroundColor = self.brandBackgroundColor
        
        //downloadFBBrandStoreList(brand_name: "上宇林", completion: receiveStoreList)
        downloadFBBrandStoreList(brand_name: self.brandProfile.brandName, completion: receiveStoreList)

    }

    override func viewWillAppear(_ animated: Bool) {
        self.title = "分店資訊及訂購"
        self.navigationController?.title = "分店資訊及訂購"
        self.tabBarController?.title = "分店資訊及訂購"
    }

    func receiveStoreList(items: [DetailStoreInformation]?) {
        if items == nil {
            print("No stores exist on the server, just return")
            return
        }
        
        self.storeList = items!.sorted(by: { $0.storeID < $1.storeID })
        self.tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.storeList.isEmpty {
            return 0
        } else {
            return self.storeList.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BrandStoreCell", for: indexPath) as! BrandStoreCell
        
        cell.setData(store_info: self.storeList[indexPath.row])
        //cell.backgroundColor = TEST_BACKGROUND_COLOR
        cell.backgroundColor = self.brandBackgroundColor
        cell.delegate = self
        cell.tag = indexPath.row

        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
}

extension BrandStoreListTableViewController: BrandStoreDelegate {
    func selectedStoreToOrder(sender: BrandStoreCell, index: Int) {
        print("Receive BrandStoreDelegate selectedStoreToOrder for index[\(index)]")
        self.selectedStoreInfo = self.storeList[index]
        downloadFBDetailMenuInformation(menu_number: self.storeList[index].storeMenuNumber, completion: { menu_info in
            if menu_info == nil {
                return
            }
            
            self.detailMenuInfo = menu_info!

            var storeContact: StoreContactInformation = StoreContactInformation()
            storeContact.storeName = self.selectedStoreInfo.storeName
            storeContact.storeAddress = self.selectedStoreInfo.storeAddress
            storeContact.storePhoneNumber = self.selectedStoreInfo.storePhoneNumber
            storeContact.facebookURL = self.selectedStoreInfo.storeFacebookURL
            storeContact.instagramURL = self.selectedStoreInfo.storeInstagramURL

            guard let deliveryController = self.storyboard?.instantiateViewController(withIdentifier: "DELIVERY_INFO_VC") as? DeliveryInformationTableViewController else {
                assertionFailure("[AssertionFailure] StoryBoard: DELIVERY_INFO_VC can't find!! (BrandStoreListTableViewController)")
                return
            }

            deliveryController.orderType = ORDER_TYPE_OFFICIAL_MENU
            deliveryController.brandName = self.detailMenuInfo.brandName
            deliveryController.storeName = self.selectedStoreInfo.storeName
            deliveryController.detailMenuInformation = self.detailMenuInfo
            deliveryController.storeInfo = storeContact
            deliveryController.brandBackgroundColor = self.brandBackgroundColor
            deliveryController.brandTextTintColor = self.brandTextTintColor

            let controller = UIAlertController(title: "選擇訂購方式", message: nil, preferredStyle: .alert)
            
            let groupAction = UIAlertAction(title: "揪團訂購", style: .default) { (_) in
                print("Create GroupOrder for friends")
                self.groupOrderFlag = true
                
                deliveryController.groupOrderFlag = self.groupOrderFlag
                self.navigationController?.show(deliveryController, sender: self)
            }
            
            groupAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
            controller.addAction(groupAction)
            
            let singleAction = UIAlertAction(title: "自己訂購", style: .default) { (_) in
                print("Create GroupOrder for myself")
                self.groupOrderFlag = false
                
                deliveryController.groupOrderFlag = self.groupOrderFlag
                self.navigationController?.show(deliveryController, sender: self)
            }

            singleAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
            controller.addAction(singleAction)
            
            let cancelAction = UIAlertAction(title: "取消", style: .default) { (_) in
               print("Cancel update")
            }
            
            cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
            controller.addAction(cancelAction)
            
            self.present(controller, animated: true, completion: nil)
        })
    }
    
    func displayStoreMap(sender: BrandStoreCell, index: Int) {
        print("Receive BrandStoreDelegate displayStoreMap for index[\(index)]")
        guard let storeMapController = self.storyboard?.instantiateViewController(withIdentifier: "BRAND_MAP_VC") as? BrandStoreMapTableViewController else {
            assertionFailure("[AssertionFailure] StoryBoard: BRAND_MAP_VC can't find!! (BrandStoreMapTableViewController)")
            return
        }
        
        storeMapController.storeInfo = self.storeList[index]
        storeMapController.brandBackgroundColor = self.brandBackgroundColor
        storeMapController.brandTextTintColor = self.brandTextTintColor
        self.navigationController?.show(storeMapController, sender: self)
    }
    
    func dialPhoneNumber(sender: BrandStoreCell, index: Int) {
        print("Receive BrandStoreDelegate dialPhoneNumber for index[\(index)]")
        print("The Store's phone number is [\(String(describing: self.storeList[index].storePhoneNumber))]")
        if self.storeList[index].storePhoneNumber == nil {
            print("Store Phone Number is nil")
            return
        }
                    
        guard let url = URL(string: "tel://\(self.storeList[index].storePhoneNumber!)") else {
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
