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
    var productRecipePriceList: ProductRecipePriceList!
    
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!

    var selectedCategory: Int = 0
    //var detailProductFlag: Bool = true
    //var menuImages: [UIImage] = [UIImage(imageLiteralResourceName: "ToolBar_ProductDetail"), UIImage(imageLiteralResourceName: "ToolBar_ProductBrief")]
    
    @IBOutlet weak var categorySegment: UISegmentedControl!
    //@IBOutlet weak var productListBarButton: UIBarButtonItem!
    
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
        requestProductRecipePrice()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "\(self.favoriteStoreInfo.brandName)  \(self.favoriteStoreInfo.storeName) 產品列表"
        //self.tableView.reloadData()
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
                tmpProduct.favorite = getProductFavoriteFlag(brand_id: Int(product_data!.brandID), store_id: Int(self.favoriteStoreInfo.storeID), product_id: Int(product_data!.productID))
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

    func getProductFavoriteFlag(brand_id: Int, store_id: Int, product_id: Int) -> Bool {
        let fetchRequest: NSFetchRequest<FAVORITE_PRODUCT> = FAVORITE_PRODUCT.fetchRequest()
        let predicateString = "brandID == \(brand_id) AND storeID == \(store_id) AND productID == \(product_id)"
        print("getProductFavoriteFlag predicateString = \(predicateString)")
        let predicate = NSPredicate(format: predicateString)
        fetchRequest.predicate = predicate

        do {
            let product_data = try vc.fetch(fetchRequest).first
            if product_data == nil {
                return false
            } else {
                return true
            }
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    func requestProductRecipePrice() {
        if self.favoriteStoreInfo.brandID == 0 || self.favoriteStoreInfo.storeID == 0 {
            let httpAlert = alert(message: "requestProductRecipePrice: Can't Get Brand ID and Store ID", title: "System Error")
            self.present(httpAlert, animated : false, completion : nil)
            return
        }
        
        let sessionConf = URLSessionConfiguration.default
        sessionConf.timeoutIntervalForRequest = HTTP_REQUEST_TIMEOUT
        sessionConf.timeoutIntervalForResource = HTTP_REQUEST_TIMEOUT
        let sessionHttp = URLSession(configuration: sessionConf)

        let uriString = "PRODUCT_RECIPE_PRICE/\(self.favoriteStoreInfo.brandID)/\(self.favoriteStoreInfo.storeID)"
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getCategoryCounnt(cate_id: self.productCategories[self.selectedCategory])
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductDetailCell", for: indexPath) as! ProductDetailCell

        cell.setData(favorite: self.storeProductList[indexPath.row].favorite,
                     image: self.storeProductList[indexPath.row].productImage!,
                     title: self.storeProductList[indexPath.row].productName,
                     sub_title: self.storeProductList[indexPath.row].productDescription!,
                     price: "30元")
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView: CategorySectionView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CategorySectionView") as! CategorySectionView
        
        sectionView.setData(catetory: self.productCategories[section])
        return sectionView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.productRecipePriceList == nil {
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let recipe_vc = storyboard.instantiateViewController(withIdentifier: "Recipe_VC") as? RecipeTableViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: Recipe_VC can't find!! (ViewController)")
            return
        }
        
        var tmpPriceList = [ProductRecipePrice]()
        
        for i in 0...self.productRecipePriceList.PRODUCT_RECIPE_PRICE.count - 1 {
            if self.productRecipePriceList.PRODUCT_RECIPE_PRICE[i].productID == self.storeProductList[indexPath.row].productID {
                tmpPriceList.append(self.productRecipePriceList.PRODUCT_RECIPE_PRICE[i])
            }
        }
        
        recipe_vc.storeProductRecipe = self.storeProductList[indexPath.row]
        recipe_vc.priceListArray = tmpPriceList
        recipe_vc.oType = "S"
        recipe_vc.isEditFlag = false
        //show(recipe_vc, sender: self)
        self.navigationController?.pushViewController(recipe_vc, animated: true)
    }

}
