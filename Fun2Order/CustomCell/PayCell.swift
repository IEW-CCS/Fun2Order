//
//  PayCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/21.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class PayCell: UITableViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var applePayButton: UIButton!
    @IBOutlet weak var googlePayButton: UIButton!
    @IBOutlet weak var linePayButton: UIButton!
    @IBOutlet weak var cashPatButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backView.layer.borderWidth = CGFloat(1.5)
        self.backView.layer.borderColor = BASIC_FRAME_BORDER_COLOR_GREEN.cgColor
        self.backView.layer.cornerRadius = 6

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    @IBAction func payByApple(_ sender: UIButton) {
        
    }
    
    @IBAction func payByGoogle(_ sender: UIButton) {
        
    }
    
    @IBAction func payByLine(_ sender: UIButton) {
        
    }
    
    @IBAction func payByCash(_ sender: UIButton) {
        
    }
    
}
