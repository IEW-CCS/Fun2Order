//
//  GroupEditTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/8/13.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
import CoreData

protocol GroupEditDelegate: class {
    func editGroupComplete(sender: GroupEditTableViewController, index: Int)
}

class GroupEditTableViewController: UITableViewController, UITextFieldDelegate {
    @IBOutlet weak var imageGroup: UIImageView!
    @IBOutlet weak var labelGroupName: UILabel!
    @IBOutlet weak var textGroupName: UITextField!
    @IBOutlet weak var textGroupDescription: UITextField!
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var buttonUpdate: UIButton!

    var isEditFlag: Bool = false
    var groupID: Int = 0
    var selectedGroupIndex: Int = -1
    var friendList: [Friend] = [Friend]()
    //var filterFriendList: [Friend] = [Friend]()
    var selectFlag: [Bool] = [Bool]()

    weak var delegate: GroupEditDelegate?

    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()

        vc = app.persistentContainer.viewContext

        let friendNib: UINib = UINib(nibName: "SelectMemberCell", bundle: nil)
        self.tableView.register(friendNib, forCellReuseIdentifier: "SelectMemberCell")

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleImageTap(_:)))
        self.imageGroup.addGestureRecognizer(tapGesture)
        self.imageGroup.isUserInteractionEnabled = true

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)

        if !self.isEditFlag {
            self.buttonUpdate.setTitle("新增", for: .normal)
            self.labelGroupName.text = ""
        } else {
            self.buttonUpdate.setTitle("變更", for: .normal)
            displayGroup()
        }
        
        self.friendList = retrieveFriendList()
        prepareFriendList()
        self.tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.title = "編輯群組資訊"
        self.navigationController?.title = "編輯群組資訊"
        self.tabBarController?.title = "編輯群組資訊"
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
          textField.resignFirstResponder()
          return true
    }
    
    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }

    func prepareFriendList() {
        if self.friendList.isEmpty {
            return
        }
        
        self.selectFlag = Array(repeating: false, count: self.friendList.count)
        
        if self.isEditFlag {
            let memberList = retrieveMemberList(group_id: self.groupID)
            if !memberList.isEmpty {
                for i in 0...friendList.count - 1 {
                    if memberList.contains(where: {$0.memberID == self.friendList[i].memberID} ) {
                        self.selectFlag[i] = true
                    }
                }
            }
        }
    }
    
    @IBAction func cancelUpdate(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func confirmUpdate(_ sender: UIButton) {
        if self.textGroupName.text == nil || self.textGroupName.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            presentSimpleAlertMessage(title: "錯誤訊息", message: "群組名稱不能為空白，請重新輸入")
            return
        }
        
        if self.isEditFlag {
            updateGroup(group_id: self.groupID)
        } else {
            addGroup()
        }
        
        updateMember()
        
        if self.selectedGroupIndex == -1 {
            self.selectedGroupIndex = 0
        }
        
        self.delegate?.editGroupComplete(sender: self, index: self.selectedGroupIndex)
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func handleImageTap(_ sender: UITapGestureRecognizer) {
        print("Group Image View is tapped")
        let controller = UIAlertController(title: "選取照片來源", message: nil, preferredStyle: .actionSheet)
        
        let photoAction = UIAlertAction(title: "相簿", style: .default) { (_) in
            // Add code to pick a photo from Album
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .photoLibrary
                imagePicker.allowsEditing = true
                imagePicker.delegate = self
                
                self.show(imagePicker, sender: self)
            }
        }
        
        photoAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        controller.addAction(photoAction)
        
        let cameraAction = UIAlertAction(title: "相機", style: .default) { (_) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = true
                imagePicker.delegate = self
                
                self.show(imagePicker, sender: self)
            }
        }
        
        cameraAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        controller.addAction(cameraAction)
        
        let cancelAction = UIAlertAction(title: "取消", style: .default) { (_) in
           print("Cancel update")
        }
        cancelAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        controller.addAction(cancelAction)
        
        present(controller, animated: true, completion: nil)
    }
    
    func displayGroup() {
        let fetchRequest: NSFetchRequest<GROUP_TABLE> = GROUP_TABLE.fetchRequest()
        let predicateString = "groupID == \(self.groupID)"
        let predicate = NSPredicate(format: predicateString)
        fetchRequest.predicate = predicate

        do {
            let group_data = try vc.fetch(fetchRequest).first
            self.imageGroup.image = UIImage(data: group_data!.groupImage!)!
            self.labelGroupName.text = group_data?.groupName
            self.textGroupName.text = group_data?.groupName
            self.textGroupDescription.text = group_data?.groupDescription
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func addGroup() {
        let groupData = NSEntityDescription.insertNewObject(forEntityName: "GROUP_TABLE", into: vc) as! GROUP_TABLE
        
        let serialID = getGroupSerial()
        groupData.groupID = Int16(serialID)
        self.groupID = Int(groupData.groupID)
        groupData.groupName = self.textGroupName.text
        groupData.groupImage = self.imageGroup.image!.pngData()
        groupData.groupDescription = self.textGroupDescription.text
        groupData.groupCreateTime = Date()
        
        app.saveContext()
        
        saveGroupSerial(new_serial: serialID + 1)
        let groupList = retrieveGroupList()
        if !groupList.isEmpty {
            self.selectedGroupIndex = groupList.count - 1
        }
    }
    
    func updateGroup(group_id: Int) {
        let fetchRequest: NSFetchRequest<GROUP_TABLE> = GROUP_TABLE.fetchRequest()
        let predicateString = "groupID == \(group_id)"
        let predicate = NSPredicate(format: predicateString)
        fetchRequest.predicate = predicate

        do {
            let group_data = try vc.fetch(fetchRequest).first
            group_data?.setValue(self.textGroupName.text, forKey: "groupName")
            group_data?.setValue(self.imageGroup.image!.pngData(), forKey: "groupImage")
            group_data?.setValue(self.textGroupDescription.text, forKey: "groupDescription")
        } catch {
            print(error.localizedDescription)
        }
        
        app.saveContext()
    }
    
    func getGroupSerial() -> Int {
        var returnSerial: Int = 0
        
        let path = NSHomeDirectory() + "/Documents/AppConfig.plist"
        if let plist = NSMutableDictionary(contentsOfFile: path) {
            if let serialID = plist["MemberGroupSerial"] {returnSerial = (serialID as? Int)!}
        }
        
        return returnSerial
    }
    
    func saveGroupSerial(new_serial: Int) {
        let path = NSHomeDirectory() + "/Documents/AppConfig.plist"
        if let plist = NSMutableDictionary(contentsOfFile: path) {
            plist["MemberGroupSerial"] = new_serial
            
            if !plist.write(toFile: path, atomically: true) {
                print("Save AppConfig.plist failed")
            }
        }
    }

    func updateMember() {
        if self.friendList.isEmpty {
            print("GroupEditTableViewController updateMember: self.friendList is empty")
            return
        }
        
        deleteMemberByGroup(group_id: self.groupID)
        
        let semaphore = DispatchSemaphore(value: 2)

        for i in 0...self.friendList.count - 1 {
            if self.selectFlag[i] {
                var memberInfo: GroupMember = GroupMember()
                memberInfo.groupID = self.groupID
                memberInfo.memberID = self.friendList[i].memberID
                memberInfo.memberName = self.friendList[i].memberName
                semaphore.wait()
                insertGroupMember(member_info: memberInfo)
                semaphore.signal()
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            if self.friendList.isEmpty {
                return 0
            }
            
            return self.friendList.count
        }
        
        return super.tableView(tableView, numberOfRowsInSection: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectMemberCell", for: indexPath) as! SelectMemberCell
            
            cell.setData(member_id: self.friendList[indexPath.row].memberID, member_name: self.friendList[indexPath.row].memberName, ini_status: self.selectFlag[indexPath.row])
            
            cell.tag = indexPath.row
            cell.delegate = self

            cell.selectionStyle = UITableViewCell.SelectionStyle.none
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
            return 50
        }

        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

}

extension GroupEditTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        let newImage = resizeImage(image: image, width: 120)
        self.imageGroup.image = newImage
        dismiss(animated: true, completion: nil)
    }
}

extension GroupEditTableViewController: SetMemberSelectedStatusDelegate {
    func setMemberSelectedStatus(cell: UITableViewCell, status: Bool, data_index: Int) {
        self.selectFlag[data_index] = status
    }
}
