//
//  MemberCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/23.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class MemberCell: UITableViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var memberImage: UIImageView!
    @IBOutlet weak var memberLabel: UILabel!

    let semaphore = DispatchSemaphore(value: 2)

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backView.layer.borderWidth = CGFloat(1.0)
        self.backView.layer.borderColor = UIColor.lightGray.cgColor
        self.backView.layer.cornerRadius = 6
        
        self.memberImage.layer.borderWidth = 1.0
        self.memberImage.layer.borderColor = UIColor.lightGray.cgColor
        self.memberImage.layer.cornerRadius = 6
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

}
