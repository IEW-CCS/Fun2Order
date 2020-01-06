//
//  FavoriteTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/13.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class FavoriteTableViewController: UITableViewController {
    var favoriteStoreArray = [FavoriteStoreInfo]()
    var isSelectStoreCellOpened: Bool = false
    var brandProfileList =  [BrandProfile]()
    var brandTitle = String()
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!

    @IBOutlet weak var menuBarItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.title = self.title

        vc = app.persistentContainer.viewContext

        let cellViewNib: UINib = UINib(nibName: "SelectStoreCell", bundle: nil)
        self.tableView.register(cellViewNib, forCellReuseIdentifier: "SelectStoreCell")

        let favoriteCellViewNib: UINib = UINib(nibName: "FavoriteStoreCell", bundle: nil)
        self.tableView.register(favoriteCellViewNib, forCellReuseIdentifier: "FavoriteStoreCell")
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.receiveBrandInfo(_:)),
            name: NSNotification.Name(rawValue: "BrandInfo"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.addToFavorite(_:)),
            name: NSNotification.Name(rawValue: "AddToFavorite"),
            object: nil
        )

        getDefaultBrandData()
        self.favoriteStoreArray = retrieveFavoriteStore()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "選擇我的最愛"
        self.navigationController?.title = "選擇我的最愛"
        self.tabBarController?.title = "選擇我的最愛"
    }
    
    func getDefaultBrandData() {
        let selectedBrandID = getSelectedBrandID()
        if selectedBrandID == 0 {
            return
        }
        
        let brand_data = retrieveBrandProfile(brand_id: selectedBrandID)
        if brand_data == nil {
            return
        }
        
        self.brandTitle = brand_data!.brandName!
        self.tabBarController?.title = self.brandTitle
    }
    
    @objc func receiveBrandInfo(_ notification: Notification) {
        if let brandIndex = notification.object as? Int {
            let brand_data = retrieveBrandProfile(brand_id: brandIndex)
            if brand_data == nil {
                return
            }

            self.brandTitle = brand_data!.brandName!
            print("FavoriteTableViewController received brand name: \(self.brandTitle)")
            //self.tabBarController?.title = self.brandTitle
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }
    
    @objc func addToFavorite(_ notification: Notification) {
        if let storeInfo = notification.object as? FavoriteStoreInfo {
            print("FavoriteTableViewController received store name: \(storeInfo.storeName)")
            print("FavoriteTableViewController received store addr: \(storeInfo.storeDescription)")
            insertFavoriteStore(info: storeInfo)
            self.favoriteStoreArray.append(storeInfo)
            print("self.favoriteStoreArray.count = \(self.favoriteStoreArray.count)")
            let indexPath = IndexPath(row: self.favoriteStoreArray.count - 1 , section: 1)
            self.tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if self.isSelectStoreCellOpened {
                return 1
            } else {
                return 0
            }
        } else {
            if self.favoriteStoreArray.isEmpty {
                return 0
            }
        
            return self.favoriteStoreArray.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectStoreCell", for: indexPath) as! SelectStoreCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteStoreCell", for: indexPath) as! FavoriteStoreCell
        cell.setData(brand_image: self.favoriteStoreArray[indexPath.row].storeBrandImage,
                     title: self.favoriteStoreArray[indexPath.row].storeName,
                     sub_title: self.favoriteStoreArray[indexPath.row].storeDescription)

        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.delegate = self
        cell.indexPath = indexPath

        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        }
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if editingStyle == .delete {
                if deleteFavoriteStore(brand_id: self.favoriteStoreArray[indexPath.row].brandID, store_id: self.favoriteStoreArray[indexPath.row].storeID) {
                    self.favoriteStoreArray.remove(at: indexPath.row )
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        } else {
            return
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let sectionView = UIView(frame: CGRect(x: 5, y: 0, width: tableView.frame.width - 10, height: 44))
            sectionView.layer.borderWidth = 1
            sectionView.layer.borderColor = UIColor.darkGray.cgColor
            sectionView.backgroundColor = UIColor(red: 179/255, green: 229/255, blue: 252/255, alpha: 1.0)
            //let sectionTitle = UILabel(frame: sectionView.layer.frame)
            let sectionTitle = UILabel(frame: CGRect(x: 5, y: 0, width: tableView.frame.width - 10, height: 44))
            
            sectionTitle.text = "選擇 \(self.brandTitle) 最愛店家"
            sectionTitle.textAlignment = .center
            sectionView.addSubview(sectionTitle)
            
            let tapGestureRecognizer = UITapGestureRecognizer(
                target: self,
                action: #selector(self.headerTapped(_:))
            )
            
            sectionView.addGestureRecognizer(tapGestureRecognizer)
            return sectionView
        }
        
        return tableView.headerView(forSection: section)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 230
        }
        
        return 100
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 0 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let product_vc = storyboard.instantiateViewController(withIdentifier: "ProductList_VC") as? ProductDetailTableViewController else{
                assertionFailure("[AssertionFailure] StoryBoard: ProductList_VC can't find!! (ViewController)")
                return
            }

            product_vc.favoriteStoreInfo = self.favoriteStoreArray[indexPath.row]
            product_vc.orderType = ORDER_TYPE_SINGLE
            show(product_vc, sender: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 0
        } else {
            return 44
        }
    }

    @objc func headerTapped(_ sender: UITapGestureRecognizer?) {
        print("Section Header tapped")
        if self.isSelectStoreCellOpened {
            self.isSelectStoreCellOpened = false
            let sections = IndexSet.init(integer: 0)
            tableView.reloadSections(sections, with: .fade)
        } else {
            self.isSelectStoreCellOpened = true
            let sections = IndexSet.init(integer: 0)
            tableView.reloadSections(sections, with: .fade)
        }
    }
    
}

extension FavoriteTableViewController: DisplayGroupOrderDelegate {
    func didGroupButtonPressed(at index: IndexPath) {
        guard let groupOrderController = self.storyboard?.instantiateViewController(withIdentifier: "GroupOrder_VC") as? GroupOrderViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: QRCode_VC can't find!! (QRCodeViewController)")
            return
        }
        
        //groupOrderController.modalTransitionStyle = .crossDissolve
        //groupOrderController.modalPresentationStyle = .overFullScreen
        groupOrderController.favoriteStoreInfo = self.favoriteStoreArray[index.row]
        navigationController?.show(groupOrderController, sender: self)
    }
}
