//
//  JoinGroupOrderTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/1/8.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import GoogleMobileAds

protocol JoinGroupOrderDelegate: class {
    func refreshHistoryInvitationList(sender: JoinGroupOrderTableViewController)
    func refreshLimitedMenuItems(sender: JoinGroupOrderTableViewController, items: [MenuItem]?)
}

extension JoinGroupOrderDelegate {
    func refreshHistoryInvitationList(sender: JoinGroupOrderTableViewController) {}
    func refreshLimitedMenuItems(sender: JoinGroupOrderTableViewController, items: [MenuItem]?) {}
}

class JoinGroupOrderTableViewController: UITableViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {
    @IBOutlet weak var labelBrandName: UILabel!
    @IBOutlet weak var buttonDetailInfo: UIButton!
    @IBOutlet weak var segmentLocation: UISegmentedControl!
    @IBOutlet weak var barButtonCart: UIBarButtonItem!
    @IBOutlet weak var buttonAddCustom: UIButton!
    @IBOutlet weak var buttonAddNew: UIButton!
    @IBOutlet weak var textProductName: UITextField!
    @IBOutlet weak var labelQuantity: UILabel!
    @IBOutlet weak var stepperQuantity: UIStepper!
    @IBOutlet weak var textSinglePrice: UITextField!
    @IBOutlet weak var textComments: UITextField!
    
    var menuInformation: MenuInformation = MenuInformation()
    var memberContent: MenuOrderMemberContent = MenuOrderMemberContent()
    var menuOrder: MenuOrder?
    var memberIndex: Int = -1
    var interstitialAd: GADInterstitial!
    var selectedLocationIndex: Int = -1
    let app = UIApplication.shared.delegate as! AppDelegate
    weak var refreshNotificationDelegate: ApplicationRefreshNotificationDelegate?
    weak var delegate: JoinGroupOrderDelegate?
    var imageArray: [UIImage] = [UIImage]()
    var menuDescription: String = ""
    var isNeedToConfirmFlag: Bool = false
    var limitedMenuItems: [MenuItem]?
    var orderGlobalQuantity: [MenuItem]?
    var originalMenuProductItems: [MenuProductItem]? // **
    var productQuantity: Int = 0
    var selectedProductName: String = ""
    weak var brandCartVC: BrandCartTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshNotificationDelegate = app.notificationDelegate
        
        self.buttonDetailInfo.layer.borderWidth = 1.0
        self.buttonDetailInfo.layer.borderColor = UIColor.systemBlue.cgColor
        self.buttonDetailInfo.layer.cornerRadius = 6

        self.buttonAddNew.layer.borderWidth = 1.0
        self.buttonAddNew.layer.borderColor = UIColor.systemBlue.cgColor
        self.buttonAddNew.layer.cornerRadius = 6

        //let itemCellViewNib: UINib = UINib(nibName: "MenuItemCell", bundle: nil)
        //self.tableView.register(itemCellViewNib, forCellReuseIdentifier: "MenuItemCell")
        
        let itemCellViewNib: UINib = UINib(nibName: "MenuItemWithCartCell", bundle: nil)
        self.tableView.register(itemCellViewNib, forCellReuseIdentifier: "MenuItemWithCartCell")

        let backImage = self.navigationItem.leftBarButtonItem?.image
        let newBackButton = UIBarButtonItem(title: "返回", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        navigationController?.navigationBar.backIndicatorImage = backImage

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)

        self.labelBrandName.text = self.menuInformation.brandName
        self.labelQuantity.text = "0"
        self.textSinglePrice.keyboardType = .numberPad
        
        //self.limitedMenuItems = self.menuInformation.menuItems
        //self.limitedMenuItems = self.menuOrder?.limitedMenuItems
        prepareLimitedMenuItems()
        self.originalMenuProductItems = self.memberContent.orderContent.menuProductItems
        monitorFBProductQuantityLimit(owner_id: self.memberContent.orderOwnerID, order_number: self.memberContent.orderContent.orderNumber, completion: getLimitedMenuItems)
        
        setupInterstitialAd()
        setupCartBadgeNumber()
        //refreshJoinGroupOrder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
          textField.resignFirstResponder()
          return true
    }

    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }

    func prepareLimitedMenuItems() {
        if self.menuInformation.menuItems == nil {
            print("Menu items is nil, just return")
            return
        }
        
        if !self.menuInformation.menuItems!.isEmpty {
            self.limitedMenuItems = [MenuItem]()
            for i in 0...self.menuInformation.menuItems!.count - 1 {
                var item: MenuItem = MenuItem()
                item.itemName = self.menuInformation.menuItems![i].itemName
                item.itemPrice = self.menuInformation.menuItems![i].itemPrice
                item.sequenceNumber = self.menuInformation.menuItems![i].sequenceNumber
                self.limitedMenuItems!.append(item)
            }
        }
    }
    
    func getLimitedMenuItems(items: [MenuItem]?) {
        print("JoinGroupOrderTableViewController getLimitedMenuItems: Menu Items = \(String(describing: items))")
        
        self.orderGlobalQuantity = items
        if items == nil || self.limitedMenuItems == nil {
            print("getLimitedMenuItems: Limited menu items == nil, reset limited quantity information")
            if self.limitedMenuItems != nil {
                if !self.limitedMenuItems!.isEmpty {
                    for i in 0...self.limitedMenuItems!.count - 1 {
                        self.limitedMenuItems![i].quantityLimitation = nil
                        self.limitedMenuItems![i].quantityRemained = nil
                    }
                }
            }
            return
        }
        
        for i in 0...self.limitedMenuItems!.count - 1 {
            for j in 0...items!.count - 1 {
                if self.limitedMenuItems![i].itemName == items![j].itemName {
                    self.limitedMenuItems![i] = items![j]
                    continue
                }
            }
        }
        
        self.brandCartVC?.setLimitedMenuItems(items: self.limitedMenuItems, global_quantity: self.orderGlobalQuantity)
        
        //self.delegate?.refreshLimitedMenuItems(sender: self, items: self.limitedMenuItems)
        //print("self.limitedMenuItems = \(String(describing: self.limitedMenuItems))")
        self.tableView.reloadData()
    }

    @objc func back(sender: UIBarButtonItem) {
        var alertWindow: UIWindow!
        if self.isNeedToConfirmFlag {
            let controller = UIAlertController(title: "提示訊息", message: "訂購單已更動，您確定要離開嗎？", preferredStyle: .alert)

            let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
                print("Confirm to ignore JoinOrder change")
                self.releaseFBObserver()
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
            self.releaseFBObserver()
            self.navigationController?.popToRootViewController(animated: true)
            self.dismiss(animated: false, completion: nil)
        }
    }

    func releaseFBObserver() {
        let databaseRef = Database.database().reference()
        let pathString = "USER_MENU_ORDER/\(self.memberContent.orderOwnerID)/\(self.memberContent.orderContent.orderNumber)/limitedMenuItems"

        databaseRef.child(pathString).removeAllObservers()
    }

    func setupInterstitialAd() {
        let adUnitID = JOINORDER_INTERSTITIAL_AD
        self.interstitialAd = GADInterstitial(adUnitID: adUnitID)
        let adRequest = GADRequest()
        self.interstitialAd.load(adRequest)
        self.interstitialAd.delegate = self
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
        self.brandCartVC = cartController
        cartController.memberContent = self.memberContent
        cartController.brandName = self.menuInformation.brandName
        cartController.memberIndex = self.memberIndex
        cartController.needContactInfoFlag = self.menuOrder!.needContactInfoFlag
        cartController.originalMenuProductItems = self.originalMenuProductItems
        cartController.orderGlobalQuantity = self.orderGlobalQuantity
        cartController.delegate = self

        self.navigationController?.show(cartController, sender: self)
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
        
        customlController.delegate = self
        
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func addNewProduct(_ sender: UIButton) {
        var singlePrice: Int = 0
        var menuItem: MenuProductItem = MenuProductItem()
        
        var menuItemSequenceIndex = 0

        let product_string = self.textProductName.text
        if product_string == nil || product_string!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            presentSimpleAlertMessage(title: "錯誤訊息", message: "新增的產品名稱不能為空白，請重新輸入")
            return
        }
        
        if self.labelQuantity.text! == "0" {
            presentSimpleAlertMessage(title: "錯誤資訊", message: "產品數量不能為零，請重新指定產品數量")
            return
        }
        
        if !checkLimitedMenuItemsRemainedQuantity(limited_items: self.limitedMenuItems, product_name: product_string!, product_quantity: Int(self.labelQuantity.text!)!) {
            return
        }
        
        var comments_string: String = ""
        if self.textComments.text != nil {
            comments_string = self.textComments.text!
        }
        
        if self.textSinglePrice.text != nil {
            singlePrice = Int(self.textSinglePrice.text!)!
        }

        menuItem.itemName = product_string!
        menuItem.itemQuantity = Int(self.labelQuantity.text!)!
        menuItem.itemPrice = singlePrice
        menuItem.itemComments = comments_string
        
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
        
    func refreshJoinGroupOrder() {
        self.labelBrandName.text = self.menuInformation.brandName
        self.menuDescription = self.menuInformation.menuDescription
        setupLocationSegment()
        if self.menuInformation.multiMenuImageURL != nil {
            downloadFBMultiMenuImages(images_url: self.menuInformation.multiMenuImageURL!, completion: receivedMultiMenuImages)
        } else {
            if self.menuInformation.menuImageURL != "" {
                downloadFBMultiMenuImages(images_url: [self.menuInformation.menuImageURL], completion: receivedOriginalSingleMenuImage)
            }
        }
        self.setupCartBadgeNumber()
    }

    func receivedMultiMenuImages(images: [UIImage]?) {
        if images != nil {
            self.imageArray = images!
            self.tableView.reloadData()
        } else {
            if self.menuInformation.menuImageURL != "" {
                downloadFBMultiMenuImages(images_url: [self.menuInformation.menuImageURL], completion: receivedOriginalSingleMenuImage)
            }
        }
    }
    
    func receivedOriginalSingleMenuImage(images: [UIImage]?) {
        if images != nil {
            self.imageArray.append(images![0])
            self.tableView.reloadData()
        }
    }
    
    @IBAction func changeQuantity(_ sender: UIStepper) {
        self.productQuantity = Int(sender.value)
        self.labelQuantity.text = String(self.productQuantity)
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
            if self.menuInformation.menuItems == nil {
                print("self.menuInformation.menuItems == nil, numberOfRowsInSection return 0")
                return 0
            }
            
            print("self.menuInformation.menuItems numberOfRowsInSection return \(self.menuInformation.menuItems!.count)")
            return self.menuInformation.menuItems!.count
        }
        
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 2 {
            if self.menuInformation.menuItems != nil {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemWithCartCell", for: indexPath) as! MenuItemWithCartCell
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                //cell.setProductInfo(product_info: MenuItem(), type: MENU_ITEM_CELL_TYPE_REMAINED_HEADER)
                let contents: [String] = ["價格", "限量"]
                cell.setData(name: "產品名稱", contents: contents, index: indexPath.row, style: 0)
                cell.selectionStyle = UITableViewCell.SelectionStyle.none

                cell.tag = indexPath.row
                
                return cell
            } else {
                return MenuItemCell()
            }
        }
        
        if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemWithCartCell", for: indexPath) as! MenuItemWithCartCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            //cell.setProductInfo(product_info: self.limitedMenuItems![indexPath.row], type: MENU_ITEM_CELL_TYPE_REMAINED_BODY)
            
            let price_string = String(self.limitedMenuItems![indexPath.row].itemPrice)
            var limit_quantity_string: String = ""
            if self.limitedMenuItems![indexPath.row].quantityLimitation != nil {
                if self.limitedMenuItems![indexPath.row].quantityRemained != nil {
                    limit_quantity_string = String(self.limitedMenuItems![indexPath.row].quantityRemained!)
                } else {
                    limit_quantity_string = String(self.limitedMenuItems![indexPath.row].quantityLimitation!)
                }
            }
            
            let contents: [String] = [price_string, limit_quantity_string]
            cell.setData(name: self.limitedMenuItems![indexPath.row].itemName, contents: contents, index: indexPath.row, style: 1)
            if self.limitedMenuItems != nil {
                if self.limitedMenuItems![indexPath.row].quantityRemained != nil {
                    let remainedQuantity: Int = Int(self.limitedMenuItems![indexPath.row].quantityRemained!)
                    if remainedQuantity == 0 {
                        cell.isUserInteractionEnabled = false
                        cell.setDisable()
                    }
                }
            }
            
            cell.delegate = self
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.tag = indexPath.row
            
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
                                assertionFailure("[AssertionFailure] StoryBoard: ORDER_BOARD_VC can't find!! (JoinGroupOrderTableViewController)")
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
        if indexPath.section == 0 && indexPath.row == 1 {
            if self.menuOrder!.locations == nil {
                return 0
            }
        }
        
        if indexPath.section == 0 && indexPath.row == 3 {
            if self.menuInformation.menuItems == nil {
                return 0
            }
        }
        
        if indexPath.section == 1 {
            if self.menuInformation.menuItems != nil {
                return 0
            }
        }
        
        if indexPath.section == 2 {
            if self.menuInformation.menuItems == nil {
                return 0
            }
        }
        
        if indexPath.section == 3 {
            return 44
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 || section == 3 {
            return 0
        }
        
        if section == 1 {
            if self.menuInformation.menuItems != nil {
                return 0
            }
        }
        if section == 2 {
            if self.menuInformation.menuItems == nil {
                return 0
            }
        }
        
        return 50
        //return super.tableView(tableView, heightForHeaderInSection: section)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowMenuImage" {
            if let controllerImage = segue.destination as? MenuImageDescriptionTableViewController {
                controllerImage.imageArray = self.imageArray
                controllerImage.menuDescription = self.menuInformation.menuDescription
                controllerImage.isDisplayMode = true
                //controllerImage.delegate = self
            }
        }
    }
}

extension JoinGroupOrderTableViewController: JoinOrderSelectProductDelegate {
    func setProduct(menu_item: MenuProductItem) {
        
        if self.memberContent.orderContent.menuProductItems == nil {
            self.memberContent.orderContent.menuProductItems = [MenuProductItem]()
        }
        
        self.memberContent.orderContent.menuProductItems?.append(menu_item)
        
        if self.memberContent.orderContent.menuProductItems != nil {
            var totalQuantity: Int = 0
            for i in 0...self.memberContent.orderContent.menuProductItems!.count - 1 {
                totalQuantity = totalQuantity + self.memberContent.orderContent.menuProductItems![i].itemQuantity
            }
            self.memberContent.orderContent.itemQuantity = totalQuantity
        }
        
        self.isNeedToConfirmFlag = true
        let sectionIndex = IndexSet(integer: 1)
        self.tableView.reloadSections(sectionIndex, with: .automatic)
        //self.tableView.reloadData()
    }
}

extension JoinGroupOrderTableViewController: MenuOrderBoardDelegate {
    func setFollowProductInformation(items: [MenuProductItem]) {
        if !items.isEmpty {
            if self.memberContent.orderContent.menuProductItems != nil {
                for i in 0...items.count - 1 {
                    self.memberContent.orderContent.menuProductItems!.append(items[i])
                }
            } else {
                self.memberContent.orderContent.menuProductItems = items
            }

            if self.memberContent.orderContent.menuProductItems != nil {
                var totalQuantity: Int = 0
                for i in 0...self.memberContent.orderContent.menuProductItems!.count - 1 {
                    totalQuantity = totalQuantity + self.memberContent.orderContent.menuProductItems![i].itemQuantity
                }
                self.memberContent.orderContent.itemQuantity = totalQuantity
            }
            
            self.isNeedToConfirmFlag = true
            let sectionIndex = IndexSet(integer: 1)
            self.tableView.reloadSections(sectionIndex, with: .automatic)
        }
    }
}

extension JoinGroupOrderTableViewController: BrandCartDelegate {
    func updateOrderContent(sender: BrandCartTableViewController, content: [MenuProductItem]?) {
        self.memberContent.orderContent.menuProductItems = content
        setupCartBadgeNumber()
    }
}

extension JoinGroupOrderTableViewController: CustomProductDelegate {
    func getAddedProductInfo(sender: CustomProductViewController, name: String, quantity: Int, single_price: Int, comments: String) {
        print("DetailJoinGroupOrderTableViewController received CustomProductDelegate")
        var menuItem: MenuProductItem = MenuProductItem()
        
        if !checkLimitedMenuItemsRemainedQuantity(limited_items: self.limitedMenuItems, product_name: name, product_quantity: quantity) {
            return
        }
        
        var menuItemSequenceIndex = 0
        menuItem.itemName = name
        menuItem.itemQuantity = quantity
        menuItem.itemPrice = single_price
        menuItem.itemComments = comments

        if self.memberContent.orderContent.menuProductItems == nil {
            self.memberContent.orderContent.menuProductItems = [MenuProductItem]()
            menuItemSequenceIndex = 1
        }
        if !self.memberContent.orderContent.menuProductItems!.isEmpty {
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

extension JoinGroupOrderTableViewController: GADInterstitialDelegate {
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

extension JoinGroupOrderTableViewController: MenuItemWithCartDelegate {
    func addProductToSelectRecipe(sender: MenuItemWithCartCell, index: Int) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        guard let recipeController = storyBoard.instantiateViewController(withIdentifier: "SELECT_RECIPE_VC") as? JoinOrderSelectRecipeTableViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: SELECT_RECIPE_VC can't find!! (JoinGroupOrderTableViewController)")
            return
        }
        self.selectedProductName = self.menuInformation.menuItems![index].itemName
        recipeController.productName = self.selectedProductName
        recipeController.menuInformation = self.menuInformation
        recipeController.isSelectRecipeMode = true
        recipeController.delegate = self

        self.navigationController?.show(recipeController, sender: self)
    }
}

extension JoinGroupOrderTableViewController: JoinOrderSelectRecipeDelegate {
    func setRecipe(sender: JoinOrderSelectRecipeTableViewController, recipe_items: [MenuRecipe], quantity: Int, single_price: Int, comments: String) {
        print("JoinGroupOrderTableViewController received setRecipe")
        //print("Product Item = \(recipe_items)")
        var menu_item: MenuProductItem = MenuProductItem()
        var menuItemSequenceIndex = 0
        var isAnyRecipeItemFound: Bool = false

        if !checkLimitedMenuItemsRemainedQuantity(limited_items: self.limitedMenuItems, product_name: self.selectedProductName, product_quantity: quantity) {
            return
        }
        
        if self.memberContent.orderContent.menuProductItems == nil {
            self.memberContent.orderContent.menuProductItems = [MenuProductItem]()
            menuItemSequenceIndex = 1
        }
        if !self.memberContent.orderContent.menuProductItems!.isEmpty {
            let lastIndex = self.memberContent.orderContent.menuProductItems!.count - 1
            menuItemSequenceIndex = self.memberContent.orderContent.menuProductItems![lastIndex].sequenceNumber + 1
        }
        
        menu_item.itemName = self.selectedProductName
        menu_item.itemQuantity = quantity
        menu_item.itemPrice = single_price
        menu_item.itemComments = comments

        // Create Recipe Items content string
        if !recipe_items.isEmpty {
            for i in 0...recipe_items.count - 1 {
                if recipe_items[i].recipeItems != nil {
                    for j in 0...recipe_items[i].recipeItems!.count - 1 {
                        if recipe_items[i].recipeItems![j].checkedFlag {
                            //recipeString = recipeString + self.menuRecipes[i].recipeItems![j].recipeName + " "
                            isAnyRecipeItemFound = true
                        }
                    }
                }
            }
        }

        //self.labelRecipe.text = recipeString
        
        if isAnyRecipeItemFound {
            var tmpMenuRecipes: [MenuRecipe] = [MenuRecipe]()
            for i in 0...recipe_items.count - 1 {
                var tmpMenuRecipe: MenuRecipe = MenuRecipe()
                tmpMenuRecipe.allowedMultiFlag = recipe_items[i].allowedMultiFlag
                tmpMenuRecipe.recipeCategory = recipe_items[i].recipeCategory
                tmpMenuRecipe.sequenceNumber = recipe_items[i].sequenceNumber
                var isFound: Bool = false
                var tmpItems: [RecipeItem] = [RecipeItem]()
                if recipe_items[i].recipeItems != nil {
                    for j in 0...recipe_items[i].recipeItems!.count - 1 {
                        if recipe_items[i].recipeItems![j].checkedFlag {
                            isFound = true
                            var tmpItem: RecipeItem = RecipeItem()
                            tmpItem.recipeName = recipe_items[i].recipeItems![j].recipeName
                            tmpItem.checkedFlag = recipe_items[i].recipeItems![j].checkedFlag
                            tmpItem.sequenceNumber = recipe_items[i].recipeItems![j].sequenceNumber
                            tmpItems.append(tmpItem)
                        }
                    }
                }
                
                if isFound {
                    tmpMenuRecipe.recipeItems = tmpItems
                    tmpMenuRecipes.append(tmpMenuRecipe)
                }
            }
            menu_item.menuRecipes = tmpMenuRecipes
        }

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
        self.tableView.reloadData()

    }
}
