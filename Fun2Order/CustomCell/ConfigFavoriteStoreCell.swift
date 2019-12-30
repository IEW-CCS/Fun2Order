//
//  ConfigFavoriteStoreCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/12/23.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class ConfigFavoriteStoreCell: UITableViewCell {
    @IBOutlet weak var imageBrandIcon: UIImageView!
    @IBOutlet weak var labelStoreName: UILabel!
    @IBOutlet weak var labelStoreDescription: UILabel!
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
    
    func setData(brand_image: UIImage, title: String, sub_title: String) {
        self.labelStoreName.text = title
        self.labelStoreDescription.text = sub_title
        self.imageBrandIcon.image = brand_image
    }
    
    func setIndex(index: IndexPath) {
        self.rowIndex = index
    }
    
    @IBAction func deleteStore(_ sender: UIButton) {
        let controller = UIAlertController(title: "刪除最愛店家", message: "刪除最愛店家會一併刪除與此店家有關的最愛產品，確定要刪除此最愛店家嗎？", preferredStyle: .alert)

        let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
            print("Confirm to delete this store")
            NotificationCenter.default.post(name: NSNotification.Name("ConfigDeleteStore"), object: self.rowIndex)
        }
        
        controller.addAction(okAction)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        app.window?.rootViewController!.present(controller, animated: true, completion: nil)
    }
    
}
