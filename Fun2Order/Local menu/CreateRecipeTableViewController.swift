//
//  CreateRecipeTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/1/8.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
import Firebase

protocol CreateRecipeDelegate: class {
    func sendRecipeItems(sender: CreateRecipeTableViewController, menu_recipes: [MenuRecipe]?)
}

class CreateRecipeTableViewController: UITableViewController {
    var brandCategory: [String] = [String]()
    var customBrandCategory: [String] = [String]()
    var menuRecipeTemplates: [MenuRecipeTemplate] = [MenuRecipeTemplate]()
    var customRecipeTemplate: [MenuRecipeTemplate] = [MenuRecipeTemplate]()
    var selectedTemoplateIndex:Int = -1
    var cellHeight = [Int]();
    var isEditedMode: Bool = false
    var menuRecipes: [MenuRecipe]?
    weak var delegate: CreateRecipeDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        let selectTemplateCellViewNib: UINib = UINib(nibName: "SelectMenuRecipeTemplateCell", bundle: nil)
        self.tableView.register(selectTemplateCellViewNib, forCellReuseIdentifier: "SelectMenuRecipeTemplateCell")

        let menuRecipeCellViewNib: UINib = UINib(nibName: "MenuRecipeCell", bundle: nil)
        self.tableView.register(menuRecipeCellViewNib, forCellReuseIdentifier: "MenuRecipeCell")

        let basicButtonCellViewNib: UINib = UINib(nibName: "BasicButtonCell", bundle: nil)
        self.tableView.register(basicButtonCellViewNib, forCellReuseIdentifier: "BasicButtonCell")

        refershRecipe()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }

    override func viewDidDisappear(_ animated: Bool) {
        print("CreateRecipeTableViewController enters viewDidDisappear")
        self.dismiss(animated: true, completion: {
            print("CreateRecipeTableViewController dismissed")
        })
    }

    func refershRecipe() {
        self.selectedTemoplateIndex = 0
        self.cellHeight.removeAll()
        if self.menuRecipes != nil {
            self.cellHeight = Array(repeating: 0, count: self.menuRecipes!.count)
        }
        self.tableView.reloadData()
    }
    
    func displayTemplate() {
        let controller = UIAlertController(title: "請選擇範本", message: nil, preferredStyle: .alert)

        guard let templateController = self.storyboard?.instantiateViewController(withIdentifier: "TEMPLATE_VC") as? TemplateViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: TEMPLATE_VC can't find!! (QRCodeViewController)")
            return
        }
        
        templateController.preferredContentSize.height = 360
        controller.preferredContentSize.height = 360

        controller.setValue(templateController, forKey: "contentViewController")

        controller.addChild(templateController)
        templateController.setData(template_ids: self.brandCategory, custom_template_ids: self.customBrandCategory)
        templateController.delegate = self
        
        present(controller, animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.menuRecipes == nil {
            return 1
        } else {
            return self.menuRecipes!.count + 2
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectMenuRecipeTemplateCell", for: indexPath) as! SelectMenuRecipeTemplateCell

            cell.delegate = self
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
        
        if indexPath.row == self.menuRecipes!.count + 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BasicButtonCell", for: indexPath) as! BasicButtonCell
            
            let iconImage: UIImage = UIImage(named: "Icon_Menu_Recipe.png")!.withRenderingMode(.alwaysTemplate)
            if self.isEditedMode {
                cell.setData(icon: iconImage, button_text: "修改配方", action_type: BUTTON_ACTION_SETUP_RECIPE)
            } else {
                cell.setData(icon: iconImage, button_text: "設定配方", action_type: BUTTON_ACTION_SETUP_RECIPE)
            }
            cell.delegate = self
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuRecipeCell", for: indexPath) as! MenuRecipeCell

        cell.setData(recipe_data: self.menuRecipes![indexPath.row - 1], number_for_row: 3)
        cellHeight[indexPath.row - 1] = cell.getCellHeight()
        cell.tag = indexPath.row - 1
        cell.delegate = self
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row != 0 && indexPath.row !=  self.menuRecipes!.count + 1 {
            return CGFloat(cellHeight[indexPath.row - 1])
        }

        return 54
    }
    
}

extension CreateRecipeTableViewController: MenuRecipeCellDelegate {
    func setMenuRecipe(cell: UITableViewCell, menu_recipe: MenuRecipe, data_index: Int) {
        self.menuRecipes![data_index] = menu_recipe
    }
    
    func addRecipeItem(cell: UITableViewCell, menu_recipe: MenuRecipe, data_index: Int) {
        self.menuRecipes![data_index] = menu_recipe
        self.tableView.reloadData()
    }
}

extension CreateRecipeTableViewController: SelectMenuRecipeTemplateCellDelegate {
    func queryMenuRecipeTemplateData(cell: UITableViewCell) {
        let dispatchGroup = DispatchGroup()

        let databaseRef = Database.database().reference()
        let templateDatabasePath = "MENU_RECIPE_TEMPLATE"
        //testFunction1()
        //testFunction2()
        dispatchGroup.enter()
        databaseRef.child(templateDatabasePath).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                self.menuRecipeTemplates.removeAll()
                
                let childEnumerator = snapshot.children
                
                let childDecoder: JSONDecoder = JSONDecoder()
                while let childData = childEnumerator.nextObject() as? DataSnapshot {
                    do {
                        let childJsonData = try? JSONSerialization.data(withJSONObject: childData.value as Any, options: [])
                        let realData = try childDecoder.decode(MenuRecipeTemplate.self, from: childJsonData!)
                        self.menuRecipeTemplates.append(realData)
                    } catch {
                        print("queryMenuRecipeTemplateData jsonData decode failed: \(error.localizedDescription)")
                        continue
                    }
                }

                if !self.menuRecipeTemplates.isEmpty {
                    self.menuRecipeTemplates.sort(by: {$0.sequenceNumber < $1.sequenceNumber})
                    self.brandCategory.removeAll()
                    for i in 0...self.menuRecipeTemplates.count - 1 {
                        self.brandCategory.append(self.menuRecipeTemplates[i].templateName)
                    }
                }
                dispatchGroup.leave()
            } else {
                print("queryMenuRecipeTemplateData snapshot doesn't exist!")
                dispatchGroup.leave()
                return
            }
        }) { (error) in
            print(error.localizedDescription)
            dispatchGroup.leave()
        }

        let customTemplateDatabasePath = "USER_CUSTOM_RECIPE_TEMPLATE/\(Auth.auth().currentUser!.uid)"
        dispatchGroup.enter()
        databaseRef.child(customTemplateDatabasePath).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                self.customRecipeTemplate.removeAll()
                
                let childEnumerator = snapshot.children
                
                let childDecoder: JSONDecoder = JSONDecoder()
                while let childData = childEnumerator.nextObject() as? DataSnapshot {
                    //print("child = \(childData)")
                    do {
                        let childJsonData = try? JSONSerialization.data(withJSONObject: childData.value as Any, options: [])
                        let realData = try childDecoder.decode(MenuRecipeTemplate.self, from: childJsonData!)
                        self.customRecipeTemplate.append(realData)
                        //print("Success: \(realData.brandName)")
                    } catch {
                        print("queryMenuRecipeTemplateData jsonData decode failed: \(error.localizedDescription)")
                        continue
                    }
                }
                
                if !self.customRecipeTemplate.isEmpty {
                    self.customRecipeTemplate.sort(by: {$0.sequenceNumber < $1.sequenceNumber})
                    self.customBrandCategory.removeAll()
                    for i in 0...self.customRecipeTemplate.count - 1 {
                        self.customBrandCategory.append(self.customRecipeTemplate[i].templateName)
                    }
                }
                dispatchGroup.leave()
            } else {
                print("queryMenuRecipeTemplateData snapshot doesn't exist!")
                dispatchGroup.leave()
                return
            }
        }) { (error) in
            print(error.localizedDescription)
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) {
            self.displayTemplate()
        }
    }
    
    func addNewRecipeCategory(cell: UITableViewCell) {
        let controller = UIAlertController(title: "請輸入類別名稱", message: nil, preferredStyle: .actionSheet)

        guard let categoryController = self.storyboard?.instantiateViewController(withIdentifier: "RECIPE_CATEGORY_VC") as? RecipeCategoryViewController else{
            assertionFailure("[AssertionFailure] StoryBoard: RECIPE_CATEGORY_VC can't find!! (QRCodeViewController)")
            return
        }

        controller.setValue(categoryController, forKey: "contentViewController")
        categoryController.preferredContentSize.height = 120
        controller.preferredContentSize.height = 120
        categoryController.preferredContentSize.width = 320
        controller.preferredContentSize.width = 320
        controller.addChild(categoryController)
        
        let cancelAction = UIAlertAction(title: "取消", style: .default) { (_) in
            print("Cancel to create recipe category!")
        }
        
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        controller.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
            let category_controller = controller.children[0] as! RecipeCategoryViewController
            let recipeCategory = category_controller.getRecipeCategory()
            if recipeCategory == nil || recipeCategory!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                presentSimpleAlertMessage(title: "錯誤訊息", message: "輸入的配方類別名稱不能為空白，請重新輸入")
                return
            }

            var menuRecipeData: MenuRecipe = MenuRecipe()
            menuRecipeData.recipeCategory = category_controller.getRecipeCategory()!
            menuRecipeData.allowedMultiFlag = category_controller.getCheckStatus()
            if self.menuRecipes == nil {
                menuRecipeData.sequenceNumber = 1
                self.menuRecipes = [MenuRecipe]()
                self.menuRecipes?.append(menuRecipeData)
            } else {
                var sequenceNumber: Int = 0
                for i in 0...self.menuRecipes!.count - 1 {
                    if self.menuRecipes![i].sequenceNumber > sequenceNumber {
                        sequenceNumber = self.menuRecipes![i].sequenceNumber
                    }
                }
                sequenceNumber = sequenceNumber + 1
                menuRecipeData.sequenceNumber = sequenceNumber
                self.menuRecipes?.append(menuRecipeData)
            }
            self.refershRecipe()
        }

        okAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        controller.addAction(okAction)

        present(controller, animated: true, completion: nil)
    }
    
    func saveMenuRecipeTemplate(cell: UITableViewCell) {
        //print("CreateRecipeTableViewController receive BasicButtonDelegate.setupRecipe")
        
        if self.menuRecipes == nil {
            presentSimpleAlertMessage(title: "警告訊息", message: "目前自訂的範本內容為空白，因此無法儲存，請新增資料後再試一次。")
            return
        } else {
            let controller = UIAlertController(title: "請輸入範本名稱", message: nil, preferredStyle: .alert)
            controller.addTextField { (textField) in
                textField.placeholder = "範本名稱"
            }
            
            let cancelAction = UIAlertAction(title: "取消", style: .default) { (_) in
                print("Cancel to save custom recipe template!")
            }
            
            cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
            controller.addAction(cancelAction)
            
            let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
                let templateName = controller.textFields?[0].text
                if templateName == nil || templateName!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                    presentSimpleAlertMessage(title: "錯誤訊息", message: "範本名稱不可為空白，請重新輸入")
                    return
                }

                var tmpData: [MenuRecipe]?
                
                for i in 0...self.menuRecipes!.count - 1 {
                    var recipeItems: [RecipeItem] = [RecipeItem]()
                    if self.menuRecipes![i].recipeItems != nil {
                        for j in 0...self.menuRecipes![i].recipeItems!.count - 1 {
                            //if self.menuRecipes![i].recipeItems![j].checkedFlag {
                                var tmpItem: RecipeItem = RecipeItem()
                                tmpItem.sequenceNumber = self.menuRecipes![i].recipeItems![j].sequenceNumber
                                tmpItem.checkedFlag = true
                                tmpItem.recipeName = self.menuRecipes![i].recipeItems![j].recipeName
                                
                                recipeItems.append(tmpItem)
                            //}
                        }
                    }
                    
                    if !recipeItems.isEmpty {
                        var finalRecipe: MenuRecipe = MenuRecipe()
                        finalRecipe.sequenceNumber = self.menuRecipes![i].sequenceNumber
                        finalRecipe.recipeCategory = self.menuRecipes![i].recipeCategory
                        finalRecipe.allowedMultiFlag = self.menuRecipes![i].allowedMultiFlag
                        finalRecipe.recipeItems = recipeItems
                        
                        if tmpData == nil {
                            tmpData = [MenuRecipe]()
                        }
                        tmpData?.append(finalRecipe)
                    }
                }

                if tmpData != nil {
                    var templateData: MenuRecipeTemplate = MenuRecipeTemplate()
                    templateData.sequenceNumber = getRecipeTemplateLastSequenceNumber()
                    templateData.templateName = templateName!
                    templateData.menuRecipes = tmpData!
                    
                    if Auth.auth().currentUser?.uid != nil {
                        uploadFBMenuRecipeTemplate(user_id: Auth.auth().currentUser!.uid, template: templateData)
                    }
                }
                
            }
            okAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
            controller.addAction(okAction)
            
            present(controller, animated: true, completion: nil)
        }
    }
}

extension CreateRecipeTableViewController: BasicButtonDelegate {
    func setupRecipe(sender: BasicButtonCell) {
        print("CreateRecipeTableViewController receive BasicButtonDelegate.setupRecipe")
        if self.menuRecipes == nil {
            //NotificationCenter.default.post(name: NSNotification.Name("SendRecipeItems"), object: nil)
            delegate?.sendRecipeItems(sender: self, menu_recipes: nil)
            navigationController?.popViewController(animated: true)
            self.dismiss(animated: false, completion: nil)
        } else {
            var tmpData: [MenuRecipe]?
            
            for i in 0...self.menuRecipes!.count - 1 {
                var recipeItems: [RecipeItem] = [RecipeItem]()
                if self.menuRecipes![i].recipeItems != nil {
                    for j in 0...self.menuRecipes![i].recipeItems!.count - 1 {
                        if self.menuRecipes![i].recipeItems![j].checkedFlag {
                            var tmpItem: RecipeItem = RecipeItem()
                            tmpItem.sequenceNumber = self.menuRecipes![i].recipeItems![j].sequenceNumber
                            tmpItem.checkedFlag = true
                            tmpItem.recipeName = self.menuRecipes![i].recipeItems![j].recipeName
                            
                            recipeItems.append(tmpItem)
                        }
                    }
                }
                
                if !recipeItems.isEmpty {
                    var finalRecipe: MenuRecipe = MenuRecipe()
                    finalRecipe.sequenceNumber = self.menuRecipes![i].sequenceNumber
                    finalRecipe.recipeCategory = self.menuRecipes![i].recipeCategory
                    finalRecipe.allowedMultiFlag = self.menuRecipes![i].allowedMultiFlag
                    finalRecipe.recipeItems = recipeItems
                    
                    if tmpData == nil {
                        tmpData = [MenuRecipe]()
                    }
                    tmpData?.append(finalRecipe)
                }
            }

            delegate?.sendRecipeItems(sender: self, menu_recipes: tmpData)
            navigationController?.popViewController(animated: true)
            self.dismiss(animated: false, completion: nil)
        }
    }
}

extension CreateRecipeTableViewController: MenuTemplateDelegate {
    func sendTemplateSelectedIndex(sender: TemplateViewController, type: Int, index: Int) {
        if type == 0 && self.customRecipeTemplate.isEmpty {
            return
        }
        
        if type == 1 && self.menuRecipeTemplates.isEmpty {
            return
        }
        
        self.selectedTemoplateIndex = index
        //let indexPath = IndexPath(row: 0, section: 0)
        //let cell = self.tableView.cellForRow(at: indexPath) as! SelectMenuRecipeTemplateCell
        //cell.setData(template_name: self.brandCategory[templateIndex])
        cellHeight.removeAll()
        if type == 0 {
            cellHeight = Array(repeating: 0, count: self.customRecipeTemplate[self.selectedTemoplateIndex].menuRecipes.count)

            if self.menuRecipes != nil {
                self.menuRecipes!.removeAll()
            } else {
                self.menuRecipes = [MenuRecipe]()
            }
            self.menuRecipes = Array<MenuRecipe>(repeating: MenuRecipe(), count: self.customRecipeTemplate[self.selectedTemoplateIndex].menuRecipes.count)

            self.menuRecipes = self.customRecipeTemplate[self.selectedTemoplateIndex].menuRecipes
            self.tableView.reloadData()
        } else if type == 1 {
            cellHeight = Array(repeating: 0, count: self.menuRecipeTemplates[self.selectedTemoplateIndex].menuRecipes.count)

            if self.menuRecipes != nil {
                self.menuRecipes!.removeAll()
            } else {
                self.menuRecipes = [MenuRecipe]()
            }
            self.menuRecipes = Array<MenuRecipe>(repeating: MenuRecipe(), count: self.menuRecipeTemplates[self.selectedTemoplateIndex].menuRecipes.count)

            self.menuRecipes = self.menuRecipeTemplates[self.selectedTemoplateIndex].menuRecipes
            self.tableView.reloadData()
        }
    }
    
    func deleteCustomTemplate(sender: TemplateViewController, index: Int) {
        print("Delete index[\(index)] of custom template name[\(self.customRecipeTemplate[index].templateName)]")
        
        self.customRecipeTemplate.remove(at: index)
    }
}
