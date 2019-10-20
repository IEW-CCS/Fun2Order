//
//  FavoriteTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/13.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class FavoriteTableViewController: UITableViewController {
    let brandTitles: [String] = ["上宇林", "丸作", "五十嵐", "公館手作", "迷克夏", "自在軒", "柚豆", "紅太陽", "茶湯會", "圓石", "Teas原味"]

    var favoriteStoreArray = [FavoriteStoreInfo]()
    var isSelectStoreCellOpened: Bool = false

    @IBOutlet weak var menuBarItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.title = self.title

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

    }

    @objc func receiveBrandInfo(_ notification: Notification) {
        if let brandIndex = notification.object as? Int {
            print("FavoriteTableViewController received brand name: \(self.brandTitles[brandIndex])")
            self.tabBarController?.title = self.brandTitles[brandIndex]
        }
    }
    
    @objc func addToFavorite(_ notification: Notification) {
        if let storeInfo = notification.object as? FavoriteStoreInfo {
            print("FavoriteTableViewController received store name: \(storeInfo.storeName)")
            print("FavoriteTableViewController received store addr: \(storeInfo.storeAddressInfo)")
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
                     sub_title: self.favoriteStoreArray[indexPath.row].storeAddressInfo)

        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if editingStyle == .delete {
                self.favoriteStoreArray.remove(at: indexPath.row )
                tableView.deleteRows(at: [indexPath], with: .fade)
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
            sectionTitle.text = "Select Store"
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
            guard let vc = storyboard.instantiateViewController(withIdentifier: "ProductList_VC") as? ProductDetailTableViewController else{
                assertionFailure("[AssertionFailure] StoryBoard: pickerStoryboard can't find!! (ViewController)")
                return
            }
            show(vc, sender: self)
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
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
