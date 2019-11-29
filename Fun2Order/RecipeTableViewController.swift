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
    var favoriteProductRecipes = [FavoriteProductRecipe]()
    
    
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

        //itemHeight = Array(repeating: 0, count: titleArray.count)
        print("self.storeProductRecipe.recipe.count = \(countRecipe)")
        retrieveProductRecipeCode()
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
            var tmpfavoriteProdRcp = FavoriteProductRecipe()
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
            favoriteProductRecipes.append(tmpfavoriteProdRcp)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.favoriteProductRecipes.count + 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == self.favoriteProductRecipes.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "QuantityCell", for: indexPath) as! QuantityCell
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
        
        if indexPath.row == self.favoriteProductRecipes.count + 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BasicButtonCell", for: indexPath) as! BasicButtonCell
            
            let iconImage: UIImage = UIImage(named: "Icon_Favorite3.png")!
            cell.setData(icon: iconImage, button_text: "加入我的最愛產品")
 
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
        
        if indexPath.row == self.favoriteProductRecipes.count + 2 {
           let cell = tableView.dequeueReusableCell(withIdentifier: "BasicButtonCell", for: indexPath) as! BasicButtonCell
           
           let iconImage: UIImage = UIImage(named: "Icon_Cart_Red.png")!
           cell.setData(icon: iconImage, button_text: "加入購物車")

           cell.selectionStyle = UITableViewCell.SelectionStyle.none
           return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath) as! RecipeCell
        
        //cell.setItemData(title: titleArray[indexPath.row], item_array: itemData[indexPath.row], number_for_row: 3)
        cell.setData(row_index: indexPath.row, recipe_data: self.favoriteProductRecipes[indexPath.row], number_for_row: 3)
        itemHeight[indexPath.row] = cell.getCellHeight()
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row >= self.favoriteProductRecipes.count {
            if indexPath.row == self.favoriteProductRecipes.count  {
                return 74
            }
            
            return 54
        }

        return CGFloat(itemHeight[indexPath.row])
    }
    
}
