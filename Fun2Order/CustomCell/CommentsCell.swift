//
//  CommentsCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/12/5.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class CommentsCell: UITableViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //self.backView.layer.borderWidth = CGFloat(1.5)
        //self.backView.layer.borderColor = UIColor.darkGray.cgColor
        //self.backView.layer.cornerRadius = 6
        self.textView.text = ""
        self.textView.layer.borderWidth = CGFloat(1.0)
        self.textView.layer.borderColor = UIColor.darkGray.cgColor
        self.textView.layer.cornerRadius = 6
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func getComments() -> String {
        return self.textView.text
    }
    
    func setComments(comments_string: String) {
        self.textView.text = comments_string
    }
}
