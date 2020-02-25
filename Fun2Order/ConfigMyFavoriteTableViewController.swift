//
//  ConfigMyFavoriteTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/12/17.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit
import CoreData

class ConfigMyFavoriteTableViewController: UITableViewController {
    @IBOutlet weak var favoriteSegment: UISegmentedControl!
    
    var favoriteStoreArray = [FavoriteStoreInfo]()
    var favoriteAddress: [FavoriteAddress] = [FavoriteAddress]()
    var selectedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.favoriteSegment.selectedSegmentIndex = self.selectedIndex
        self.favoriteStoreArray = retrieveFavoriteStore()
        self.favoriteAddress = retrieveFavoriteAddress()
        
        let storeNib: UINib = UINib(nibName: "ConfigFavoriteStoreCell", bundle: nil)
        self.tableView.register(storeNib, forCellReuseIdentifier: "ConfigFavoriteStoreCell")

        let productNib: UINib = UINib(nibName: "ConfigFavoriteProductCell", bundle: nil)
        self.tableView.register(productNib, forCellReuseIdentifier: "ConfigFavoriteProductCell")

        let addressNib: UINib = UINib(nibName: "ConfigFavoriteAddressCell", bundle: nil)
        self.tableView.register(addressNib, forCellReuseIdentifier: "ConfigFavoriteAddressCell")
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.deleteMyFavoriteStore(_:)),
            name: NSNotification.Name(rawValue: "ConfigDeleteStore"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.deleteMyFavoriteAddress(_:)),
            name: NSNotification.Name(rawValue: "ConfigDeleteAddress"),
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        self.favoriteStoreArray = retrieveFavoriteStore()
        self.favoriteAddress = retrieveFavoriteAddress()
        self.tableView.reloadData()
    }
    
    @IBAction func changeFavoriteCategory(_ sender: UISegmentedControl) {
        self.selectedIndex = sender.selectedSegmentIndex
        self.tableView.reloadData()
    }

    @objc func deleteMyFavoriteStore(_ notification: Notification) {
        print("ConfigMyFavoriteTableViewController receive ConfigDeleteStore notification")
        if let row_index = notification.object as? IndexPath {
            if deleteStoreFavoriteProduct(brand_id: self.favoriteStoreArray[row_index.row].brandID, store_id: self.favoriteStoreArray[row_index.row].storeID) {
                if deleteFavoriteStore(brand_id: self.favoriteStoreArray[row_index.row].brandID, store_id: self.favoriteStoreArray[row_index.row].storeID) {
                    self.favoriteStoreArray.remove(at: row_index.row)
                    self.tableView.deleteRows(at: [row_index], with: .fade)
                    self.tableView.reloadData()

                    //Add message to inform user that action is successful
                    let messageString: String = "已成功刪除我的最愛店家"
                    let alertMessage = UIAlertController(title: messageString, message: nil, preferredStyle: .alert)
                    self.present(alertMessage, animated: true, completion: nil)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                        self.presentedViewController?.dismiss(animated: true, completion: nil)
                        self.navigationController?.popViewController(animated: true)
                        self.dismiss(animated: false, completion: nil)
                    }

                }
            }
        }
    }

    @objc func deleteMyFavoriteAddress(_ notification: Notification) {
        print("ConfigMyFavoriteTableViewController receive ConfigDeleteAddress notification")
        if let row_index = notification.object as? IndexPath {
            deleteFavoriteAddress(favorite_address: self.favoriteAddress[row_index.row].favoriteAddress)
            self.favoriteAddress.remove(at: row_index.row)
            self.tableView.deleteRows(at: [row_index], with: .fade)
            self.tableView.reloadData()
            
            //Add message to inform user that action is successful
            let messageString: String = "已成功刪除我的最愛外送地址"
            let alertMessage = UIAlertController(title: messageString, message: nil, preferredStyle: .alert)
            self.present(alertMessage, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                self.presentedViewController?.dismiss(animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.selectedIndex == 0 {
            if self.favoriteStoreArray.isEmpty {
                return 0
            } else {
                return self.favoriteStoreArray.count
            }
        } else if self.selectedIndex == 1 {
            if self.favoriteAddress.isEmpty {
                return 0
            } else {
                return self.favoriteAddress.count
            }
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.selectedIndex == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ConfigFavoriteStoreCell", for: indexPath) as! ConfigFavoriteStoreCell
            
            cell.setData(brand_image: self.favoriteStoreArray[indexPath.row].storeBrandImage, title: self.favoriteStoreArray[indexPath.row].storeName, sub_title: self.favoriteStoreArray[indexPath.row].storeDescription)
            let index = IndexPath(row: indexPath.row, section: indexPath.section)
            cell.setIndex(index: index)
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConfigFavoriteAddressCell", for: indexPath) as! ConfigFavoriteAddressCell
        
        cell.setData(address: self.favoriteAddress[indexPath.row].favoriteAddress)
        let index = IndexPath(row: indexPath.row, section: indexPath.section)
        cell.setIndex(index: index)
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.selectedIndex == 0 {
            return 100
        }
        
        return 60
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let product_vc = storyboard.instantiateViewController(withIdentifier: "CONFIG_FAVORITE_PRODUCT_VC") as? ConfigFavoriteProductTableViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: CONFIG_FAVORITE_PRODUCT_VC can't find!! (ViewController)")
            return
        }

        product_vc.brandID = self.favoriteStoreArray[indexPath.row].brandID
        product_vc.storeID = self.favoriteStoreArray[indexPath.row].storeID
        navigationController?.show(product_vc, sender: self)
    }
}
