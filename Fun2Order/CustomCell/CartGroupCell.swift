//
//  CartGroupCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/21.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class CartGroupCell: UITableViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var orderTableView: UITableView!
    
    
    let memberImages: [UIImage] = [UIImage(named: "Image_Me.png")!,
                                UIImage(named: "Image_Me.png")!,
                                UIImage(named: "Image_Friend1.png")!,
                                UIImage(named: "Image_Friend2.png")!,
                                UIImage(named: "Image_Friend3.png")!,
                                UIImage(named: "Image_Friend4.png")!,
                                UIImage(named: "Image_Friend5.png")!]
    
    let productTitles: [String] = ["紅茶", "綠茶", "珍珠鮮奶茶", "觀音拿鐵", "金桔檸檬", "仙草凍奶茶", "青茶"]
    let recipeTitles: [String] = ["微糖 微冰 大杯", "微糖 少冰 大杯", "半糖 少冰 中杯", "微糖 去冰 大杯", "全糖 微冰 中杯", "半糖 微冰 大杯", "少糖 少冰 大杯"]
    
    let quantitlArray: [String] = ["1", "2", "1", "1", "2", "3", "5"]
    
    let payImages: [UIImage] =  [UIImage(named: "Pay_Cash.png")!,
                                UIImage(named: "Pay_Cash.png")!,
                                UIImage(named: "Pay_ApplePay.png")!,
                                UIImage(named: "Pay_LinePay.png")!,
                                UIImage(named: "Pay_LinePay.png")!,
                                UIImage(named: "Pay_GooglePay.png")!,
                                UIImage(named: "Pay_Cash.png")!]
    
    let meFlags: [Bool] = [true, true, false, false, false, false, false]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backView.layer.borderWidth = CGFloat(1.5)
        self.backView.layer.borderColor = BASIC_FRAME_BORDER_COLOR_GREEN.cgColor
        self.backView.layer.cornerRadius = 6
        
        let nib = UINib(nibName: "CartListCell", bundle: nil)
        self.orderTableView.register(nib, forCellReuseIdentifier: "CartListCell")
        self.orderTableView.delegate = self
        self.orderTableView.dataSource = self
        self.orderTableView.layer.cornerRadius = 6
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}

extension CartGroupCell: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberofSections section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.productTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartListCell", for: indexPath) as! CartListCell
        
        cell.setData(me_flag: self.meFlags[indexPath.row],
                     member_image: self.memberImages[indexPath.row],
                     product_title: self.productTitles[indexPath.row],
                     recipe: self.recipeTitles[indexPath.row],
                     quantity: self.quantitlArray[indexPath.row],
                     pay_image: self.payImages[indexPath.row])
        
        return cell
    }
}
