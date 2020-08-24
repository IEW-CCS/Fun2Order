//
//  BrandMenuTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/8/20.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
import Firebase
import WebKit

class BrandMenuTableViewController: UITableViewController {
    @IBOutlet weak var imageBrandIcon: UIImageView!
    @IBOutlet weak var imageBanner: UIImageView!
    @IBOutlet weak var labelBrandName: UILabel!
    @IBOutlet weak var segmentCategory: ScrollUISegmentController!
    
    var brandBackgroundColor: UIColor!
    var brandTextTintColor: UIColor!
    var brandProfile: DetailBrandProfile = DetailBrandProfile()

    var detailBrandProfile: DetailBrandProfile = DetailBrandProfile()
    var detailMenuInfo: DetailMenuInformation = DetailMenuInformation()
    var filterProducts: [DetailProductItem] = [DetailProductItem]()
    var productCategory: [String] = [String]()
    var selectedIndex: Int = -1
    var menuOrder: MenuOrder = MenuOrder()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("BrandStoreListTableViewController viewDidLoad")
        
        let productCell: UINib = UINib(nibName: "ProductPriceCell", bundle: nil)
        self.tableView.register(productCell, forCellReuseIdentifier: "ProductPriceCell")

        self.labelBrandName.text = self.brandProfile.brandName
        self.labelBrandName.isHidden = true
        
        self.imageBrandIcon.layer.borderWidth = 1.0
        self.imageBrandIcon.layer.borderColor = UIColor.white.cgColor
        self.imageBrandIcon.layer.cornerRadius = 6
        self.imageBrandIcon.isHidden = true

        //self.tableView.backgroundColor = TEST_BACKGROUND_COLOR
        self.tableView.backgroundColor = self.brandBackgroundColor

        if self.brandProfile.brandMenuBannerURL != nil {
            let url = URL(string: self.brandProfile.brandMenuBannerURL!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            if url == nil {
                print("URL returns nil")
                return
            }
            
            self.imageBanner.kf.setImage(with: url)
        }

        self.segmentCategory.segmentDelegate = self
        downloadFBDetailBrandProfile(brand_name: self.brandProfile.brandName, completion: receiveFBDetailBrandProfile)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.title = "產品訊息"
        self.navigationController?.title = "產品訊息"
        self.tabBarController?.title = "產品訊息"
    }

    func setupSegmentCategory() {
        if self.productCategory.isEmpty {
            self.segmentCategory.isHidden = true
            return
        }
        
        self.segmentCategory.isHidden = false
        self.segmentCategory.removeAllItems()
        self.segmentCategory.segmentItems = self.productCategory
        self.selectedIndex = 0
        self.segmentCategory.setSelectedIndex(index: self.selectedIndex)
    }

    func receiveFBDetailBrandProfile(brand_profile: DetailBrandProfile?) {
        if brand_profile == nil {
            return
        }
        
        self.detailBrandProfile = brand_profile!
        downloadBrandImage(brand_profile: self.detailBrandProfile)
        downloadFBDetailMenuInformation(menu_number: brand_profile!.menuNumber, completion: { menu_info in
            if menu_info == nil {
                return
            }
            
            self.detailMenuInfo = menu_info!
            self.productCategory = self.createBrandCategory()
            if !self.productCategory.isEmpty {
                self.setupSegmentCategory()
            }
            self.filterProductsByCategory(index: self.selectedIndex)
            self.tableView.reloadData()
        })
    }
    
    func downloadBrandImage(brand_profile: DetailBrandProfile)  {
        if brand_profile.imageDownloadUrl == nil {
            print("brand_data.brandData.imageDownloadUrl is nil")
            let storageRef = Storage.storage().reference().child(brand_profile.brandIconImage!)
            storageRef.downloadURL(completion: { (url, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                if url == nil {
                    print("downloadURL returns nil")
                    return
                }
                
                print("downloadURL = \(url!)")
                
                self.imageBrandIcon.kf.setImage(with: url)
            })
        } else {
            //print("brand_data.brandData.imageDownloadUrl NOT nil")
            let url = URL(string: brand_profile.imageDownloadUrl!)
            self.imageBrandIcon.kf.setImage(with: url)
        }
    }
    
    func createBrandCategory() -> [String] {
        var categoryArray: [String] = [String]()
        
        if self.detailMenuInfo.productCategory == nil {
            print("self.detailMenuInfo.productCategory is nil")
            return categoryArray
        }

        if self.detailMenuInfo.productCategory!.isEmpty {
            print("self.detailMenuInfo.productCategory is empty")
            return categoryArray
        }

        for i in 0...self.detailMenuInfo.productCategory!.count - 1 {
            categoryArray.append(self.detailMenuInfo.productCategory![i].categoryName)
        }
        
        return categoryArray
    }
    
    func filterProductsByCategory(index: Int) {
        self.filterProducts.removeAll()
        if index < 0 {
            print("filterProductsByCategory -> self.selectedIndex < 0, just return")
            return
        }
        
        if self.detailMenuInfo.productCategory == nil {
            print("filterProductsByCategory -> self.detailMenuInfo.productCategory == nil, just return")
            return
        }
        
        if self.detailMenuInfo.productCategory!.isEmpty {
            print("filterProductsByCategory -> self.detailMenuInfo.productCategory is empty, just return")
            return
        }

        if self.detailMenuInfo.productCategory![index].productItems == nil {
            print("filterProductsByCategory -> self.detailMenuInfo.productCategory![index].productItems is nil, just return")
            return

        }
        
        self.filterProducts = self.detailMenuInfo.productCategory![index].productItems!
    }
    
    func getPriceRecipeItems(index: Int) -> [String] {
        var itemsString: [String] = [String]()

        if index < 0 {
            print("getPriceRecipeItems -> self.selectedIndex < 0, just return")
            return itemsString
        }

        let priceTemplate = self.detailMenuInfo.productCategory![index].priceTemplate
        if priceTemplate.recipeList.isEmpty {
            return itemsString
        }
        
        for i in 0...priceTemplate.recipeList.count - 1 {
            itemsString.append(priceTemplate.recipeList[i].itemName)
        }

        return itemsString
    }
    
    func getProductPriceItems(index: Int) -> [String] {
        var itemsString: [String] = [String]()
        var priceItemsArray: [String] = [String]()

        if self.filterProducts.isEmpty {
            return itemsString
        }
        
        priceItemsArray = getPriceRecipeItems(index: self.selectedIndex)
        
        if self.filterProducts[index].priceList == nil {
            return itemsString
        }
        
        for i in 0...priceItemsArray.count - 1 {
            for j in 0...self.filterProducts[index].priceList!.count - 1 {
                if self.filterProducts[index].priceList![j].recipeItemName == priceItemsArray[i] {
                    if self.filterProducts[index].priceList![j].availableFlag {
                        itemsString.append(String(self.filterProducts[index].priceList![j].price))
                    } else {
                        itemsString.append("")
                    }
                    break
                }
            }
        }
        
        return itemsString
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            if self.selectedIndex < 0 {
                return 0
            }
            
            if self.filterProducts.isEmpty {
                return 0
            }
            
            return self.filterProducts.count
        }
        
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductPriceCell", for: indexPath) as! ProductPriceCell
            let contents = self.getPriceRecipeItems(index: self.selectedIndex)
            //let description = self.filterProducts[indexPath.row].productDescription ?? ""
            cell.setData(name: "", description: "", contents: contents, style: 0)
            //cell.backgroundColor = TEST_BACKGROUND_COLOR
            cell.backgroundColor = self.brandBackgroundColor
            cell.selectionStyle = UITableViewCell.SelectionStyle.none

            return cell
        }
        
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductPriceCell", for: indexPath) as! ProductPriceCell

            let contents = self.getProductPriceItems(index: indexPath.row)
            let description = self.filterProducts[indexPath.row].productDescription ?? ""
            cell.setData(name: self.filterProducts[indexPath.row].productName, description: description, contents: contents, style: 1)
            //cell.backgroundColor = TEST_BACKGROUND_COLOR
            cell.backgroundColor = self.brandBackgroundColor
            cell.selectionStyle = UITableViewCell.SelectionStyle.none

            return cell
        }
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        //cell.backgroundColor = TEST_BACKGROUND_COLOR
        cell.backgroundColor = self.brandBackgroundColor
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        if indexPath.section == 1 {
            let newIndexPath = IndexPath(row: 0, section: indexPath.section)
            return super.tableView(tableView, indentationLevelForRowAt: newIndexPath)
        }
        return super.tableView(tableView, indentationLevelForRowAt: indexPath)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 44
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if self.filterProducts[indexPath.row].productWebURL == nil {
                return
            }
            
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            guard let productDetailController = storyBoard.instantiateViewController(withIdentifier: "BRAND_PRODUCT_VC") as? BrandProductDescriptionViewController else{
                assertionFailure("[AssertionFailure] StoryBoard: BRAND_PRODUCT_VC can't find!! (BrandProductDescriptionViewController)")
                return
            }
            
            productDetailController.productURL = self.filterProducts[indexPath.row].productWebURL!
            
            navigationController?.show(productDetailController, sender: self)
        }
    }


}

extension BrandMenuTableViewController: ScrollUISegmentControllerDelegate {
    func selectItemAt(index: Int, onScrollUISegmentController scrollUISegmentController: ScrollUISegmentController) {
        //print("select Item At [\(index)] in scrollUISegmentController")
        self.selectedIndex = index
        self.filterProductsByCategory(index: self.selectedIndex)
        self.tableView.reloadData()
    }
}
