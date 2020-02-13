//
//  ConfigFavoriteProductCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/12/23.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class ConfigFavoriteProductCell: UITableViewCell {
    @IBOutlet weak var imageProduct: UIImageView!
    @IBOutlet weak var labelProductName: UILabel!
    @IBOutlet weak var labelRecipe: UILabel!
    @IBOutlet weak var backView: UIView!
    var rowIndex = IndexPath()
    let app = UIApplication.shared.delegate as! AppDelegate

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backView.layer.borderWidth = CGFloat(1.0)
        self.backView.layer.borderColor = BASIC_FRAME_BORDER_COLOR_GREEN.cgColor
        self.backView.layer.cornerRadius = 6
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setData(product_image: UIImage, title: String, sub_title: String) {
        self.labelProductName.text = title
        self.labelRecipe.text = sub_title
        self.imageProduct.image = product_image
    }
    
    func setIndex(index: IndexPath) {
        self.rowIndex = index
    }
    
    @IBAction func deleteProduct(_ sender: UIButton) {
        var alertWindow: UIWindow!
        let controller = UIAlertController(title: "刪除最愛產品", message: "確定要刪除此最愛產品嗎？", preferredStyle: .alert)

        let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
            print("Confirm to delete this product")
            NotificationCenter.default.post(name: NSNotification.Name("ConfigDeleteProduct"), object: self.rowIndex)
            alertWindow.isHidden = true
        }
        
        controller.addAction(okAction)
        //let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (_) in
            print("Cancel the action")
            alertWindow.isHidden = true
        }
        controller.addAction(cancelAction)
        //app.window?.rootViewController!.present(controller, animated: true, completion: nil)
        alertWindow = presentAlert(controller)

    }
    
}
