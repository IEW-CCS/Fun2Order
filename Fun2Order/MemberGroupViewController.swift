//
//  MemberGroupViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/12/17.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class MemberGroupViewController: UIViewController {
    @IBOutlet weak var collectionGroup: UICollectionView!
    @IBOutlet weak var buttonAddMember: UIButton!
    @IBOutlet weak var memberTableView: UITableView!
    
    var groupList: [Group] = [Group]()
    var memberList: [GroupMember] = [GroupMember]()
    var addIndex: Int = 0
    var selectedGroupIndex: Int = -1

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionGroup.layer.borderWidth = 1.0
        self.collectionGroup.layer.borderColor = UIColor.systemBlue.cgColor
        self.collectionGroup.layer.cornerRadius = 6
        
        let iconImage: UIImage? = UIImage(named: "Icon_Add_Member.png")
        self.buttonAddMember.setImage(iconImage, for: UIControl.State.normal)

        let groupCellViewNib: UINib = UINib(nibName: "GroupCell", bundle: nil)
        self.collectionGroup.register(groupCellViewNib, forCellWithReuseIdentifier: "GroupCell")
        collectionGroup.dataSource = self
        collectionGroup.delegate = self
        

        let memberCellViewNib: UINib = UINib(nibName: "MemberCell", bundle: nil)
        self.memberTableView.register(memberCellViewNib, forCellReuseIdentifier: "MemberCell")
        self.memberTableView.delegate = self
        self.memberTableView.dataSource = self

        self.groupList = retrieveGroupList()
        if self.groupList.isEmpty {
            self.addIndex = 0
            self.buttonAddMember.isEnabled = false
        } else {
            self.selectedGroupIndex = 0
            self.addIndex = self.groupList.count
            self.buttonAddMember.isEnabled = true
        }
        
        if self.selectedGroupIndex >= 0 {
            self.memberList.removeAll()
            self.memberList = retrieveMemberList(group_id: self.groupList[self.selectedGroupIndex].groupID)
            self.memberTableView.reloadData()
        }
    }

    func addMember(friends: [Friend]) {
        if friends.isEmpty {
            print("MemberGroupViewController addMember: friend list is empty")
            return
        }
        
        for i in 0...friends.count - 1 {
            var memberInfo: GroupMember = GroupMember()
            var isExist: Bool = false
            for memberData in self.memberList {
                if memberData.memberID == friends[i].memberID {
                    var alertWindow: UIWindow!
                    let controller = UIAlertController(title: "忽略加入群組", message: "此好友\(friends[i].memberName)已加入群組中", preferredStyle: .alert)

                    let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
                        print("Confirm to delete this order information")
                        alertWindow.isHidden = true
                    }
                    
                    controller.addAction(okAction)
                    alertWindow = presentAlert(controller)
                    isExist = true
                    break
                }
            }
            
            if !isExist {
                memberInfo.groupID = self.groupList[selectedGroupIndex].groupID
                memberInfo.memberID = friends[i].memberID
                memberInfo.memberName = friends[i].memberName
                print("memberInfo = \(memberInfo)")
                insertGroupMember(member_info: memberInfo)
                self.memberList.removeAll()
                self.memberList = retrieveMemberList(group_id: self.groupList[self.selectedGroupIndex].groupID)
                self.memberTableView.reloadData()
            }
        }
    }
    
    @objc func handleLongPressGroupCell(_ sender: UILongPressGestureRecognizer) {
        if(sender.state == .began) {
            if sender.view!.tag == self.groupList.count {
                return
            }
            
            print("Long pressed the group cell [\(sender.view!.tag)]")
            self.selectedGroupIndex = sender.view!.tag
            self.memberList.removeAll()
            self.memberList = retrieveMemberList(group_id: self.groupList[self.selectedGroupIndex].groupID)
            self.memberTableView.reloadData()
            
            let controller = UIAlertController(title: "編輯群組動作", message: nil, preferredStyle: .actionSheet)
            
            let editAction = UIAlertAction(title: "編輯群組", style: .default) { (_) in
                print("Edit Group Information")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let group_vc = storyboard.instantiateViewController(withIdentifier: "GROUP_EDIT_VC") as? GroupEditViewController else{
                    assertionFailure("[AssertionFailure] StoryBoard: GROUP_EDIT_VC can't find!! (ViewController)")
                    return
                }

                group_vc.isEditFlag = true
                group_vc.groupID = self.groupList[sender.view!.tag].groupID
                group_vc.delegate = self
                self.navigationController?.show(group_vc, sender: self)
            }
            
            editAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
            controller.addAction(editAction)
            
            let deleteAction = UIAlertAction(title: "刪除群組", style: .default) { (_) in
                print("Delete Group[\(sender.view!.tag)] Information")
                let alertController = UIAlertController(title: "刪除群組資訊", message: "刪除群組會一併刪除與此群組有關的會員資訊，確定要刪除此群組資訊嗎？", preferredStyle: .alert)

                let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
                    print("Confirm to delete this geoup")
                    print("groupID = \(self.groupList[sender.view!.tag].groupID)")
                    deleteGroup(group_id: self.groupList[sender.view!.tag].groupID)
                    deleteMemberByGroup(group_id: self.groupList[sender.view!.tag].groupID)
                    //self.selectedGroupIndex = self.selectedGroupIndex - 1
                    self.groupList = retrieveGroupList()
                    if self.groupList.isEmpty {
                        self.addIndex = 0
                        self.selectedGroupIndex = -1
                        self.buttonAddMember.isEnabled = false
                    } else {
                        self.addIndex = self.groupList.count
                        if self.selectedGroupIndex != 0 {
                            self.selectedGroupIndex = self.selectedGroupIndex - 1
                        }
                        self.buttonAddMember.isEnabled = true
                    }
                    
                    self.collectionGroup.reloadData()
                    self.collectionGroup.collectionViewLayout.invalidateLayout()
                    
                    self.memberList.removeAll()
                    if self.selectedGroupIndex >= 0 {
                        self.memberList = retrieveMemberList(group_id: self.groupList[self.selectedGroupIndex].groupID)
                        //self.memberTableView.reloadData()
                    }
                    self.memberTableView.reloadData()
                }
                
                alertController.addAction(okAction)
                let cancelDeleteAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                alertController.addAction(cancelDeleteAction)
                self.present(alertController, animated: true, completion: nil)
            }
            
            deleteAction.setValue(UIColor.red, forKey: "titleTextColor")
            controller.addAction(deleteAction)
            
            let cancelAction = UIAlertAction(title: "取消", style: .default) { (_) in
               print("Cancel update")
            }
            cancelAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
            controller.addAction(cancelAction)
            
            present(controller, animated: true, completion: nil)
        }
    }
    
    @objc func handleLongPressMemberCell(_ sender: UILongPressGestureRecognizer) {
        if(sender.state == .began) {
            print("Long pressed the member cell [\(sender.view!.tag)]")
            let controller = UIAlertController(title: "編輯群組好友", message: nil, preferredStyle: .actionSheet)
            
            let deleteAction = UIAlertAction(title: "刪除好友", style: .default) { (_) in
                print("Delete memberList[\(sender.view!.tag)] information, member name = \(self.memberList[sender.view!.tag].memberName)")
                let alertController = UIAlertController(title: "刪除好友資訊", message: "確定要刪除此群組的好友資訊嗎？", preferredStyle: .alert)

                let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
                    print("Confirm to delete this member")
                    deleteMember(group_id: self.memberList[sender.view!.tag].groupID, member_id: self.memberList[sender.view!.tag].memberID)

                    self.memberList.removeAll()
                    if self.selectedGroupIndex >= 0 {
                        self.memberList = retrieveMemberList(group_id: self.groupList[self.selectedGroupIndex].groupID)
                        self.memberTableView.reloadData()
                    }
                }
                
                alertController.addAction(okAction)
                let cancelDeleteAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                alertController.addAction(cancelDeleteAction)
                self.present(alertController, animated: true, completion: nil)
            }
            
            deleteAction.setValue(UIColor.red, forKey: "titleTextColor")
            controller.addAction(deleteAction)
            
            let cancelAction = UIAlertAction(title: "取消", style: .default) { (_) in
               print("Cancel update")
            }
            cancelAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
            controller.addAction(cancelAction)
            
            present(controller, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowGroupFriendList" {
            if let controllerGroupFriendList = segue.destination as? GroupFriendListTableViewController {
                var filteredFriendsList: [Friend] = [Friend]()
                
                let allFriendsList = retrieveFriendList()
                
                if !allFriendsList.isEmpty {
                    for i in 0...allFriendsList.count - 1 {
                        var isFound: Bool = false
                        if !self.memberList.isEmpty {
                            for j in 0...self.memberList.count - 1 {
                                if allFriendsList[i].memberID == self.memberList[j].memberID {
                                    isFound = true
                                    break
                                }
                            }
                        }
                        
                        if !isFound {
                            filteredFriendsList.append(allFriendsList[i])
                        }
                    }
                }
                
                controllerGroupFriendList.friendList = filteredFriendsList
                controllerGroupFriendList.delegate = self
            }
        }
    }

}

extension MemberGroupViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
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

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPressGroupCell(_:)))
        longPressGesture.delegate = self
        cell.addGestureRecognizer(longPressGesture)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.groupList.isEmpty {
            print("CollectionView numberOfItemsInSection return 1")
            return 1
        } else {
            print("CollectionView numberOfItemsInSection return groupList.count + 1 = \(self.groupList.count + 1)")
            return self.groupList.count + 1
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == self.addIndex {
            print("Clicke to add new group")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let group_vc = storyboard.instantiateViewController(withIdentifier: "GROUP_EDIT_VC") as? GroupEditViewController else{
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
            self.memberTableView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
}

extension MemberGroupViewController: UITableViewDelegate, UITableViewDataSource {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberCell", for: indexPath) as! MemberCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        //cell.setData(image: self.memberImages[indexPath.row], name: self.memberNames[indexPath.row])
        //cell.setData(image: self.memberList[indexPath.row].memberImage, name: self.memberList[indexPath.row].memberName)
        cell.setData(member_id: self.memberList[indexPath.row].memberID, member_name: self.memberList[indexPath.row].memberName)
        cell.tag = indexPath.row

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPressMemberCell(_:)))
        longPressGesture.delegate = self
        cell.addGestureRecognizer(longPressGesture)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        //header.layer.backgroundColor = UIColor.clear.cgColor
        header.backgroundView?.layer.backgroundColor = UIColor.white.cgColor

        if !self.groupList.isEmpty {
            header.textLabel?.textAlignment = .center
            header.textLabel?.text = "\(self.groupList[self.selectedGroupIndex].groupName)  會員列表"
        } else {
            header.textLabel?.text = ""
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
}

extension MemberGroupViewController: GroupFriendListDelegate {
    func getSelectedFriendList(sender: GroupFriendListTableViewController, friend_list: [Friend]) {
        print("MemberGroupViewController receive selected friend list")
        print("Friend List = \(friend_list)")
        self.addMember(friends: friend_list)
    }
}

extension MemberGroupViewController: GroupEditDelegate {
    func editGroupComplete(sender: GroupEditViewController) {
        self.groupList = retrieveGroupList()
        print("MemberGroupViewController refreshGroup groupList.count = \(self.groupList.count)")
        if self.groupList.isEmpty {
            self.addIndex = 0
            self.buttonAddMember.isEnabled = false
        } else {
            self.addIndex = self.groupList.count
            self.buttonAddMember.isEnabled = true
            self.selectedGroupIndex = self.groupList.count - 1
        }
        
        self.collectionGroup.reloadData()
        self.collectionGroup.collectionViewLayout.invalidateLayout()
        self.memberTableView.reloadData()
    }
}
