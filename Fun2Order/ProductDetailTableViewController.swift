//
//  ProductDetailTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/16.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class ProductDetailTableViewController: UITableViewController {
    var productCategories = [String]()
    var productList = [ProductInformation]()
    var storeProductList = [StoreProductRecipe]()
    var favoriteStoreInfo = FavoriteStoreInfo()
    
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!

    var selectedCategory: Int = 0
    var detailProductFlag: Bool = true
    var menuImages: [UIImage] = [UIImage(imageLiteralResourceName: "ToolBar_ProductDetail"), UIImage(imageLiteralResourceName: "ToolBar_ProductBrief")]
    
    @IBOutlet weak var categorySegment: UISegmentedControl!
    @IBOutlet weak var productListBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let detailCellViewNib: UINib = UINib(nibName: "ProductDetailCell", bundle: nil)
        self.tableView.register(detailCellViewNib, forCellReuseIdentifier: "ProductDetailCell")
        
        let briefCellViewNib: UINib = UINib(nibName: "ProductBriefCell", bundle: nil)
        self.tableView.register(briefCellViewNib, forCellReuseIdentifier: "ProductBriefCell")
        
        let sectionViewNib: UINib = UINib(nibName: "CategorySectionView", bundle: nil)
        self.tableView.register(sectionViewNib, forHeaderFooterViewReuseIdentifier: "CategorySectionView")
        
        vc = app.persistentContainer.viewContext

        retrieveCategoryInformation()
        retrieveProductInfo()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        //print("Title = \(self.favoriteStoreInfo.brandName)  \(self.favoriteStoreInfo.storeName) 產品列表")
        self.title = "\(self.favoriteStoreInfo.brandName)  \(self.favoriteStoreInfo.storeName) 產品列表"
    }

    @IBAction func changeProductListView(_ sender: UIBarButtonItem) {
        self.detailProductFlag = !self.detailProductFlag
        if self.detailProductFlag {
            self.productListBarButton.image = UIImage(imageLiteralResourceName: "ToolBar_ProductDetail")
            self.categorySegment.isHidden = false
            self.categorySegment.isEnabled = true
        } else {
            self.productListBarButton.image = UIImage(imageLiteralResourceName: "ToolBar_ProductBrief")
            self.categorySegment.isHidden = true
            self.categorySegment.isEnabled = false
        }
        
        self.tableView.reloadData()
    }
    
    @IBAction func displayCartView(_ sender: UIBarButtonItem) {
        print("Click displayCartView menu item")
    }
    
    @IBAction func selectCategory(_ sender: UISegmentedControl) {
        self.selectedCategory = self.categorySegment.selectedSegmentIndex
        retrieveProductInfo()
        self.tableView.reloadData()
    }
    
    func retrieveCategoryInformation() {
        if self.favoriteStoreInfo.brandID == 0 || self.favoriteStoreInfo.storeID == 0 {
            print("ProductDetailTableViewController retrieveCategoryInformation --> brandID or storeID is 0")
            return
        }
        
        self.productCategories.removeAll()
        
        let fetchSortRequest: NSFetchRequest<CODE_TABLE> = CODE_TABLE.fetchRequest()
        let predicateString = "codeCategory == \"\(CODE_PRODUCT_CATEGORY)\" AND codeExtension == \(self.favoriteStoreInfo.brandID)"
        print("retrieveCategoryInformation predicateString = \(predicateString)")
        let predicate = NSPredicate(format: predicateString)
        fetchSortRequest.predicate = predicate
        let sort = NSSortDescriptor(key: "index", ascending: true)
        fetchSortRequest.sortDescriptors = [sort]
        
        do {
            let code_list = try vc.fetch(fetchSortRequest)
            for code_data in code_list {
                self.productCategories.append(code_data.code!)
            }
            refreshProductCategorySegment()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func refreshProductCategorySegment() {
        self.categorySegment.removeAllSegments()
        for i in 0...(self.productCategories.count - 1) {
            self.categorySegment.insertSegment(withTitle: self.productCategories[i], at: i, animated: true)
        }
        self.categorySegment.selectedSegmentIndex = 0
    }
    
    func retrieveProductInfo() {
        self.storeProductList.removeAll()
        
        let prod_recipe_list = retrieveProductRecipe(brand_id: self.favoriteStoreInfo.brandID, store_id: self.favoriteStoreInfo.storeID)!
        
        for prod_recipe in prod_recipe_list {
            let fetchRequest: NSFetchRequest<PRODUCT_INFORMATION> = PRODUCT_INFORMATION.fetchRequest()
            let predicateString = "brandID == \(self.favoriteStoreInfo.brandID) AND productID == \(prod_recipe.productID)"
            print("retrieveCategoryInformation predicateString = \(predicateString)")
            let predicate = NSPredicate(format: predicateString)
            fetchRequest.predicate = predicate

            do {
                let product_data = try vc.fetch(fetchRequest).first

                if product_data?.productCategory != self.productCategories[self.selectedCategory] {
                    continue
                }
                
                var tmpProduct = StoreProductRecipe()
                tmpProduct.brandID = Int(product_data!.brandID)
                tmpProduct.storeID = Int(self.favoriteStoreInfo.storeID)
                tmpProduct.productID = Int(product_data!.productID)
                tmpProduct.recipe.append(prod_recipe.recipe1)
                tmpProduct.recipe.append(prod_recipe.recipe2)
                tmpProduct.recipe.append(prod_recipe.recipe3)
                tmpProduct.recipe.append(prod_recipe.recipe4)
                tmpProduct.recipe.append(prod_recipe.recipe5)
                tmpProduct.recipe.append(prod_recipe.recipe6)
                tmpProduct.recipe.append(prod_recipe.recipe7)
                tmpProduct.recipe.append(prod_recipe.recipe8)
                tmpProduct.recipe.append(prod_recipe.recipe9)
                tmpProduct.recipe.append(prod_recipe.recipe10)
                tmpProduct.brandName = self.favoriteStoreInfo.brandName
                tmpProduct.storeName = self.favoriteStoreInfo.storeName
                tmpProduct.productCategory = product_data!.productCategory!
                tmpProduct.productName = product_data!.productName!
                tmpProduct.productDescription = product_data!.productDescription!
                tmpProduct.productImage = UIImage(data: product_data!.productImage!)!
                tmpProduct.recommand = product_data!.recommand!
                tmpProduct.popularity = product_data!.popularity!
                tmpProduct.limit = product_data!.limit!
                
                self.storeProductList.append(tmpProduct)
                
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func getCategoryCounnt(cate_id: String) -> Int {
        var cateCount: Int = 0
        
        for i in 0...self.storeProductList.count - 1 {
            if self.storeProductList[i].productCategory == cate_id {
                cateCount = cateCount + 1
            }
        }
        
        print("Category: [\(cate_id)] count is \(cateCount)")
        return cateCount
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.detailProductFlag {
            return 1
        } else {
            //return 2
            return self.productCategories.count
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.detailProductFlag {
            //return self.productTitles[self.selectedCategory].count
            return getCategoryCounnt(cate_id: self.productCategories[self.selectedCategory])
        } else {
            //return self.productTitles[section].count
            return getCategoryCounnt(cate_id: self.productCategories[section])
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.detailProductFlag {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductDetailCell", for: indexPath) as! ProductDetailCell

            cell.setData(favorite: self.storeProductList[indexPath.row].favorite,
                         image: self.storeProductList[indexPath.row].productImage!,
                         title: self.storeProductList[indexPath.row].productName,
                         sub_title: self.storeProductList[indexPath.row].productDescription!,
                         price: "30元")
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductBriefCell", for: indexPath) as! ProductBriefCell
            //cell.setData(favorite: self.productFavoriteFlag[indexPath.section][indexPath.row],
            //             product_name: self.productTitles[indexPath.section][indexPath.row])
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.detailProductFlag {
            return 100
        } else {
            return 44
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if !self.detailProductFlag {
            let sectionView: CategorySectionView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CategorySectionView") as! CategorySectionView
            
            sectionView.setData(catetory: self.productCategories[section])
            return sectionView
        } else {
            let sectionView = super.tableView(tableView, viewForHeaderInSection: section) as! CategorySectionView
            
            return sectionView
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.detailProductFlag {
            return 0
        } else {
            return 44
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "Recipe_VC") as? RecipeTableViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: Recipe_VC can't find!! (ViewController)")
            return
        }
        
        vc.storeProductRecipe = self.storeProductList[indexPath.row]
        show(vc, sender: self)
    }

}
