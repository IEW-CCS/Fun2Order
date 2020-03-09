//
//  BasicButtonCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/20.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit
import CoreData
import Foundation

protocol BasicButtonDelegate: class {
    func menuList(sender: BasicButtonCell)
    func menuCreate(sender: BasicButtonCell)
    func menuConfirm(sender: BasicButtonCell)
    func assignRecipe(sender: BasicButtonCell)
    func sendRecipeItems(sender: BasicButtonCell)
    func addFavoriteProduct(sender: BasicButtonCell)
    func setupRecipe(sender: BasicButtonCell)
    func displayAbout(sender: BasicButtonCell)
    func refreshStatusSummary(sender: BasicButtonCell)
    func notifyMenuOrderDueTime(sender: BasicButtonCell)
    func joinOrderToSelectRecipe(sender: BasicButtonCell)
}

extension BasicButtonDelegate {
    func menuList(sender: BasicButtonCell) {}
    func menuCreate(sender: BasicButtonCell) {}
    func menuConfirm(sender: BasicButtonCell) {}
    func assignRecipe(sender: BasicButtonCell) {}
    func sendRecipeItems(sender: BasicButtonCell) {}
    func addFavoriteProduct(sender: BasicButtonCell) {}
    func setupRecipe(sender: BasicButtonCell) {}
    func displayAbout(sender: BasicButtonCell) {}
    func refreshStatusSummary(sender: BasicButtonCell) {}
    func notifyMenuOrderDueTime(sender: BasicButtonCell) {}
    func joinOrderToSelectRecipe(sender: BasicButtonCell) {}
}

class BasicButtonCell: UITableViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var iconImage: UIImageView!
    var actionType: String = ""
    weak var delegate: BasicButtonDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backView.layer.borderWidth = CGFloat(1.5)
        self.backView.layer.borderColor = COLOR_PEPPER_RED.cgColor
        self.backView.layer.cornerRadius = 6
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setData(icon: UIImage, button_text: String, action_type: String) {
        self.favoriteButton.setTitle(button_text, for: .normal)
        self.iconImage.image = icon
        self.iconImage.tintColor = CUSTOM_COLOR_EMERALD_GREEN
        self.actionType = action_type
    }
    
    func setEnable() {
        self.favoriteButton.isEnabled = true
    }
    
    func setDisable() {
        self.favoriteButton.isEnabled = false
    }
    
    @IBAction func addToFavorite(_ sender: UIButton) {
        switch self.actionType {
        case BUTTON_ACTION_FAVORITE:
            // Send notification to RecipeTableViewController
            NotificationCenter.default.post(name: NSNotification.Name("AddFavoriteProduct"), object: nil)
            break
                
        case BUTTON_ACTION_CART:
            // Send notification to RecipeTableViewController
            NotificationCenter.default.post(name: NSNotification.Name("AddToCart"), object: nil)
            break

        case BUTTON_ACTION_MENU_LIST:
            // Send notification to MenuHomeTableViewController
            //NotificationCenter.default.post(name: NSNotification.Name("MenuList"), object: nil)
            delegate?.menuList(sender: self)
            break
            
        case BUTTON_ACTION_MENU_CREATE:
            // Send notification to MenuHomeTableViewController
            //NotificationCenter.default.post(name: NSNotification.Name("MenuCreate"), object: nil)
            delegate?.menuCreate(sender: self)
            break
            
        case BUTTON_ACTION_MENU_CONFIRM:
            // Send notification to CreateMenuTableViewController
            //NotificationCenter.default.post(name: NSNotification.Name("MenuConfirm"), object: nil)
            delegate?.menuConfirm(sender: self)
            break

        case BUTTON_ACTION_ASSIGN_RECIPE:
            // Send notification to CreateMenuTableViewController
            //NotificationCenter.default.post(name: NSNotification.Name("AssignRecipe"), object: nil)
            delegate?.assignRecipe(sender: self)
            break

        case BUTTON_ACTION_SETUP_RECIPE:
            // Send notification to CreateRecipeTableViewController
            //NotificationCenter.default.post(name: NSNotification.Name("SetupRecipe"), object: nil)
            delegate?.setupRecipe(sender: self)
            break

        case BUTTON_ACTION_ABOUT:
            // Send notification to MenuHomeTableViewController
            //NotificationCenter.default.post(name: NSNotification.Name("DisplayAbout"), object: nil)
            delegate?.displayAbout(sender: self)
            break

        case BUTTON_ACTION_REFRESH_STATUS_SUMMARY:
            // Send notification to StatusSummaryTableViewController
            //NotificationCenter.default.post(name: NSNotification.Name("RefreshStatusSummary"), object: nil)
            delegate?.refreshStatusSummary(sender: self)
            break

        case BUTTON_ACTION_NOTIFY_MENUORDER_DUETIME:
            // Send notification to StatusSummaryTableViewController
            //NotificationCenter.default.post(name: NSNotification.Name("NotifyMenuOrderDueTime"), object: nil)
            delegate?.notifyMenuOrderDueTime(sender: self)
            break

        case BUTTON_ACTION_JOINORDER_SELECT_RECIPE:
            // Send notification to StatusSummaryTableViewController
            //NotificationCenter.default.post(name: NSNotification.Name("JoinOrderSelectRecipe"), object: nil)
            delegate?.joinOrderToSelectRecipe(sender: self)
            break

        default:
            break
        }
    }
}
