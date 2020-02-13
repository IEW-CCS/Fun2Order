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

        //collectionGroup.register(GroupCell.self, forCellWithReuseIdentifier: "GroupCollectionView")
        let groupCellViewNib: UINib = UINib(nibName: "GroupCell", bundle: nil)
        self.collectionGroup.register(groupCellViewNib, forCellWithReuseIdentifier: "GroupCell")
        collectionGroup.dataSource = self
        collectionGroup.delegate = self

        let memberCellViewNib: UINib = UINib(nibName: "MemberCell", bundle: nil)
        self.memberTableView.register(memberCellViewNib, forCellReuseIdentifier: "MemberCell")
        self.memberTableView.delegate = self
        self.memberTableView.dataSource = self

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.refreshGroup(_:)),
            name: NSNotification.Name(rawValue: "RefreshGroup"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.addMember),
            name: NSNotification.Name(rawValue: "AddMember"),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.addMember),
            name: NSNotification.Name(rawValue: "RefreshMember"),
            object: nil
        )

        self.groupList = retrieveGroupList()
        if self.groupList.isEmpty {
            self.addIndex = 0
        } else {
            self.selectedGroupIndex = 0
            self.addIndex = self.groupList.count
        }
        
        if self.selectedGroupIndex >= 0 {
            self.memberList.removeAll()
            self.memberList = retrieveMemberList(group_id: self.groupList[self.selectedGroupIndex].groupID)
            self.memberTableView.reloadData()
        }
    }
    
    @IBAction func scanMemberCode(_ sender: UIButton) {
        if self.selectedGroupIndex < 0 {
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let qrcode_vc = storyboard.instantiateViewController(withIdentifier: "SCAN_QRCODE_VC") as? ScanQRCodeViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: GROUP_EDIT_VC can't find!! (ViewController)")
            return
        }

        navigationController?.show(qrcode_vc, sender: self)
    }
    
    @objc func refreshGroup(_ notification: Notification) {
        self.groupList = retrieveGroupList()
        if self.groupList.isEmpty {
            self.addIndex = 0
        } else {
            self.addIndex = self.groupList.count
        }
        
        self.collectionGroup.reloadData()
    }

    @objc func refreshMember(_ notification: Notification) {
        self.memberList.removeAll()
        self.memberList = retrieveMemberList(group_id: self.groupList[self.selectedGroupIndex].groupID)
        self.memberTableView.reloadData()
    }
    
    @objc func addMember(_ notification: Notification) {
        print("MemberGroupViewController received AddMember notification")
        if var memberInfo = notification.object as? GroupMember {
            print("memberInfo.memberID = \(memberInfo.memberID)")
            for memberData in self.memberList {
                if memberData.memberID == memberInfo.memberID {
                    let memberAlert = alert(message: "此會員已加入群組中", title: "加入錯誤")
                    self.present(memberAlert, animated : false, completion : nil)

                    return
                }
            }
            
            memberInfo.groupID = self.groupList[selectedGroupIndex].groupID
            print("memberInfo = \(memberInfo)")
            insertGroupMember(member_info: memberInfo)
            self.memberList.removeAll()
            self.memberList = retrieveMemberList(group_id: self.groupList[self.selectedGroupIndex].groupID)
            self.memberTableView.reloadData()
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
                self.navigationController?.show(group_vc, sender: self)
            }
            
            editAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
            controller.addAction(editAction)
            
            let deleteAction = UIAlertAction(title: "刪除群組", style: .default) { (_) in
                print("Delete Group[\(sender.view!.tag)] Information")
                let alertController = UIAlertController(title: "刪除群組資訊", message: "刪除群組會一併刪除與此群組有關的會員資訊，確定要刪除此群組資訊嗎？", preferredStyle: .alert)

                let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
                    print("Confirm to delete this geoup")
                    deleteGroup(group_id: self.groupList[sender.view!.tag].groupID)
                    deleteMemberByGroup(group_id: self.groupList[sender.view!.tag].groupID)
                    //self.selectedGroupIndex = self.selectedGroupIndex - 1
                    self.groupList = retrieveGroupList()
                    if self.groupList.isEmpty {
                        self.addIndex = 0
                    } else {
                        self.addIndex = self.groupList.count
                        if self.selectedGroupIndex != 0 {
                            self.selectedGroupIndex = self.selectedGroupIndex - 1
                        }
                    }
                    
                    self.collectionGroup.reloadData()
                    
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
    
    @objc func handleLongPressMemberCell(_ sender: UILongPressGestureRecognizer) {
        if(sender.state == .began) {
            print("Long pressed the member cell [\(sender.view!.tag)]")
            let controller = UIAlertController(title: "編輯會員動作", message: nil, preferredStyle: .actionSheet)
            
            let deleteAction = UIAlertAction(title: "刪除會員", style: .default) { (_) in
                print("Delete Member[\(sender.view!.tag)] Information")
                let alertController = UIAlertController(title: "刪除會員資訊", message: "確定要刪除此會員資訊嗎？", preferredStyle: .alert)

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
            return 1
        } else {
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
        cell.setData(image: self.memberList[indexPath.row].memberImage, name: self.memberList[indexPath.row].memberName)
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
        if !self.groupList.isEmpty {
            let header = view as! UITableViewHeaderFooterView
            //header.layer.backgroundColor = UIColor.clear.cgColor
            header.backgroundView?.layer.backgroundColor = UIColor.white.cgColor
            header.textLabel?.textAlignment = .center
            if !self.groupList.isEmpty {
                header.textLabel?.text = "\(self.groupList[self.selectedGroupIndex].groupName)  會員列表"
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
}
