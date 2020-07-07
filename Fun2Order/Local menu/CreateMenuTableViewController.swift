//
//  CreateMenuTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/1/8.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
import Firebase

protocol CreateMenuDelegate: class {
    func refreshMenuList(sender: CreateMenuTableViewController)
}

class CreateMenuTableViewController: UITableViewController, UITextFieldDelegate {
    @IBOutlet weak var textBrandName: UITextField!
    @IBOutlet weak var buttonCategory: UIButton!
    @IBOutlet weak var labelCategory: UILabel!
    @IBOutlet weak var textViewDescription: UITextView!
    @IBOutlet weak var buttonMenuImage: UIButton!
    @IBOutlet weak var buttonProduct: UIButton!
    @IBOutlet weak var labelLocationCount: UILabel!
    @IBOutlet weak var labelProductCount: UILabel!
    @IBOutlet weak var checkboxContactInfo: Checkbox!
    @IBOutlet weak var buttonTest: UIButton!
    
    var menuInformation: MenuInformation = MenuInformation()
    var menuIcon: UIImage?
    var savedMenuInformation: MenuInformation = MenuInformation()
    var isNeedToConfirmFlag: Bool = false
    var isEditedMode: Bool = false
    var testDate: Date = Date()
    weak var delegate: CreateMenuDelegate?
    var updatedBrandCategory: String = ""
    var imageArray: [UIImage] = [UIImage]()
    var menuDescription: String = ""
    var originalMennuImagePathList: [String]?
    var brandCategoryIndex: Int = -1
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .gray)
    var isNeedContactInfo: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        let basicButtonCellViewNib: UINib = UINib(nibName: "BasicButtonCell", bundle: nil)
        self.tableView.register(basicButtonCellViewNib, forCellReuseIdentifier: "BasicButtonCell")

        self.textViewDescription.layer.borderWidth = 1
        self.textViewDescription.layer.borderColor = UIColor.lightGray.cgColor
        self.textViewDescription.layer.cornerRadius = 6
        self.textViewDescription.text = ""
        
        self.checkboxContactInfo.valueChanged = { (isChecked) in
            print("checkbox is checked: \(isChecked)")
            self.isNeedContactInfo = isChecked
        }

        self.labelCategory.text = ""
        
        self.textBrandName.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)

        self.savedMenuInformation = self.menuInformation
        
        self.activityIndicator.frame = self.view.bounds
        self.view.addSubview(self.activityIndicator)

        let backImage = self.navigationItem.leftBarButtonItem?.image
        let newBackButton = UIBarButtonItem(title: "返回", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        navigationController?.navigationBar.backIndicatorImage = backImage

        //self.buttonTest.isHidden = true
        refreshMenu()
    }

    @objc func back(sender: UIBarButtonItem) {
        var alertWindow: UIWindow!
        
        if self.savedMenuInformation.brandName != self.menuInformation.brandName {
            self.isNeedToConfirmFlag = true
        }
        
        if self.savedMenuInformation.brandCategory != self.menuInformation.brandCategory {
            self.isNeedToConfirmFlag = true
        }

        if self.isNeedToConfirmFlag {
            let controller = UIAlertController(title: "提示訊息", message: "菜單資料已更動，您確定要離開嗎？", preferredStyle: .alert)

            let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
                print("Confirm to ignore CreateMennu change")
                self.navigationController?.popToRootViewController(animated: true)
                self.dismiss(animated: false, completion: nil)

                alertWindow.isHidden = true
            }
            
            controller.addAction(okAction)
            let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (_) in
                print("Cancel to ignore CreateMenu change")
                alertWindow.isHidden = true
            }
            controller.addAction(cancelAction)
            alertWindow = presentAlert(controller)
            //return false
        } else {
            self.navigationController?.popToRootViewController(animated: true)
            self.dismiss(animated: false, completion: nil)
            //return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
          textField.resignFirstResponder()
          return true
    }
    
    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }
    
    func refreshMenu() {
        var locationCount: Int = 0
        var itemCount: Int = 0
        
        if self.isEditedMode {
            print("CreateMenuTableViewController Edit Mode is ON!")
        }

        self.textBrandName.text = self.menuInformation.brandName
        self.labelCategory.text = self.menuInformation.brandCategory
        self.textViewDescription.text = self.menuInformation.menuDescription
        
        if self.menuInformation.multiMenuImageURL != nil {
            downloadFBMultiMenuImages(images_url: self.menuInformation.multiMenuImageURL!, completion: receivedMultiMenuImages)
        } else {
            if self.menuInformation.menuImageURL != "" {
                downloadFBMultiMenuImages(images_url: [self.menuInformation.menuImageURL], completion: receivedOriginalSingleMenuImage)
            }
        }

        if self.menuInformation.locations != nil {
            locationCount = self.menuInformation.locations!.count
        }
        self.labelLocationCount.text = "\(locationCount) 項"

        if self.menuInformation.menuItems != nil {
            itemCount = self.menuInformation.menuItems!.count
        }
        self.labelProductCount.text = "\(itemCount) 項"

        if self.menuInformation.needContactInfoFlag == nil {
            self.checkboxContactInfo.isChecked = false
            self.isNeedContactInfo = false
        } else {
            if self.menuInformation.needContactInfoFlag! {
                self.checkboxContactInfo.isChecked = true
                self.isNeedContactInfo = true
            } else {
                self.checkboxContactInfo.isChecked = false
                self.isNeedContactInfo = false
            }
        }
    }

    func receivedMultiMenuImages(images: [UIImage]?) {
        if images != nil {
            self.imageArray = images!
            if !self.imageArray.isEmpty {
                if self.menuIcon == nil {
                    self.menuIcon = UIImage()
                }
                self.menuIcon = resizeImage(image: self.imageArray[0], width: CGFloat(MENU_ICON_WIDTH))
            }
            self.tableView.reloadData()
        } else {
            if self.menuInformation.menuImageURL != "" {
                downloadFBMultiMenuImages(images_url: [self.menuInformation.menuImageURL], completion: receivedOriginalSingleMenuImage)
            }
        }
    }
    
    func receivedOriginalSingleMenuImage(images: [UIImage]?) {
        if images != nil {
            self.imageArray.append(images![0])
            if !self.imageArray.isEmpty {
                if self.menuIcon == nil {
                    self.menuIcon = UIImage()
                }
                self.menuIcon = resizeImage(image: self.imageArray[0], width: CGFloat(MENU_ICON_WIDTH))
            }
            self.tableView.reloadData()
        }
    }

    func uploadMenuInformation(menu_info: MenuInformation) {
        if !self.imageArray.isEmpty {
            self.activityIndicator.startAnimating()
            let menuImage = self.imageArray[0]
            let storageRef = Storage.storage().reference().child(menu_info.menuImageURL)
            let newImage = resizeImage(image: menuImage, width: 1440)
            let uploadData = newImage.jpegData(compressionQuality: 0.5)
            if uploadData != nil {
                storageRef.putData(uploadData!, metadata: nil, completion: { (data, error) in
                    if error != nil {
                        print(error!.localizedDescription)
                        return
                    }
                })
            }

            if self.originalMennuImagePathList == nil {
                uploadMultiMenuImages(menu_info: menu_info)
            } else {
                let dispatchGroup = DispatchGroup()

                for i in 0...self.originalMennuImagePathList!.count - 1 {
                    let newPath = self.originalMennuImagePathList![i]
                    let newRef = Storage.storage().reference()
                    if newPath == "" {
                        print("uploadMenuInformation newPath is empty")
                        continue
                    }
                    
                    dispatchGroup.enter()
                    newRef.child(newPath).delete(completion: {(error) in
                        if error == nil {
                            dispatchGroup.leave()
                            return
                        }
                        dispatchGroup.leave()
                        return
                    })
                }
                
                dispatchGroup.notify(queue: .main) {
                    self.uploadMultiMenuImages(menu_info: menu_info)
                }
            }
            
        } else {
            uploadMenuData(menu_info: menu_info)
        }

    }
    
    func uploadMultiMenuImages(menu_info: MenuInformation) {
        //let newPath = "Menu_Image/\(self.menuInformation.userID)/\(self.menuInformation.menuNumber)/"
        let dispatchGroup = DispatchGroup()

        let newRef = Storage.storage().reference()

        for i in 0...self.imageArray.count - 1 {
            dispatchGroup.enter()
            let newImage = resizeImage(image: self.imageArray[i], width: 1440)
            let uploadData = newImage.jpegData(compressionQuality: 0.5)
            //let imagePath = newPath + "\(i).jpeg"
            let imagePath = self.menuInformation.multiMenuImageURL![i]
            if uploadData != nil {
                newRef.child(imagePath).putData(uploadData!, metadata: nil, completion: { (data, error) in
                    if error != nil {
                        print(error!.localizedDescription)
                        dispatchGroup.leave()
                        return
                    }
                    dispatchGroup.leave()
                })
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.uploadMenuData(menu_info: menu_info)
        }
    }
    
    func uploadMenuData(menu_info: MenuInformation) {
        let databaseRef = Database.database().reference()
        if Auth.auth().currentUser?.uid == nil {
            print("uploadMenuData Auth.auth().currentUser?.uid == nil")
            return
        }

        //let pathString = "USER_MENU_INFORMATION/\(menu_info.userID)/\(menu_info.menuNumber)"
        let pathString = "USER_MENU_INFORMATION/\(Auth.auth().currentUser!.uid)/\(menu_info.menuNumber)"
        databaseRef.child(pathString).setValue(menu_info.toAnyObject()) { (_, _) in
            print("CreateMenuTableViewController uploadMenuInformation -> Firebase setValue of Menu Information successful")
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
            presentSimpleAlertMessage(title: "訊息", message: "菜單資料已成功儲存")
            self.delegate?.refreshMenuList(sender: self)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func selectBrandCategory(_ sender: UIButton) {
        var alertWindow: UIWindow!
        var alertTextWindow: UIWindow!
        
        let brandCategoryList = retrieveMenuBrandCategory()
        
        if !brandCategoryList.isEmpty {
            let controller = UIAlertController(title: "請選擇菜單分類", message: nil, preferredStyle: .alert)
            controller.view.tintColor = CUSTOM_COLOR_EMERALD_GREEN
            for cate_data in brandCategoryList {
                let action = UIAlertAction(title: cate_data, style: .default) { (action) in
                    print("title = \(action.title!)")
                    self.labelCategory.text = action.title!
                    self.menuInformation.brandCategory = action.title!
                    alertWindow.isHidden = true
               }
               controller.addAction(action)
            }
            
            controller.addTextField { (textField) in
                textField.placeholder = "新增分類"
            }
                        
            let addAction = UIAlertAction(title: "加入菜單分類", style: .default) { (_) in
                print("Add to brand category!")
                let category_string = controller.textFields?[0].text
                if category_string == nil {
                    presentSimpleAlertMessage(title: "錯誤訊息", message: "新增的品牌類別不能為空白，請重新輸入")
                    alertWindow.isHidden = true
                    return
                }
                
                if category_string!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                    presentSimpleAlertMessage(title: "錯誤訊息", message: "新增的品牌類別不能為空白，請重新輸入")
                    alertWindow.isHidden = true
                    return
                }

                for i in 0...brandCategoryList.count - 1 {
                    if brandCategoryList[i] == category_string! {
                        presentSimpleAlertMessage(title: "錯誤訊息", message: "新增的品牌類別已重複，請重新輸入")
                        alertWindow.isHidden = true
                        return
                    }
                }
                
                print("New added brand category = \(category_string!)")
                insertMenuBrandCategory(category: category_string!)
                self.updatedBrandCategory = category_string!
                self.updateBrandCatogory()
                self.labelCategory.text = category_string!
                self.menuInformation.brandCategory = category_string!
                self.isNeedToConfirmFlag = true
                self.delegate?.refreshMenuList(sender: self)
                alertWindow.isHidden = true
            }
            addAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
            controller.addAction(addAction)

            let cancelAction = UIAlertAction(title: "取消", style: .default) { (_) in
                print("Cancel to select brand category!")
                alertWindow.isHidden = true
            }
            
            cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
            controller.addAction(cancelAction)

            alertWindow = presentAlert(controller)
            return
        }
        
        let textController = UIAlertController(title: "新增菜單分類", message: nil, preferredStyle: .alert)
            textController.addTextField { (textField) in
                textField.placeholder = "新增分類"
        }
        
        let addAction = UIAlertAction(title: "加入菜單分類", style: .default) { (_) in
            print("Add to brand category!")
            let category_string = textController.textFields?[0].text
            if category_string == nil {
                presentSimpleAlertMessage(title: "錯誤訊息", message: "新增的品牌類別不能為空白，請重新輸入")
                alertWindow.isHidden = true
                return
            }
            
            if category_string!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                presentSimpleAlertMessage(title: "錯誤訊息", message: "新增的品牌類別不能為空白，請重新輸入")
                alertWindow.isHidden = true
                return
            }

            if !brandCategoryList.isEmpty {
                for i in 0...brandCategoryList.count - 1 {
                    if brandCategoryList[i] == category_string! {
                        presentSimpleAlertMessage(title: "錯誤訊息", message: "新增的品牌類別已重複，請重新輸入")
                        alertWindow.isHidden = true
                        return
                    }
                }
            }
            
            print("New added brand category = \(category_string!)")
            insertMenuBrandCategory(category: category_string!)
            self.updatedBrandCategory = category_string!
            self.updateBrandCatogory()
            self.labelCategory.text = category_string!
            self.menuInformation.brandCategory = category_string!
            self.isNeedToConfirmFlag = true
            self.delegate?.refreshMenuList(sender: self)
            alertTextWindow.isHidden = true
        }
        
        textController.addAction(addAction)

        let cancelAction = UIAlertAction(title: "取消", style: .default) { (_) in
            print("Cancel to select brand category!")
            alertTextWindow.isHidden = true
        }
        
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        textController.addAction(cancelAction)
        
        alertTextWindow = presentAlert(textController)
    }
    
    func updateBrandCatogory() {
        if Auth.auth().currentUser?.uid != nil {
            downloadFBUserProfile(user_id: Auth.auth().currentUser!.uid, completion: receiveMyProfile)
        }
    }
    
    func receiveMyProfile(user_profile: UserProfile?) {
        if user_profile == nil {
            presentSimpleAlertMessage(title: "錯誤訊息", message: "存取使用者資料發生錯誤")
            return
        }
        
        var profile = user_profile!
        var brandList = [String]()
        if profile.brandCategoryList == nil {
            brandList.append(self.updatedBrandCategory)
            profile.brandCategoryList = brandList
        } else {
            profile.brandCategoryList!.append(self.updatedBrandCategory)
        }
        uploadFBUserProfile(user_profile: profile)
    }

    @IBAction func editStoreInformation(_ sender: UIButton) {
        let controller = UIAlertController(title: "請輸入店家聯絡資訊", message: nil, preferredStyle: .alert)

        guard let storeController = self.storyboard?.instantiateViewController(withIdentifier: "STORE_CONTACT_VC") as? StoreContactInformationViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: STORE_CONTACT_VC can't find!! (StoreContactInformationViewController)")
            return
        }

        storeController.preferredContentSize.height = 200
        controller.preferredContentSize.height = 200
        storeController.preferredContentSize.width = 320
        controller.preferredContentSize.width = 320
        controller.setValue(storeController, forKey: "contentViewController")
        controller.addChild(storeController)
        if self.menuInformation.storeInfo != nil {
            storeController.setData(store_info: self.menuInformation.storeInfo!)
        }
        storeController.delegate = self
        
        present(controller, animated: true, completion: nil)

    }
    
    @IBAction func addLocation(_ sender: UIButton) {
        let controller = UIAlertController(title: "請輸入地點", message: nil, preferredStyle: .alert)
        controller.addTextField { (textField) in
            textField.placeholder = "輸入地點"
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .default) { (_) in
            print("Cancel to update location!")
        }
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        controller.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
            let location_string = controller.textFields?[0].text
            if location_string == nil || location_string!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                presentSimpleAlertMessage(title: "錯誤訊息", message: "輸入的地點不能為空白，請重新輸入")
                return
            }

            if location_string != "" {
                if self.menuInformation.locations == nil {
                    self.menuInformation.locations = [String]()
                }
                if !self.menuInformation.locations!.isEmpty {
                    for i in 0...self.menuInformation.locations!.count - 1 {
                        if self.menuInformation.locations![i] == location_string {
                            presentSimpleAlertMessage(title: "錯誤訊息", message: "地點不能重覆，請重新輸入新地點")
                            return
                        }
                    }
                }
                self.menuInformation.locations?.append(location_string!)
                self.labelLocationCount.text = "\(self.menuInformation.locations!.count) 項"
                self.isNeedToConfirmFlag = true
            }
        }
        okAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        controller.addAction(okAction)
        
        present(controller, animated: true, completion: nil)

    }
    
    @IBAction func addProduct(_ sender: UIButton) {
        let controller = UIAlertController(title: "請輸入產品相關資訊", message: nil, preferredStyle: .alert)

        guard let productController = self.storyboard?.instantiateViewController(withIdentifier: "BASIC_PRODUCT_VC") as? BasicProductViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: BASIC_PRODUCT_VC can't find!! (BasicProductViewController)")
            return
        }

        productController.preferredContentSize.height = 250
        controller.preferredContentSize.height = 250
        productController.preferredContentSize.width = 320
        controller.preferredContentSize.width = 320
        controller.setValue(productController, forKey: "contentViewController")
        controller.addChild(productController)
        productController.operationMode = PRODUCT_OPERATION_MODE_ADD
        productController.delegate = self
        
        present(controller, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 3 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "BasicButtonCell", for: indexPath) as! BasicButtonCell
                
                let iconImage: UIImage = UIImage(named: "Icon_Menu_Recipe.png")!.withRenderingMode(.alwaysTemplate)
                if self.isEditedMode {
                    cell.setData(icon: iconImage, button_text: "修改配方", action_type: BUTTON_ACTION_ASSIGN_RECIPE)
                } else {
                    cell.setData(icon: iconImage, button_text: "設定配方", action_type: BUTTON_ACTION_ASSIGN_RECIPE)
                }
                
                cell.delegate = self
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                return cell
            }

            if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "BasicButtonCell", for: indexPath) as! BasicButtonCell
                
                let iconImage: UIImage = UIImage(named: "Icon_Menu_Item.png")!.withRenderingMode(.alwaysTemplate)
                if self.isEditedMode {
                    cell.setData(icon: iconImage, button_text: "修改菜單", action_type: BUTTON_ACTION_MENU_CONFIRM)
                } else {
                    cell.setData(icon: iconImage, button_text: "產生菜單", action_type: BUTTON_ACTION_MENU_CONFIRM)
                }

                cell.delegate = self
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                return cell
            }
        }
        
        if indexPath.section == 0 && indexPath.row == 3 {
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            for view in cell.subviews {
                if view.isKind(of: UIImageView.self) {
                    view.removeFromSuperview()
                }
            }

            if !self.imageArray.isEmpty {
                let rectArray = calculateImagePosition(frame: cell.frame)
                print("rectArray = \(rectArray)")
                for i in 0...self.imageArray.count - 1 {
                    let imageView = UIImageView(frame: rectArray[i])
                    //imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleBottomMargin, .flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin]
                    imageView.contentMode = .scaleAspectFit
                    imageView.layer.borderWidth = 1.0
                    imageView.layer.borderColor = UIColor.darkGray.cgColor
                    imageView.layer.cornerRadius = 6
                    imageView.image = self.imageArray[i]
                    cell.addSubview(imageView)
                }
            }
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }

        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
    }

    func calculateImagePosition(frame: CGRect) -> [CGRect] {
        var returnRect: [CGRect] = [CGRect]()
        let imageCount = self.imageArray.count
        let X_INSET: CGFloat = 10
        let Y_INSET: CGFloat = 10

        let scaleWidth = frame.width / CGFloat(imageCount)
        for i in 0...imageCount - 1 {
            let rect = CGRect(x: X_INSET + CGFloat(i) * scaleWidth, y: Y_INSET, width: scaleWidth - X_INSET * 2, height: frame.height - Y_INSET * 2)
            returnRect.append(rect)
        }
        
        return returnRect
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 3 {
            return 54
        }
        
        // Hide the cell to edit Locations information
        if indexPath.section == 1 && indexPath.row == 0 {
            return 0
        }

        return super.tableView(tableView, heightForRowAt: indexPath)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 || section == 3 {
            return 0
        }
        
        //return super.tableView(tableView, heightForHeaderInSection: section)
        return 40
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowMenuImage" {
            if let controllerImage = segue.destination as? MenuImageDescriptionTableViewController {
                controllerImage.imageArray = self.imageArray
                controllerImage.menuDescription = self.menuInformation.menuDescription
                controllerImage.delegate = self
            }
        }

        if segue.identifier == "ShowLocation" {
            if let controllerLocation = segue.destination as? MenuLocationTableViewController {
                controllerLocation.locationArray = self.menuInformation.locations
                controllerLocation.delegate = self
            }
        }

        if segue.identifier == "ShowProduct" {
            if let controllerProduct = segue.destination as? MenuItemTableViewController {
                controllerProduct.menuItemArray = self.menuInformation.menuItems
                controllerProduct.delegate = self
            }
        }

    }

}

extension CreateMenuTableViewController: StoreContactInformationDelegate {
    func getStoreContactInfo(sender: StoreContactInformationViewController, contact: StoreContactInformation) {
        self.menuInformation.storeInfo = contact
        self.isNeedToConfirmFlag = true
    }
}

extension CreateMenuTableViewController: MenuImageDescriptionDelegate {
    func getMenuImageDescription(sender: MenuImageDescriptionTableViewController, menu_images: [UIImage], menu_description: String) {
        self.imageArray = menu_images
        self.menuDescription = menu_description
        
        self.textViewDescription.text = self.menuDescription
        self.menuInformation.menuDescription = menu_description
        if !self.imageArray.isEmpty {
            self.menuIcon = resizeImage(image: self.imageArray[0], width: CGFloat(MENU_ICON_WIDTH))
        }
        
        self.isNeedToConfirmFlag = true
        self.tableView.reloadData()
    }
}

extension CreateMenuTableViewController: MenuLocationDelegate {
    func updateMenuLocation(locations: [String]?) {
        var locationCount: Int = 0

        self.menuInformation.locations = locations
        if self.menuInformation.locations != nil {
            locationCount = self.menuInformation.locations!.count
        }
        self.labelLocationCount.text = "\(locationCount) 項"
        self.isNeedToConfirmFlag = true
    }
}

extension CreateMenuTableViewController: MenuItemDelegate {
    func updateMenuItem(menu_items: [MenuItem]?) {
        var itemCount: Int = 0

        self.menuInformation.menuItems = menu_items
        if self.menuInformation.menuItems != nil {
            itemCount = self.menuInformation.menuItems!.count
        }
        self.labelProductCount.text = "\(itemCount) 項"
        self.isNeedToConfirmFlag = true
    }
}

extension CreateMenuTableViewController: CreateRecipeDelegate {
    func sendRecipeItems(sender: CreateRecipeTableViewController, menu_recipes: [MenuRecipe]?) {
        print("CreateMenuTableViewController receives CreateRecipeDelegate.sendRecipeItems")
        self.menuInformation.menuRecipes = menu_recipes
        self.isNeedToConfirmFlag = true
    }
}

extension CreateMenuTableViewController: BasicButtonDelegate {
    func menuConfirm(sender: BasicButtonCell) {
        print("CreateMenuTableViewController receives CreateRecipeDelegate.menuConfirm")
        
        let nowDate = Date()
        if self.isEditedMode {
            deleteMenuIcon(menu_number: self.savedMenuInformation.menuNumber)
        } else {
            self.menuInformation.menuNumber = generateMenuNumber(date: nowDate)
        }
        
        //Create Menu and save to CoreData tables
        self.menuInformation.brandName = self.textBrandName.text!
        if self.textBrandName.text == nil || self.textBrandName.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            presentSimpleAlertMessage(title: "錯誤訊息", message: "輸入的品牌名稱不能為空白，請重新輸入")
            return
        }

        self.menuInformation.brandCategory = self.labelCategory.text!
        
        let formatter = DateFormatter()
        formatter.dateFormat = DATETIME_FORMATTER
        let timeString = formatter.string(from: nowDate)

        self.menuInformation.createTime = timeString
        self.menuInformation.menuDescription = self.textViewDescription.text
        if(Auth.auth().currentUser?.uid != nil) {
            self.menuInformation.userID = Auth.auth().currentUser!.uid
            self.menuInformation.userName = Auth.auth().currentUser!.displayName!
        } else {
            //self.menuInformation.userID = "Guest"
            //self.menuInformation.userName = "Guest"
            presentSimpleAlertMessage(title: "錯誤訊息", message: "會員ID不存在！")
            return
        }

        self.originalMennuImagePathList = self.menuInformation.multiMenuImageURL
        if !self.imageArray.isEmpty {
            self.menuInformation.menuImageURL = generateMenuImageURL(user_id: self.menuInformation.userID, menu_number: self.menuInformation.menuNumber)
            deleteMenuIcon(menu_number: self.menuInformation.menuNumber)
            if self.menuIcon != nil {
                insertMenuIcon(menu_number: self.menuInformation.menuNumber, menu_icon: self.menuIcon!)
            }
            
            if self.menuInformation.multiMenuImageURL == nil {
                self.menuInformation.multiMenuImageURL = [String]()
            } else {
                self.menuInformation.multiMenuImageURL!.removeAll()
            }
            
            for i in 0...self.imageArray.count - 1 {
                let newPath = "Menu_Image/\(self.menuInformation.userID)/\(self.menuInformation.menuNumber)/\(i).jpeg"
                self.menuInformation.multiMenuImageURL!.append(newPath)
            }
        }

        self.menuInformation.needContactInfoFlag = self.isNeedContactInfo
        
        sender.setDisable()
        //insertMenuInformation(menu_info: self.menuInformation)
        uploadMenuInformation(menu_info: self.menuInformation)
    }
    
    func assignRecipe(sender: BasicButtonCell) {
        print("CreateMenuTableViewController receives CreateRecipeDelegate.assignRecipe")
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        guard let recipeController = storyBoard.instantiateViewController(withIdentifier: "CREATERECIPE_VC") as? CreateRecipeTableViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: CREATERECIPE_VC can't find!! (QRCodeViewController)")
            return
        }
        
        if self.isEditedMode {
            recipeController.isEditedMode = true
            //recipeController.menuRecipes = self.menuInformation.menuRecipes
        }
        recipeController.menuRecipes = self.menuInformation.menuRecipes
        recipeController.delegate = self
        
        navigationController?.show(recipeController, sender: self)
    }
}

extension CreateMenuTableViewController: BasicProductDelegate {
    func addBasicProductInformation(sender: BasicProductViewController, product_info: MenuItem) {
        print("CreateMenuTableViewController BasicProductDelegate receive addBasicProductInformation")
        print("product_info = \(product_info)")
        var product = product_info
        if self.menuInformation.menuItems == nil {
            self.menuInformation.menuItems = [MenuItem]()
            product.sequenceNumber = 1
        } else {
            product.sequenceNumber = self.menuInformation.menuItems![self.menuInformation.menuItems!.count - 1].sequenceNumber + 1
        }
        
        if !self.menuInformation.menuItems!.isEmpty {
            for i in 0...self.menuInformation.menuItems!.count - 1 {
                if self.menuInformation.menuItems![i].itemName == product.itemName {
                    presentSimpleAlertMessage(title: "錯誤訊息", message: "產品名稱不能重覆，請重新輸入新產品名稱")
                    return
                }
            }
        }

        self.menuInformation.menuItems?.append(product)
        self.labelProductCount.text = "\(self.menuInformation.menuItems!.count) 項"
        self.isNeedToConfirmFlag = true
    }
}

/*
extension CreateMenuTableViewController: UINavigationBarDelegate {
    func navigationShouldPopOnBackButton() -> Bool {
        var alertWindow: UIWindow!
        
        if self.savedMenuInformation.brandName != self.menuInformation.brandName {
            self.isNeedToConfirmFlag = true
        }
        
        if self.savedMenuInformation.brandCategory != self.menuInformation.brandCategory {
            self.isNeedToConfirmFlag = true
        }

        if self.isNeedToConfirmFlag {
            let controller = UIAlertController(title: "提示訊息", message: "菜單資料已更動，您確定要離開嗎？", preferredStyle: .alert)

            let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
                print("Confirm to ignore CreateMennu change")
                self.navigationController?.popToRootViewController(animated: true)
                self.dismiss(animated: false, completion: nil)

                alertWindow.isHidden = true
            }
            
            controller.addAction(okAction)
            let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (_) in
                print("Cancel to ignore CreateMenu change")
                alertWindow.isHidden = true
            }
            controller.addAction(cancelAction)
            alertWindow = presentAlert(controller)
            return false
        } else {
            //self.navigationController?.popToRootViewController(animated: true)
            //self.dismiss(animated: false, completion: nil)
            return true
        }
    }

    func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        print("CreateMenuTableViewController navigationBar shouldPop event processed!!!")
        var shouldPop = true
        //let currentVC = self.topViewController
        
        //if (currentVC?.responds(to: #selector(currentViewControllerShouldPop)))! {
        shouldPop = navigationShouldPopOnBackButton()
        //}
        
        if shouldPop {
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
            return true
        } else {
            for subView in navigationBar.subviews {
                if 0.0 < subView.alpha && subView.alpha < 1.0 {
                    UIView.animate(withDuration: 0.25, animations: {
                        subView.alpha = 1.0
                    })
                }
            }
            return false
        }
        //return false
    }
}
*/
