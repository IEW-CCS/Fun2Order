//
//  BasicButtonCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/20.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit
import CoreData

class BasicButtonCell: UITableViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var iconImage: UIImageView!
    var actionType: String = ""
    
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
        self.actionType = action_type
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
            NotificationCenter.default.post(name: NSNotification.Name("MenuList"), object: nil)
            break
            
        case BUTTON_ACTION_MENU_CREATE:
            // Send notification to MenuHomeTableViewController
            NotificationCenter.default.post(name: NSNotification.Name("MenuCreate"), object: nil)
            break
            
        case BUTTON_ACTION_MENU_CONFIRM:
            // Send notification to CreateMenuTableViewController
            NotificationCenter.default.post(name: NSNotification.Name("MenuConfirm"), object: nil)
            break

        case BUTTON_ACTION_ASSIGN_RECIPE:
            // Send notification to CreateMenuTableViewController
            NotificationCenter.default.post(name: NSNotification.Name("AssignRecipe"), object: nil)
            break

        case BUTTON_ACTION_SETUP_RECIPE:
            // Send notification to CreateRecipeTableViewController
            NotificationCenter.default.post(name: NSNotification.Name("SetupRecipe"), object: nil)
            break

        case BUTTON_ACTION_ABOUT:
            // Send notification to MenuHomeTableViewController
            NotificationCenter.default.post(name: NSNotification.Name("DisplayAbout"), object: nil)
            break

        case BUTTON_ACTION_REFRESH_STATUS_SUMMARY:
            // Send notification to StatusSummaryTableViewController
            NotificationCenter.default.post(name: NSNotification.Name("RefreshStatusSummary"), object: nil)
            break

        case BUTTON_ACTION_NOTIFY_MENUORDER_DUETIME:
            // Send notification to StatusSummaryTableViewController
            NotificationCenter.default.post(name: NSNotification.Name("NotifyMenuOrderDueTime"), object: nil)
            break

        case BUTTON_ACTION_JOINORDER_SELECT_RECIPE:
            // Send notification to StatusSummaryTableViewController
            NotificationCenter.default.post(name: NSNotification.Name("JoinOrderSelectRecipe"), object: nil)
            break

        default:
            break
        }
    }
}
