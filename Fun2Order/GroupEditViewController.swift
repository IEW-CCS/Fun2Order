//
//  GroupEditViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/12/26.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit
import CoreData

protocol GroupEditDelegate: class {
    func editGroupComplete(sender: GroupEditViewController)
}

class GroupEditViewController: UIViewController {
    @IBOutlet weak var imageGroup: UIImageView!
    @IBOutlet weak var labelGroupName: UILabel!
    @IBOutlet weak var textGroupName: UITextField!
    @IBOutlet weak var textGroupDescription: UITextField!
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var buttonUpdate: UIButton!
    
    var isEditFlag: Bool = false
    var groupID: Int = 0
    weak var delegate: GroupEditDelegate?

    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()

        vc = app.persistentContainer.viewContext

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleImageTap(_:)))
        self.imageGroup.addGestureRecognizer(tapGesture)
        self.imageGroup.isUserInteractionEnabled = true
        
        if !self.isEditFlag {
            self.buttonUpdate.setTitle("新增", for: .normal)
            self.labelGroupName.text = ""
        } else {
            self.buttonUpdate.setTitle("變更", for: .normal)
            displayGroup()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.title = "編輯群組資訊"
        self.navigationController?.title = "編輯群組資訊"
        self.tabBarController?.title = "編輯群組資訊"
    }

    @IBAction func cancelUpdate(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func confirmUpdate(_ sender: UIButton) {
        if self.textGroupName.text == nil || self.textGroupName.text! == "" {
            presentSimpleAlertMessage(title: "錯誤訊息", message: "群組名稱不能為空白，請重新輸入")
            return
        }
        if self.isEditFlag {
            updateGroup(group_id: self.groupID)
        } else {
            addGroup()
        }
        
        //NotificationCenter.default.post(name: NSNotification.Name("RefreshGroup"), object: nil)
        delegate?.editGroupComplete(sender: self)
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
        groupData.groupName = self.textGroupName.text
        groupData.groupImage = self.imageGroup.image!.pngData()
        groupData.groupDescription = self.textGroupDescription.text
        groupData.groupCreateTime = Date()
        
        app.saveContext()
        
        saveGroupSerial(new_serial: serialID + 1)
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
}

extension GroupEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        let newImage = resizeImage(image: image, width: 120)
        self.imageGroup.image = newImage
        dismiss(animated: true, completion: nil)
    }
}
