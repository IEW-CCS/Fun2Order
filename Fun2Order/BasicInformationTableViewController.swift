//
//  BasicInformationTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/12/19.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class BasicInformationTableViewController: UITableViewController {
    @IBOutlet weak var labelPhoneNumber: UILabel!
    @IBOutlet weak var labelUserName: UILabel!
    @IBOutlet weak var labelGender: UILabel!
    @IBOutlet weak var labelBirthday: UILabel!
    @IBOutlet weak var labelAddress: UILabel!
    @IBOutlet weak var imageQRCode: UIImageView!
    @IBOutlet weak var imagePhone: UIImageView!
    @IBOutlet weak var imageName: UIImageView!
    @IBOutlet weak var imageGender: UIImageView!
    @IBOutlet weak var imageBirthday: UIImageView!
    @IBOutlet weak var imageAddress: UIImageView!
    
    var myUserID: String = ""
    var myProfile: UserProfile = UserProfile()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //tmpDeleteProfile()
        setupImageTintColor()
        //loadSetupConfig()
        
        if Auth.auth().currentUser?.uid != nil {
            downloadFBUserProfile(user_id: Auth.auth().currentUser!.uid, completion: setupBasicInformation)
        }
    }

    func setupImageTintColor() {
        self.imageQRCode.image = UIImage(named: "Icon_QRCode.png")?.withRenderingMode(.alwaysTemplate)
        self.imageQRCode.tintColor = CUSTOM_COLOR_EMERALD_GREEN

        self.imagePhone.image = UIImage(named: "Icon_Phone.png")?.withRenderingMode(.alwaysTemplate)
        self.imagePhone.tintColor = CUSTOM_COLOR_EMERALD_GREEN

        self.imageName.image = UIImage(named: "Icon_Name.png")?.withRenderingMode(.alwaysTemplate)
        self.imageName.tintColor = CUSTOM_COLOR_EMERALD_GREEN

        self.imageGender.image = UIImage(named: "Icon_Gender.png")?.withRenderingMode(.alwaysTemplate)
        self.imageGender.tintColor = CUSTOM_COLOR_EMERALD_GREEN

        self.imageBirthday.image = UIImage(named: "Icon_Birthday.png")?.withRenderingMode(.alwaysTemplate)
        self.imageBirthday.tintColor = CUSTOM_COLOR_EMERALD_GREEN

        self.imageAddress.image = UIImage(named: "Icon_Address.png")?.withRenderingMode(.alwaysTemplate)
        self.imageAddress.tintColor = CUSTOM_COLOR_EMERALD_GREEN
    }
    
    func setupBasicInformation(user_profile: UserProfile?) {
        if user_profile == nil {
            presentSimpleAlertMessage(title: "錯誤訊息", message: "存取使用者資料發生錯誤")
            return
        }
        
        self.myProfile = user_profile!
        self.myUserID = user_profile!.userID
        self.labelPhoneNumber.text = user_profile!.phoneNumber
        self.labelUserName.text = user_profile!.userName
        self.labelGender.text = user_profile!.gender
        self.labelBirthday.text = user_profile!.birthday
        self.labelAddress.text = user_profile!.address
    }
    
    func tmpDeleteProfile() {
        let fm = FileManager.default
        let dst = NSHomeDirectory() + "/Documents/MyProfile.plist"
        try! fm.removeItem(atPath: dst)
    }
    
    func loadSetupConfig() {
        let path = NSHomeDirectory() + "/Documents/MyProfile.plist"
        if let plist = NSMutableDictionary(contentsOfFile: path) {
            if let userID = plist["UserID"] {self.myUserID = (userID as? String)!}
            if let phoneNumber = plist["PhoneNumber"] {labelPhoneNumber.text = phoneNumber as? String}
            //if let emailAddress = plist["EmailAddress"] {labelEMail.text = emailAddress as? String}
            //if let userAccount = plist["UserAccount"]{ labelUserAccount.text = userAccount as? String }
            if let userName = plist["UserName"] {labelUserName.text = userName as? String}
            if let gender = plist["Gender"] {labelGender.text = gender as? String}
            if let birthday = plist["Birthday"] {labelBirthday.text = birthday as? String}
            if let address = plist["Address"] {labelAddress.text = address as? String}
        }
    }

    func saveSetupConfig() {
        if self.labelUserName.text == nil || self.labelUserName.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            presentSimpleAlertMessage(title: "錯誤訊息", message: "姓名欄位不可為空白，請重新輸入")
            return
        }
        
        self.myProfile.userName = self.labelUserName.text!
        self.myProfile.gender = self.labelGender.text
        self.myProfile.birthday = self.labelBirthday.text
        self.myProfile.address = self.labelAddress.text
        uploadFBUserProfile(user_profile: self.myProfile)
        
        let path = NSHomeDirectory() + "/Documents/MyProfile.plist"
        if let plist = NSMutableDictionary(contentsOfFile: path) {
            plist["PhoneNumber"] = labelPhoneNumber.text
            //plist["EmailAddress"] = labelEMail.text
            //plist["UserAccount"] = labelUserAccount.text
            plist["UserName"] = labelUserName.text
            plist["Gender"] = labelGender.text
            plist["Birthday"] = labelBirthday.text
            plist["Address"] = labelAddress.text
            
            if !plist.write(toFile: path, atomically: true) {
                print("Save MyProfile.plist failed")
                return
            }
            
            let changeRequest = Auth.auth().currentUser!.createProfileChangeRequest()
            changeRequest.displayName = self.labelUserName.text
            changeRequest.commitChanges(completion: { (error) in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
            })

            presentSimpleAlertMessage(title: "訊息", message: "基本資料已成功更新")
            NotificationCenter.default.post(name: NSNotification.Name("UpdateProfile"), object: self.labelUserName.text)
        }
    }
    
    /*
    func updateEMailAddress() {
        let controller = UIAlertController(title: "請輸入電子郵件地址", message: nil, preferredStyle: .alert)
        controller.addTextField { (textField) in
            textField.placeholder = "變更電子郵件地址"
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .default) { (_) in
            print("Cancel to update email address!")
        }
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        controller.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
            let email_string = controller.textFields?[0].text
            self.labelEMail.text = email_string!
        }
        okAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        controller.addAction(okAction)
        
        present(controller, animated: true, completion: nil)
    }
    
    func updateUserAccount() {
        let controller = UIAlertController(title: "請輸入使用者名稱", message: nil, preferredStyle: .alert)
        controller.addTextField { (textField) in
            textField.placeholder = "變更使用者名稱"
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .default) { (_) in
            print("Cancel to update user account!")
        }
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        controller.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
            let useraccount_string = controller.textFields?[0].text
            self.labelUserAccount.text = useraccount_string!
        }
        okAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        controller.addAction(okAction)
        
        present(controller, animated: true, completion: nil)
    }
    */
    
    func updateUserName() {
        let controller = UIAlertController(title: "請輸入姓名", message: nil, preferredStyle: .alert)
        controller.addTextField { (textField) in
            textField.placeholder = "變更姓名"
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .default) { (_) in
            print("Cancel to update user name!")
        }
        
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        controller.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
            let username_string = controller.textFields?[0].text
            if username_string == nil || username_string!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                presentSimpleAlertMessage(title: "錯誤訊息", message: "姓名欄位不可為空白，請重新輸入")
                return
            }
            self.labelUserName.text = username_string!
            //self.saveSetupConfig()
            NotificationCenter.default.post(name: NSNotification.Name("RefreshProfile"), object: self.labelUserName.text)
        }
        okAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        controller.addAction(okAction)
        
        present(controller, animated: true, completion: nil)
    }
    
    func updateAddress() {
        let controller = UIAlertController(title: "請輸入地址", message: nil, preferredStyle: .alert)
        controller.addTextField { (textField) in
            textField.placeholder = "變更地址"
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .default) { (_) in
            print("Cancel to update address!")
        }
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        controller.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
            let address_string = controller.textFields?[0].text
            self.labelAddress.text = address_string!
        }
        okAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        controller.addAction(okAction)
        
        present(controller, animated: true, completion: nil)
    }
    
/*
    func updatePassword() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let password_vc = storyboard.instantiateViewController(withIdentifier: "CHANGE_PWD_VC") as? ChangePasswordViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: CHANGE_PWD_VC can't find!! (BasicInformationTableViewController)")
            return
        }
        
        self.navigationController?.pushViewController(password_vc, animated: true)
    }
*/
    
    func displayQRCode() {
        guard let qrCodeController = self.storyboard?.instantiateViewController(withIdentifier: "QRCode_VC") as? QRCodeViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: QRCode_VC can't find!! (QRCodeViewController)")
            return
        }
        
        qrCodeController.setQRCodeText(code: self.myUserID)
        qrCodeController.modalTransitionStyle = .crossDissolve
        qrCodeController.modalPresentationStyle = .overFullScreen
        navigationController?.present(qrCodeController, animated: true, completion: nil)
            
    }
    
    func updateGender() {
        let controller = UIAlertController(title: "請選擇性別", message: nil, preferredStyle: .actionSheet)

        guard let genderController = self.storyboard?.instantiateViewController(withIdentifier: "GENDER_VC") as? GenderViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: GENDER_VC can't find!! (QRCodeViewController)")
            return
        }

        controller.setValue(genderController, forKey: "contentViewController")
        genderController.preferredContentSize.height = 120
        controller.preferredContentSize.height = 120
        controller.addChild(genderController)
        
        let cancelAction = UIAlertAction(title: "取消", style: .default) { (_) in
            print("Cancel to update gender!")
        }
        
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        controller.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
            let gender_controller = controller.children[0] as! GenderViewController
            self.labelGender.text = gender_controller.getGender()
        }
        
        okAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        controller.addAction(okAction)
        
        present(controller, animated: true, completion: nil)
    }
    
    func updateBirthday() {
        let controller = UIAlertController(title: "請選擇生日日期", message: nil, preferredStyle: .actionSheet)

        guard let birthdayController = self.storyboard?.instantiateViewController(withIdentifier: "BIRTHDAY_VC") as? BirthdayViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: BIRTHDAY_VC can't find!! (QRCodeViewController)")
            return
        }

        controller.setValue(birthdayController, forKey: "contentViewController")
        birthdayController.preferredContentSize.height = 180
        controller.preferredContentSize.height = 180
        controller.addChild(birthdayController)
        
        let cancelAction = UIAlertAction(title: "取消", style: .default) { (_) in
            print("Cancel to update gender!")
        }
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        controller.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
            let birthday_controller = controller.children[0] as! BirthdayViewController
            self.labelBirthday.text = birthday_controller.getBirthday()
        }
        
        okAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        controller.addAction(okAction)
        
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func updateProfile(_ sender: UIButton) {
        saveSetupConfig()
    }
    
    @IBAction func deleteProfile(_ sender: UIButton) {
        if Auth.auth().currentUser?.uid == nil {
            print("Current User uID is null, just return deleteProfile funciton")
            return
        }
        
        do {
            let path = NSHomeDirectory() + "/Documents/MyProfile.plist"
            if let plist = NSMutableDictionary(contentsOfFile: path) {
                plist["UserID"] = ""
                plist["PhoneNumber"] = ""
                plist["EmailAddress"] = ""
                plist["UserAccount"] = ""
                plist["UserPassword"] = ""
                plist["UserName"] = ""
                plist["Gender"] = ""
                plist["Birthday"] = ""
                plist["Address"] = ""
                plist["UserImage"] = UIImage(named: "Image_Default_Member.png")!.pngData()

                if !plist.write(toFile: path, atomically: true) {
                    print("Save MyProfile.plist failed")
                    return
                }

                let databaseRef = Database.database().reference()
                //let profilePathString = "USER_PROFILE/\(self.myUserID)"
                if Auth.auth().currentUser?.uid == nil {
                    print("Auth currentUser.uid is nil")
                    return
                }
                
                let profilePathString = "USER_PROFILE/\(Auth.auth().currentUser!.uid)"
                databaseRef.child(profilePathString).removeValue()
                
                let storageRef = Storage.storage().reference()
                //let imagePath = "UserProfile_Photo/\(self.myUserID).png"
                //let imagePath = getUserPhotoStoragePath(u_id: self.myUserID)
                let imagePath = getUserPhotoStoragePath(u_id: Auth.auth().currentUser!.uid)
                storageRef.child(imagePath).delete(completion: nil)
                
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "EntryViewController") as! EntryViewController
                try Auth.auth().signOut()
                navigationController?.pushViewController(nextViewController, animated: true)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont.systemFont(ofSize: 22)
        header.textLabel?.textAlignment = .center
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            return 0
        }
        
        return 40
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected row index = \(indexPath.row)")
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                displayQRCode()
                break
                
            default:
                break
            }
        }
        
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                updateUserName()
                break
                
            case 1:
                updateGender()
                break
                
            case 2:
                updateBirthday()
                break
                
            case 3:
                updateAddress()
                break
                
            default:
                break
            }
        }

    }
    
}
