//
//  RecipeTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/19.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit
import CoreData

class RecipeTableViewController: UITableViewController {
    var itemHeight = [Int]();
    var storeProductRecipe = StoreProductRecipe()
    var productRecipes = [ProductRecipeInformation]()
    var priceListArray = [ProductRecipePrice]()
    var editOrderInfo: OrderInformation = OrderInformation()
    var finalPrice: Int = 0
    var oType: String = "S"
    var isEditFlag: Bool = false
    
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        vc = app.persistentContainer.viewContext
        
        let detailCellViewNib: UINib = UINib(nibName: "RecipeCell", bundle: nil)
        self.tableView.register(detailCellViewNib, forCellReuseIdentifier: "RecipeCell")

        let commentsCellViewNib: UINib = UINib(nibName: "CommentsCell", bundle: nil)
        self.tableView.register(commentsCellViewNib, forCellReuseIdentifier: "CommentsCell")

        let quantityCellViewNib: UINib = UINib(nibName: "QuantityCell", bundle: nil)
        self.tableView.register(quantityCellViewNib, forCellReuseIdentifier: "QuantityCell")

        let basicButtonCellViewNib: UINib = UINib(nibName: "BasicButtonCell", bundle: nil)
        self.tableView.register(basicButtonCellViewNib, forCellReuseIdentifier: "BasicButtonCell")
        
        let countRecipe = getRecipeCount()
        itemHeight = Array(repeating: 0, count: countRecipe)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.receivePriceUpdate(_:)),
            name: NSNotification.Name(rawValue: "ProductPriceUpdate"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.receiveAddFavoriteProduct),
            name: NSNotification.Name(rawValue: "AddFavoriteProduct"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.receiveAddToCart),
            name: NSNotification.Name(rawValue: "AddToCart"),
            object: nil
        )

        //itemHeight = Array(repeating: 0, count: titleArray.count)
        print("self.storeProductRecipe.recipe.count = \(countRecipe)")
        retrieveProductRecipeCode()
        if self.isEditFlag {
            updateEditRecipeStatus()
            //self.finalPrice = getFinalPrice()
        }
        
        if self.storeProductRecipe.favorite {
            self.finalPrice = getFinalPrice()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.title = "\(self.storeProductRecipe.brandName)  \(self.storeProductRecipe.productName)"
    }
    
    func getRecipeCount() -> Int {
        var recipeCount: Int = 0
        for i in 0...self.storeProductRecipe.recipe.count - 1 {
            if self.storeProductRecipe.recipe[i] != "" {
                recipeCount = recipeCount + 1
            }
        }
        
        return recipeCount
    }
    
    func retrieveProductRecipeCode() {
        if self.storeProductRecipe.brandID == 0 || self.storeProductRecipe.storeID == 0 || self.storeProductRecipe.productID == 0 {
            print("RecepeTableViewController retrieveProductRecipe brandID or storeID or productID is 0")
            return
        }

        for i in 0...getRecipeCount() - 1 {
            var tmpfavoriteProdRcp = ProductRecipeInformation()
            tmpfavoriteProdRcp.brandID = self.storeProductRecipe.brandID
            tmpfavoriteProdRcp.storeID = self.storeProductRecipe.storeID
            tmpfavoriteProdRcp.productID = self.storeProductRecipe.productID
            tmpfavoriteProdRcp.recipeCategory = self.storeProductRecipe.recipe[i]!
            
            let fetchSortRequest: NSFetchRequest<CODE_TABLE> = CODE_TABLE.fetchRequest()
            let predicateString = "codeCategory == \"BRAND_\(tmpfavoriteProdRcp.recipeCategory)\" AND codeExtension == \"\(tmpfavoriteProdRcp.brandID)\""
            print("retrieveProductRecipeCode predicateString: \(predicateString)")
            let predicate = NSPredicate(format: predicateString)
            fetchSortRequest.predicate = predicate
            let sort = NSSortDescriptor(key: "index", ascending: true)
            fetchSortRequest.sortDescriptors = [sort]

            do {
                let tmpSubRecipe_list = try vc.fetch(fetchSortRequest)
                if tmpSubRecipe_list.count == 0 {
                    print("Get 0 count under the condition -> \(predicateString)")
                    continue
                }
                
                for tmpSubRecipe_data in tmpSubRecipe_list {
                    var tmpSub = [String]()
                    if tmpSubRecipe_data.extension1 != "" {
                        tmpSub.append(tmpSubRecipe_data.extension1!)
                    }
                    
                    if tmpSubRecipe_data.extension2 != "" {
                        tmpSub.append(tmpSubRecipe_data.extension2!)
                    }
                    
                    if tmpSubRecipe_data.extension3 != "" {
                        tmpSub.append(tmpSubRecipe_data.extension3!)
                    }
                    
                    if tmpSubRecipe_data.extension4 != "" {
                        tmpSub.append(tmpSubRecipe_data.extension4!)
                    }
                    
                    if tmpSubRecipe_data.extension5 != "" {
                        tmpSub.append(tmpSubRecipe_data.extension5!)
                    }
                
                    var tmpSubRecipeCategory = [RecipeSubCategory]()
                    var tmpSubRcp = RecipeSubCategory()
                    if tmpSub.isEmpty {
                        tmpSubRcp.recipeMainCategory = self.storeProductRecipe.recipe[i]!
                        tmpSubRcp.recipeSubCategory = self.storeProductRecipe.recipe[i]!
                        for sub_data in tmpSubRecipe_list {
                            var tmpItem = RecipeItem()
                            tmpItem.recipeName = sub_data.code!
                            tmpItem.checkedFlag = retrieveFavoriteProductRecipeFlag(recipe_code: tmpSubRcp.recipeSubCategory, recipe_subcode: sub_data.code!)
                            tmpSubRcp.recipeDetail.append(tmpItem)
                        }
                        tmpSubRecipeCategory.append(tmpSubRcp)
                        tmpfavoriteProdRcp.recipeSubCategoryDetail.append(tmpSubRecipeCategory)
                        break
                    }

                    for j in 0...tmpSub.count - 1 {
                        var tmpSubRcp = RecipeSubCategory()
                        let fetch2: NSFetchRequest<CODE_TABLE> = CODE_TABLE.fetchRequest()
                        let predicateString = "codeCategory == \"BRAND_\(tmpSub[j])\" AND codeExtension == \"\(tmpfavoriteProdRcp.brandID)\""
                        print("tmpSub predicateString = \(predicateString)")
                        let predicate = NSPredicate(format: predicateString)
                        fetch2.predicate = predicate
                        let sort = NSSortDescriptor(key: "index", ascending: true)
                        fetch2.sortDescriptors = [sort]
                        do {
                            let sub_list = try vc.fetch(fetch2)
                            if sub_list.count == 0 {
                                print("Get 0 count under the condition -> \(predicateString)")
                                continue
                            }
                            
                            tmpSubRcp.recipeMainCategory = tmpSubRecipe_data.code!
                            tmpSubRcp.recipeSubCategory = tmpSub[j]
                            for sub_data in sub_list {
                                var tmpItem = RecipeItem()
                                tmpItem.recipeName = sub_data.code!
                                tmpItem.checkedFlag = retrieveFavoriteProductRecipeFlag(recipe_code: tmpSubRcp.recipeSubCategory, recipe_subcode: sub_data.code!)
                                tmpSubRcp.recipeDetail.append(tmpItem)
                            }
                            
                            tmpSubRecipeCategory.append(tmpSubRcp)
                        } catch {
                            print(error.localizedDescription)
                        }
                    }

                    if tmpSubRecipeCategory.isEmpty {
                        print("RecipeTableViewController retrieveProductRecipeCode() -> tmpSubRecipeCategory count is 0")
                        continue
                    }
                    
                    tmpfavoriteProdRcp.recipeSubCategoryDetail.append(tmpSubRecipeCategory)
                }
            } catch {
                print(error.localizedDescription)
            }
            self.productRecipes.append(tmpfavoriteProdRcp)
        }
    }
    
    func updateEditRecipeStatus() {
        for i in 0...self.productRecipes.count - 1 {
            for j in 0...self.productRecipes[i].recipeSubCategoryDetail.count - 1 {
                for k in 0...self.productRecipes[i].recipeSubCategoryDetail[j].count - 1 {
                    for m in 0...self.productRecipes[i].recipeSubCategoryDetail[j][k].recipeDetail.count - 1 {
                        for index in 0...self.editOrderInfo.contentList[0].itemRecipe.count - 1 {
                            if self.editOrderInfo.contentList[0].itemRecipe[index].recipeSubCode == self.productRecipes[i].recipeSubCategoryDetail[j][k].recipeDetail[m].recipeName {
                                self.productRecipes[i].recipeSubCategoryDetail[j][k].recipeDetail[m].checkedFlag = true
                            }
                        }
                    }
                }
            }
        }
    }
    
    func deleteFavoriteRecipeItem(brand_id: Int, store_id: Int, product_id: Int) {
        let fetchRequest: NSFetchRequest<FAVORITE_PRODUCT_RECIPE> = FAVORITE_PRODUCT_RECIPE.fetchRequest()
        let predicateString = "brandID == \(brand_id) AND storeID == \(store_id) AND productID == \(product_id)"

        let predicate = NSPredicate(format: predicateString)
        fetchRequest.predicate = predicate
        
        do {
            let recipe_list = try vc.fetch(fetchRequest)
            for recipe_data in recipe_list {
                vc.delete(recipe_data)
            }
        } catch {
            print(error.localizedDescription)
        }

        app.saveContext()
    }
    
    func deleteOrderProductRecipeItem(order_number: String, item_number: Int, product_id: Int) {
        let fetchRequest: NSFetchRequest<ORDER_PRODUCT_RECIPE> = ORDER_PRODUCT_RECIPE.fetchRequest()
        let predicateString = "orderNumber == \"\(order_number)\" AND itemNumber == \(item_number) AND productID == \(product_id)"

        let predicate = NSPredicate(format: predicateString)
        fetchRequest.predicate = predicate
        
        do {
            let recipe_list = try vc.fetch(fetchRequest)
            for recipe_data in recipe_list {
                vc.delete(recipe_data)
            }
        } catch {
            print(error.localizedDescription)
        }

        app.saveContext()
    }
    
    @objc func receivePriceUpdate(_ notification: Notification) {
        if let productRecipeData = notification.object as? ProductRecipeInformation {
            self.productRecipes[productRecipeData.rowIndex] = productRecipeData
            let price = getFinalPrice()
            print("RecipeTableViewController -> Get the final price: \(price)")
            self.finalPrice = price
            
            let row_index = IndexPath(row: self.productRecipes.count + 1, section: 0)
            print("receivePriceUpdate -> row_index.row = \(row_index.row)")
            let cell = self.tableView.cellForRow(at: row_index) as! QuantityCell
            cell.setSinglePrice(price: self.finalPrice)
        }
    }
    
    @objc func receiveAddFavoriteProduct(_ notification: Notification) {
        print("Receive AddFavoriteProduct notification.")
        
        if deleteSingleFavoriteProduct(brand_id: self.storeProductRecipe.brandID, store_id: self.storeProductRecipe.storeID, product_id: self.storeProductRecipe.productID) {
            deleteFavoriteRecipeItem(brand_id: self.storeProductRecipe.brandID, store_id: self.storeProductRecipe.storeID, product_id: self.storeProductRecipe.productID)
        }
        
        let productData = NSEntityDescription.insertNewObject(forEntityName: "FAVORITE_PRODUCT", into: vc) as! FAVORITE_PRODUCT
        productData.brandID = Int16(self.storeProductRecipe.brandID)
        productData.storeID = Int16(self.storeProductRecipe.storeID)
        productData.productID = Int16(self.storeProductRecipe.productID)
        app.saveContext()
        
        for i in 0...self.productRecipes.count - 1 {
            for j in 0...self.productRecipes[i].recipeSubCategoryDetail.count - 1 {
                for k in 0...self.productRecipes[i].recipeSubCategoryDetail[j].count - 1 {
                    for index in 0...self.productRecipes[i].recipeSubCategoryDetail[j][k].recipeDetail.count - 1 {
                        if self.productRecipes[i].recipeSubCategoryDetail[j][k].recipeDetail[index].checkedFlag {
                            let recipeData = NSEntityDescription.insertNewObject(forEntityName: "FAVORITE_PRODUCT_RECIPE", into: vc) as! FAVORITE_PRODUCT_RECIPE
                            recipeData.brandID = Int16(self.storeProductRecipe.brandID)
                            recipeData.storeID = Int16(self.storeProductRecipe.storeID)
                            recipeData.productID = Int16(self.storeProductRecipe.productID)
                            recipeData.recipeCode = self.productRecipes[i].recipeSubCategoryDetail[j][k].recipeSubCategory
                            recipeData.recipeSubCode = self.productRecipes[i].recipeSubCategoryDetail[j][k].recipeDetail[index].recipeName
                            app.saveContext()
                        }
                    }
                }
            }
        }
        
        //Add message to inform user that action is successful
        var messageString: String = ""
        if self.storeProductRecipe.favorite {
            messageString = "已更新我的最愛產品"
        } else {
            messageString = "已加入我的最愛產品"
        }
        
        let alertMessage = UIAlertController(title: messageString, message: nil, preferredStyle: .alert)
        self.present(alertMessage, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
            self.presentedViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func receiveAddToCart(_ notification: Notification) {
        print("Receive AddToCart notification.")
        
        if self.isEditFlag {
            updateEditedOrderInformation(order_info: self.editOrderInfo)

            return
        }
        
        let orderInfo = retrieveOrderInformation(brand_id: self.storeProductRecipe.brandID, store_id: self.storeProductRecipe.storeID)
        
        if orderInfo == nil {
            let timeZone = TimeZone.init(identifier: "UTC+8")
            let formatter = DateFormatter()
            formatter.timeZone = timeZone
            formatter.locale = Locale.init(identifier: "zh_TW")
            formatter.dateFormat = DATETIME_FORMATTER
            
            let tmpOrderNumber = formatter.string(from: Date())
            
            let order_data = NSEntityDescription.insertNewObject(forEntityName: "ORDER_INFORMATION", into: vc) as! ORDER_INFORMATION
            order_data.orderNumber = tmpOrderNumber
            order_data.orderType = self.oType
            //order_data.deliveryType =
            order_data.orderStatus = ORDER_STATUS_INIT
            if self.oType == ORDER_TYPE_SINGLE {
                order_data.orderImage = UIImage(named: "Image_Person.png")!.pngData()
            } else {
                order_data.orderImage = UIImage(named: "Image_Group.png")!.pngData()
            }
            order_data.orderCreateTime = Date()
            //order_data.orderOwner =
            let quantity_row_index = IndexPath(row: self.productRecipes.count + 1, section: 0)
            let quantity_cell = self.tableView.cellForRow(at: quantity_row_index) as! QuantityCell
            order_data.orderTotalPrice = Int16(quantity_cell.getTotalPrice())
            order_data.orderTotalQuantity = Int16(quantity_cell.getQuantity())
            order_data.brandID = Int16(self.storeProductRecipe.brandID)
            order_data.brandName = self.storeProductRecipe.brandName
            order_data.storeID = Int16(self.storeProductRecipe.storeID)
            order_data.storeName = self.storeProductRecipe.storeName
            
            app.saveContext()
            
            insertOrderContentItem(order_number: tmpOrderNumber)
            updateOrderData(brand_id: self.storeProductRecipe.brandID, store_id: self.storeProductRecipe.storeID)
        } else {
            insertOrderContentItem(order_number: orderInfo!.orderNumber!)
            updateOrderData(brand_id: self.storeProductRecipe.brandID, store_id: self.storeProductRecipe.storeID)
        }

        //Add message to inform user that action is successful
        let messageString: String = "已加入購物車"
        let alertMessage = UIAlertController(title: messageString, message: nil, preferredStyle: .alert)
        self.present(alertMessage, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
            self.presentedViewController?.dismiss(animated: true, completion: nil)
            //self.navigationController?.popViewController(animated: true)
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func insertOrderContentItem(order_number: String) {
        let quantity_row_index = IndexPath(row: self.productRecipes.count + 1, section: 0)
        let quantity_cell = self.tableView.cellForRow(at: quantity_row_index) as! QuantityCell
        quantity_cell.setSinglePrice(price: self.finalPrice)

        let order_item = NSEntityDescription.insertNewObject(forEntityName: "ORDER_CONTENT_ITEM", into: vc) as! ORDER_CONTENT_ITEM
        
        order_item.orderNumber = order_number
        order_item.itemNumber = Int16(getLastItemNumber(order_number: order_number))
        order_item.productID = Int16(self.storeProductRecipe.productID)
        order_item.productName = self.storeProductRecipe.productName
        //order_item.itemOwnerName =
        //order_item.itemOwnerImage =
        order_item.itemCreateTime = Date()
        order_item.itemQuantity = Int16(quantity_cell.getQuantity())
        order_item.itemSinglePrice = Int16(quantity_cell.getSinglePrice())
        order_item.itemFinalPrice = Int16(quantity_cell.getTotalPrice())
        
        let comments_row_index = IndexPath(row: self.productRecipes.count, section: 0)
        let comments_cell = self.tableView.cellForRow(at: comments_row_index) as! CommentsCell
        order_item.itemComments = comments_cell.getComments()
        
        app.saveContext()
        
        insertItemRecipe(item_number: Int(order_item.itemNumber), order_number: order_number, product_id: self.storeProductRecipe.productID)
    }
    
    func updateOrderContentItem(order_info: OrderInformation) {
        let fetchRequest: NSFetchRequest<ORDER_CONTENT_ITEM> = ORDER_CONTENT_ITEM.fetchRequest()
        let predicateString = "orderNumber == \"\(order_info.orderNumber)\" AND itemNumber == \(order_info.contentList[0].itemNumber) AND productID == \(order_info.contentList[0].productID)"
        let predicate = NSPredicate(format: predicateString)
        fetchRequest.predicate = predicate
        
        do {
            let item_data = try vc.fetch(fetchRequest).first
            if item_data != nil {
                let quantity_row_index = IndexPath(row: self.productRecipes.count + 1, section: 0)
                let quantity_cell = self.tableView.cellForRow(at: quantity_row_index) as! QuantityCell
                //quantity_cell.setSinglePrice(price: self.finalPrice)
                print("updateOrderContentItem -> item_data!.itemSinglePrice = \(item_data!.itemSinglePrice)")
                quantity_cell.setSinglePrice(price: Int(item_data!.itemSinglePrice))

                item_data?.setValue(Date(), forKey: "itemCreateTime")
                item_data?.setValue(Int16(quantity_cell.getQuantity()), forKey: "itemQuantity")
                item_data?.setValue(Int16(quantity_cell.getSinglePrice()), forKey: "itemSinglePrice")
                item_data?.setValue(Int16(quantity_cell.getTotalPrice()), forKey: "itemFinalPrice")
                
                let comments_row_index = IndexPath(row: self.productRecipes.count, section: 0)
                let comments_cell = self.tableView.cellForRow(at: comments_row_index) as! CommentsCell
                item_data?.setValue(comments_cell.getComments(), forKey: "itemComments")

                app.saveContext()
            } else {
                print("RecipeTableViewController updateOrderContentItem -> item_data is nil")
                return
            }
        } catch {
            print(error.localizedDescription)
            return
        }
    }

    func insertItemRecipe(item_number: Int, order_number: String, product_id: Int) {
        
        for i in 0...self.productRecipes.count - 1 {
            for j in 0...self.productRecipes[i].recipeSubCategoryDetail.count - 1 {
                for k in 0...self.productRecipes[i].recipeSubCategoryDetail[j].count - 1 {
                    for index in 0...self.productRecipes[i].recipeSubCategoryDetail[j][k].recipeDetail.count - 1 {
                        if self.productRecipes[i].recipeSubCategoryDetail[j][k].recipeDetail[index].checkedFlag {
                            let item_recipe = NSEntityDescription.insertNewObject(forEntityName: "ORDER_PRODUCT_RECIPE", into: vc) as! ORDER_PRODUCT_RECIPE
                            
                            item_recipe.orderNumber = order_number
                            item_recipe.itemNumber = Int16(item_number)
                            item_recipe.productID = Int16(product_id)
                            item_recipe.recipeCode = self.productRecipes[i].recipeSubCategoryDetail[j][k].recipeSubCategory
                            item_recipe.recipeSubCode = self.productRecipes[i].recipeSubCategoryDetail[j][k].recipeDetail[index].recipeName
                            
                            app.saveContext()
                        }
                    }
                }
            }
        }
    }
    
    func updateEditedOrderInformation(order_info: OrderInformation) {
        updateOrderContentItem(order_info: order_info)
        deleteOrderProductRecipeItem(order_number: order_info.orderNumber, item_number: order_info.contentList[0].itemNumber, product_id: order_info.contentList[0].productID)
        insertItemRecipe(item_number: order_info.contentList[0].itemNumber, order_number: order_info.orderNumber, product_id: order_info.contentList[0].productID)
        updateOrderData(brand_id: self.storeProductRecipe.brandID, store_id: self.storeProductRecipe.storeID)
        
        let messageString: String = "已更新購物車"

        let alertMessage = UIAlertController(title: messageString, message: nil, preferredStyle: .alert)
        self.present(alertMessage, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
            self.presentedViewController?.dismiss(animated: true, completion: nil)
            //Send notofication to CartTableViewController
            NotificationCenter.default.post(name: NSNotification.Name("RefreshCartOrder"), object: nil)
            self.navigationController?.popViewController(animated: true)
        }
    }

    func getLastItemNumber(order_number: String) -> Int {
        
        let fetchRequest: NSFetchRequest<ORDER_CONTENT_ITEM> = ORDER_CONTENT_ITEM.fetchRequest()
        let predicateString = "orderNumber == \(order_number)"
        print("getLastItemNumber predicateString = \(predicateString)")
        let predicate = NSPredicate(format: predicateString)
        fetchRequest.predicate = predicate
        let sort = NSSortDescriptor(key: "itemNumber", ascending: false)
        fetchRequest.sortDescriptors = [sort]

        do {
            let item_data = try vc.fetch(fetchRequest).first
            if item_data == nil {
                return 1
            } else {
                return (Int(item_data!.itemNumber) + 1)
            }
        } catch {
            print(error.localizedDescription)
            return 0
        }
    }

    func getFinalPrice() -> Int {
        var tmpFinalPrice: Int = 0
        
        for i in 0...self.productRecipes.count - 1 {
            for j in 0...self.productRecipes[i].recipeSubCategoryDetail.count - 1 {
                for k in 0...self.productRecipes[i].recipeSubCategoryDetail[j].count - 1 {
                    for index in 0...self.productRecipes[i].recipeSubCategoryDetail[j][k].recipeDetail.count - 1 {
                        if self.productRecipes[i].recipeSubCategoryDetail[j][k].recipeDetail[index].checkedFlag {
                            let itemPrice = getItemPrice(recipe_code: self.productRecipes[i].recipeSubCategoryDetail[j][k].recipeSubCategory, recipe_subcode: self.productRecipes[i].recipeSubCategoryDetail[j][k].recipeDetail[index].recipeName)
                            tmpFinalPrice = tmpFinalPrice + itemPrice
                        }
                    }
                }
            }
        }
        
        return tmpFinalPrice
    }
    
    func getItemPrice(recipe_code: String, recipe_subcode: String) -> Int {
        var tmpItemPrice: Int = 0
        
        for i in 0...self.priceListArray.count - 1{
            if self.priceListArray[i].recipeCode == recipe_code && self.priceListArray[i].recipeSubCode == recipe_subcode {
                tmpItemPrice = Int(self.priceListArray[i].price)!
                break
            }
        }
        
        return tmpItemPrice
    }
    
    func retrieveFavoriteProductRecipeFlag(recipe_code: String, recipe_subcode: String) -> Bool {
        let fetchRequest: NSFetchRequest<FAVORITE_PRODUCT_RECIPE> = FAVORITE_PRODUCT_RECIPE.fetchRequest()
        let predicateString = "brandID == \(self.storeProductRecipe.brandID) AND storeID == \(self.storeProductRecipe.storeID) AND productID == \(self.storeProductRecipe.productID) AND recipeCode == \"\(recipe_code)\" AND recipeSubCode == \"\(recipe_subcode)\""
        print("retrieveFavoriteProductRecipeFlag predicateString = \(predicateString)")
        let predicate = NSPredicate(format: predicateString)
        fetchRequest.predicate = predicate

        do {
            let recipe_data = try vc.fetch(fetchRequest).first
            if recipe_data == nil {
                return false
            } else {
                return true
            }
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.productRecipes.count + 4
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == self.productRecipes.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsCell", for: indexPath) as! CommentsCell
            if self.isEditFlag {
                cell.setComments(comments_string: self.editOrderInfo.contentList[0].itemComments)
            }
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }

        if indexPath.row == self.productRecipes.count + 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "QuantityCell", for: indexPath) as! QuantityCell
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            if self.isEditFlag {
                cell.setSinglePrice(price: self.editOrderInfo.contentList[0].itemSinglePrice)
                cell.setQuantity(prod_quantity: self.editOrderInfo.contentList[0].itemQuantity)
                cell.setTotalPrice(total_price: self.editOrderInfo.contentList[0].itemFinalPrice)
            } else {
                cell.setSinglePrice(price: self.finalPrice)
            }
            
            return cell
        }
        
        if indexPath.row == self.productRecipes.count + 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BasicButtonCell", for: indexPath) as! BasicButtonCell
            
            let iconImage: UIImage = UIImage(named: "Icon_Favorite3.png")!
            if self.storeProductRecipe.favorite {
                cell.setData(icon: iconImage, button_text: "更新我的最愛產品", action_type: BUTTON_ACTION_FAVORITE)
            } else {
                cell.setData(icon: iconImage, button_text: "加入我的最愛產品", action_type: BUTTON_ACTION_FAVORITE)
            }
 
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
        
        if indexPath.row == self.productRecipes.count + 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BasicButtonCell", for: indexPath) as! BasicButtonCell
           
            let iconImage: UIImage = UIImage(named: "Icon_Cart_Red.png")!
            
            if self.isEditFlag {
                cell.setData(icon: iconImage, button_text: "更新購物車", action_type: BUTTON_ACTION_CART)
            } else {
                cell.setData(icon: iconImage, button_text: "加入購物車", action_type: BUTTON_ACTION_CART)
            }

            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath) as! RecipeCell

        self.productRecipes[indexPath.row].rowIndex = indexPath.row
        cell.setData(recipe_data: self.productRecipes[indexPath.row], number_for_row: 3)
        itemHeight[indexPath.row] = cell.getCellHeight()
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row >= self.productRecipes.count {
            if indexPath.row == self.productRecipes.count {
                return 120
            }
            
            if indexPath.row == self.productRecipes.count + 1 {
                return 74
            }
            
            return 54
        }

        return CGFloat(itemHeight[indexPath.row])
    }
    
}
