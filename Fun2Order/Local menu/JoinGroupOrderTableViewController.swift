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

class JoinGroupOrderTableViewController: UITableViewController {
    @IBOutlet weak var labelBrandName: UILabel!
    @IBOutlet weak var segmentLocation: UISegmentedControl!
    @IBOutlet weak var buttonConfirm: UIButton!
    @IBOutlet weak var textViewDescription: UITextView!
    
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
    var originalMenuProductItems: [MenuProductItem]?
    var selectProductVC: JoinOrderSelectProductViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshNotificationDelegate = app.notificationDelegate

        self.textViewDescription.layer.borderWidth = 1
        self.textViewDescription.layer.borderColor = UIColor.lightGray.cgColor
        self.textViewDescription.layer.cornerRadius = 6
        self.textViewDescription.text = ""

        let productCellViewNib: UINib = UINib(nibName: "NewProductCell", bundle: nil)
        self.tableView.register(productCellViewNib, forCellReuseIdentifier: "NewProductCell")

        let backImage = self.navigationItem.leftBarButtonItem?.image
        let newBackButton = UIBarButtonItem(title: "返回", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        navigationController?.navigationBar.backIndicatorImage = backImage

        self.limitedMenuItems = self.menuInformation.menuItems
        self.originalMenuProductItems = self.memberContent.orderContent.menuProductItems
        monitorFBProductQuantityLimit(owner_id: self.memberContent.orderOwnerID, order_number: self.memberContent.orderContent.orderNumber, completion: getLimitedMenuItems)
        
        setupInterstitialAd()
        
        //refreshJoinGroupOrder()
    }

    func getLimitedMenuItems(items: [MenuItem]?) {
        print("JoinGroupOrderTableViewController getLimitedMenuItems: Menu Items = \(String(describing: items))")
        
        self.orderGlobalQuantity = items
        if items == nil || self.limitedMenuItems == nil {
            print("getLimitedMenuItems: Limited menu items == nil, no need to process")
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
        
        self.selectProductVC?.setMenuItems(items: self.limitedMenuItems)
        
        //self.delegate?.refreshLimitedMenuItems(sender: self, items: self.limitedMenuItems)
        //print("self.limitedMenuItems = \(String(describing: self.limitedMenuItems))")
        //self.tableViewProduct.reloadData()
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

        //databaseRef.child(pathString).observeSingleEvent(of: .value, with: { (snapshot) in
        databaseRef.child(pathString).removeAllObservers()
    }
    
    func verifyLimitedQuantity() -> Bool {
        var summaryOldMenuProductItems: [MenuProductItem]?
        var summaryNewMenuProductItems: [MenuProductItem]?
        var summaryFinalMenuProductItems: [MenuProductItem]?
        
        if self.originalMenuProductItems != nil {
            for i in 0...self.originalMenuProductItems!.count - 1 {
                if i == 0 {
                    summaryOldMenuProductItems = [MenuProductItem]()
                    summaryOldMenuProductItems!.append(self.originalMenuProductItems![i])
                } else {
                    var isFound: Bool = false
                    for j in 0...summaryOldMenuProductItems!.count - 1 {
                        if summaryOldMenuProductItems![j].itemName == self.originalMenuProductItems![i].itemName {
                            summaryOldMenuProductItems![j].itemQuantity = summaryOldMenuProductItems![j].itemQuantity + self.originalMenuProductItems![i].itemQuantity
                            isFound = true
                            break
                        }
                    }
                    if !isFound {
                        summaryOldMenuProductItems!.append(self.originalMenuProductItems![i])
                    }
                }
            }
        }

        if self.memberContent.orderContent.menuProductItems != nil {
            for i in 0...self.memberContent.orderContent.menuProductItems!.count - 1 {
                if i == 0 {
                    summaryNewMenuProductItems = [MenuProductItem]()
                    summaryNewMenuProductItems!.append(self.memberContent.orderContent.menuProductItems![i])
                } else {
                    var isFound: Bool = false
                    for j in 0...summaryNewMenuProductItems!.count - 1 {
                        if summaryNewMenuProductItems![j].itemName == self.memberContent.orderContent.menuProductItems![i].itemName {
                            summaryNewMenuProductItems![j].itemQuantity = summaryNewMenuProductItems![j].itemQuantity + self.memberContent.orderContent.menuProductItems![i].itemQuantity
                            isFound = true
                            break
                        }
                    }
                    if !isFound {
                        summaryNewMenuProductItems!.append(self.memberContent.orderContent.menuProductItems![i])
                    }
                }
            }
        }
        
        summaryFinalMenuProductItems = summaryNewMenuProductItems
        if summaryOldMenuProductItems != nil {
            for i in 0...summaryOldMenuProductItems!.count - 1 {
                var isFound: Bool = false
                let index: Int = i
                for j in 0...summaryFinalMenuProductItems!.count - 1 {
                    if summaryFinalMenuProductItems![j].itemName == summaryOldMenuProductItems![i].itemName {
                        summaryFinalMenuProductItems![j].itemQuantity = summaryFinalMenuProductItems![j].itemQuantity - summaryOldMenuProductItems![i].itemQuantity
                        isFound = true
                        break
                    }
                }
                if !isFound {
                    var tmpData: MenuProductItem = MenuProductItem()
                    tmpData = summaryOldMenuProductItems![index]
                    tmpData.itemQuantity = 0 - tmpData.itemQuantity
                    summaryFinalMenuProductItems!.append(tmpData)
                }
            }
        }

        if self.orderGlobalQuantity != nil && summaryFinalMenuProductItems != nil {
            var remainedQuantity: Int = 0
            for i in 0...summaryFinalMenuProductItems!.count - 1 {
                for j in 0...self.orderGlobalQuantity!.count - 1 {
                    if summaryFinalMenuProductItems![i].itemName == self.orderGlobalQuantity![j].itemName {
                        if self.orderGlobalQuantity![j].quantityLimitation == nil {
                            continue
                        }

                        if self.orderGlobalQuantity![j].quantityRemained != nil {
                            remainedQuantity = Int(self.orderGlobalQuantity![j].quantityRemained!)
                        }
                        
                        //if summaryFinalMenuProductItems![i].itemQuantity > remainedQuantity {
                        if (remainedQuantity - summaryFinalMenuProductItems![i].itemQuantity) < 0 {
                            presentSimpleAlertMessage(title: "錯誤訊息", message: "[\(summaryFinalMenuProductItems![i].itemName)] 為限量商品，目前訂購的數量已超過剩餘的數量，請修改數量或選擇其他產品後再重新送出")
                            return false
                        } else {
                            self.orderGlobalQuantity![j].quantityRemained = remainedQuantity - summaryFinalMenuProductItems![i].itemQuantity
                        }
                    }
                }
            }
        }
        return true
    }

    func setupInterstitialAd() {
        let adUnitID = JOINORDER_INTERSTITIAL_AD
        self.interstitialAd = GADInterstitial(adUnitID: adUnitID)
        let adRequest = GADRequest()
        self.interstitialAd.load(adRequest)
        self.interstitialAd.delegate = self
    }

    @IBAction func confirmToJoinOrder(_ sender: UIButton) {
        if self.memberIndex < 0 {
            print("memberIndex wrong in JoinGroupOrderTableViewController !!")
            presentSimpleAlertMessage(title: "錯誤訊息", message: "內部錯誤：memberIndex值為錯誤")
            return
        }

        //if self.menuInformation.locations != nil {
        if self.menuOrder!.locations != nil {
            if self.segmentLocation.selectedSegmentIndex < 0 {
                // User does not select location, show alert
                print("Doesn't select location, just return")
                presentSimpleAlertMessage(title: "錯誤訊息", message: "尚未選擇地點，請重新選取地點資訊")
                return
            }
        }
        
        if self.memberContent.orderContent.menuProductItems == nil {
            presentSimpleAlertMessage(title: "錯誤訊息", message: "尚未輸入任何產品資訊，請重新輸入")
            return
        }
        
        //if self.menuInformation.needContactInfoFlag != nil {
        //    if self.menuInformation.needContactInfoFlag! {
        if self.menuOrder!.needContactInfoFlag != nil {
            if self.menuOrder!.needContactInfoFlag! {
                let controller = UIAlertController(title: "訂單需要您輸入郵寄或聯絡資訊", message: nil, preferredStyle: .alert)

                guard let personalController = self.storyboard?.instantiateViewController(withIdentifier: "PERSONAL_CONTACT_VC") as? PersonalContactViewController else{
                    assertionFailure("[AssertionFailure] StoryBoard: PERSONAL_CONTACT_VC can't find!! (PersonalContactViewController)")
                    return
                }

                personalController.preferredContentSize.height = 200
                controller.preferredContentSize.height = 200
                personalController.preferredContentSize.width = 320
                controller.preferredContentSize.width = 320
                controller.setValue(personalController, forKey: "contentViewController")
                controller.addChild(personalController)
                
                let userInfo = getMyContactInfo()
                
                personalController.setData(user_info: userInfo)
                personalController.delegate = self
                
                present(controller, animated: true, completion: nil)
            } else {
                updateOrderContent()
            }
        } else {
            updateOrderContent()
        }
    }

    func updateOrderContent() {
        //if self.menuInformation.locations != nil {
        if self.menuOrder!.locations != nil {
            self.memberContent.orderContent.location = self.menuOrder!.locations![self.segmentLocation.selectedSegmentIndex]
        }

        var totalQuantity: Int = 0
        for i in 0...self.memberContent.orderContent.menuProductItems!.count - 1 {
            totalQuantity = totalQuantity + self.memberContent.orderContent.menuProductItems![i].itemQuantity
        }
        self.memberContent.orderContent.itemQuantity = totalQuantity

        if !verifyLimitedQuantity() {
            return
        }

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = DATETIME_FORMATTER
        let timeString = timeFormatter.string(from: Date())
        self.memberContent.orderContent.createTime = timeString

        self.memberContent.orderContent.replyStatus = MENU_ORDER_REPLY_STATUS_ACCEPT
        self.memberContent.orderContent.itemOwnerName = getMyUserName()
        
        if self.memberContent.orderOwnerID == "" || self.memberContent.orderContent.orderNumber == "" {
            print("confirmToJoinOrder self.memberContent.orderOwnerID is empty")
            return
        }

        let databaseRef = Database.database().reference()
        let limitedPath = "USER_MENU_ORDER/\(self.memberContent.orderOwnerID)/\(self.memberContent.orderContent.orderNumber)/limitedMenuItems"
        var globalQuantityArray: [Any] = [Any]()
        if self.orderGlobalQuantity != nil {
            for itemData in (self.orderGlobalQuantity as [MenuItem]?)! {
                globalQuantityArray.append(itemData.toAnyObject())
            }
        }

        databaseRef.child(limitedPath).setValue(globalQuantityArray) { (error, reference) in
            if let error = error {
                print("upload orderGlobalQuantity error in JoinGroupOrderTableViewController")
                presentSimpleAlertMessage(title: "錯誤訊息", message: "上傳團購單產品限量資訊時發生錯誤：\(error.localizedDescription)")
                return
            }
        }
        
        let pathString = "USER_MENU_ORDER/\(self.memberContent.orderOwnerID)/\(self.memberContent.orderContent.orderNumber)/contentItems/\(self.memberIndex)"
        databaseRef.child(pathString).setValue(self.memberContent.toAnyObject()) { (error, reference) in
            if let error = error {
                print("upload memberContent error in JoinGroupOrderTableViewController")
                presentSimpleAlertMessage(title: "錯誤訊息", message: "上傳團購單資訊時發生錯誤：\(error.localizedDescription)")
                return
            }
            let formatter = DateFormatter()
            formatter.dateFormat = DATETIME_FORMATTER
            let dateString = formatter.string(from: Date())
            updateNotificationReplyStatus(order_number: self.memberContent.orderContent.orderNumber, reply_status: MENU_ORDER_REPLY_STATUS_ACCEPT, reply_time: dateString)
            self.refreshNotificationDelegate?.refreshNotificationList()
            self.delegate?.refreshHistoryInvitationList(sender: self)
            self.isNeedToConfirmFlag = false
            self.releaseFBObserver()
            self.navigationController?.popToRootViewController(animated: true)
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    func refreshJoinGroupOrder() {
        self.labelBrandName.text = self.menuInformation.brandName
        self.textViewDescription.text = self.menuInformation.menuDescription
        self.menuDescription = self.menuInformation.menuDescription
        setupLocationSegment()
        //downloadFBMenuImage(menu_url: self.menuInformation.menuImageURL, completion: receiveMenuImage)
        if self.menuInformation.multiMenuImageURL != nil {
            downloadFBMultiMenuImages(images_url: self.menuInformation.multiMenuImageURL!, completion: receivedMultiMenuImages)
        } else {
            if self.menuInformation.menuImageURL != "" {
                downloadFBMultiMenuImages(images_url: [self.menuInformation.menuImageURL], completion: receivedOriginalSingleMenuImage)
            }
        }
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
        
    @IBAction func changeLocationIndex(_ sender: UISegmentedControl) {
        self.selectedLocationIndex = self.segmentLocation.selectedSegmentIndex
        self.isNeedToConfirmFlag = true
    }
    
    func setupLocationSegment() {
        self.segmentLocation.removeAllSegments()
        //if self.menuInformation.locations == nil {
        if self.menuOrder!.locations == nil {
            self.segmentLocation.isEnabled = false
            self.segmentLocation.isHidden = true
        } else {
            //if !self.menuInformation.locations!.isEmpty {
            if !self.menuOrder!.locations!.isEmpty {
                self.segmentLocation.isEnabled = true
                self.segmentLocation.isHidden = false
                //for i in 0...(self.menuInformation.locations!.count - 1) {
                for i in 0...(self.menuOrder!.locations!.count - 1) {
                    //self.segmentLocation.insertSegment(withTitle: self.menuInformation.locations![i], at: i, animated: true)
                    //if self.memberContent.orderContent.location == self.menuInformation.locations![i] {
                    //    self.segmentLocation.selectedSegmentIndex = i
                    //}
                    self.segmentLocation.insertSegment(withTitle: self.menuOrder!.locations![i], at: i, animated: true)
                    if self.memberContent.orderContent.location == self.menuOrder!.locations![i] {
                        self.segmentLocation.selectedSegmentIndex = i
                    }
                }
            }
        }
        
        print("self.segmentLocation.selectedSegmentIndex = \(self.segmentLocation.selectedSegmentIndex)")
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            if self.memberContent.orderContent.menuProductItems == nil {
                return 0
            } else {
                return self.memberContent.orderContent.menuProductItems!.count
            }
        }
        
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 2 {
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            for view in cell.subviews {
                if view.isKind(of: UIImageView.self) {
                    view.removeFromSuperview()
                }
            }

            if !self.imageArray.isEmpty {
                cell.contentView.contentMode = .scaleAspectFit
                let rectArray = calculateImagePosition(frame: cell.frame)
                print("rectArray = \(rectArray)")
                for i in 0...self.imageArray.count - 1 {
                    let imageView = UIImageView(frame: rectArray[i])
                    imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleBottomMargin, .flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin]
                    imageView.contentMode = .scaleAspectFit
                    imageView.layer.borderWidth = 1.0
                    imageView.layer.borderColor = UIColor.darkGray.cgColor
                    imageView.layer.cornerRadius = 6
                    imageView.image = self.imageArray[i]
                    cell.addSubview(imageView)
                }
            }
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }

        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewProductCell", for: indexPath) as! NewProductCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.setData(item: self.memberContent.orderContent.menuProductItems![indexPath.row])
            cell.AdjustAutoLayout()
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.tag = indexPath.row
            
            return cell
        }
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }

    func calculateImagePosition(frame: CGRect) -> [CGRect] {
        var returnRect: [CGRect] = [CGRect]()
        let imageCount = self.imageArray.count
        let X_INSET: CGFloat = 10
        let Y_INSET: CGFloat = 10

        let scaleWidth = frame.width / CGFloat(imageCount)
        for i in 0...imageCount - 1 {
            let rect = CGRect(x: X_INSET + CGFloat(i) * scaleWidth, y: Y_INSET, width: scaleWidth - X_INSET * 2, height: frame.height - Y_INSET * 2)
            returnRect.append(rect)
        }
        
        return returnRect
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 4 {
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
        if indexPath.section == 1 {
            return 80
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 || section == 2 {
            return 0
        }
        
        return 50
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section != 1 {
            return false
        }
        
        return true
    }

    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "刪除"
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if editingStyle == .delete {
                self.isNeedToConfirmFlag = true
                self.memberContent.orderContent.menuProductItems!.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                if !self.memberContent.orderContent.menuProductItems!.isEmpty {
                    var totalQuantity: Int = 0
                    for i in 0...self.memberContent.orderContent.menuProductItems!.count - 1 {
                        totalQuantity = totalQuantity + self.memberContent.orderContent.menuProductItems![i].itemQuantity
                    }
                    self.memberContent.orderContent.itemQuantity = totalQuantity
                } else {
                    self.memberContent.orderContent.itemQuantity = 0
                    self.memberContent.orderContent.menuProductItems = nil
                }
            }
        } else {
            return
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowInputProduct" {
            if let controllerProduct = segue.destination as? JoinOrderSelectProductViewController {
                self.selectProductVC = controllerProduct
                controllerProduct.menuInformation = self.menuInformation
                //controllerProduct.ownerID = self.memberContent.orderOwnerID
                //controllerProduct.orderNumber = self.memberContent.orderContent.orderNumber
                controllerProduct.limitedMenuItems = self.limitedMenuItems
                //controllerProduct.setParentDelegate(joinorder_delegate: self.delegate)
                //controllerProduct.parentVC = self
                controllerProduct.delegate = self
            }
        }

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
        if !self.memberContent.orderContent.menuProductItems!.isEmpty {
            if self.memberContent.orderContent.menuProductItems!.count == MAX_NEW_PRODUCT_COUNT {
                presentSimpleAlertMessage(title: "錯誤訊息", message: "產品項目超過限制(最多10種)，請重新輸入產品資訊")
                return
            }
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
                if (self.memberContent.orderContent.menuProductItems!.count + items.count) > MAX_NEW_PRODUCT_COUNT {
                    print("Over the max number limitation of new product")
                    presentSimpleAlertMessage(title: "錯誤訊息", message: "產品項目超過限制(最多10種)，請重新輸入產品資訊")
                    return
                } else {
                    for i in 0...items.count - 1 {
                        self.memberContent.orderContent.menuProductItems!.append(items[i])
                    }
                }
            } else {
                if items.count > MAX_NEW_PRODUCT_COUNT {
                    print("Over the max number limitation of new product")
                    presentSimpleAlertMessage(title: "錯誤訊息", message: "產品項目超過限制(最多10種)，請重新輸入產品資訊")
                    return
                } else {
                    self.memberContent.orderContent.menuProductItems = items
                }
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

extension JoinGroupOrderTableViewController: PersonalContactInfoDelegate {
    func getUserContactInfo(sender: PersonalContactViewController, contact: UserContactInformation?) {
        self.memberContent.orderContent.userContactInfo = contact
        updateOrderContent()
    }
}

extension JoinGroupOrderTableViewController: GADInterstitialDelegate {
    /// Tells the delegate an ad request succeeded.
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("interstitialDidReceiveAd")
        if self.interstitialAd.isReady {
            self.interstitialAd.present(fromRootViewController: self)
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
