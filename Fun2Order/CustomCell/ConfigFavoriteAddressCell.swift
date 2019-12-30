//
//  ConfigFavoriteAddressCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/12/23.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class ConfigFavoriteAddressCell: UITableViewCell {
    @IBOutlet weak var labelAddress: UILabel!
    @IBOutlet weak var backView: UIView!
    var rowIndex = IndexPath()
    let app = UIApplication.shared.delegate as! AppDelegate

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backView.layer.borderWidth = CGFloat(1.0)
        self.backView.layer.borderColor = BASIC_FRAME_BORDER_COLOR_GREEN.cgColor
        self.backView.layer.cornerRadius = 6    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setData(address: String) {
        self.labelAddress.text = address
    }
    
    func setIndex(index: IndexPath) {
        self.rowIndex = index
    }
    
    @IBAction func deleteAddress(_ sender: UIButton) {
        let controller = UIAlertController(title: "刪除最愛外送地址", message: "確定要刪除此最愛外送地址嗎？", preferredStyle: .alert)

        let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
            print("Confirm to delete this address")
            NotificationCenter.default.post(name: NSNotification.Name("ConfigDeleteAddress"), object: self.rowIndex)
        }
        
        controller.addAction(okAction)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        app.window?.rootViewController!.present(controller, animated: true, completion: nil)

    }
    
}
