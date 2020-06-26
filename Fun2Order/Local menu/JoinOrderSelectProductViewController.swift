//
//  JoinOrderSelectProductViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/2/4.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
import Firebase

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
    @IBOutlet weak var labelRecipe: UILabel!
    
    weak var delegate: JoinOrderSelectProductDelegate?
    var menuInformation: MenuInformation = MenuInformation()
    var menuProductItem: MenuProductItem = MenuProductItem()
    var menuRecipes: [MenuRecipe] = [MenuRecipe]()
    var limitedMenuItems: [MenuItem]?
    weak var parentDelegate: JoinGroupOrderDelegate?
    //var parentVC: JoinGroupOrderTableViewController!
    //var ownerID: String = ""
    //var orderNumber: String = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()
        labelProductName.text = ""
        labelQuantity.text = "1"
        self.labelRecipe.text = ""
        
        if self.menuInformation.menuItems == nil {
            self.labelProductName.isEnabled = true
            self.tableViewProduct.isHidden = true
            self.labelProductList.isHidden = true
        } else {
            self.labelProductName.isEnabled = true
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
        
        self.labelRecipe.textColor = COLOR_PEPPER_RED
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)

        let backImage = self.navigationItem.leftBarButtonItem?.image
        let newBackButton = UIBarButtonItem(title: "返回", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        navigationController?.navigationBar.backIndicatorImage = backImage

        self.stepperQuantity.value = 1

        //self.limitedMenuItems = self.menuInformation.menuItems
        
        //let parentVC = self.parent as! JoinGroupOrderTableViewController
        //self.parentDelegate = self.parentVC.delegate
        //self.parentDelegate = self
        //monitorFBProductQuantityLimit(owner_id: self.ownerID, order_number: self.orderNumber, completion: getLimitedMenuItems)
    }

    @objc func back(sender: UIBarButtonItem) {
        //let databaseRef = Database.database().reference()
        //let pathString = "USER_MENU_ORDER/\(self.ownerID)/\(self.orderNumber)/limitedMenuItems"
        //databaseRef.child(pathString).removeAllObservers()
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: false, completion: nil)
    }

    func setMenuItems(items: [MenuItem]?) {
        print("JoinOrderSelectProductViewController setMenuItems: \(String(describing: items))")
        self.limitedMenuItems = items
        self.tableViewProduct.reloadData()
    }
    
    
    //func setParentDelegate(joinorder_delegate: JoinGroupOrderDelegate?) {
    //    var parent_delegate = joinorder_delegate
    //    parent_delegate = self
    //}
/*
    func getLimitedMenuItems(items: [MenuItem]?) {
        print("JoinOrderSelectProductViewController getLimitedMenuItems: Menu Items = \(String(describing: items))")
        
        if items == nil || self.limitedMenuItems == nil {
            print("getLimitedMenuItems: Limited menu items == nil, no need to process")
            return
        }
        
        //self.limitedMenuItems = items
        for i in 0...self.limitedMenuItems!.count - 1 {
            for j in 0...items!.count - 1 {
                if self.limitedMenuItems![i].itemName == items![j].itemName {
                    self.limitedMenuItems![i] = items![j]
                    continue
                }
            }
        }
        
        //print("self.limitedMenuItems = \(String(describing: self.limitedMenuItems))")
        self.tableViewProduct.reloadData()
    }
*/
    
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
        if labelProductName.text == nil || labelProductName.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
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
        
        if self.limitedMenuItems != nil {
            var remainedQuantity: Int = 0
            for i in 0...self.limitedMenuItems!.count - 1 {
                if self.menuProductItem.itemName == self.limitedMenuItems![i].itemName {
                    if self.limitedMenuItems![i].quantityLimitation == nil {
                        continue
                    }
                    
                    if self.limitedMenuItems![i].quantityRemained != nil {
                        remainedQuantity = Int(self.limitedMenuItems![i].quantityRemained!)
                    }
                    
                    if self.menuProductItem.itemQuantity > remainedQuantity {
                        presentSimpleAlertMessage(title: "錯誤訊息", message: "此產品為限量商品，目前訂購的數量已超過剩餘的數量，請修改數量或選擇其他產品後再重新送出")
                        return
                    }
                }
            }
        }

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

        self.labelRecipe.text = recipeString
        
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
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        if self.menuInformation.menuItems == nil {
            return 0
        }
        
        return self.menuInformation.menuItems!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell", for: indexPath) as! MenuItemCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        if indexPath.section == 0 {
            cell.setProductInfo(product_info: MenuItem(), type: MENU_ITEM_CELL_TYPE_REMAINED_HEADER)
        } else {
            //cell.setProductInfo(product_info: self.menuInformation.menuItems![indexPath.row], type: MENU_ITEM_CELL_TYPE_REMAINED_BODY)
            cell.setProductInfo(product_info: self.limitedMenuItems![indexPath.row], type: MENU_ITEM_CELL_TYPE_REMAINED_BODY)
        }
        
        if self.limitedMenuItems != nil {
            if self.limitedMenuItems![indexPath.row].quantityRemained != nil {
                let remainedQuantity: Int = Int(self.limitedMenuItems![indexPath.row].quantityRemained!)
                if remainedQuantity == 0 {
                    cell.isUserInteractionEnabled = false
                    cell.setDisable()
                }
            }
        }
        //cell.setData(name: self.menuInformation.menuItems![indexPath.row].itemName, price: String(self.menuInformation.menuItems![indexPath.row].itemPrice))
        cell.tag = indexPath.row
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 0 {
            labelProductName.text = self.menuInformation.menuItems![indexPath.row].itemName
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

}

//extension JoinOrderSelectProductViewController: JoinGroupOrderDelegate {
//    func refreshLimitedMenuItems(sender: JoinGroupOrderTableViewController, items: [MenuItem]?) {
//        print("JoinOrderSelectProductViewController received refreshLimitedMenuItems")
//    }
//}
