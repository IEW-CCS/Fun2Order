//
//  BrandEventCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/8/20.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit
import Kingfisher

class BrandEventCell: UITableViewCell {
    @IBOutlet weak var imageEvent: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelSubTitle: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setData(event_data: DetailBrandEvent) {
        if event_data.eventImageURL != nil {
            //print("event_data.eventImageURL is not nil")
            //print("event_data.eventImageURL = \(event_data.eventImageURL!)")
            let url = URL(string: event_data.eventImageURL!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            //print("url = \(String(describing: url))")
            self.imageEvent.kf.setImage(with: url)
        }
        
        self.labelTitle.text = event_data.eventTitle
        self.labelSubTitle.text = event_data.eventSubTitle
        self.labelDate.text = event_data.publishDate
    }
}
