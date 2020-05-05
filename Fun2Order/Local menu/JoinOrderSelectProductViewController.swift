//
//  JoinOrderSelectProductViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/2/4.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

protocol JoinOrderSelectProductDelegate: class {
    func setProduct(menu_item: MenuProductItem)
}

class JoinOrderSelectProductViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var labelProductName: UITextField!
    @IBOutlet weak var labelQuantity: UILabel!
    @IBOutlet weak var stepperQuantity: UIStepper!
    @IBOutlet weak var labelProductList: UILabel!
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var buttonConfirm: UIButton!
    @IBOutlet weak var buttonRecipe: UIButton!
    @IBOutlet weak var tableViewProduct: UITableView!
    @IBOutlet weak var textComments: UITextField!
    
    weak var delegate: JoinOrderSelectProductDelegate?
    var menuInformation: MenuInformation = MenuInformation()
    var menuProductItem: MenuProductItem = MenuProductItem()
    var menuRecipes: [MenuRecipe] = [MenuRecipe]()

    override func viewDidLoad() {
        super.viewDidLoad()
        labelProductName.text = ""
        labelQuantity.text = "1"
        
        if self.menuInformation.menuItems == nil {
            self.labelProductName.isEnabled = true
            self.tableViewProduct.isHidden = true
            self.labelProductList.isHidden = true
        } else {
            self.labelProductName.isEnabled = false
            self.tableViewProduct.isHidden = false
            self.labelProductList.isHidden = false
        }
        
        let itemCellViewNib: UINib = UINib(nibName: "MenuItemCell", bundle: nil)
        self.tableViewProduct.register(itemCellViewNib, forCellReuseIdentifier: "MenuItemCell")

        self.tableViewProduct.delegate = self
        self.tableViewProduct.dataSource = self
        self.tableViewProduct.layer.borderWidth = 1.0
        self.tableViewProduct.layer.borderColor = UIColor.lightGray.cgColor
        self.tableViewProduct.layer.cornerRadius = 6
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)

        self.stepperQuantity.value = 1
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
          textField.resignFirstResponder()
          return true
    }
    
    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }

    @IBAction func changeQuantity(_ sender: UIStepper) {
        let quantity = Int(sender.value)
        self.labelQuantity.text = String(quantity)
    }
    
    @IBAction func actionCancel(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: false, completion: nil)
    }

    @IBAction func actionConfirm(_ sender: UIButton) {
        if labelProductName.text == nil || labelProductName.text! == "" {
            print("Product Name should not be blank")
            presentSimpleAlertMessage(title: "錯誤訊息", message: "產品名稱不能為空白，請重新輸入或選擇產品")
            return
        }
        
        if Int(self.labelQuantity.text!) == 0 {
            presentSimpleAlertMessage(title: "錯誤訊息", message: "產品數量不能為0，請重新指定產品數量")
            return
        }
        
        self.menuProductItem.itemName = self.labelProductName.text!

        if self.textComments.text != nil {
            self.menuProductItem.itemComments = self.textComments.text!
        }

        self.menuProductItem.itemQuantity = Int(self.labelQuantity.text!)!
        
        delegate?.setProduct(menu_item: self.menuProductItem)
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: false, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowInputRecipe" {
            if let controllerRecipe = segue.destination as? JoinOrderSelectRecipeTableViewController {
                controllerRecipe.menuInformation = self.menuInformation
                controllerRecipe.isSelectRecipeMode = true
                controllerRecipe.delegate = self
            }
        }
    }
}

extension JoinOrderSelectProductViewController: JoinOrderSelectRecipeDelegate {
    func setRecipe(menu_recipes: [MenuRecipe]) {
        var isAnyRecipeItemFound: Bool = false
        
        self.menuRecipes = menu_recipes
        
        var recipeString: String = ""
        // Create Recipe Items content string
        if !self.menuRecipes.isEmpty {
            for i in 0...self.menuRecipes.count - 1 {
                if self.menuRecipes[i].recipeItems != nil {
                    for j in 0...self.menuRecipes[i].recipeItems!.count - 1 {
                        if self.menuRecipes[i].recipeItems![j].checkedFlag {
                            recipeString = recipeString + self.menuRecipes[i].recipeItems![j].recipeName + " "
                            isAnyRecipeItemFound = true
                        }
                    }
                }
            }
        }
        
        if isAnyRecipeItemFound {
            var tmpMenuRecipes: [MenuRecipe] = [MenuRecipe]()
            for i in 0...self.menuRecipes.count - 1 {
                var tmpMenuRecipe: MenuRecipe = MenuRecipe()
                tmpMenuRecipe.allowedMultiFlag = self.menuRecipes[i].allowedMultiFlag
                tmpMenuRecipe.recipeCategory = self.menuRecipes[i].recipeCategory
                tmpMenuRecipe.sequenceNumber = self.menuRecipes[i].sequenceNumber
                var isFound: Bool = false
                var tmpItems: [RecipeItem] = [RecipeItem]()
                if self.menuRecipes[i].recipeItems != nil {
                    for j in 0...self.menuRecipes[i].recipeItems!.count - 1 {
                        if self.menuRecipes[i].recipeItems![j].checkedFlag {
                            isFound = true
                            var tmpItem: RecipeItem = RecipeItem()
                            tmpItem.recipeName = self.menuRecipes[i].recipeItems![j].recipeName
                            tmpItem.checkedFlag = self.menuRecipes[i].recipeItems![j].checkedFlag
                            tmpItem.sequenceNumber = self.menuRecipes[i].recipeItems![j].sequenceNumber
                            tmpItems.append(tmpItem)
                        }
                    }
                }
                
                if isFound {
                    tmpMenuRecipe.recipeItems = tmpItems
                    tmpMenuRecipes.append(tmpMenuRecipe)
                }
            }
            self.menuProductItem.menuRecipes = tmpMenuRecipes
        }
        
        //self.labelRecipe.text = recipeString
    }
}

extension JoinOrderSelectProductViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.menuInformation.menuItems == nil {
            return 0
        }
        
        return self.menuInformation.menuItems!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell", for: indexPath) as! MenuItemCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.setData(name: self.menuInformation.menuItems![indexPath.row].itemName, price: String(self.menuInformation.menuItems![indexPath.row].itemPrice))
        cell.tag = indexPath.row
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        labelProductName.text = self.menuInformation.menuItems![indexPath.row].itemName
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

}
