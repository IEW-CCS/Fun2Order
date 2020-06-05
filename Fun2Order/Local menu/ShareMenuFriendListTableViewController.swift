//
//  ShareMenuFriendListTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/6/4.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

protocol ShareMenuFriendListDelegate: class {
    func getShareFriendList(sender: ShareMenuFriendListTableViewController, friend_list: [String])
}

class ShareMenuFriendListTableViewController: UITableViewController {
    var allFriendList: [Friend] = [Friend]()
    var allFriendSelectedIndex: [Bool] = [Bool]()
    weak var delegate: ShareMenuFriendListDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let memberCellViewNib: UINib = UINib(nibName: "SelectMemberCell", bundle: nil)
        self.tableView.register(memberCellViewNib, forCellReuseIdentifier: "SelectMemberCell")

        self.allFriendList = retrieveFriendList()
        if !self.allFriendList.isEmpty {
            self.allFriendSelectedIndex = Array(repeating: false, count: self.allFriendList.count)
        }
        self.tableView.reloadData()
    }

    
    @IBAction func cancelShareMenu(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmShareMenu(_ sender: UIBarButtonItem) {
        var selectedFriendList: [String] = [String]()
        if self.allFriendList.isEmpty {
            presentSimpleAlertMessage(title: "提示訊息", message: "好友列表為空白，請加入好友後再分享。")
            return
        }
        
        for i in 0...self.allFriendSelectedIndex.count - 1 {
            if self.allFriendSelectedIndex[i] {
                selectedFriendList.append(self.allFriendList[i].memberID)
            }
        }
        
        if selectedFriendList.isEmpty {
            presentSimpleAlertMessage(title: "錯誤訊息", message: "尚未選擇任何好友，請重新選取。")
            return
        }
        
        self.delegate?.getShareFriendList(sender: self, friend_list: selectedFriendList)
        navigationController?.popViewController(animated: true)
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.allFriendList.isEmpty {
            return 0
        }
        
        return self.allFriendList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectMemberCell", for: indexPath) as! SelectMemberCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none

        cell.setData(member_id: self.allFriendList[indexPath.row].memberID, member_name: self.allFriendList[indexPath.row].memberName, ini_status: false)
        cell.delegate = self
        cell.tag = indexPath.row
        
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

extension ShareMenuFriendListTableViewController: SetMemberSelectedStatusDelegate {
    func setMemberSelectedStatus(cell: UITableViewCell, status: Bool, data_index: Int) {
        self.allFriendSelectedIndex[data_index] = status
    }
}
