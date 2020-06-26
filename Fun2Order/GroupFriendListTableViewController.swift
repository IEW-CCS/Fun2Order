//
//  GroupFriendListTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/2/24.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

protocol GroupFriendListDelegate: class {
    func getSelectedFriendList(sender: GroupFriendListTableViewController, friend_list: [Friend])
}

class GroupFriendListTableViewController: UITableViewController {
    @IBOutlet weak var barButtonConfirm: UIBarButtonItem!
    var friendList: [Friend] = [Friend]()
    var selectFlag: [Bool] = [Bool]()
    
    weak var delegate: GroupFriendListDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let friendNib: UINib = UINib(nibName: "SelectMemberCell", bundle: nil)
        self.tableView.register(friendNib, forCellReuseIdentifier: "SelectMemberCell")

        //self.friendList = retrieveFriendList()
        if !self.friendList.isEmpty {
            selectFlag = Array(repeating: false, count: self.friendList.count)
            self.barButtonConfirm.isEnabled = true
        } else {
            self.barButtonConfirm.isEnabled = false
        }
    }

    
    @IBAction func cancelSelect(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmSelect(_ sender: UIBarButtonItem) {
        var returnList: [Friend] = [Friend]()

        if self.friendList.isEmpty {
            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
        }
        
        for i in 0...self.friendList.count - 1 {
            if self.selectFlag[i] {
                returnList.append(self.friendList[i])
            }
        }
        
        delegate?.getSelectedFriendList(sender: self, friend_list: returnList)
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectMemberCell", for: indexPath) as! SelectMemberCell
        
        cell.setData(member_id: self.friendList[indexPath.row].memberID, member_name: self.friendList[indexPath.row].memberName, ini_status: self.selectFlag[indexPath.row])
        
        cell.tag = indexPath.row
        cell.setCheckStatus(status: false)
        cell.delegate = self

        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

}

extension GroupFriendListTableViewController: SetMemberSelectedStatusDelegate {
    func setMemberSelectedStatus(cell: UITableViewCell, status: Bool, data_index: Int) {
        self.selectFlag[data_index] = status
    }
}
