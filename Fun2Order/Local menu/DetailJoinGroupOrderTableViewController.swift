//
//  DetailJoinGroupOrderTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/7/9.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
import Firebase
import CoreData
import GoogleMobileAds

protocol DetailJoinGroupOrderDelegate: class {
    func refreshHistoryInvitationList(sender: DetailJoinGroupOrderTableViewController)
}

extension DetailJoinGroupOrderDelegate {
    func refreshHistoryInvitationList(sender: DetailJoinGroupOrderTableViewController) {}
}


class DetailJoinGroupOrderTableViewController: UITableViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {
    @IBOutlet weak var segmentLocation: UISegmentedControl!
    @IBOutlet weak var segmentProductCategory: ScrollUISegmentController!
    @IBOutlet weak var barButtonCart: UIBarButtonItem!
    @IBOutlet weak var labelBrandName: UILabel!
    @IBOutlet weak var imageBrandIcon: UIImageView!
    
    var detailMenuInformation: DetailMenuInformation = DetailMenuInformation()
    var memberContent: MenuOrderMemberContent = MenuOrderMemberContent()
    var menuOrder: MenuOrder?
    var memberIndex: Int = -1
    var interstitialAd: GADInterstitial!
    var selectedLocationIndex: Int = -1
    let app = UIApplication.shared.delegate as! AppDelegate
    weak var refreshNotificationDelegate: ApplicationRefreshNotificationDelegate?
    weak var delegate: DetailJoinGroupOrderDelegate?
    var isNeedToConfirmFlag: Bool = false
    var filterProducts: [DetailProductItem] = [DetailProductItem]()
    var standAloneFlagArray: [Bool] = [Bool]()
    var allowedMultiFlagArray: [Bool] = [Bool]()
    var mandatoryFlagArray: [Bool] = [Bool]()
    var productCategory: [String] = [String]()
    var selectedIndex: Int = -1
    var selectedProductIndex: Int = 0
    var shortageProducts: [ShortageItem] = [ShortageItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshNotificationDelegate = app.notificationDelegate
        
        self.segmentProductCategory.layer.borderWidth = 1.0
        self.segmentProductCategory.layer.borderColor = UIColor.systemBlue.cgColor
        self.segmentProductCategory.layer.cornerRadius = 6
        
        self.imageBrandIcon.layer.borderWidth = 1.0
        self.imageBrandIcon.layer.borderColor = UIColor.darkGray.cgColor
        self.imageBrandIcon.layer.cornerRadius = 6
        
        self.labelBrandName.text = self.detailMenuInformation.brandName
        
        getBrandIconImage(name: self.detailMenuInformation.brandName)
        
        let productCell: UINib = UINib(nibName: "ProductPriceWithCartCell", bundle: nil)
        self.tableView.register(productCell, forCellReuseIdentifier: "ProductPriceWithCartCell")

        let backImage = self.navigationItem.leftBarButtonItem?.image
        let newBackButton = UIBarButtonItem(title: "返回", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        navigationController?.navigationBar.backIndicatorImage = backImage

        self.segmentProductCategory.segmentDelegate = self

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)

        setupShortageProducts()
        setupInterstitialAd()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
          textField.resignFirstResponder()
          return true
    }
    
    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }

    @objc func back(sender: UIBarButtonItem) {
        var alertWindow: UIWindow!
        if self.isNeedToConfirmFlag {
            let controller = UIAlertController(title: "提示訊息", message: "訂購單已更動，您確定要離開嗎？", preferredStyle: .alert)

            let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
                print("Confirm to ignore JoinOrder change")
                self.navigationController?.popToRootViewController(animated: true)
                self.dismiss(animated: false, completion: nil)

                alertWindow.isHidden = true
            }
            
            controller.addAction(okAction)
            let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (_) in
                print("Cancel to ignore JoinOrder change")
                alertWindow.isHidden = true
            }
            controller.addAction(cancelAction)
            alertWindow = presentAlert(controller)
        } else {
            self.navigationController?.popToRootViewController(animated: true)
            self.dismiss(animated: false, completion: nil)
        }
    }

    func setupInterstitialAd() {
        let adUnitID = JOINORDER_INTERSTITIAL_AD
        self.interstitialAd = GADInterstitial(adUnitID: adUnitID)
        let adRequest = GADRequest()
        self.interstitialAd.load(adRequest)
        self.interstitialAd.delegate = self
    }

    func setupSegmentCategory() {
        if self.productCategory.isEmpty {
            self.segmentProductCategory.isHidden = true
            return
        }
        
        self.segmentProductCategory.isHidden = false
        self.segmentProductCategory.removeAllItems()
        self.segmentProductCategory.segmentItems = self.productCategory
        self.selectedIndex = 0
        self.segmentProductCategory.setSelectedIndex(index: self.selectedIndex)
    }

    func getBrandIconImage(name: String) {
        var brandData: DetailBrandCategory = DetailBrandCategory()
        let databaseRef = Database.database().reference()
        let pathString = "BRAND_CATEGORY/\(name)"

        databaseRef.child(pathString).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let brandCategory = snapshot.value
                let jsonData = try? JSONSerialization.data(withJSONObject: brandCategory as Any, options: [])

                let decoder: JSONDecoder = JSONDecoder()
                do {
                    brandData = try decoder.decode(DetailBrandCategory.self, from: jsonData!)
                    if brandData.brandIconImage != nil {
                        downloadFBBrandImage(brand_url: brandData.brandIconImage!, completion: self.receiveBrandImage)
                    }
                } catch {
                    print("getBrandIconImage brandData jsonData decode failed: \(error.localizedDescription)")
                    return
                }
            } else {
                print("getBrandIconImage BRAND_CATEGORY snapshot doesn't exist!")
                return
            }
        })  { (error) in
            print("getBrandIconImage Firebase error = \(error.localizedDescription)")
            return
        }
    }

    func receiveBrandImage(image: UIImage?) {
        if image != nil {
            self.imageBrandIcon.image = image!
        }
    }

    func createBrandCategory() -> [String] {
        var categoryArray: [String] = [String]()
        
        if self.detailMenuInformation.productCategory == nil {
            print("self.detailMenuInformation.productCategory is nil")
            return categoryArray
        }

        if self.detailMenuInformation.productCategory!.isEmpty {
            print("self.detailMenuInformation.productCategory is empty")
            return categoryArray
        }

        for i in 0...self.detailMenuInformation.productCategory!.count - 1 {
            categoryArray.append(self.detailMenuInformation.productCategory![i].categoryName)
            self.standAloneFlagArray.append(self.detailMenuInformation.productCategory![i].priceTemplate.standAloneProduct)
            self.allowedMultiFlagArray.append(self.detailMenuInformation.productCategory![i].priceTemplate.allowMultiSelectionFlag)
            self.mandatoryFlagArray.append(self.detailMenuInformation.productCategory![i].priceTemplate.mandatoryFlag)
        }
        
        return categoryArray
    }
    
    func filterProductsByCategory(index: Int) {
        self.filterProducts.removeAll()
        if index < 0 {
            print("filterProductsByCategory -> self.selectedIndex < 0, just return")
            return
        }
        
        if self.detailMenuInformation.productCategory == nil {
            print("filterProductsByCategory -> self.detailMenuInformation.productCategory == nil, just return")
            return
        }
        
        if self.detailMenuInformation.productCategory!.isEmpty {
            print("filterProductsByCategory -> self.detailMenuInformation.productCategory is empty, just return")
            return
        }

        if self.detailMenuInformation.productCategory![index].productItems == nil {
            print("filterProductsByCategory -> self.detailMenuInformation.productCategory![index].productItems is nil, just return")
            return

        }
        
        self.filterProducts = self.detailMenuInformation.productCategory![index].productItems!
    }

    func setupShortageProducts() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let dayString = formatter.string(from: Date())
        
        downloadFBStoreShortageProductList(brand_name: self.menuOrder!.brandName, store_name: self.menuOrder!.storeInfo!.storeName!, day_string: dayString, completion: { shortageList in
            if shortageList == nil {
                return
            }
            
            self.shortageProducts = shortageList!
            print("self.shortageProducts = \(self.shortageProducts)")
            self.tableView.reloadData()
        })
    }
    
    func verifyShortageProduct(item_name: String) -> Bool {
        var result: Bool = false
        
        if !self.shortageProducts.isEmpty {
            if self.shortageProducts.contains(where: {$0.itemProduct == item_name}) {
                result = true
            }
        }
        
        return result
    }
    
    func getPriceRecipeItems(index: Int) -> [String] {
        var itemsString: [String] = [String]()

        if index < 0 {
            print("getPriceRecipeItems -> self.selectedIndex < 0, just return")
            return itemsString
        }

        let priceTemplate = self.detailMenuInformation.productCategory![index].priceTemplate
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

    @IBAction func addCustomProduct(_ sender: UIButton) {
        let controller = UIAlertController(title: "請輸入自訂的產品資訊", message: nil, preferredStyle: .alert)

        guard let customlController = self.storyboard?.instantiateViewController(withIdentifier: "CUSTOM_PRODUCT_VC") as? CustomProductViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: CUSTOM_PRODUCT_VC can't find!! (DetailJoinGroupOrderTableViewCOntroller)")
            return
        }

        customlController.preferredContentSize.height = 250
        controller.preferredContentSize.height = 250
        customlController.preferredContentSize.width = 320
        controller.preferredContentSize.width = 320
        controller.setValue(customlController, forKey: "contentViewController")
        controller.addChild(customlController)
        
        //customlController.setData(user_info: userInfo)
        customlController.delegate = self
        
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func displayBrandCart(_ sender: UIBarButtonItem) {
        if self.memberIndex < 0 {
            print("memberIndex wrong in JoinGroupOrderTableViewController !!")
            presentSimpleAlertMessage(title: "錯誤訊息", message: "內部錯誤：memberIndex值為錯誤")
            return
        }

        if self.menuOrder!.locations != nil {
            if self.segmentLocation.selectedSegmentIndex < 0 {
                // User does not select location, show alert
                print("Doesn't select location, just return")
                presentSimpleAlertMessage(title: "錯誤訊息", message: "尚未選擇地點，請重新選取地點資訊")
                return
            }
        }
        
        if self.menuOrder!.locations != nil {
            self.memberContent.orderContent.location = self.menuOrder!.locations![self.segmentLocation.selectedSegmentIndex]
        }

        guard let cartController = self.storyboard?.instantiateViewController(withIdentifier: "BRAND_CART_VC") as? BrandCartTableViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: BRAND_CART_VC can't find!! (DetailJoinGroupOrderTableViewController)")
            return
        }
        
        cartController.memberContent = self.memberContent
        cartController.brandName = self.detailMenuInformation.brandName
        cartController.memberIndex = self.memberIndex
        cartController.needContactInfoFlag = self.menuOrder!.needContactInfoFlag
        cartController.menuOrder = self.menuOrder!
        cartController.delegate = self

        self.navigationController?.show(cartController, sender: self)
    }
    
    func refreshJoinGroupOrder() {
        //self.labelBrandName.text = self.detailMenuInformation.brandName
        setupLocationSegment()
        self.productCategory = self.createBrandCategory()
        if !self.productCategory.isEmpty {
            self.setupSegmentCategory()
        }
        self.filterProductsByCategory(index: self.selectedIndex)
        setupCartBadgeNumber()
        self.tableView.reloadData()
    }

    @IBAction func changeLocationIndex(_ sender: UISegmentedControl) {
        self.selectedLocationIndex = self.segmentLocation.selectedSegmentIndex
        self.isNeedToConfirmFlag = true
    }

    func setupLocationSegment() {
        self.segmentLocation.removeAllSegments()
        if self.menuOrder!.locations == nil {
            self.segmentLocation.isEnabled = false
            self.segmentLocation.isHidden = true
        } else {
            if !self.menuOrder!.locations!.isEmpty {
                self.segmentLocation.isEnabled = true
                self.segmentLocation.isHidden = false
                for i in 0...(self.menuOrder!.locations!.count - 1) {
                    self.segmentLocation.insertSegment(withTitle: self.menuOrder!.locations![i], at: i, animated: true)
                    if self.memberContent.orderContent.location == self.menuOrder!.locations![i] {
                        self.segmentLocation.selectedSegmentIndex = i
                    }
                }
            }
        }
        
        print("self.segmentLocation.selectedSegmentIndex = \(self.segmentLocation.selectedSegmentIndex)")
    }

    func setupCartBadgeNumber() {
        if self.memberContent.orderContent.menuProductItems != nil {
            self.barButtonCart.addBadge(text: String(self.memberContent.orderContent.menuProductItems!.count))
        } else {
            self.barButtonCart.removeBadge()
        }

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 3 {
            if self.selectedIndex < 0 {
                return 0
            }
            
            if self.filterProducts.isEmpty {
                return 0
            }
            
            print("self.productItemsTableView numberOfRowsInSection = \(self.filterProducts.count)")
            return self.filterProducts.count
        }
        
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductPriceWithCartCell", for: indexPath) as! ProductPriceWithCartCell
            let contents = self.getPriceRecipeItems(index: self.selectedIndex)
            //let description = self.filterProducts[indexPath.row].productDescription ?? ""
            cell.setData(name: "", description: "", contents: contents, index: indexPath.row, style: 0, standalone_flag: false)
            cell.selectionStyle = UITableViewCell.SelectionStyle.none

            return cell
        }
        
        if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductPriceWithCartCell", for: indexPath) as! ProductPriceWithCartCell
            
            cell.delegate = self
            let contents = self.getProductPriceItems(index: indexPath.row)
            let description = self.filterProducts[indexPath.row].productDescription ?? ""
            cell.setData(name: self.filterProducts[indexPath.row].productName, description: description, contents: contents, index: indexPath.row, style: 1, standalone_flag: self.standAloneFlagArray[self.selectedIndex])
            if !self.shortageProducts.isEmpty {
                if self.verifyShortageProduct(item_name: self.filterProducts[indexPath.row].productName) {
                    cell.setDisable()
                }
            }
            cell.selectionStyle = UITableViewCell.SelectionStyle.none

            return cell
        }
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }

    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        if indexPath.section == 3 {
            let newIndexPath = IndexPath(row: 0, section: indexPath.section)
            return super.tableView(tableView, indentationLevelForRowAt: newIndexPath)
        } else {
            return super.tableView(tableView, indentationLevelForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 2 {
            //print("Enter tableView didSelectRowAt function")
            let databaseRef = Database.database().reference()
            let orderString = "USER_MENU_ORDER/\(self.memberContent.orderOwnerID)/\(self.memberContent.orderContent.orderNumber)"
            databaseRef.child(orderString).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    let itemRawData = snapshot.value
                    let jsonData = try? JSONSerialization.data(withJSONObject: itemRawData as Any, options: [])

                    let decoder: JSONDecoder = JSONDecoder()
                    do {
                        self.menuOrder = try decoder.decode(MenuOrder.self, from: jsonData!)
                        if self.menuOrder != nil {
                            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                            guard let boardController = storyBoard.instantiateViewController(withIdentifier: "ORDER_BOARD_VC") as? MenuOrderBoardViewController else{
                                assertionFailure("[AssertionFailure] StoryBoard: ORDER_BOARD_VC can't find!! (QRCodeViewController)")
                                return
                            }
                            
                            boardController.menuOrder = self.menuOrder!
                            boardController.delegate = self
                            
                            self.navigationController?.show(boardController, sender: self)
                        }
                    } catch {
                        print("attendGroupOrder jsonData decode failed: \(error.localizedDescription)")
                        presentSimpleAlertMessage(title: "錯誤訊息", message: "存取訂單資料時發生錯誤")
                    }
                } else {
                    print("attendGroupOrder snapshot doesn't exist!")
                    presentSimpleAlertMessage(title: "錯誤訊息", message: "訂單資料不存在，請聯絡團購發起人")
                }
            }) { (error) in
                print(error.localizedDescription)
                presentSimpleAlertMessage(title: "錯誤訊息", message: error.localizedDescription)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 || indexPath.section == 3 {
            return 44
        }

        if indexPath.section == 0 && indexPath.row == 1 {
            if self.menuOrder?.locations == nil {
                return 0
            }
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || section == 2 || section == 3 {
            return 0
        }
        
        return 50
    }
}

extension DetailJoinGroupOrderTableViewController: MenuOrderBoardDelegate {
    func setFollowProductInformation(items: [MenuProductItem]) {
        if !items.isEmpty {
            if self.memberContent.orderContent.menuProductItems != nil {
                //if (self.memberContent.orderContent.menuProductItems!.count + items.count) > MAX_NEW_PRODUCT_COUNT {
                //    print("Over the max number limitation of new product")
                //    presentSimpleAlertMessage(title: "錯誤訊息", message: "產品項目超過限制(最多10種)，請重新輸入產品資訊")
                //    return
                //} else {
                    for i in 0...items.count - 1 {
                        self.memberContent.orderContent.menuProductItems!.append(items[i])
                    }
                //}
            } else {
                //if items.count > MAX_NEW_PRODUCT_COUNT {
                //    print("Over the max number limitation of new product")
                //    presentSimpleAlertMessage(title: "錯誤訊息", message: "產品項目超過限制(最多10種)，請重新輸入產品資訊")
                //    return
                //} else {
                    self.memberContent.orderContent.menuProductItems = items
                //}
            }

            if self.memberContent.orderContent.menuProductItems != nil {
                var totalQuantity: Int = 0
                for i in 0...self.memberContent.orderContent.menuProductItems!.count - 1 {
                    totalQuantity = totalQuantity + self.memberContent.orderContent.menuProductItems![i].itemQuantity
                }
                self.memberContent.orderContent.itemQuantity = totalQuantity
            }
            
            self.isNeedToConfirmFlag = true
            self.setupCartBadgeNumber()
            self.tableView.reloadData()
        }
    }
}

extension DetailJoinGroupOrderTableViewController: GADInterstitialDelegate {
    /// Tells the delegate an ad request succeeded.
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("interstitialDidReceiveAd")
        if self.interstitialAd.isReady {
            //self.interstitialAd.present(fromRootViewController: self)
            refreshJoinGroupOrder()
        } else {
            print("Interstitial Ad is not ready !!")
        }
    }

    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
        refreshJoinGroupOrder()
    }

    /// Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        print("interstitialWillPresentScreen")
    }

    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        print("interstitialWillDismissScreen")
    }

    /// Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("interstitialDidDismissScreen")
    }

    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        print("interstitialWillLeaveApplication")
    }
}

extension DetailJoinGroupOrderTableViewController: ScrollUISegmentControllerDelegate {
    func selectItemAt(index: Int, onScrollUISegmentController scrollUISegmentController: ScrollUISegmentController) {
        //print("select Item At [\(index)] in scrollUISegmentController")
        self.selectedIndex = index
        self.filterProductsByCategory(index: self.selectedIndex)
        self.tableView.reloadData()
    }
}

extension DetailJoinGroupOrderTableViewController: CustomProductDelegate {
    func getAddedProductInfo(sender: CustomProductViewController, name: String, quantity: Int, single_price: Int, comments: String) {
        print("DetailJoinGroupOrderTableViewController received CustomProductDelegate")
        var menuItem: MenuProductItem = MenuProductItem()
        
        var menuItemSequenceIndex = 0
        //menuItem.sequenceNumber == ??
        menuItem.itemName = name
        menuItem.itemQuantity = quantity
        menuItem.itemPrice = single_price
        menuItem.itemComments = comments

        if self.memberContent.orderContent.menuProductItems == nil {
            self.memberContent.orderContent.menuProductItems = [MenuProductItem]()
            menuItemSequenceIndex = 1
        }
        if !self.memberContent.orderContent.menuProductItems!.isEmpty {
            //if self.memberContent.orderContent.menuProductItems!.count == MAX_NEW_PRODUCT_COUNT {
            //    presentSimpleAlertMessage(title: "錯誤訊息", message: "產品項目超過限制(最多10種)，請重新輸入產品資訊")
            //    return
            //}
            let lastIndex = self.memberContent.orderContent.menuProductItems!.count - 1
            menuItemSequenceIndex = self.memberContent.orderContent.menuProductItems![lastIndex].sequenceNumber + 1
        }
        menuItem.sequenceNumber = menuItemSequenceIndex
        self.memberContent.orderContent.menuProductItems?.append(menuItem)
        
        if self.memberContent.orderContent.menuProductItems != nil {
            var totalQuantity: Int = 0
            for i in 0...self.memberContent.orderContent.menuProductItems!.count - 1 {
                totalQuantity = totalQuantity + self.memberContent.orderContent.menuProductItems![i].itemQuantity
            }
            self.memberContent.orderContent.itemQuantity = totalQuantity
        }
        
        self.setupCartBadgeNumber()
        self.isNeedToConfirmFlag = true
        self.tableView.reloadData()

    }
}

extension DetailJoinGroupOrderTableViewController: ProductPriceWithCartDelegate {
    func addProductToCart(sender: ProductPriceWithCartCell, index: Int) {
        print("Product[\(index)] add to Cart!")
        guard let recipeController = self.storyboard?.instantiateViewController(withIdentifier: "DETAIL_SELECT_RECIPE_VC") as? DetailJoinGroupOrderSelectRecipeTableViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: DETAIL_SELECT_RECIPE_VC can't find!! (DetailJoinGroupOrderTableViewController)")
            return
        }
        
        if self.detailMenuInformation.recipeTemplates != nil {
            recipeController.recipeTemplates = self.detailMenuInformation.recipeTemplates!
        }
        self.selectedProductIndex = index
        recipeController.detailProductItem = self.filterProducts[index]
        recipeController.mandatoryFlag = self.mandatoryFlagArray[self.selectedIndex]
        recipeController.shortageProducts = self.shortageProducts
        recipeController.delegate = self
        
        self.navigationController?.show(recipeController, sender: self)
    }
}

extension DetailJoinGroupOrderTableViewController: DetailJoinGroupOrderSelectRecipeDelegate {
    func convertProductItem(item: [DetailRecipeTemplate], quantity: Int, single_price: Int, comments: String) -> MenuProductItem {
        var menuItem: MenuProductItem = MenuProductItem()
        
        //var menuItemSequenceIndex = 0
        menuItem.itemName = self.filterProducts[self.selectedProductIndex].productName
        menuItem.itemQuantity = quantity
        menuItem.itemPrice = single_price
        menuItem.itemComments = comments

        /*
        if self.memberContent.orderContent.menuProductItems == nil {
           self.memberContent.orderContent.menuProductItems = [MenuProductItem]()
           menuItemSequenceIndex = 1
        }
        if !self.memberContent.orderContent.menuProductItems!.isEmpty {
           let lastIndex = self.memberContent.orderContent.menuProductItems!.count - 1
           menuItemSequenceIndex = self.memberContent.orderContent.menuProductItems![lastIndex].sequenceNumber + 1
        }
        menuItem.sequenceNumber = menuItemSequenceIndex
        */
        
        if item.isEmpty {
            return menuItem
        }
        
        var menuRecipeSequenceIndex: Int = 0
        for i in 0...item.count - 1 {
            if !item[i].recipeList.isEmpty {
                var isFoundItem: Bool = false
                for j in 0...item[i].recipeList.count - 1 {
                    if item[i].recipeList[j].itemCheckedFlag {
                        isFoundItem = true
                    }
                }
                
                if !isFoundItem {
                    continue
                }
                
                menuRecipeSequenceIndex = menuRecipeSequenceIndex + 1
                var menuRecipe: MenuRecipe = MenuRecipe()
                menuRecipe.allowedMultiFlag = self.allowedMultiFlagArray[self.selectedIndex]
                menuRecipe.recipeCategory = item[i].templateName
                menuRecipe.sequenceNumber = menuRecipeSequenceIndex
                menuRecipe.recipeItems = [RecipeItem]()
                var recipeItemSequenceIndex: Int = 0
                for k in 0...item[i].recipeList.count - 1 {
                    if item[i].recipeList[k].itemCheckedFlag {
                        recipeItemSequenceIndex = recipeItemSequenceIndex + 1
                        var recipeItem: RecipeItem = RecipeItem()
                        recipeItem.sequenceNumber = recipeItemSequenceIndex
                        recipeItem.checkedFlag = true
                        recipeItem.recipeName = item[i].recipeList[k].itemName
                        menuRecipe.recipeItems!.append(recipeItem)
                    }
                }
                
                if menuItem.menuRecipes == nil {
                     menuItem.menuRecipes = [MenuRecipe]()
                }
                menuItem.menuRecipes!.append(menuRecipe)
            }
        }
        
        return menuItem
    }
    
    func confirmProductRecipe(sender: DetailJoinGroupOrderSelectRecipeTableViewController, recipe_items: [DetailRecipeTemplate], quantity: Int, single_price: Int, comments: String) {
        print("DetailJoinGroupOrderTableViewController received DetailJoinGroupOrderSelectRecipeDelegate")
        //print("Product Item = \(recipe_items)")
        
        var menuItemSequenceIndex = 0

        if self.memberContent.orderContent.menuProductItems == nil {
            self.memberContent.orderContent.menuProductItems = [MenuProductItem]()
            menuItemSequenceIndex = 1
        }
        if !self.memberContent.orderContent.menuProductItems!.isEmpty {
            //if self.memberContent.orderContent.menuProductItems!.count == MAX_NEW_PRODUCT_COUNT {
            //    presentSimpleAlertMessage(title: "錯誤訊息", message: "產品項目超過限制(最多10種)，請重新輸入產品資訊")
            //    return
            //}
            let lastIndex = self.memberContent.orderContent.menuProductItems!.count - 1
            menuItemSequenceIndex = self.memberContent.orderContent.menuProductItems![lastIndex].sequenceNumber + 1
        }
        
        var menu_item = self.convertProductItem(item: recipe_items, quantity: quantity, single_price: single_price, comments: comments)
        
        menu_item.sequenceNumber = menuItemSequenceIndex
        self.memberContent.orderContent.menuProductItems?.append(menu_item)
        
        if self.memberContent.orderContent.menuProductItems != nil {
            var totalQuantity: Int = 0
            for i in 0...self.memberContent.orderContent.menuProductItems!.count - 1 {
                totalQuantity = totalQuantity + self.memberContent.orderContent.menuProductItems![i].itemQuantity
            }
            self.memberContent.orderContent.itemQuantity = totalQuantity
        }
        
        self.setupCartBadgeNumber()
        self.isNeedToConfirmFlag = true
        //let sectionIndex = IndexSet(integer: 1)
        //self.tableView.reloadSections(sectionIndex, with: .automatic)
        self.tableView.reloadData()
    }
}

extension DetailJoinGroupOrderTableViewController: BrandCartDelegate {
    func changeOrderContent(sender: BrandCartTableViewController, content: [MenuProductItem]?) {
        self.memberContent.orderContent.menuProductItems = content
        setupCartBadgeNumber()
    }
}
