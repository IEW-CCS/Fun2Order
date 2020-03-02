//
//  CreateMenuTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/1/8.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
import Firebase

class CreateMenuTableViewController: UITableViewController, UITextFieldDelegate {
    @IBOutlet weak var textBrandName: UITextField!
    @IBOutlet weak var buttonCategory: UIButton!
    @IBOutlet weak var labelCategory: UILabel!
    @IBOutlet weak var textViewDescription: UITextView!
    @IBOutlet weak var buttonMenuImage: UIButton!
    @IBOutlet weak var imageMenuPhoto: UIImageView!
    @IBOutlet weak var buttonProduct: UIButton!
    @IBOutlet weak var labelLocationCount: UILabel!
    @IBOutlet weak var labelProductCount: UILabel!
    
    var menuInformation: MenuInformation = MenuInformation()
    //var menuIcon: UIImage = UIImage()
    var menuIcon: UIImage?
    var savedMenuInformation: MenuInformation = MenuInformation()
    var isNeedSave: Bool = false
    var isEditedMode: Bool = false
    var testDate: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let basicButtonCellViewNib: UINib = UINib(nibName: "BasicButtonCell", bundle: nil)
        self.tableView.register(basicButtonCellViewNib, forCellReuseIdentifier: "BasicButtonCell")

        self.textViewDescription.layer.borderWidth = 1
        self.textViewDescription.layer.borderColor = UIColor.lightGray.cgColor
        self.textViewDescription.layer.cornerRadius = 6
        self.textViewDescription.text = ""
        
        self.imageMenuPhoto.layer.borderWidth = 1
        self.imageMenuPhoto.layer.borderColor = UIColor.lightGray.cgColor
        self.imageMenuPhoto.layer.cornerRadius = 6
        
        self.labelCategory.text = ""
        
        self.textBrandName.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        self.savedMenuInformation = self.menuInformation
        refreshMenu()
    }
    
    override func viewWillAppear(_ animated: Bool) {

    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
          textField.resignFirstResponder()
          return true
    }
    
    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("CreateMenuTableViewController enters viewDidDisappear")
        self.dismiss(animated: true, completion: {
            print("CreateMenuTableViewController dismissed")
        })
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
        if self.menuInformation.menuImageURL != "" {
            let storageRef = Storage.storage().reference()
            storageRef.child(self.menuInformation.menuImageURL).getData(maxSize: 3 * 2048 * 2048, completion: { (data, error) in
                if let error = error {
                    print(error.localizedDescription)
                    DispatchQueue.main.async {
                        let httpAlert = alert(message: error.localizedDescription, title: "存取菜單影像錯誤")
                        self.present(httpAlert, animated : false, completion : nil)
                        return
                    }
                }
                
                self.imageMenuPhoto.image = UIImage(data: data!)!
                if self.menuIcon == nil {
                    self.menuIcon = UIImage()
                }
                self.menuIcon = resizeImage(image: self.imageMenuPhoto.image!, width: CGFloat(MENU_ICON_WIDTH))
            })
        }
        
        if self.menuInformation.locations != nil {
            locationCount = self.menuInformation.locations!.count
        }
        self.labelLocationCount.text = "\(locationCount) 項"

        
        if self.menuInformation.menuItems != nil {
            itemCount = self.menuInformation.menuItems!.count
        }
        self.labelProductCount.text = "\(itemCount) 項"

    }

    func generateMenuNumber(date: Date) -> String {
        let timeZone = TimeZone.init(identifier: "UTC+8")
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.locale = Locale.init(identifier: "zh_TW")
        formatter.dateFormat = DATETIME_FORMATTER
        
        var tmpMenuNumber = formatter.string(from: date)
        if(Auth.auth().currentUser?.uid != nil) {
            tmpMenuNumber = "\(Auth.auth().currentUser!.uid)-MENU-\(tmpMenuNumber)"
        } else {
            tmpMenuNumber = "Guest-MENU-\(tmpMenuNumber)"
        }

        return tmpMenuNumber
    }
    
    func generateMenuImageURL(user_id: String, menu_number: String) -> String {
        let pathString = "Menu_Image/\(user_id)/\(menu_number).jpeg"
        
        return pathString
    }
    
    func uploadMenuInformation(menu_info: MenuInformation) {
        let menuImage = self.imageMenuPhoto.image
        if menuImage != nil {
            let storageRef = Storage.storage().reference().child(menu_info.menuImageURL)
            let newImage = resizeImage(image: menuImage!, width: 1440)
            let uploadData = newImage.jpegData(compressionQuality: 0.5)
            if uploadData != nil {
                storageRef.putData(uploadData!, metadata: nil, completion: { (data, error) in
                    if error != nil {
                        print(error!.localizedDescription)
                        return
                    }
                })
            }
        }
        
        let databaseRef = Database.database().reference()
        let pathString = "USER_MENU_INFORMATION/\(menu_info.userID)/\(menu_info.menuNumber)"
        //print("menu_info transformed object = \(menu_info.toAnyObject())")
        
        databaseRef.child(pathString).setValue(menu_info.toAnyObject()) { (_, _) in
            print("Firebase setValue of Menu Information successfule, then send notification to refresh Menu List")
            // Send notification to refresh Menu List function
            NotificationCenter.default.post(name: NSNotification.Name("RefreshMenuList"), object: nil)
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
            
            let cancelAction = UIAlertAction(title: "取消", style: .default) { (_) in
                print("Cancel to select brand category!")
                alertWindow.isHidden = true
            }
            
            cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
            controller.addAction(cancelAction)
            
            let addAction = UIAlertAction(title: "加入菜單分類", style: .default) { (_) in
                print("Add to brand category!")
                let category_string = controller.textFields?[0].text
                print("New added brand category = \(category_string!)")
                insertMenuBrandCategory(category: category_string!)
                self.labelCategory.text = category_string!
                self.menuInformation.brandCategory = category_string!
                alertWindow.isHidden = true
            }
            addAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
            controller.addAction(addAction)
            
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
            print("New added brand category = \(category_string!)")
            insertMenuBrandCategory(category: category_string!)
            self.labelCategory.text = category_string!
            self.menuInformation.brandCategory = category_string!
            alertTextWindow.isHidden = true
        }
        
        textController.addAction(addAction)
        alertTextWindow = presentAlert(textController)
    }
    
    @IBAction func selectMenuPhoto(_ sender: UIButton) {
        let controller = UIAlertController(title: "選取照片來源", message: nil, preferredStyle: .actionSheet)
        
        let photoAction = UIAlertAction(title: "相簿", style: .default) { (_) in
            // Add code to pick a photo from Album
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .photoLibrary
                //imagePicker.allowsEditing = true
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
                //imagePicker.allowsEditing = true
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
            if location_string != "" {
                if self.menuInformation.locations == nil {
                    self.menuInformation.locations = [String]()
                }
                self.menuInformation.locations?.append(location_string!)
                self.labelLocationCount.text = "\(self.menuInformation.locations!.count) 項"
                self.isNeedSave = true
            }
        }
        okAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        controller.addAction(okAction)
        
        present(controller, animated: true, completion: nil)

    }
    
    @IBAction func addProduct(_ sender: UIButton) {
        let controller = UIAlertController(title: "請輸入產品名稱或價格", message: nil, preferredStyle: .alert)
        controller.addTextField { (textField) in
            textField.placeholder = "產品名稱"
        }

        controller.addTextField { (textField) in
            textField.placeholder = "價格"
        }

        let cancelAction = UIAlertAction(title: "取消", style: .default) { (_) in
            print("Cancel to update product & price!")
        }
        
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        controller.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
            var tmpProductItem = MenuItem()
            let product_string = controller.textFields?[0].text
            let price_string = controller.textFields?[1].text
            tmpProductItem.itemName = product_string!
            if price_string != "" {
                tmpProductItem.itemPrice = Int(price_string!)!
            }
            
            if self.menuInformation.menuItems == nil {
                self.menuInformation.menuItems = [MenuItem]()
                tmpProductItem.sequenceNumber = 1
            } else {
                tmpProductItem.sequenceNumber = self.menuInformation.menuItems![self.menuInformation.menuItems!.count - 1].sequenceNumber + 1
            }

            self.menuInformation.menuItems?.append(tmpProductItem)
            self.labelProductCount.text = "\(self.menuInformation.menuItems!.count) 項"
            self.isNeedSave = true
        }
        okAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        controller.addAction(okAction)
        
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
                    cell.setData(icon: iconImage, button_text: "指定配方", action_type: BUTTON_ACTION_ASSIGN_RECIPE)
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

        return super.tableView(tableView, cellForRowAt: indexPath)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 3 {
            return 54
        }

        return super.tableView(tableView, heightForRowAt: indexPath)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 3 {
            return 0
        }
        
        return super.tableView(tableView, heightForHeaderInSection: section)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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

extension CreateMenuTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        //let newImage = resizeImage(image: image, width: 1024)
        self.imageMenuPhoto.image = image
        let iconImage = resizeImage(image: image, width: CGFloat(MENU_ICON_WIDTH))
        if self.menuIcon == nil {
            self.menuIcon = UIImage()
        }
        self.menuIcon = iconImage
        self.isNeedSave = true
        dismiss(animated: true, completion: nil)
    }
}

extension CreateMenuTableViewController: MenuLocationDelegate {
    func deleteMenuLocation(locations: [String]?) {
        var locationCount: Int = 0

        self.menuInformation.locations = locations
        if self.menuInformation.locations != nil {
            locationCount = self.menuInformation.locations!.count
        }
        self.labelLocationCount.text = "\(locationCount) 項"
    }
}

extension CreateMenuTableViewController: MenuItemDelegate {
    func deleteMenuItem(menu_items: [MenuItem]?) {
        var itemCount: Int = 0

        self.menuInformation.menuItems = menu_items
        if self.menuInformation.menuItems != nil {
            itemCount = self.menuInformation.menuItems!.count
        }
        self.labelProductCount.text = "\(itemCount) 項"
    }
}

extension CreateMenuTableViewController: CreateRecipeDelegate {
    func sendRecipeItems(sender: CreateRecipeTableViewController, menu_recipes: [MenuRecipe]?) {
        print("CreateMenuTableViewController receives CreateRecipeDelegate.sendRecipeItems")
        self.menuInformation.menuRecipes = menu_recipes
    }
}

extension CreateMenuTableViewController: BasicButtonDelegate {
    func menuConfirm(sender: BasicButtonCell) {
        print("CreateMenuTableViewController receives CreateRecipeDelegate.menuConfirm")
        
        let nowDate = Date()
        if self.isEditedMode {
            //deleteMenuInformation(menu_info: self.savedMenuInformation)
            deleteMenuIcon(menu_number: self.savedMenuInformation.menuNumber)
            //deleteFBMenuInformation(user_id: self.savedMenuInformation.userID, menu_number: self.savedMenuInformation.menuNumber, image_url: self.savedMenuInformation.menuImageURL)
        } else {
            self.menuInformation.menuNumber = generateMenuNumber(date: nowDate)
        }
        
        //Create Menu and save to CoreData tables
        self.menuInformation.brandName = self.textBrandName.text!
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
            self.menuInformation.userID = "Guest"
            self.menuInformation.userName = "Guest"
        }
        
        if self.imageMenuPhoto.image != nil {
            self.menuInformation.menuImageURL = generateMenuImageURL(user_id: self.menuInformation.userID, menu_number: self.menuInformation.menuNumber)
            deleteMenuIcon(menu_number: self.menuInformation.menuNumber)
            if self.menuIcon != nil {
                insertMenuIcon(menu_number: self.menuInformation.menuNumber, menu_icon: self.menuIcon!)
            }
        }

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
