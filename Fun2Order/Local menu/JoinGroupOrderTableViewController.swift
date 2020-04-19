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

protocol JoinGroupOrderDelegate: class {
    func refreshHistoryInvitationList(sender: JoinGroupOrderTableViewController)
}

class JoinGroupOrderTableViewController: UITableViewController {
    @IBOutlet weak var labelBrandName: UILabel!
    @IBOutlet weak var imageMenu: UIImageView!
    @IBOutlet weak var segmentLocation: UISegmentedControl!
    @IBOutlet weak var buttonConfirm: UIButton!
    
    var menuInformation: MenuInformation = MenuInformation()
    var memberContent: MenuOrderMemberContent = MenuOrderMemberContent()
    var menuOrder: MenuOrder?
    var memberIndex: Int = -1
    //var menuProductItems: [MenuProductItem]?
    //var menuItem: MenuItem = MenuItem()
    //var menuRecipes: [MenuRecipe] = [MenuRecipe]()
    //var productQuantity: Int = 0
    //var productComments: String = ""
    var selectedLocationIndex: Int = -1
    let app = UIApplication.shared.delegate as! AppDelegate
    weak var refreshNotificationDelegate: ApplicationRefreshNotificationDelegate?
    weak var delegate: JoinGroupOrderDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshNotificationDelegate = app.notificationDelegate

        self.imageMenu.layer.borderWidth = 1.0
        self.imageMenu.layer.borderColor = UIColor.lightGray.cgColor
        self.imageMenu.layer.cornerRadius = 6

        let productCellViewNib: UINib = UINib(nibName: "NewProductCell", bundle: nil)
        self.tableView.register(productCellViewNib, forCellReuseIdentifier: "NewProductCell")

        let tapGesture = UITapGestureRecognizer(target: self, action:#selector(self.menuImageClicked(_:)))
        imageMenu.isUserInteractionEnabled = true
        imageMenu.addGestureRecognizer(tapGesture)

        refreshJoinGroupOrder()
        
    }
    
    @IBAction func confirmToJoinOrder(_ sender: UIButton) {
        if self.memberIndex < 0 {
            print("memberIndex wrong in JoinGroupOrderTableViewController !!")
            return
        }

        if self.menuInformation.locations != nil {
            if self.segmentLocation.selectedSegmentIndex < 0 {
                // User does not select location, show alert
                print("Doesn't not select location, just return")
                presentSimpleAlertMessage(title: "錯誤訊息", message: "尚未選擇地點，請重新選取地點資訊")
                return
            } else {
                self.memberContent.orderContent.location = self.menuInformation.locations![self.segmentLocation.selectedSegmentIndex]
            }
        }
        
        if self.memberContent.orderContent.menuProductItems == nil {
            presentSimpleAlertMessage(title: "錯誤訊息", message: "尚未輸入任何產品資訊，請重新輸入")
            return
        } else {
            var totalQuantity: Int = 0
            for i in 0...self.memberContent.orderContent.menuProductItems!.count - 1 {
                totalQuantity = totalQuantity + self.memberContent.orderContent.menuProductItems![i].itemQuantity
            }
            self.memberContent.orderContent.itemQuantity = totalQuantity
        }

        self.memberContent.orderContent.replyStatus = MENU_ORDER_REPLY_STATUS_ACCEPT
        
        let databaseRef = Database.database().reference()
        let pathString = "USER_MENU_ORDER/\(self.memberContent.orderOwnerID)/\(self.memberContent.orderContent.orderNumber)/contentItems/\(self.memberIndex)"
        databaseRef.child(pathString).setValue(self.memberContent.toAnyObject()) { (error, reference) in
            if let error = error {
                print("upload memberContent error in JoinGroupOrderTableViewController")
                print(error.localizedDescription)
            }
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = DATETIME_FORMATTER
        let dateString = formatter.string(from: Date())
        updateNotificationReplyStatus(order_number: self.memberContent.orderContent.orderNumber, reply_status: MENU_ORDER_REPLY_STATUS_ACCEPT, reply_time: dateString)
        self.refreshNotificationDelegate?.refreshNotificationList()
        self.delegate?.refreshHistoryInvitationList(sender: self)
        navigationController?.popToRootViewController(animated: true)
        self.dismiss(animated: false, completion: nil)
    }
    
    func refreshJoinGroupOrder() {
        self.labelBrandName.text = self.menuInformation.brandName
        //self.labelProductQuantity.text = ""
        setupLocationSegment()
        downloadFBMenuImage(menu_url: self.menuInformation.menuImageURL, completion: receiveMenuImage)
        //downloadMenuImage()
    }
    
    func receiveMenuImage(menu_image: UIImage) {
        self.imageMenu.image = menu_image
    }
    
    @IBAction func changeLocationIndex(_ sender: UISegmentedControl) {
        self.selectedLocationIndex = self.segmentLocation.selectedSegmentIndex
    }
    
    func setupLocationSegment() {
        self.segmentLocation.removeAllSegments()
        if self.menuInformation.locations == nil {
            self.segmentLocation.isEnabled = false
            self.segmentLocation.isHidden = true
        } else {
            if !self.menuInformation.locations!.isEmpty {
                self.segmentLocation.isEnabled = true
                self.segmentLocation.isHidden = false
                for i in 0...(self.menuInformation.locations!.count - 1) {
                    self.segmentLocation.insertSegment(withTitle: self.menuInformation.locations![i], at: i, animated: true)
                    if self.memberContent.orderContent.location == self.menuInformation.locations![i] {
                        self.segmentLocation.selectedSegmentIndex = i
                    }
                }
            }
        }
        
        print("self.segmentLocation.selectedSegmentIndex = \(self.segmentLocation.selectedSegmentIndex)")
    }
    
    @objc func menuImageClicked(_ sender: UITapGestureRecognizer) {
        print("Menu Image tapped")
        guard let imageView = sender.view as? UIImageView else {
            print("UIImageView is nil, just return")
            return
        }
        
        if imageView.image == nil {
            print("imageView.image is nil, just return")
            return
        }

        let zoomView = ImageZoomView(frame: UIScreen.main.bounds, image: imageView.image!)
        zoomView.bounces = false
        //let zoomView = ImageZoomView(frame: self.view.bounds, image: imageView.image!)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        tap.cancelsTouchesInView = false
        zoomView.addGestureRecognizer(tap)
        self.view.addSubview(zoomView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true

    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
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
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewProductCell", for: indexPath) as! NewProductCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.setData(item: self.memberContent.orderContent.menuProductItems![indexPath.row])
            cell.AdjustAutoLayout()
            cell.tag = indexPath.row
            
            return cell
        }
        
        return super.tableView(tableView, cellForRowAt: indexPath)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 2 {
            print("Enter tableView didSelectRowAt function")
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
                    }
                } else {
                    print("attendGroupOrder snapshot doesn't exist!")
                }
            }) { (error) in
                print(error.localizedDescription)
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

/*
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .default, title: "刪除") { (action, indexPath) in

        }

        return [delete]
    }
*/

    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "刪除"
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if editingStyle == .delete {
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
                controllerProduct.menuInformation = self.menuInformation
                controllerProduct.delegate = self
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
                    presentSimpleAlertMessage(title: "錯誤訊息", message: "產品種類超過限制(最多五種)，請重新輸入產品資訊")
                } else {
                    for i in 0...items.count - 1 {
                        self.memberContent.orderContent.menuProductItems!.append(items[i])
                    }
                }
            } else {
                if items.count > MAX_NEW_PRODUCT_COUNT {
                    print("Over the max number limitation of new product")
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

            let sectionIndex = IndexSet(integer: 1)
            self.tableView.reloadSections(sectionIndex, with: .automatic)
        }
    }
}
