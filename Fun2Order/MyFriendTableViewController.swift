//
//  MyFriendTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/2/22.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

class MyFriendTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    var friendList: [Friend] = [Friend]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let friendNib: UINib = UINib(nibName: "MemberCell", bundle: nil)
        self.tableView.register(friendNib, forCellReuseIdentifier: "MemberCell")

        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "正在更新好友列表")
        self.tableView.refreshControl = refreshControl
        refreshControl?.addTarget(self, action: #selector(pullToRefreshFriendList), for: .valueChanged)

        self.friendList = retrieveFriendList()
    }

    @objc func pullToRefreshFriendList() {
        refreshFriendList()
        //self.refreshControl?.endRefreshing()
    }

    func refreshFriendList() {
        self.friendList.removeAll()
        self.friendList = retrieveFriendList()
        self.refreshControl?.endRefreshing()
        self.tableView.reloadData()
    }

    @objc func handleLongPressMemberCell(_ sender: UILongPressGestureRecognizer) {
        if(sender.state == .began) {
            print("Long pressed the member cell [\(sender.view!.tag)]")
            let controller = UIAlertController(title: "編輯好友動作", message: nil, preferredStyle: .actionSheet)
            
            let deleteAction = UIAlertAction(title: "刪除好友", style: .default) { (_) in
                print("Delete Firend[\(sender.view!.tag)] Information")
                let alertController = UIAlertController(title: "刪除好友資訊", message: "確定要刪除此好友資訊嗎？", preferredStyle: .alert)

                let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
                    print("Confirm to delete this friend")
                    deleteFriend(member_id: self.friendList[sender.view!.tag].memberID)
                    self.refreshFriendList()
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.friendList.isEmpty {
            return 0
        }
        
        return self.friendList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberCell", for: indexPath) as! MemberCell
        
        cell.setData(member_id: self.friendList[indexPath.row].memberID, member_name: self.friendList[indexPath.row].memberName)
        
        cell.tag = indexPath.row
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPressMemberCell(_:)))
        longPressGesture.delegate = self
        cell.addGestureRecognizer(longPressGesture)

        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowQRCodeScan" {
            if let controllerQRCodeScan = segue.destination as? ScanQRCodeViewController {
                controllerQRCodeScan.delegate = self
            }
        }
    }

}

extension MyFriendTableViewController: ScanQRCodeDelegate {
    func getQRCodeMemberInfo(sender: ScanQRCodeViewController, member_id: String, member_name: String) {
        var isUserDuplicate: Bool = false
        var newFriend: Friend = Friend()
        newFriend.memberID = member_id
        newFriend.memberName = member_name
        
        if !self.friendList.isEmpty {
            for i in 0...self.friendList.count - 1 {
                if self.friendList[i].memberID == member_id {
                    isUserDuplicate = true
                    break
                }
            }
        }

        if isUserDuplicate {
            print("User ID is duplicate!")
            presentSimpleAlertMessage(title: "警告訊息", message: "\(member_name)已存在於好友列表中")
            return
        } else {
            insertFriend(friend_info: newFriend)
            refreshFriendList()
        }
    }
}
