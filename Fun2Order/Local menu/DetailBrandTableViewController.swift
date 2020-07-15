//
//  DetailBrandTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/6/27.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

class DetailBrandTableViewController: UITableViewController {
    @IBOutlet weak var imageBrandIcon: UIImageView!
    @IBOutlet weak var labelBrandName: UILabel!
    @IBOutlet weak var segmentCategory: ScrollUISegmentController!
    @IBOutlet weak var buttonGroup: UIButton!
    
    var brandName: String = ""
    var brandImage: UIImage?
    
    var detailBrandProfile: DetailBrandProfile = DetailBrandProfile()
    var detailMenuInfo: DetailMenuInformation = DetailMenuInformation()
    var filterProducts: [DetailProductItem] = [DetailProductItem]()
    var productCategory: [String] = [String]()
    var selectedIndex: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let productCell: UINib = UINib(nibName: "ProductPriceCell", bundle: nil)
        self.tableView.register(productCell, forCellReuseIdentifier: "ProductPriceCell")

        self.labelBrandName.text = self.brandName
        if self.brandImage != nil {
            self.imageBrandIcon.image = self.brandImage!
        }
        
        self.buttonGroup.layer.cornerRadius = 6

        self.imageBrandIcon.layer.borderWidth = 1.0
        self.imageBrandIcon.layer.borderColor = UIColor.white.cgColor
        self.imageBrandIcon.layer.cornerRadius = 6
        
        self.segmentCategory.segmentDelegate = self
        downloadFBDetailBrandProfile(brand_name: self.brandName, completion: receiveFBDetailBrandProfile)
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

    func setData(brand_name: String, brand_image: UIImage?) {
        self.brandName = brand_name
        self.brandImage = brand_image
    }
    
    func receiveFBDetailBrandProfile(brand_profile: DetailBrandProfile?) {
        if brand_profile == nil {
            return
        }
        
        self.detailBrandProfile = brand_profile!
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
    
    @IBAction func confirmJoinGroup(_ sender: UIButton) {
        let groupList = retrieveGroupList()
        if groupList.isEmpty{
            presentSimpleAlertMessage(title: "提示訊息", message: "您尚未建立任何群組，請至\n『我的設定』--> 『群組資訊』中\n先建立群組並加入好友\n之後即可開始使用揪團功能")
            return
        }
        guard let groupOrderController = self.storyboard?.instantiateViewController(withIdentifier: "DETAIL_CREATE_ORDER_VC") as? DetailGroupOrderTableViewController else {
            assertionFailure("[AssertionFailure] StoryBoard: DETAIL_CREATE_ORDER_VC can't find!! (MenuListTableViewController)")
            return
        }
        groupOrderController.orderType = ORDER_TYPE_OFFICIAL_MENU
        groupOrderController.brandName = self.brandName
        groupOrderController.detailMenuInformation = self.detailMenuInfo
        navigationController?.show(groupOrderController, sender: self)
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
            cell.setData(name: "", contents: contents, style: 0)
            cell.selectionStyle = UITableViewCell.SelectionStyle.none

            return cell
        }
        
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductPriceCell", for: indexPath) as! ProductPriceCell
            
            let contents = self.getProductPriceItems(index: indexPath.row)
            cell.setData(name: self.filterProducts[indexPath.row].productName, contents: contents, style: 1)
            cell.selectionStyle = UITableViewCell.SelectionStyle.none

            return cell
        }
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
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

}

extension DetailBrandTableViewController: ScrollUISegmentControllerDelegate {
    func selectItemAt(index: Int, onScrollUISegmentController scrollUISegmentController: ScrollUISegmentController) {
        //print("select Item At [\(index)] in scrollUISegmentController")
        self.selectedIndex = index
        self.filterProductsByCategory(index: self.selectedIndex)
        self.tableView.reloadData()
    }
}
