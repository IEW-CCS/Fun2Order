//
//  SelectMemberCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/1/5.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
import Kingfisher
import Firebase

protocol SetMemberSelectedStatusDelegate: class {
    func setMemberSelectedStatus(cell: UITableViewCell, status: Bool, data_index: Int)
}

class SelectMemberCell: UITableViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var memberImage: UIImageView!
    @IBOutlet weak var memberLabel: UILabel!
    @IBOutlet weak var selectCheckBox: Checkbox!
    @IBOutlet weak var labelSubTitle: UILabel!
    
    var checkStatus: Bool = true
    weak var delegate: SetMemberSelectedStatusDelegate?
    let semaphore = DispatchSemaphore(value: 2)

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backView.layer.borderWidth = CGFloat(1.0)
        self.backView.layer.borderColor = UIColor.systemBlue.cgColor
        self.backView.layer.cornerRadius = 6
        
        self.memberImage.layer.borderWidth = CGFloat(1.0)
        self.memberImage.layer.borderColor = UIColor.clear.cgColor
        self.memberImage.layer.cornerRadius = 6
        
        self.selectCheckBox.isChecked = true
        
        self.selectCheckBox.valueChanged = { (isChecked) in
            print("checkbox is checked: \(isChecked)")
            self.checkStatus = isChecked
            self.delegate?.setMemberSelectedStatus(cell: self, status: self.checkStatus, data_index: self.tag)
        }
        self.labelSubTitle.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func receiveMemberImage(member_image: UIImage?) {
        if member_image != nil {
            self.memberImage.image = member_image!
        }
    }
    
    func receiveUserProfile(user_profile: UserProfile?) {
        if user_profile == nil {
            self.selectCheckBox.isChecked = false
            self.selectCheckBox.isCheckEnabled = false
            self.checkStatus = false
            self.memberLabel.text = "好友資料錯誤"
            self.delegate?.setMemberSelectedStatus(cell: self, status: self.checkStatus, data_index: self.tag)
            return
        }
        
        self.memberLabel.text = user_profile!.userName
        DispatchQueue.main.async {
            let result = self.semaphore.wait(timeout: DispatchTime.distantFuture)
            print(result)
            print("updateFriend")
            updateFriend(member_id: user_profile!.userID, member_name: user_profile!.userName)
            self.semaphore.signal()
        }
        DispatchQueue.main.async {
            let result = self.semaphore.wait(timeout: DispatchTime.distantFuture)
            print(result)
            updateGroupFriend(member_id: user_profile!.userID, member_name: user_profile!.userName)
            self.semaphore.signal()
        }
    }

    func setData(image: UIImage, name: String) {
        self.memberImage.image = image
        self.memberLabel.text = name
    }

    func setData(member_id: String, member_name: String, ini_status: Bool) {
        //self.memberLabel.text = member_name
        self.selectCheckBox.isChecked = ini_status
        //downloadFBMemberImage(member_id: member_id, completion: receiveMemberImage)
        downloadFBUserProfile(user_id: member_id, completion: receiveUserProfile)
        downloadUserImage(member_id: member_id)
    }

    func downloadUserImage(member_id: String) {
        let databaseRef = Database.database().reference()
        let storageRef = Storage.storage().reference()
        
        let pathString = "USER_PROFILE/\(member_id)/photoURL"
        databaseRef.child(pathString).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let imageURL = snapshot.value as! String
                storageRef.child(imageURL).downloadURL(completion: { (url, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    
                    if url == nil {
                        print("downloadURL returns nil")
                        return
                    }
                    
                    print("downloadURL = \(url!)")
                    
                    self.memberImage.kf.setImage(with: url)
                })
            } else {
                print("downloadMemberImage photoURL snapshot doesn't exist!")
            }
        })  { (error) in
            print(error.localizedDescription)
        }
    }

    func downloadContactImage(contact: UserContactInfo) {
        let storageRef = Storage.storage().reference()
        
        storageRef.child(contact.userImageURL).downloadURL(completion: { (url, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if url == nil {
                print("downloadURL returns nil")
                return
            }
            
            print("downloadURL = \(url!)")
            
            self.memberImage.kf.setImage(with: url)
        })
    }

    func getCheckStatus() -> Bool {
        return self.checkStatus
    }
    
    func setCheckStatus(status: Bool) {
        self.selectCheckBox.isChecked = status
    }
    
    func setContact(contact: UserContactInfo, ini_status: Bool) {
        self.selectCheckBox.isChecked = ini_status
        self.labelSubTitle.text = contact.userContactName
        downloadFBUserProfile(user_id: contact.userID, completion: receiveUserProfile)
        downloadContactImage(contact: contact)
    }
}
