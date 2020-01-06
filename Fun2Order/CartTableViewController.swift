//
//  CartTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/21.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit
import CoreData

class CartTableViewController: UITableViewController {
    var orderList: [OrderInformation] = [OrderInformation]()
    var productRecipePriceList: ProductRecipePriceList!
    var editStoreProductRecipe: StoreProductRecipe = StoreProductRecipe()
    var editOrderInformation: OrderInformation = OrderInformation()

    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()

        vc = app.persistentContainer.viewContext

        let cartGroupCellViewNib: UINib = UINib(nibName: "CartOrderCell", bundle: nil)
        self.tableView.register(cartGroupCellViewNib, forCellReuseIdentifier: "CartOrderCell")

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.payByApplePay(_:)),
            name: NSNotification.Name(rawValue: "PayByApplePay"),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.payByGooglePay(_:)),
            name: NSNotification.Name(rawValue: "PayByGooglePay"),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.payByLinePay(_:)),
            name: NSNotification.Name(rawValue: "PayByLinePay"),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.payByCash(_:)),
            name: NSNotification.Name(rawValue: "PayByCash"),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.editDeleteOrderProduct(_:)),
            name: NSNotification.Name(rawValue: "EditDeleteOrderProduct"),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.editProductRecipe(_:)),
            name: NSNotification.Name(rawValue: "EditProductRecipe"),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.addProductRecipe(_:)),
            name: NSNotification.Name(rawValue: "AddProductRecipe"),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.refreshCart(_:)),
            name: NSNotification.Name(rawValue: "RefreshCartOrder"),
            object: nil
        )

        retrieveOrderList()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.title = "我的訂單"
        self.tabBarController?.title = "我的訂單"
        self.navigationController?.title = "我的訂單"
    }
    
    func retrieveOrderList() {
        self.orderList.removeAll()
        
        let fetchOrder: NSFetchRequest<ORDER_INFORMATION> = ORDER_INFORMATION.fetchRequest()
        let pOrderString = "orderStatus == \"\(ORDER_STATUS_INIT)\""
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
    
    func prepareStoreProductRecipe(order_info: OrderInformation) -> StoreProductRecipe? {
        let fetchRequest: NSFetchRequest<PRODUCT_RECIPE> = PRODUCT_RECIPE.fetchRequest()
        let predicateString = "brandID == \(order_info.brandID) AND storeID == \(order_info.storeID) AND productID == \(order_info.contentList[0].productID)"
        print("prepareStoreProductRecipe predicateString = \(predicateString)")
        let predicate = NSPredicate(format: predicateString)
        fetchRequest.predicate = predicate

        do {
            let productRecipe_data = try vc.fetch(fetchRequest).first
            if productRecipe_data == nil {
                return nil
            } else {
                let fetchProductRequest: NSFetchRequest<PRODUCT_INFORMATION> = PRODUCT_INFORMATION.fetchRequest()
                let pProductString = "brandID == \(order_info.brandID) AND productID == \(order_info.contentList[0].productID)"
                print("prepareStoreProductRecipe pProductString = \(pProductString)")
                let predicate2 = NSPredicate(format: pProductString)
                fetchProductRequest.predicate = predicate2
                
                do {
                    let product_data = try vc.fetch(fetchProductRequest).first
                    var tmpProduct = StoreProductRecipe()
                    tmpProduct.brandID = Int(productRecipe_data!.brandID)
                    tmpProduct.storeID = Int(productRecipe_data!.storeID)
                    tmpProduct.productID = Int(productRecipe_data!.productID)
                    tmpProduct.favorite = false
                    tmpProduct.recipe.append(productRecipe_data!.recipe1)
                    tmpProduct.recipe.append(productRecipe_data!.recipe2)
                    tmpProduct.recipe.append(productRecipe_data!.recipe3)
                    tmpProduct.recipe.append(productRecipe_data!.recipe4)
                    tmpProduct.recipe.append(productRecipe_data!.recipe5)
                    tmpProduct.recipe.append(productRecipe_data!.recipe6)
                    tmpProduct.recipe.append(productRecipe_data!.recipe7)
                    tmpProduct.recipe.append(productRecipe_data!.recipe8)
                    tmpProduct.recipe.append(productRecipe_data!.recipe9)
                    tmpProduct.recipe.append(productRecipe_data!.recipe10)
                    tmpProduct.brandName = order_info.brandName
                    tmpProduct.storeName = order_info.storeName
                    tmpProduct.productCategory = product_data!.productCategory!
                    tmpProduct.productName = product_data!.productName!
                    tmpProduct.productDescription = product_data!.productDescription!
                    tmpProduct.productImage = UIImage(data: product_data!.productImage!)!
                    tmpProduct.recommand = product_data!.recommand!
                    tmpProduct.popularity = product_data!.popularity!
                    tmpProduct.limit = product_data!.limit!
                    
                    return tmpProduct
                } catch {
                    print(error.localizedDescription)
                    return nil
                }
            }
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func requestPriceList(brand_id: Int, store_id: Int) {
        let sessionConf = URLSessionConfiguration.default
        sessionConf.timeoutIntervalForRequest = HTTP_REQUEST_TIMEOUT
        sessionConf.timeoutIntervalForResource = HTTP_REQUEST_TIMEOUT
        let sessionHttp = URLSession(configuration: sessionConf)

        let uriString = "PRODUCT_RECIPE_PRICE/\(brand_id)/\(store_id)"
        print("requestProductRecipePrice -> uriString = \(uriString)")
        
        let temp = getFirebaseUrlForRequest(uri: uriString)
        let urlString = temp.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let urlRequest = URLRequest(url: URL(string: urlString)!)

        print("requestProductRecipePrice")
        let task = sessionHttp.dataTask(with: urlRequest) {(data, response, error) in
            do {
                if error != nil{
                    let httpAlert = alert(message: error!.localizedDescription, title: "Http Error")
                    self.present(httpAlert, animated : false, completion : nil)
                } else {
                    guard let httpResponse = response as? HTTPURLResponse,
                        (200...299).contains(httpResponse.statusCode) else {
                            let errorResponse = response as? HTTPURLResponse
                            let message: String = String(errorResponse!.statusCode) + " - " + HTTPURLResponse.localizedString(forStatusCode: errorResponse!.statusCode)
                            let httpAlert = alert(message: message, title: "Http Error")
                            self.present(httpAlert, animated : false, completion : nil)
                            return
                    }
                    
                    let outputStr  = String(data: data!, encoding: String.Encoding.utf8) as String?
                    let jsonData = outputStr!.data(using: String.Encoding.utf8, allowLossyConversion: true)
                    let decoder = JSONDecoder()
                    self.productRecipePriceList = try decoder.decode(ProductRecipePriceList.self, from: jsonData!)
                    print("requestProductRecipePrice finished!")
                    DispatchQueue.main.async {
                        self.displayRecipeViewController()
                    }
                }
            } catch {
                print(error.localizedDescription)
                let httpAlert = alert(message: error.localizedDescription, title: "Request Product Recipe Price Error")
                self.present(httpAlert, animated : false, completion : nil)
                return
            }
        }
        task.resume()
        
        return
    }

    func displayRecipeViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let recipe_vc = storyboard.instantiateViewController(withIdentifier: "Recipe_VC") as? RecipeTableViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: Recipe_VC can't find!! (ViewController)")
            return
        }
        
        var tmpPriceList = [ProductRecipePrice]()
        
        for i in 0...self.productRecipePriceList.PRODUCT_RECIPE_PRICE.count - 1 {
            if self.productRecipePriceList.PRODUCT_RECIPE_PRICE[i].productID == self.editOrderInformation.contentList[0].productID {
                tmpPriceList.append(self.productRecipePriceList.PRODUCT_RECIPE_PRICE[i])
            }
        }
        
        recipe_vc.storeProductRecipe = self.editStoreProductRecipe
        recipe_vc.priceListArray = tmpPriceList
        recipe_vc.oType = self.editOrderInformation.orderType
        recipe_vc.isEditFlag = true
        recipe_vc.editOrderInfo = self.editOrderInformation
        self.navigationController?.pushViewController(recipe_vc, animated: true)
        //navigationController?.show(recipe_vc, sender: self)
        //show(recipe_vc, sender: self)
    }
    
    @objc func payByApplePay(_ notification: Notification) {
        let alertController = UIAlertController(title: "Pay", message: "Pay by ApplePay", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated : false, completion : nil)
    }

    @objc func payByGooglePay(_ notification: Notification) {
        let alertController = UIAlertController(title: "Pay", message: "Pay by GooglePay", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated : false, completion : nil)
    }

    @objc func payByLinePay(_ notification: Notification) {
        let alertController = UIAlertController(title: "Pay", message: "Pay by LinePay", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated : false, completion : nil)
    }

    @objc func payByCash(_ notification: Notification) {
        let alertController = UIAlertController(title: "Pay", message: "Pay by Cash", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated : false, completion : nil)
    }

    @objc func editProductRecipe(_ notification: Notification) {
        print("CartTableViewController receive EditProductRecipe notification")
        if let order_info = notification.object as? OrderInformation {
            //print("order_info = \(order_info)")
            let storeProductRecipe = prepareStoreProductRecipe(order_info: order_info)
            
            if storeProductRecipe == nil {
                print("CartTableViewController editProductRecipe -> storeProductRecipe is nil")
                return
            }

            self.editStoreProductRecipe = storeProductRecipe!
            self.editOrderInformation = order_info
            
            requestPriceList(brand_id: order_info.brandID, store_id: order_info.storeID)
        }
    }

    @objc func addProductRecipe(_ notification: Notification) {
        print("CartTableViewController receive AddProductRecipe notification")
        if let store_info = notification.object as? FavoriteStoreInfo {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let product_vc = storyboard.instantiateViewController(withIdentifier: "ProductList_VC") as? ProductDetailTableViewController else{
                assertionFailure("[AssertionFailure] StoryBoard: ProductList_VC can't find!! (ViewController)")
                return
            }

            product_vc.favoriteStoreInfo = store_info
            product_vc.orderType = ORDER_TYPE_GROUP
            show(product_vc, sender: self)
        }
    }

    @objc func refreshCart(_ notification: Notification) {
        print("CartTableViewController receive RefreshCartOrder notification")
        retrieveOrderList()
        self.tableView.reloadData()
    }

    @objc func editDeleteOrderProduct(_ notification: Notification) {
        print("CartTableViewController receive EditDeleteOrderProduct notification")
        self.orderList.removeAll()
        retrieveOrderList()
        self.tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.orderList.count > 0 {
            return self.orderList.count
        }
        
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartOrderCell", for: indexPath) as! CartOrderCell
        cell.setData(order_info: self.orderList[indexPath.row])
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 600
    }
}
