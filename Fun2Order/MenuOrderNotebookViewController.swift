//
//  MenuOrderNotebookViewController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/1/22.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

class MenuOrderNotebookViewController: UIViewController {
    @IBOutlet weak var buttonCopy: UIButton!
    @IBOutlet weak var segmentOption: UISegmentedControl!
    @IBOutlet weak var textViewContent: UITextView!
    
    var menuOrder: MenuOrder = MenuOrder()
    var filterItems: [MenuOrderMemberContent] = [MenuOrderMemberContent]()
    var isNoLocations: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.textViewContent.layer.borderWidth = 1
        self.textViewContent.layer.borderColor = UIColor.darkGray.cgColor
        self.textViewContent.layer.cornerRadius = 6
        
        setupSegmentOption()
    }
    
    @IBAction func changeOption(_ sender: UISegmentedControl) {
        if self.isNoLocations {
            if self.segmentOption.selectedSegmentIndex == 0 {
                generateContentString()
            } else {
                generateMergedContentString()
            }
        } else {
            if self.segmentOption.selectedSegmentIndex == self.menuOrder.locations!.count {
                generateMergedContentString()
            } else {
                generateContentString()
            }
        }
    }
    
    @IBAction func copyContent(_ sender: UIButton) {
        UIPasteboard.general.string = self.textViewContent.text
    }
    
    func setupSegmentOption() {
        //if self.menuOrder.locations.isEmpty {
        if self.menuOrder.locations == nil {
            self.segmentOption.removeAllSegments()
            self.segmentOption.insertSegment(withTitle: "全部項目", at: 0, animated: true)
            self.segmentOption.insertSegment(withTitle: "顯示合併項目", at: 1, animated: true)
            self.segmentOption.selectedSegmentIndex = 0
            self.isNoLocations = true
        } else {
            self.segmentOption.removeAllSegments()
            for i in 0...(self.menuOrder.locations!.count - 1) {
                self.segmentOption.insertSegment(withTitle: self.menuOrder.locations![i], at: i, animated: true)
            }
            self.segmentOption.insertSegment(withTitle: "顯示合併項目", at: self.menuOrder.locations!.count, animated: true)
            self.segmentOption.selectedSegmentIndex = 0
            self.isNoLocations = false
        }
        generateContentString()
    }
    
    func getItemString(index: Int) -> String {
/*
        var itemString: String = ""
        itemString = itemString + self.menuOrder.contentItems[index].orderContent.itemOwnerName + " " + self.menuOrder.contentItems[index].orderContent.itemProductName + " "
        let spaceCount = itemString.lengthOfBytes(using: .utf8)
        let prefixSpaces = String(repeating: " ", count: spaceCount)

        if self.menuOrder.contentItems[index].orderContent.menuRecipes != nil {
            for j in 0...self.menuOrder.contentItems[index].orderContent.menuRecipes!.count - 1 {
                if self.menuOrder.contentItems[index].orderContent.menuRecipes![j].recipeItems != nil {
                    for k in 0...self.menuOrder.contentItems[index].orderContent.menuRecipes![j].recipeItems!.count - 1 {
                        itemString = itemString + self.menuOrder.contentItems[index].orderContent.menuRecipes![j].recipeItems![k].recipeName + " "
                    }
                }
            }
        }
        
        itemString = itemString + " * " + String(self.menuOrder.contentItems[index].orderContent.itemQuantity) + "\n"
        if self.menuOrder.contentItems[index].orderContent.itemComments != "" {
            itemString = itemString + prefixSpaces + self.menuOrder.contentItems[index].orderContent.itemComments + "\n"
        }
*/
        
        var itemString: String = ""
        if self.menuOrder.contentItems[index].orderContent.menuProductItems != nil {
            for m in 0...self.menuOrder.contentItems[index].orderContent.menuProductItems!.count - 1 {
                itemString = itemString + self.menuOrder.contentItems[index].orderContent.itemOwnerName + " " + self.menuOrder.contentItems[index].orderContent.menuProductItems![m].itemName + " "
                let spaceCount = itemString.lengthOfBytes(using: .utf8)
                let prefixSpaces = String(repeating: " ", count: spaceCount)

                if self.menuOrder.contentItems[index].orderContent.menuProductItems![m].menuRecipes != nil {
                    for j in 0...self.menuOrder.contentItems[index].orderContent.menuProductItems![m].menuRecipes!.count - 1 {
                        if self.menuOrder.contentItems[index].orderContent.menuProductItems![m].menuRecipes![j].recipeItems != nil {
                            for k in 0...self.menuOrder.contentItems[index].orderContent.menuProductItems![m].menuRecipes![j].recipeItems!.count - 1 {
                                itemString = itemString + self.menuOrder.contentItems[index].orderContent.menuProductItems![m].menuRecipes![j].recipeItems![k].recipeName + " "
                            }
                        }
                    }
                }
                
                itemString = itemString + " * " + String(self.menuOrder.contentItems[index].orderContent.menuProductItems![m].itemQuantity) + "\n"
                if self.menuOrder.contentItems[index].orderContent.menuProductItems![m].itemComments != "" {
                    itemString = itemString + prefixSpaces + self.menuOrder.contentItems[index].orderContent.menuProductItems![m].itemComments + "\n"
                }
            }
        }

        return itemString
    }
    
    func getMergedItemRecipe(index: Int, product_index: Int) -> String {
/*
        var recipeString: String = ""
        recipeString = recipeString + self.menuOrder.contentItems[index].orderContent.itemProductName + "  "
        if self.menuOrder.contentItems[index].orderContent.menuRecipes != nil {
            for j in 0...self.menuOrder.contentItems[index].orderContent.menuRecipes!.count - 1 {
                if self.menuOrder.contentItems[index].orderContent.menuRecipes![j].recipeItems != nil {
                    for k in 0...self.menuOrder.contentItems[index].orderContent.menuRecipes![j].recipeItems!.count - 1 {
                        recipeString = recipeString + self.menuOrder.contentItems[index].orderContent.menuRecipes![j].recipeItems![k].recipeName + " "
                    }
                }
            }
        }
*/
 
        var recipeString: String = ""
        if self.menuOrder.contentItems[index].orderContent.menuProductItems != nil {
            //for m in 0...self.menuOrder.contentItems[index].orderContent.menuProductItems!.count - 1 {
                recipeString = recipeString + self.menuOrder.contentItems[index].orderContent.menuProductItems![product_index].itemName + "  "
                if self.menuOrder.contentItems[index].orderContent.menuProductItems![product_index].menuRecipes != nil {
                    for j in 0...self.menuOrder.contentItems[index].orderContent.menuProductItems![product_index].menuRecipes!.count - 1 {
                        if self.menuOrder.contentItems[index].orderContent.menuProductItems![product_index].menuRecipes![j].recipeItems != nil {
                            for k in 0...self.menuOrder.contentItems[index].orderContent.menuProductItems![product_index].menuRecipes![j].recipeItems!.count - 1 {
                                recipeString = recipeString + self.menuOrder.contentItems[index].orderContent.menuProductItems![product_index].menuRecipes![j].recipeItems![k].recipeName + " "
                            }
                        }
                    }
                }
            //recipeString = recipeString + self.menuOrder.contentItems[index].orderContent.menuProductItems![product_index].itemComments
            //}
        }


        return recipeString
    }
    
    func generateContentString() {
        var content: String = ""
        if self.menuOrder.contentItems.isEmpty {
            return
        }
        
        if self.isNoLocations {
            for i in 0...self.menuOrder.contentItems.count - 1 {
                if self.menuOrder.contentItems[i].orderContent.replyStatus != MENU_ORDER_REPLY_STATUS_ACCEPT {
                    continue
                }
                content = content + getItemString(index: i)
            }
        } else {
            for i in 0...self.menuOrder.contentItems.count - 1 {
                if self.menuOrder.contentItems[i].orderContent.replyStatus != MENU_ORDER_REPLY_STATUS_ACCEPT {
                    continue
                }
                if self.menuOrder.contentItems[i].orderContent.location != self.menuOrder.locations![self.segmentOption.selectedSegmentIndex] {
                    continue
                }
                
                content = content + getItemString(index: i)
            }
        }
        self.textViewContent.text = content
    }

    func generateMergedContentString() {
        var mergedContent: [MergedContent] = [MergedContent]()
        
        var tmp: MergedContent = MergedContent()

        if self.menuOrder.contentItems.isEmpty {
            return
        }

        for i in 0...self.menuOrder.contentItems.count - 1 {
            if self.menuOrder.contentItems[i].orderContent.replyStatus != MENU_ORDER_REPLY_STATUS_ACCEPT {
                continue
            }
            
            if self.menuOrder.contentItems[i].orderContent.menuProductItems != nil {
                for k in 0...self.menuOrder.contentItems[i].orderContent.menuProductItems!.count - 1 {
                    if mergedContent.isEmpty {
                        tmp.mergedRecipe = getMergedItemRecipe(index: i, product_index: k)
                        tmp.comments = self.menuOrder.contentItems[i].orderContent.menuProductItems![k].itemComments
                        tmp.quantity = self.menuOrder.contentItems[i].orderContent.menuProductItems![k].itemQuantity
                        tmp.location = self.menuOrder.contentItems[i].orderContent.location
                        mergedContent.append(tmp)
                    } else {
                        var isFound: Bool = false
                        for j in 0...mergedContent.count - 1 {
                            if mergedContent[j].mergedRecipe == getMergedItemRecipe(index: i, product_index: k) && mergedContent[j].location == self.menuOrder.contentItems[i].orderContent.location && mergedContent[j].comments == self.menuOrder.contentItems[i].orderContent.menuProductItems![k].itemComments {
                                mergedContent[j].quantity = mergedContent[j].quantity + self.menuOrder.contentItems[i].orderContent.menuProductItems![k].itemQuantity
                                isFound = true
                                break
                            }
                        }
                        
                        if !isFound {
                            tmp.comments = self.menuOrder.contentItems[i].orderContent.menuProductItems![k].itemComments
                            tmp.mergedRecipe = getMergedItemRecipe(index: i, product_index: k)
                            tmp.quantity = self.menuOrder.contentItems[i].orderContent.menuProductItems![k].itemQuantity
                            tmp.location = self.menuOrder.contentItems[i].orderContent.location
                            mergedContent.append(tmp)
                        }
                    }
                }
            }
        }

        if self.isNoLocations {
            if !mergedContent.isEmpty {
                var content: String = ""
                for i in 0...mergedContent.count - 1 {
                    content = content + mergedContent[i].mergedRecipe + " * " + String(mergedContent[i].quantity) + "\n"
                    content = content + mergedContent[i].comments + "\n"
                }
                self.textViewContent.text = content
            }
        } else {
            if !mergedContent.isEmpty {
                var content: String = ""
                let prefixString = "  "
                for i in 0...self.menuOrder.locations!.count - 1 {
                    content = content + "--" + self.menuOrder.locations![i] + "\n"
                    for j in 0...mergedContent.count - 1 {
                        if mergedContent[j].location == self.menuOrder.locations![i] {
                            content = content + prefixString + mergedContent[j].mergedRecipe + " * " + String(mergedContent[j].quantity) + "\n"
                            content = content + prefixString + mergedContent[j].comments + "\n"
                        }
                    }
                }
                self.textViewContent.text = content
            }
        }
    }
}
