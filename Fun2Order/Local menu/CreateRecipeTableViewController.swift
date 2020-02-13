//
//  CreateRecipeTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/1/8.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
import Firebase

class CreateRecipeTableViewController: UITableViewController {
    var brandCategory: [String] = [String]()
    var menuRecipeTemplates: [MenuRecipeTemplate] = [MenuRecipeTemplate]()
    var selectedTemoplateIndex:Int = -1
    var cellHeight = [Int]();
    var isEditedMode: Bool = false
    var menuRecipes: [MenuRecipe]?

    override func viewDidLoad() {
        super.viewDidLoad()

        let selectTemplateCellViewNib: UINib = UINib(nibName: "SelectMenuRecipeTemplateCell", bundle: nil)
        self.tableView.register(selectTemplateCellViewNib, forCellReuseIdentifier: "SelectMenuRecipeTemplateCell")

        let menuRecipeCellViewNib: UINib = UINib(nibName: "MenuRecipeCell", bundle: nil)
        self.tableView.register(menuRecipeCellViewNib, forCellReuseIdentifier: "MenuRecipeCell")

        let basicButtonCellViewNib: UINib = UINib(nibName: "BasicButtonCell", bundle: nil)
        self.tableView.register(basicButtonCellViewNib, forCellReuseIdentifier: "BasicButtonCell")

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.receiveTemplateIndex(_:)),
            name: NSNotification.Name(rawValue: "SelectTemplate"),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.receiveSetupRecipe(_:)),
            name: NSNotification.Name(rawValue: "SetupRecipe"),
            object: nil
        )

        refershRecipe()
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

        controller.setValue(templateController, forKey: "contentViewController")
        templateController.preferredContentSize.height = 200
        controller.preferredContentSize.height = 200
        controller.addChild(templateController)
        templateController.setData(template_ids: self.brandCategory)
        
        present(controller, animated: true, completion: nil)
    }

    @objc func receiveSetupRecipe(_ notification: Notification) {
        if self.menuRecipes == nil {
            // Send notification to CreateMenuTableViewController
            NotificationCenter.default.post(name: NSNotification.Name("SendRecipeItems"), object: nil)
            navigationController?.popViewController(animated: true)
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
                    finalRecipe.isAllowedMulti = self.menuRecipes![i].isAllowedMulti
                    finalRecipe.recipeItems = recipeItems
                    if tmpData == nil {
                        tmpData = [MenuRecipe]()
                    }
                    tmpData?.append(finalRecipe)
                }
            }

            // Send notification to CreateMenuTableViewController
            NotificationCenter.default.post(name: NSNotification.Name("SendRecipeItems"), object: tmpData)
            navigationController?.popViewController(animated: true)
        }
    }

    @objc func receiveTemplateIndex(_ notification: Notification) {
        if let templateIndex = notification.object as? Int {
            self.selectedTemoplateIndex = templateIndex
            let indexPath = IndexPath(row: 0, section: 0)
            let cell = self.tableView.cellForRow(at: indexPath) as! SelectMenuRecipeTemplateCell
            cell.setData(template_name: self.brandCategory[templateIndex])
            cellHeight.removeAll()
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
            
            let iconImage: UIImage = UIImage(named: "Icon_Menu_Recipe.png")!
            if self.isEditedMode {
                cell.setData(icon: iconImage, button_text: "修改配方", action_type: BUTTON_ACTION_SETUP_RECIPE)
            } else {
                cell.setData(icon: iconImage, button_text: "設定配方", action_type: BUTTON_ACTION_SETUP_RECIPE)
            }

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
}

extension CreateRecipeTableViewController: SelectMenuRecipeTemplateCellDelegate {
    func queryMenuRecipeTemplateData(cell: UITableViewCell) {
        let databaseRef = Database.database().reference()
        let templateDatabasePath = "MENU_RECIPE_TEMPLATE"
        //testFunction1()
        //testFunction2()
        databaseRef.child(templateDatabasePath).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let templateDictionary = snapshot.value
                let jsonData = try? JSONSerialization.data(withJSONObject: templateDictionary as Any, options: [])
                let jsonString = String(data: jsonData!, encoding: .utf8)!
                print("jsonString = \(jsonString)")

                let decoder: JSONDecoder = JSONDecoder()
                do {
                    let templateArray = try decoder.decode([String:MenuRecipeTemplate].self, from: jsonData!)
                    self.brandCategory.removeAll()
                    self.menuRecipeTemplates.removeAll()
                    
                    for keyValuePair in templateArray {
                        self.brandCategory.append(keyValuePair.key)
                        self.menuRecipeTemplates.append(keyValuePair.value)
                    }
                    
                    self.displayTemplate()
                } catch {
                    print("jsonData decode failed: \(error.localizedDescription)")
                }
            } else {
                print("queryTemplateData snapshot doesn't exist!")
                return
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}
