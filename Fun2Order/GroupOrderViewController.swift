//
//  GroupOrderViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/22.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit
import CoreData

class GroupOrderViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var collectionGroup: UICollectionView!
    @IBOutlet weak var memberTableView: UITableView!
    @IBOutlet weak var buttonDueDate: UIButton!
    @IBOutlet weak var labelDueDate: UILabel!
    @IBOutlet weak var buttonCreateOrder: UIButton!
    @IBOutlet weak var myCheckStatus: Checkbox!
    @IBOutlet weak var labelTitle: UILabel!
    
    var groupList: [Group] = [Group]()
    var memberList: [GroupMember] = [GroupMember]()
    var selectedGroupIndex: Int = 0
    var isAttended: Bool = true
    var favoriteStoreInfo: FavoriteStoreInfo = FavoriteStoreInfo()
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        vc = app.persistentContainer.viewContext

        //let iconImage: UIImage? = UIImage(named: "Icon_Clock.png")
        //self.buttonDueDate.setImage(iconImage, for: UIControl.State.normal)
        self.buttonDueDate.layer.borderWidth = 1.0
        self.buttonDueDate.layer.borderColor = UIColor.systemBlue.cgColor
        self.buttonDueDate.layer.cornerRadius = 6
        
        self.labelDueDate.layer.borderWidth = 1.0
        self.labelDueDate.layer.borderColor = COLOR_PEPPER_RED.cgColor
        self.labelDueDate.layer.cornerRadius = 6
        self.labelDueDate.isHidden = true

        self.buttonCreateOrder.layer.borderWidth = 1.0
        self.buttonCreateOrder.layer.borderColor = UIColor.systemBlue.cgColor
        self.buttonCreateOrder.layer.cornerRadius = 6

        self.labelTitle.layer.cornerRadius = 6
        
        self.collectionGroup.layer.borderWidth = 1.0
        self.collectionGroup.layer.borderColor = UIColor.systemBlue.cgColor
        self.collectionGroup.layer.cornerRadius = 6

        let groupCellViewNib: UINib = UINib(nibName: "GroupCell", bundle: nil)
        self.collectionGroup.register(groupCellViewNib, forCellWithReuseIdentifier: "GroupCell")
        collectionGroup.dataSource = self
        collectionGroup.delegate = self

        let memberCellViewNib: UINib = UINib(nibName: "SelectMemberCell", bundle: nil)
        self.memberTableView.register(memberCellViewNib, forCellReuseIdentifier: "SelectMemberCell")
        self.memberTableView.delegate = self
        self.memberTableView.dataSource = self
        self.memberTableView.layer.borderWidth = 1.0
        self.memberTableView.layer.borderColor = UIColor.systemBlue.cgColor
        self.memberTableView.layer.cornerRadius = 6

        self.tabBarController?.title = self.title
        
        self.myCheckStatus.isChecked = true
        self.myCheckStatus.valueChanged = { (isChecked) in
            print("checkbox is checked: \(isChecked)")
            self.isAttended = isChecked
        }
        
        self.groupList = retrieveGroupList()
        if self.groupList.count > 0 {
            self.memberList = retrieveMemberList(group_id: self.groupList[self.selectedGroupIndex].groupID)
            self.memberTableView.reloadData()
        }
        
        self.labelTitle.text = "\(self.favoriteStoreInfo.brandName)  \(self.favoriteStoreInfo.storeName)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "設定揪團訂單"
        self.navigationController?.title = "設定揪團訂單"
        self.tabBarController?.title = "設定揪團訂單"
    }
    
    
    @IBAction func setupOrderDueDate(_ sender: UIButton) {
        let controller = UIAlertController(title: "請設定截止時間", message: nil, preferredStyle: .actionSheet)

        guard let dateTimeController = self.storyboard?.instantiateViewController(withIdentifier: "DATETIME_VC") as? DateTimeViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: DATETIME_VC can't find!! (QRCodeViewController)")
            return
        }

        controller.setValue(dateTimeController, forKey: "contentViewController")
        //birthdayController.preferredContentSize.height = 150
        controller.addChild(dateTimeController)
        
        let cancelAction = UIAlertAction(title: "取消", style: .default) { (_) in
            print("Cancel to update due date!")
        }
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        controller.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
            let datetime_controller = controller.children[0] as! DateTimeViewController
            self.labelDueDate.text = datetime_controller.getDueDate()
            self.labelDueDate.isHidden = false
        }
        
        okAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        controller.addAction(okAction)
        
        present(controller, animated: true, completion: nil)
    }
    
    func createGroupOrder() {
        let timeZone = TimeZone.init(identifier: "UTC+8")
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.locale = Locale.init(identifier: "zh_TW")
        formatter.dateFormat = DATETIME_FORMATTER
        
        let tmpOrderNumber = formatter.string(from: Date())
        
        let order_data = NSEntityDescription.insertNewObject(forEntityName: "ORDER_INFORMATION", into: vc) as! ORDER_INFORMATION
        order_data.orderNumber = tmpOrderNumber
        order_data.orderType = ORDER_TYPE_GROUP
        //order_data.deliveryType =
        order_data.orderStatus = ORDER_STATUS_INIT
        order_data.orderImage = UIImage(named: "Image_Group.png")!.pngData()
        order_data.orderCreateTime = Date()
        //order_data.orderOwner =
        order_data.orderTotalPrice = 0
        order_data.orderTotalQuantity = 0
        order_data.brandID = Int16(self.favoriteStoreInfo.brandID)
        order_data.brandName = self.favoriteStoreInfo.brandName
        order_data.storeID = Int16(self.favoriteStoreInfo.storeID)
        order_data.storeName = self.favoriteStoreInfo.storeName

        app.saveContext()
    }
    
    func sendGroupOrderNotification() {
        for i in 0...self.memberList.count - 1 {
            let indexPath = IndexPath(row: i, section: 0)
            let cell = self.memberTableView.cellForRow(at: indexPath) as! SelectMemberCell
            if cell.getCheckStatus() {
                print("Member[\(self.memberList[indexPath.row].memberName)] is checked, start to send notification!")
            }
        }
        
    }
    
    @IBAction func sendGroupOrder(_ sender: UIButton) {
        if self.isAttended {
            createGroupOrder()
            
            // Send remote notification to each selected member
            sendGroupOrderNotification()
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let product_vc = storyboard.instantiateViewController(withIdentifier: "ProductList_VC") as? ProductDetailTableViewController else{
                assertionFailure("[AssertionFailure] StoryBoard: ProductList_VC can't find!! (ViewController)")
                return
            }

            product_vc.favoriteStoreInfo = self.favoriteStoreInfo
            product_vc.orderType = ORDER_TYPE_GROUP
            show(product_vc, sender: self)
        }
    }
}

extension GroupOrderViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.groupList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupCell", for: indexPath) as! GroupCell
        cell.setData(group_image: self.groupList[indexPath.row].groupImage, group_name: self.groupList[indexPath.row].groupName, index: indexPath)
        //cell.setTitleColor(title_color: UIColor.black)
        cell.tag = indexPath.row
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Select group name = [\(self.groupList[indexPath.row].groupName)]")
        self.selectedGroupIndex = indexPath.row
        //List the members information in the group
        self.memberList.removeAll()
        self.memberList = retrieveMemberList(group_id: self.groupList[indexPath.row].groupID)
        self.memberTableView.reloadData()
    }
}


extension GroupOrderViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
}

extension GroupOrderViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.memberList.isEmpty {
            return 0
        }
        
        return self.memberList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectMemberCell", for: indexPath) as! SelectMemberCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        //cell.setData(image: self.memberImages[indexPath.row], name: self.memberNames[indexPath.row])
        cell.setData(image: self.memberList[indexPath.row].memberImage, name: self.memberList[indexPath.row].memberName)
        cell.tag = indexPath.row
        
        return cell
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        //header.layer.backgroundColor = UIColor.clear.cgColor
        header.backgroundView?.layer.backgroundColor = UIColor.clear.cgColor
        header.textLabel?.textAlignment = .center
        header.textLabel?.text = "\(self.groupList[self.selectedGroupIndex].groupName)  會員列表"
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
}

