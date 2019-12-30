//
//  ConfigFavoriteProductTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/12/24.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit
import CoreData

class ConfigFavoriteProductTableViewController: UITableViewController {
    var favoriteProducts = [FavoriteProduct]()
    var brandID: Int = 0
    var storeID: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        let storeNib: UINib = UINib(nibName: "ConfigFavoriteProductCell", bundle: nil)
        self.tableView.register(storeNib, forCellReuseIdentifier: "ConfigFavoriteProductCell")

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.favoriteProducts = retrieveFavoriteProductID(brand_id: self.brandID, store_id: self.storeID)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.deleteMyFavoriteProduct(_:)),
            name: NSNotification.Name(rawValue: "ConfigDeleteProduct"),
            object: nil
        )
        
    }
    
    @objc func deleteMyFavoriteProduct(_ notification: Notification) {
        print("ConfigFavoriteProductTableViewController receive ConfigDeleteProduct notification")
        if let row_index = notification.object as? IndexPath {
            if deleteSingleFavoriteProduct(brand_id: favoriteProducts[row_index.row].brandID, store_id: favoriteProducts[row_index.row].storeID, product_id: favoriteProducts[row_index.row].productID) {
 
                self.favoriteProducts = retrieveFavoriteProductID(brand_id: self.brandID, store_id: self.storeID)
                self.tableView.deleteRows(at: [row_index], with: .fade)
                self.tableView.reloadData()

                //Add message to inform user that action is successful
                let messageString: String = "已成功刪除我的最愛產品"
                let alertMessage = UIAlertController(title: messageString, message: nil, preferredStyle: .alert)
                self.present(alertMessage, animated: true, completion: nil)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                    self.presentedViewController?.dismiss(animated: true, completion: nil)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if self.favoriteProducts.isEmpty {
            return 0
        } else {
            return self.favoriteProducts.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConfigFavoriteProductCell", for: indexPath) as! ConfigFavoriteProductCell
        
        let favoriteProductDetail = retrieveFavoriteProductDetail(brand_id: self.favoriteProducts[indexPath.row].brandID, store_id: self.favoriteProducts[indexPath.row].storeID, product_id: self.favoriteProducts[indexPath.row].productID)
        
        cell.setData(product_image: favoriteProductDetail.productImage, title: favoriteProductDetail.productName, sub_title: favoriteProductDetail.productRecipeString)
        
        let index = IndexPath(row: indexPath.row, section: indexPath.section)
        cell.setIndex(index: index)
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
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
