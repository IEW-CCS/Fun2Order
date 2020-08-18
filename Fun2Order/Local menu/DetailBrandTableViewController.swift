//
//  DetailBrandTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/6/27.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Firebase

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
    var bannerView: GADBannerView!
    var menuOrder: MenuOrder = MenuOrder()

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

        self.bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        addBannerViewToView(self.bannerView)

        self.segmentCategory.segmentDelegate = self
        downloadFBDetailBrandProfile(brand_name: self.brandName, completion: receiveFBDetailBrandProfile)
    }

    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(bannerView)
        view.addConstraints([NSLayoutConstraint(item: bannerView,
                            attribute: .bottom,
                            relatedBy: .equal,
                            toItem: bottomLayoutGuide,
                            attribute: .top,
                            multiplier: 1,
                            constant: 0),
         NSLayoutConstraint(item: bannerView,
                            attribute: .centerX,
                            relatedBy: .equal,
                            toItem: view,
                            attribute: .centerX,
                            multiplier: 1,
                            constant: 0)
        ])
        
        bannerView.adUnitID = NOTIFICATIONLIST_BANNER_AD
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
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
        //let groupList = retrieveGroupList()
        //if groupList.isEmpty{
        //    presentSimpleAlertMessage(title: "提示訊息", message: "您尚未建立任何群組，請至\n『我的設定』--> 『群組資訊』中\n先建立群組並加入好友\n之後即可開始使用揪團功能")
        //    return
        //}
        let controller = UIAlertController(title: "選擇訂購方式", message: nil, preferredStyle: .alert)
        
        let groupAction = UIAlertAction(title: "揪團訂購", style: .default) { (_) in
            print("Create GroupOrder for friends")
            guard let groupOrderController = self.storyboard?.instantiateViewController(withIdentifier: "DETAIL_CREATE_ORDER_VC") as? DetailGroupOrderTableViewController else {
                assertionFailure("[AssertionFailure] StoryBoard: DETAIL_CREATE_ORDER_VC can't find!! (MenuListTableViewController)")
                return
            }
            groupOrderController.orderType = ORDER_TYPE_OFFICIAL_MENU
            groupOrderController.brandName = self.brandName
            groupOrderController.detailMenuInformation = self.detailMenuInfo
            self.navigationController?.show(groupOrderController, sender: self)
        }
        
        groupAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        controller.addAction(groupAction)
        
        let singleAction = UIAlertAction(title: "自己訂購", style: .default) { (_) in
            print("Create GroupOrder for myself")
            self.createMenuOrder()
        }
        
        singleAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        controller.addAction(singleAction)
        
        let cancelAction = UIAlertAction(title: "取消", style: .default) { (_) in
           print("Cancel update")
        }
        
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        controller.addAction(cancelAction)
        
        present(controller, animated: true, completion: nil)

    }
    
    func createMenuOrder() {
        let timeZone = TimeZone.init(identifier: "UTC+8")
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.locale = Locale.init(identifier: "zh_TW")
        formatter.dateFormat = DATETIME_FORMATTER
        
        let tmpOrderNumber = "M\(formatter.string(from: Date()))"
      
        self.menuOrder.orderNumber = tmpOrderNumber
        self.menuOrder.menuNumber = self.detailMenuInfo.menuNumber
        self.menuOrder.orderType = ORDER_TYPE_OFFICIAL_MENU
        self.menuOrder.orderStatus = ORDER_STATUS_READY
        self.menuOrder.orderOwnerID = Auth.auth().currentUser!.uid
        self.menuOrder.orderOwnerName = getMyUserName()
        self.menuOrder.orderTotalQuantity = 0
        self.menuOrder.orderTotalPrice = 0
        self.menuOrder.brandName = self.detailMenuInfo.brandName
        self.menuOrder.needContactInfoFlag = false
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = DATETIME_FORMATTER
        let timeString = timeFormatter.string(from: Date())
        self.menuOrder.createTime = timeString
        self.menuOrder.dueTime = ""

        var myContent: MenuOrderMemberContent = MenuOrderMemberContent()
        var myItem: MenuOrderContentItem = MenuOrderContentItem()

        myContent.memberID = Auth.auth().currentUser!.uid
        myContent.orderOwnerID = self.menuOrder.orderOwnerID
        myContent.memberTokenID = getMyTokenID()
        myItem.orderNumber = self.menuOrder.orderNumber
        myItem.itemOwnerID = Auth.auth().currentUser!.uid
        myItem.itemOwnerName = getMyUserName()
        myItem.replyStatus = MENU_ORDER_REPLY_STATUS_WAIT
        myItem.createTime = self.menuOrder.createTime
        myContent.orderContent = myItem
        myItem.ostype = "iOS"

        self.menuOrder.contentItems.append(myContent)
        self.uploadMenuOrder()
        self.sendMulticastNotification()
    }
    
    func uploadMenuOrder() {
        let databaseRef = Database.database().reference()
        
        if Auth.auth().currentUser?.uid == nil {
            print("uploadMenuOrder Auth.auth().currentUser?.uid == nil")
            return
        }
        
        let pathString = "USER_MENU_ORDER/\(Auth.auth().currentUser!.uid)/\(self.menuOrder.orderNumber)"
        databaseRef.child(pathString).setValue(self.menuOrder.toAnyObject()) { (error, reference) in
            if let error = error {
                print("uploadMenuOrder error = \(error.localizedDescription)")
                return
            } else {
                // Send notification to refresh HistoryList function
                print("GroupOrderViewController sends notification to refresh History List function")
                NotificationCenter.default.post(name: NSNotification.Name("RefreshHistory"), object: nil)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let join_vc = storyboard.instantiateViewController(withIdentifier: "DETAIL_JOIN_ORDER_VC") as? DetailJoinGroupOrderTableViewController else{
                    assertionFailure("[AssertionFailure] StoryBoard: JOIN_ORDER_VC can't find!! (GroupOrderViewController)")
                    return
                }

                join_vc.detailMenuInformation = self.detailMenuInfo
                join_vc.memberContent = self.menuOrder.contentItems[0]
                join_vc.memberIndex = 0
                join_vc.menuOrder = self.menuOrder
                DispatchQueue.main.async {
                    self.show(join_vc, sender: self)
                }
            }
        }
    }

    func sendMulticastNotification() {
        var tokenIDs: [String] = [String]()
        
        if !self.menuOrder.contentItems.isEmpty {
            var orderNotify: NotificationData = NotificationData()
            let title: String = "團購邀請"
            var body: String = ""
            let dateNow = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = DATETIME_FORMATTER
            let dateTimeString = formatter.string(from: dateNow)

            body = "來自『 \(self.menuOrder.orderOwnerName)』 發起的團購邀請，請點擊通知以查看詳細資訊。"
            orderNotify.messageTitle = title
            orderNotify.messageBody = body
            orderNotify.notificationType = NOTIFICATION_TYPE_ACTION_JOIN_ORDER
            orderNotify.receiveTime = dateTimeString
            orderNotify.orderOwnerID = self.menuOrder.orderOwnerID
            orderNotify.orderOwnerName = self.menuOrder.orderOwnerName
            orderNotify.menuNumber = self.menuOrder.menuNumber
            orderNotify.orderNumber = self.menuOrder.orderNumber
            orderNotify.dueTime = self.menuOrder.dueTime
            orderNotify.brandName = self.menuOrder.brandName
            orderNotify.attendedMemberCount = self.menuOrder.contentItems.count
            orderNotify.messageDetail = ""
            orderNotify.isRead = "Y"

            // send to iOS type device
            for i in 0...self.menuOrder.contentItems.count - 1 {
                if self.menuOrder.contentItems[i].orderContent.ostype != nil {
                    if self.menuOrder.contentItems[i].orderContent.ostype! == OS_TYPE_IOS {
                        tokenIDs.append(self.menuOrder.contentItems[i].memberTokenID)
                    }
                } else {
                    tokenIDs.append(self.menuOrder.contentItems[i].memberTokenID)
                }
            }
            
            if !tokenIDs.isEmpty {
                let sender = PushNotificationSender()
                sender.sendMulticastMessage(to: tokenIDs, notification_key: "", title: title, body: body, data: orderNotify, ostype: OS_TYPE_IOS)
            }
            
            tokenIDs.removeAll()
            // send to Android type device
            for i in 0...self.menuOrder.contentItems.count - 1 {
                if self.menuOrder.contentItems[i].orderContent.ostype != nil {
                    if self.menuOrder.contentItems[i].orderContent.ostype! == OS_TYPE_ANDROID {
                        tokenIDs.append(self.menuOrder.contentItems[i].memberTokenID)
                    }
                }
            }
            
            if !tokenIDs.isEmpty {
                let sender = PushNotificationSender()
                usleep(100000)
                sender.sendMulticastMessage(to: tokenIDs, notification_key: "", title: title, body: body, data: orderNotify, ostype: OS_TYPE_ANDROID)
            }
        }
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
            cell.selectionStyle = UITableViewCell.SelectionStyle.none

            return cell
        }
        
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductPriceCell", for: indexPath) as! ProductPriceCell

            let contents = self.getProductPriceItems(index: indexPath.row)
            let description = self.filterProducts[indexPath.row].productDescription ?? ""
            cell.setData(name: self.filterProducts[indexPath.row].productName, description: description, contents: contents, style: 1)
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

extension DetailBrandTableViewController: GADBannerViewDelegate {
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner loaded successfully")
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
          bannerView.alpha = 1
        })
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads")
        print(error)
    }
}
