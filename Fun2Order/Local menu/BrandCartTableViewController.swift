//
//  BrandCartTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/7/12.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
import Firebase

protocol BrandCartDelegate: class {
    func updateOrderContent(sender: BrandCartTableViewController, content: [MenuProductItem]?)
}

class BrandCartTableViewController: UITableViewController {
    @IBOutlet weak var labelBrandName: UILabel!
    @IBOutlet weak var buttonConfirm: UIButton!
    
    var brandName: String = ""
    var memberIndex: Int = 0
    var needContactInfoFlag: Bool?
    var memberContent: MenuOrderMemberContent = MenuOrderMemberContent()
    let app = UIApplication.shared.delegate as! AppDelegate
    weak var refreshNotificationDelegate: ApplicationRefreshNotificationDelegate?
    weak var delegate: BrandCartDelegate?
    var limitedMenuItems: [MenuItem]?
    var originalMenuProductItems: [MenuProductItem]?
    var orderGlobalQuantity: [MenuItem]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshNotificationDelegate = app.notificationDelegate

        self.buttonConfirm.layer.borderWidth = 1.0
        self.buttonConfirm.layer.borderColor = UIColor.systemBlue.cgColor
        self.buttonConfirm.layer.cornerRadius = 6
        
        let productCellViewNib: UINib = UINib(nibName: "NewProductCell", bundle: nil)
        self.tableView.register(productCellViewNib, forCellReuseIdentifier: "NewProductCell")
        
        self.labelBrandName.text = self.brandName

    }
    
    func setLimitedMenuItems(items: [MenuItem]?, global_quantity: [MenuItem]?) {
        self.limitedMenuItems = items
        self.orderGlobalQuantity = global_quantity
        print("BrandCartTableViewController setLimitedMenuItems received items")
        print("self.limitedMenuItems = \(String(describing: self.limitedMenuItems))")
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

    func updateOrderContent() {
        var totalQuantity: Int = 0
        if self.memberContent.orderContent.menuProductItems != nil {
            if !self.memberContent.orderContent.menuProductItems!.isEmpty {
                for i in 0...self.memberContent.orderContent.menuProductItems!.count - 1 {
                    totalQuantity = totalQuantity + self.memberContent.orderContent.menuProductItems![i].itemQuantity
                }
            }
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
            //self.delegate?.refreshHistoryInvitationList(sender: self)
            //self.isNeedToConfirmFlag = false
            presentSimpleAlertMessage(title: "訊息", message: "已成功加入團購單")
            self.navigationController?.popToRootViewController(animated: true)
            self.dismiss(animated: false, completion: nil)
        }
    }

    @IBAction func confirmAttendGroupOrder(_ sender: UIButton) {
        if self.memberContent.orderContent.menuProductItems == nil {
            presentSimpleAlertMessage(title: "錯誤訊息", message: "尚未輸入任何產品資訊，請重新輸入")
            return
        }
        
        if self.needContactInfoFlag != nil {
            if self.needContactInfoFlag! {
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
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            if self.memberContent.orderContent.menuProductItems == nil {
                return 0
            }
            
            if self.self.memberContent.orderContent.menuProductItems!.isEmpty {
                return 0
            }
            
            return self.self.memberContent.orderContent.menuProductItems!.count
        }
        
        return super.tableView(tableView, numberOfRowsInSection: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewProductCell", for: indexPath) as! NewProductCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.setData(item: self.self.memberContent.orderContent.menuProductItems![indexPath.row])
            cell.AdjustAutoLayout()
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.tag = indexPath.row
            
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
        } else {
            return super.tableView(tableView, indentationLevelForRowAt: indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 80
        }

        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        
        return 50
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        }
        
        return true
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == 1 {
            let deleteAction = UITableViewRowAction(style: .default, title: "刪除") { (action, indexPath) in
                self.deleteMenuProductItem(index: indexPath.row)
            }
                    
            return [deleteAction]
        }
        
        return super.tableView(tableView, editActionsForRowAt: indexPath)
    }
    
    func deleteMenuProductItem(index: Int) {
        var alertWindow: UIWindow!
        let controller = UIAlertController(title: "刪除產品", message: "確定要刪除此產品嗎？", preferredStyle: .alert)

        let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
            print("Confirm to delete this product")
            if self.memberContent.orderContent.menuProductItems != nil {
                self.self.memberContent.orderContent.menuProductItems!.remove(at: index)
            } else {
                alertWindow.isHidden = true
                return
            }
            
            if self.memberContent.orderContent.menuProductItems!.isEmpty {
                self.delegate?.updateOrderContent(sender: self, content: nil)
                self.memberContent.orderContent.menuProductItems = nil
            } else {
                self.delegate?.updateOrderContent(sender: self, content: self.memberContent.orderContent.menuProductItems)
            }
            self.tableView.reloadData()
            alertWindow.isHidden = true
        }
        
        controller.addAction(okAction)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (_) in
            print("Cancel to delete this location")
            alertWindow.isHidden = true
        }
        controller.addAction(cancelAction)
        alertWindow = presentAlert(controller)
    }

}

extension BrandCartTableViewController: PersonalContactInfoDelegate {
    func getUserContactInfo(sender: PersonalContactViewController, contact: UserContactInformation?) {
        self.memberContent.orderContent.userContactInfo = contact
        self.updateOrderContent()
    }
}
