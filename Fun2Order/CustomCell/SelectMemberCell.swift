//
//  SelectMemberCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/1/5.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
protocol SetMemberSelectedStatusDelegate: class {
    func setMemberSelectedStatus(cell: UITableViewCell, status: Bool, data_index: Int)
}

class SelectMemberCell: UITableViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var memberImage: UIImageView!
    @IBOutlet weak var memberLabel: UILabel!
    @IBOutlet weak var selectCheckBox: Checkbox!
    var checkStatus: Bool = true
    weak var delegate: SetMemberSelectedStatusDelegate?
    let semaphore = DispatchSemaphore(value: 2)

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backView.layer.borderWidth = CGFloat(1.0)
        self.backView.layer.borderColor = UIColor.systemBlue.cgColor
        self.backView.layer.cornerRadius = 6
        self.selectCheckBox.isChecked = true
        
        self.selectCheckBox.valueChanged = { (isChecked) in
            print("checkbox is checked: \(isChecked)")
            self.checkStatus = isChecked
            self.delegate?.setMemberSelectedStatus(cell: self, status: self.checkStatus, data_index: self.tag)
        }
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

    func setData(member_id: String, member_name: String) {
        //self.memberLabel.text = member_name
        downloadFBMemberImage(member_id: member_id, completion: receiveMemberImage)
        downloadFBUserProfile(user_id: member_id, completion: receiveUserProfile)
    }

    func getCheckStatus() -> Bool {
        return self.checkStatus
    }
    
    func setCheckStatus(status: Bool) {
        self.selectCheckBox.isChecked = status
    }
}
