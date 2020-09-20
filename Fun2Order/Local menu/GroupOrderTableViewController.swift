//
//  GroupOrderTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/7/6.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class GroupOrderTableViewController: UITableViewController {
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var collectionGroup: UICollectionView!
    @IBOutlet weak var buttonNextStep: UIButton!
    
    var groupList: [UserGroup] = [UserGroup]()
    var memberList: [GroupMember] = [GroupMember]()
    var selectedGroupIndex: Int = 0
    var menuInformation: MenuInformation = MenuInformation()
    var brandName: String = ""
    var orderType: String = ""
    var addIndex: Int = 0

    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        vc = app.persistentContainer.viewContext
        
        self.buttonNextStep.layer.borderWidth = 1.0
        self.buttonNextStep.layer.borderColor = UIColor.systemBlue.cgColor
        self.buttonNextStep.layer.cornerRadius = 6

        self.collectionGroup.layer.borderWidth = 1.0
        self.collectionGroup.layer.borderColor = UIColor.systemBlue.cgColor
        self.collectionGroup.layer.cornerRadius = 6

        let groupCellViewNib: UINib = UINib(nibName: "GroupCell", bundle: nil)
        self.collectionGroup.register(groupCellViewNib, forCellWithReuseIdentifier: "GroupCell")
        collectionGroup.dataSource = self
        collectionGroup.delegate = self

        let memberCellViewNib: UINib = UINib(nibName: "SelectMemberCell", bundle: nil)
        self.tableView.register(memberCellViewNib, forCellReuseIdentifier: "SelectMemberCell")

        self.tabBarController?.title = self.title
        
        self.groupList = retrieveGroupList()
        if !self.groupList.isEmpty {
            self.memberList = retrieveMemberList(group_id: self.groupList[self.selectedGroupIndex].groupID)
            if !self.memberList.isEmpty {
                for i in 0...self.memberList.count - 1 {
                    self.memberList[i].isSelected = true
                }
            }
            self.addIndex = self.groupList.count
            self.tableView.reloadData()
        } else {
            self.addIndex = 0
        }

        self.labelTitle.text = self.menuInformation.brandName

    }

    @IBAction func processNextStep(_ sender: UIButton) {
        guard let orderController = self.storyboard?.instantiateViewController(withIdentifier: "SEND_ORDER_VC") as? CreateGroupOrderTableViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: SEND_ORDER_VC can't find!! (GroupOrderTableViewController)")
            return
        }
        
        orderController.memberList = self.memberList
        orderController.menuInformation = self.menuInformation
        
        self.navigationController?.show(orderController, sender: self)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            if self.memberList.isEmpty {
                return 0
            }
            
            return self.memberList.count
        }
        
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectMemberCell", for: indexPath) as! SelectMemberCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none

            cell.setData(member_id: self.memberList[indexPath.row].memberID, member_name: self.memberList[indexPath.row].memberName, ini_status: self.memberList[indexPath.row].isSelected)
            cell.delegate = self
            cell.tag = indexPath.row
            
            return cell
        }
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 50
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        if indexPath.section == 1 {
            let newIndexPath = IndexPath(row: 0, section: indexPath.section)
            return super.tableView(tableView, indentationLevelForRowAt: newIndexPath)
        } else {
            return super.tableView(tableView, indentationLevelForRowAt: indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if section == 1 {
            let header = view as! UITableViewHeaderFooterView
            header.backgroundView?.layer.backgroundColor = UIColor.clear.cgColor
            header.textLabel?.textAlignment = .center
            if !self.groupList.isEmpty {
                header.textLabel?.text = "\(self.groupList[self.selectedGroupIndex].groupName)  好友列表"
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 50
        } else {
            return 0
        }
    }

}

extension GroupOrderTableViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return self.groupList.count
        if self.groupList.isEmpty {
            print("CollectionView numberOfItemsInSection return 1")
            return 1
        } else {
            print("CollectionView numberOfItemsInSection return groupList.count + 1 = \(self.groupList.count + 1)")
            return self.groupList.count + 1
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == self.addIndex {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupCell", for: indexPath) as! GroupCell
            cell.setData(group_image: UIImage(named: "Icon_Add_Group.png")!, group_name: "新增群組", index: indexPath)
            cell.setTitleColor(title_color: UIColor.systemBlue)
            cell.tag = indexPath.row
            return cell
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupCell", for: indexPath) as! GroupCell
        cell.setData(group_image: self.groupList[indexPath.row].groupImage, group_name: self.groupList[indexPath.row].groupName, index: indexPath)
        //cell.setTitleColor(title_color: UIColor.black)
        cell.tag = indexPath.row
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == self.addIndex {
            print("Clicke to add new group")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let group_vc = storyboard.instantiateViewController(withIdentifier: "GROUP_EDIT_VC") as? GroupEditTableViewController else{
                assertionFailure("[AssertionFailure] StoryBoard: GROUP_EDIT_VC can't find!! (ViewController)")
                return
            }
            
            group_vc.delegate = self
            navigationController?.show(group_vc, sender: self)
        } else {
            print("Select group name = [\(self.groupList[indexPath.row].groupName)]")
            self.selectedGroupIndex = indexPath.row
            //List the members information in the group
            self.memberList.removeAll()
            self.memberList = retrieveMemberList(group_id: self.groupList[indexPath.row].groupID)
            if !self.memberList.isEmpty {
                for i in 0...self.memberList.count - 1 {
                    self.memberList[i].isSelected = true
                }
            }
            self.tableView.reloadData()
        }
    }
}

extension GroupOrderTableViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
}

extension GroupOrderTableViewController: SetMemberSelectedStatusDelegate {
    func setMemberSelectedStatus(cell: UITableViewCell, status: Bool, data_index: Int) {
        self.memberList[data_index].isSelected = status
    }
}

extension GroupOrderTableViewController: GroupEditDelegate {
    func editGroupComplete(sender: GroupEditTableViewController, index: Int) {
        self.groupList = retrieveGroupList()
        print("GroupOrderTableViewController refreshGroup groupList.count = \(self.groupList.count)")
        if self.groupList.isEmpty {
            self.addIndex = 0
        } else {
            self.addIndex = self.groupList.count
            self.selectedGroupIndex = self.groupList.count - 1
        }

        if index >= 0 {
            self.memberList.removeAll()
            self.memberList = retrieveMemberList(group_id: self.groupList[index].groupID)
            self.selectedGroupIndex = index
            //self.memberTableView.reloadData()
        }

        self.collectionGroup.reloadData()
        self.collectionGroup.collectionViewLayout.invalidateLayout()
        self.tableView.reloadData()
    }
}
