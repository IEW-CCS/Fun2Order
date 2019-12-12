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
            NotificationCenter.default.post(name: NSNotification.Name("AddFavoriteProduct"), object: nil)
            break
                
        case BUTTON_ACTION_CART:
            NotificationCenter.default.post(name: NSNotification.Name("AddToCart"), object: nil)
            break
            
        default:
            break
        }
    }
}
