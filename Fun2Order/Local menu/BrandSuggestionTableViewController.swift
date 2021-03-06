//
//  BrandSuggestionTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/7/5.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
import Firebase

//protocol BrandSuggestionDelegate: class {
//    func getBrandSuggestionData(sender: BrandSuggestionTableViewController, data: BrandSuggestionData, image: UIImage)
//}

class BrandSuggestionTableViewController: UITableViewController, UITextFieldDelegate {
    @IBOutlet weak var textBrandName: UITextField!
    @IBOutlet weak var imageMenu: UIImageView!
    @IBOutlet weak var buttonCamera: UIButton!
    @IBOutlet weak var buttonLibrary: UIButton!
    @IBOutlet weak var buttonUpload: UIButton!
    
    //weak var delegate: BrandSuggestionDelegate?
    var menuImage: UIImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.buttonCamera.layer.borderWidth = 1.0
        self.buttonCamera.layer.borderColor = UIColor.systemBlue.cgColor
        self.buttonCamera.layer.cornerRadius = 6
        self.buttonLibrary.layer.borderWidth = 1.0
        self.buttonLibrary.layer.borderColor = UIColor.systemBlue.cgColor
        self.buttonLibrary.layer.cornerRadius = 6
        self.buttonUpload.layer.borderWidth = 1.0
        self.buttonUpload.layer.borderColor = UIColor.systemBlue.cgColor
        self.buttonUpload.layer.cornerRadius = 6
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)

        self.textBrandName.delegate = self
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
          textField.resignFirstResponder()
          return true
    }
    
    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }

    @IBAction func getImageFromCamera(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            
            self.show(imagePicker, sender: self)
        }

    }
    
    @IBAction func getImageFromPhotoLibrary(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            
            self.show(imagePicker, sender: self)
        }

    }
    
    @IBAction func uploadMenuImage(_ sender: UIButton) {
        var suggestionData: BrandSuggestionData = BrandSuggestionData()
        var dateString: String = ""
        
        if Auth.auth().currentUser?.uid == nil {
            presentSimpleAlertMessage(title: "錯誤訊息", message: "無法存取使用者ID")
            return
        }
        
        let name_string = self.textBrandName.text
        if name_string == nil || name_string!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            presentSimpleAlertMessage(title: "錯誤訊息", message: "輸入的品牌名稱不能為空白，請重新輸入")
            return
        }

        if self.imageMenu.image == nil {
            presentSimpleAlertMessage(title: "錯誤訊息", message: "菜單影像為必須之資料，請重新輸入影像")
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = DATETIME_FORMATTER
        dateString = formatter.string(from: Date())
        
        suggestionData.brandName = self.textBrandName.text!
        suggestionData.brandImageURL = "SUGGESTION_BRAND_IMAGE/\(dateString)/\(self.textBrandName.text!).jpeg"
        suggestionData.suggestedDateTime = dateString
        suggestionData.suggestedUserID = Auth.auth().currentUser!.uid
        
        let storageRef = Storage.storage().reference()
        let uploadData = self.menuImage.jpegData(compressionQuality: 1.0)
        storageRef.child(suggestionData.brandImageURL).putData(uploadData!, metadata: nil, completion: { (data, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            let databaseRef = Database.database().reference()
            let pathString = "SUGGESTION_MENU_INFORMATION/\(dateString)/\(self.textBrandName.text!)"
            databaseRef.child(pathString).setValue(suggestionData.toAnyObject()) { (error, _) in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                presentSimpleAlertMessage(title: "訊息", message: "建議的品牌資訊已上傳成功，請靜待菜單資料之建立。")
                self.navigationController?.popViewController(animated: true)
            }
        })

    }
}

extension BrandSuggestionTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        self.imageMenu.image = image
        self.menuImage = image
        dismiss(animated: true, completion: nil)
    }
}
