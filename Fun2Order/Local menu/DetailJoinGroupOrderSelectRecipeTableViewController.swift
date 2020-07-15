//
//  DetailJoinGroupOrderSelectRecipeTableViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/7/11.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

protocol DetailJoinGroupOrderSelectRecipeDelegate: class {
    func confirmProductRecipe(sender: DetailJoinGroupOrderSelectRecipeTableViewController, recipe_items: [DetailRecipeTemplate], quantity: Int, single_price: Int, comments: String)
}

class DetailJoinGroupOrderSelectRecipeTableViewController: UITableViewController {
    @IBOutlet weak var buttonAddToCart: UIButton!
    @IBOutlet weak var labelProductName: UILabel!
    @IBOutlet weak var labelQuantity: UILabel!
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var textComments: UITextField!
    
    var recipeTemplates: [DetailRecipeTemplate] = [DetailRecipeTemplate]()
    var detailProductItem: DetailProductItem = DetailProductItem()
    var selectedRecipeItems: [DetailRecipeTemplate] = [DetailRecipeTemplate]()
    var productQuantity: Int = 0
    var productSinglePrice: Int = 0
    var cellHeight = [Int]()
    var mandatoryFlag: Bool = false
    weak var delegate: DetailJoinGroupOrderSelectRecipeDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buttonAddToCart.layer.borderWidth = 1.0
        self.buttonAddToCart.layer.borderColor = UIColor.systemBlue.cgColor
        self.buttonAddToCart.layer.cornerRadius = 6
        self.buttonAddToCart.setTitle("加入\n購物車", for: .normal)
        let menuRecipeCellViewNib: UINib = UINib(nibName: "DetailMenuRecipeCell", bundle: nil)
        self.tableView.register(menuRecipeCellViewNib, forCellReuseIdentifier: "DetailMenuRecipeCell")

        self.cellHeight.removeAll()
        if self.detailProductItem.recipeRelation != nil {
            self.cellHeight = Array(repeating: 0, count: self.detailProductItem.recipeRelation!.count)
        }

        prepareRecipeItems()
        self.labelProductName.text = self.detailProductItem.productName
        self.labelQuantity.text = "0"
        self.labelPrice.text = "0"
    }

    func prepareRecipeItems() {
        if self.detailProductItem.recipeRelation != nil {
            if !self.detailProductItem.recipeRelation!.isEmpty {
                for i in 0...self.detailProductItem.recipeRelation!.count - 1 {
                    let seq_no = self.detailProductItem.recipeRelation![i].templateSequence
                    for j in 0...self.recipeTemplates.count - 1 {
                        if self.recipeTemplates[j].templateSequence == seq_no {
                            self.selectedRecipeItems.append(self.recipeTemplates[j])
                            break
                        }
                    }
                }
            }
        }
        
        if self.detailProductItem.priceList != nil && !self.selectedRecipeItems.isEmpty {
            for k in 0...self.detailProductItem.priceList!.count - 1 {
                for m in 0...self.selectedRecipeItems.count - 1 {
                    for n in 0...self.selectedRecipeItems[m].recipeList.count - 1 {
                        if self.selectedRecipeItems[m].recipeList[n].itemName == self.detailProductItem.priceList![k].recipeItemName && self.detailProductItem.priceList![k].availableFlag == true {
                            self.selectedRecipeItems[m].recipeList[n].optionalPrice = self.detailProductItem.priceList![k].price
                        }
                    }
                }
            }
        }
    }
    
    func calculateSinglePrice() {
        if self.detailProductItem.priceList == nil {
            return
        }
        
        var isFoundFlag: Bool = false
        for i in 0...self.detailProductItem.priceList!.count - 1 {
            for j in 0...self.selectedRecipeItems.count - 1 {
                for k in 0...self.selectedRecipeItems[j].recipeList.count - 1 {
                    if self.selectedRecipeItems[j].recipeList[k].itemCheckedFlag {
                        if self.detailProductItem.priceList![i].recipeItemName == self.selectedRecipeItems[j].recipeList[k].itemName {
                            self.productSinglePrice = self.selectedRecipeItems[j].recipeList[k].optionalPrice
                            isFoundFlag = true
                            break
                        }
                    }
                }
            }
        }
        
        if !isFoundFlag {
            self.productSinglePrice = self.detailProductItem.priceList![0].price
        }
        
        for m in 0...self.selectedRecipeItems.count - 1 {
            if !self.selectedRecipeItems[m].standAloneProduct {
                for n in 0...self.selectedRecipeItems[m].recipeList.count - 1 {
                    if self.selectedRecipeItems[m].recipeList[n].itemCheckedFlag {
                        self.productSinglePrice = self.productSinglePrice + self.selectedRecipeItems[m].recipeList[n].optionalPrice
                    }
                }
            }
        }
    }
    
    func verifyMandatory() -> Bool {
        for k in 0...self.detailProductItem.recipeRelation!.count - 1 {
            let seq_no = self.detailProductItem.recipeRelation![k].templateSequence
            
            var templateIndex: Int = 0
            for i in 0...self.recipeTemplates.count - 1 {
                if self.recipeTemplates[i].templateSequence == seq_no {
                    templateIndex = i
                    break
                }
            }

            if self.recipeTemplates[templateIndex].mandatoryFlag {
                var isFound: Bool = false
                
                for j in 0...self.selectedRecipeItems.count - 1 {
                    for m in 0...self.selectedRecipeItems[j].recipeList.count - 1 {
                        if self.selectedRecipeItems[j].recipeList[m].itemCheckedFlag {
                            isFound = true
                        }
                    }
                }
                
                if !isFound {
                    let errorMessage = "[\(self.recipeTemplates[templateIndex].templateName)]為必選之項目，請重新指定配方內容"
                    presentSimpleAlertMessage(title: "錯誤訊息", message: errorMessage)
                    return false
                }
            }
        }
        
        return true
    }
    
    @IBAction func changeQuantity(_ sender: UIStepper) {
        self.productQuantity = Int(sender.value)
        self.labelQuantity.text = String(self.productQuantity)
        calculateSinglePrice()
        let totalPrice = self.productQuantity * self.productSinglePrice
        self.labelPrice.text = String(totalPrice)
    }
    
    @IBAction func confirmToCart(_ sender: UIButton) {
        if self.productQuantity == 0 {
            presentSimpleAlertMessage(title: "錯誤訊息", message: "尚未指定產品數量，請重新指定")
            return
        }
        
        if !verifyMandatory() {
            return
        }
        
        var comments: String = ""
        if self.textComments.text != nil {
            comments = self.textComments.text!
        }
        
        self.delegate?.confirmProductRecipe(sender: self, recipe_items: self.selectedRecipeItems, quantity: self.productQuantity, single_price: self.productSinglePrice, comments: comments)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            if self.detailProductItem.recipeRelation == nil {
                return 0
            }
            
            return self.detailProductItem.recipeRelation!.count
        }
        
        return super.tableView(tableView, numberOfRowsInSection: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailMenuRecipeCell", for: indexPath) as! DetailMenuRecipeCell

            let seq_no = self.detailProductItem.recipeRelation![indexPath.row].templateSequence
            
            var templateIndex: Int = 0
            for i in 0...self.recipeTemplates.count - 1 {
                if self.recipeTemplates[i].templateSequence == seq_no {
                    templateIndex = i
                    break
                }
            }
            cell.setData(recipe_data: self.recipeTemplates[templateIndex], recipe_items: self.selectedRecipeItems[indexPath.row],  recipe_relation: self.detailProductItem.recipeRelation![indexPath.row].itemRelation, number_for_row: 3)
            cellHeight[indexPath.row] = cell.getCellHeight()
            cell.tag = indexPath.row
            cell.delegate = self
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return CGFloat(cellHeight[indexPath.row])
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        if indexPath.section == 1 {
            let newIndexPath = IndexPath(row: 0, section: indexPath.section)
            return super.tableView(tableView, indentationLevelForRowAt: newIndexPath)
        } else {
            return super.tableView(tableView, indentationLevelForRowAt: indexPath)
        }
    }

}

extension DetailJoinGroupOrderSelectRecipeTableViewController: DetailMenuRecipeCellDelegate {
    func configProductRecipeRelation(sender: DetailMenuRecipeCell, index: Int, recipe_items: DetailRecipeTemplate) {
        print("Receive DetailMenuRecipeCellDelegate for configProductRecipeRelation for index[\(index)]")
        print("recipe_items = \(recipe_items)")
        self.selectedRecipeItems[index] = recipe_items
        self.calculateSinglePrice()
        self.labelPrice.text = String(self.productSinglePrice * self.productQuantity)
    }
}
