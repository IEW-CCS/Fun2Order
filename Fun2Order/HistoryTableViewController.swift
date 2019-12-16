//
//  HistoryTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/22.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit
import CoreData

class HistoryTableViewController: UITableViewController {

    var orderList: [OrderInformation] = [OrderInformation]()
    
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()
        let historyCellViewNib: UINib = UINib(nibName: "OrderHistoryCell", bundle: nil)
        self.tableView.register(historyCellViewNib, forCellReuseIdentifier: "OrderHistoryCell")

        vc = app.persistentContainer.viewContext

        retrieveHistoryOrderList()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.title = "訂單歷史紀錄"
        self.navigationController?.title = "訂單歷史紀錄"
        self.tabBarController?.title = "訂單歷史紀錄"
    }

    func retrieveHistoryOrderList() {
        self.orderList.removeAll()
        
        let fetchOrder: NSFetchRequest<ORDER_INFORMATION> = ORDER_INFORMATION.fetchRequest()
        let pOrderString = "orderStatus != \"\(ORDER_STATUS_INIT)\""
        print("retrieveOrderList pOrderString = \(pOrderString)")
        let predicate1 = NSPredicate(format: pOrderString)
        fetchOrder.predicate = predicate1
        let sort = NSSortDescriptor(key: "orderCreateTime", ascending: true)
        fetchOrder.sortDescriptors = [sort]

        do {
            let order_list = try vc.fetch(fetchOrder)
            for order_data in order_list {
                var tmpOrderInfo: OrderInformation = OrderInformation()
                tmpOrderInfo.orderNumber = order_data.orderNumber!
                tmpOrderInfo.orderType = order_data.orderType!
                tmpOrderInfo.orderStatus = order_data.orderStatus!
                tmpOrderInfo.deliveryType = order_data.deliveryType ?? ""
                tmpOrderInfo.deliveryAddress = order_data.deliveryAddress ?? ""
                tmpOrderInfo.orderImage = UIImage(data: order_data.orderImage!)!
                tmpOrderInfo.orderCreateTime = order_data.orderCreateTime!
                tmpOrderInfo.orderOwner = order_data.orderOwner ?? ""
                tmpOrderInfo.orderTotalQuantity = Int(order_data.orderTotalQuantity)
                tmpOrderInfo.orderTotalPrice = Int(order_data.orderTotalPrice)
                tmpOrderInfo.brandID = Int(order_data.brandID)
                tmpOrderInfo.brandName = order_data.brandName!
                tmpOrderInfo.storeID = Int(order_data.storeID)
                tmpOrderInfo.storeName = order_data.storeName!
                
                let fetchProductItem: NSFetchRequest<ORDER_CONTENT_ITEM> = ORDER_CONTENT_ITEM.fetchRequest()
                let pProductString = "orderNumber == \"\(order_data.orderNumber!)\""
                print("retrieveOrderList pProductString = \(pProductString)")
                let predicate2 = NSPredicate(format: pProductString)
                fetchProductItem.predicate = predicate2
                let sort = NSSortDescriptor(key: "itemCreateTime", ascending: true)
                fetchProductItem.sortDescriptors = [sort]

                do {
                    let product_list = try vc.fetch(fetchProductItem)
                    for product_data in product_list {
                        var tmpProductItem: OrderContentItem = OrderContentItem()
                        tmpProductItem.orderNumber = product_data.orderNumber!
                        tmpProductItem.itemNumber = Int(product_data.itemNumber)
                        tmpProductItem.productID = Int(product_data.productID)
                        tmpProductItem.productName = product_data.productName!
                        //tmpProductItem.itemOwnerName = product_data.itemOwnerName!
                        //tmpProductItem.itemOwnerImage = UIImage(data: product_data.itemOwnerImage!)!
                        tmpProductItem.itemCreateTime = product_data.itemCreateTime!
                        tmpProductItem.itemQuantity = Int(product_data.itemQuantity)
                        tmpProductItem.itemSinglePrice = Int(product_data.itemSinglePrice)
                        tmpProductItem.itemFinalPrice = Int(product_data.itemFinalPrice)
                        tmpProductItem.itemComments = product_data.itemComments!

                        let fetchRecipeItem: NSFetchRequest<ORDER_PRODUCT_RECIPE> = ORDER_PRODUCT_RECIPE.fetchRequest()
                        let pRecipeString = "orderNumber == \"\(product_data.orderNumber!)\" AND itemNumber == \(Int(product_data.itemNumber)) AND productID == \(Int(product_data.productID))"
                        print("retrieveOrderList pRecipeString = \(pRecipeString)")
                        let predicate3 = NSPredicate(format: pRecipeString)
                        fetchRecipeItem.predicate = predicate3

                        do {
                            let recipe_list = try vc.fetch(fetchRecipeItem)
                            for recipe_data in recipe_list {
                                var tmpRecipeItem: OrderProductRecipe = OrderProductRecipe()
                                tmpRecipeItem.orderNumber = recipe_data.orderNumber!
                                tmpRecipeItem.itemNumber = Int(recipe_data.itemNumber)
                                tmpRecipeItem.productID = Int(recipe_data.productID)
                                tmpRecipeItem.recipeCode = recipe_data.recipeCode!
                                tmpRecipeItem.recipeSubCode = recipe_data.recipeSubCode!
                                tmpProductItem.itemRecipe.append(tmpRecipeItem)
                            }
                        } catch {
                            print(error.localizedDescription)
                        }
                        tmpOrderInfo.contentList.append(tmpProductItem)
                    }
                } catch {
                    print(error.localizedDescription)
                }
                self.orderList.append(tmpOrderInfo)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.orderList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderHistoryCell", for: indexPath) as! OrderHistoryCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.setData(order_info: self.orderList[indexPath.row])
        
        cell.delegate = self
        cell.indexPath = indexPath
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 270
    }

}

extension HistoryTableViewController: DisplayQRCodeDelegate {
    func didQRCodeButtonPressed(at index: IndexPath) {
        guard let qrCodeController = self.storyboard?.instantiateViewController(withIdentifier: "QRCode_VC") as? QRCodeViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: QRCode_VC can't find!! (QRCodeViewController)")
            return
        }
        
        qrCodeController.setQRCodeText(code: self.orderList[index.row].orderNumber)
        qrCodeController.modalTransitionStyle = .crossDissolve
        qrCodeController.modalPresentationStyle = .overFullScreen
        navigationController?.present(qrCodeController, animated: true, completion: nil)
    }
}
