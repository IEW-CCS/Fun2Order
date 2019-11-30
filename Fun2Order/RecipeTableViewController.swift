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
    var finalPrice: Int = 0
    
    
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        vc = app.persistentContainer.viewContext
        
        let detailCellViewNib: UINib = UINib(nibName: "RecipeCell", bundle: nil)
        self.tableView.register(detailCellViewNib, forCellReuseIdentifier: "RecipeCell")
        
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
        
        //itemHeight = Array(repeating: 0, count: titleArray.count)
        print("self.storeProductRecipe.recipe.count = \(countRecipe)")
        retrieveProductRecipeCode()
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
    
    func deleteRecipeItem() {
        let fetchRequest: NSFetchRequest<FAVORITE_PRODUCT_RECIPE> = FAVORITE_PRODUCT_RECIPE.fetchRequest()
        let predicateString = "brandID == \(self.storeProductRecipe.brandID) AND storeID == \(self.storeProductRecipe.storeID) AND productID == \(self.storeProductRecipe.productID)"

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
            
            let row_index = IndexPath(row: self.productRecipes.count, section: 0)
            let cell = self.tableView.cellForRow(at: row_index) as! QuantityCell
            cell.setSinglePrice(price: self.finalPrice)
        }
    }
    
    @objc func receiveAddFavoriteProduct(_ notification: Notification) {
        print("Receive AddFavoriteProduct notification.")
        
        deleteRecipeItem()
        
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
        return self.productRecipes.count + 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == self.productRecipes.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "QuantityCell", for: indexPath) as! QuantityCell
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.setSinglePrice(price: self.finalPrice)
            return cell
        }
        
        if indexPath.row == self.productRecipes.count + 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BasicButtonCell", for: indexPath) as! BasicButtonCell
            
            let iconImage: UIImage = UIImage(named: "Icon_Favorite3.png")!
            if self.storeProductRecipe.favorite {
                cell.setData(icon: iconImage, button_text: "更新我的最愛產品")
            } else {
                cell.setData(icon: iconImage, button_text: "加入我的最愛產品")
            }
 
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
        
        if indexPath.row == self.productRecipes.count + 2 {
           let cell = tableView.dequeueReusableCell(withIdentifier: "BasicButtonCell", for: indexPath) as! BasicButtonCell
           
           let iconImage: UIImage = UIImage(named: "Icon_Cart_Red.png")!
           cell.setData(icon: iconImage, button_text: "加入購物車")

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
            if indexPath.row == self.productRecipes.count  {
                return 74
            }
            
            return 54
        }

        return CGFloat(itemHeight[indexPath.row])
    }
    
}
