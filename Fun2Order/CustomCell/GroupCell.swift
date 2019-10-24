//
//  GroupCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/22.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit

class GroupCell: UICollectionViewCell {
    var groupLabel: UILabel!
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("CollectionViewCell init from frame")
        groupLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        groupLabel.textAlignment = .center
        self.addSubview(groupLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        print("CollectionViewCell init from coder")
        fatalError("init(coder:) has not been implemented")
    }
    
    func setData(group: String) {
        print("setData: \(group)")
        //self.groupLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        //self.groupLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.groupLabel.text = group
    }
}
