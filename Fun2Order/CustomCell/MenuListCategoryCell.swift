//
//  MenuListCategoryCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/3/17.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

protocol MenuListCategoryCellDelegate: class {
    func categoryIndexChanged(sender: MenuListCategoryCell, index: Int)
    func displayAbout(sender: MenuListCategoryCell)
    func displayCreateMenu(sender: MenuListCategoryCell)
}

class MenuListCategoryCell: UITableViewCell {
    @IBOutlet weak var buttonAbout: UIButton!
    @IBOutlet weak var buttonCreateMenu: UIButton!
    @IBOutlet weak var scrollCategorySegment: ScrollUISegmentController!
    var isMenuExist: Bool = false
    var itemsArray: [String] = [String]()
    var selectedIndex: Int = 0
    
    weak var delegate: MenuListCategoryCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.scrollCategorySegment.segmentDelegate = self
        self.scrollCategorySegment.tag = 1
        self.scrollCategorySegment.layer.borderWidth = 1
        self.scrollCategorySegment.layer.borderColor = UIColor.systemBlue.cgColor
        self.scrollCategorySegment.layer.cornerRadius = 3
        if self.isMenuExist == false {
            self.scrollCategorySegment.isHidden = true
        } else {
            self.scrollCategorySegment.isHidden = false
        }
        
        self.buttonAbout.imageView?.tintColor = UIColor.systemBlue
        self.buttonCreateMenu.imageView?.tintColor = UIColor.systemBlue
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupScrollCategorySegment(index: Int) {
        if self.itemsArray.isEmpty {
            self.scrollCategorySegment.segmentItems = ["未分類"]
            self.selectedIndex = index
        } else {
            var itemArray: [String] = [String]()
            for i in 0...(self.itemsArray.count - 1) {
                itemArray.append(self.itemsArray[i])
            }
            
            itemArray.append("未分類")
            self.scrollCategorySegment.segmentItems = itemArray
            //self.scrollCategorySegment.createSegment()
            self.selectedIndex = index
        }
    }

    func setData(menu_exist_flag: Bool, items: [String]) {
        self.isMenuExist = menu_exist_flag
        //self.itemsArray = items
        //self.scrollCategorySegment.segmentItems = items
        
        if self.isMenuExist == false {
            self.scrollCategorySegment.isHidden = true
        } else {
            self.scrollCategorySegment.isHidden = false
        }

        self.itemsArray.removeAll()
        if items.isEmpty {
            self.scrollCategorySegment.segmentItems = ["未分類"]
            self.selectedIndex = 0
        } else {
            //var itemArray: [String] = [String]()
            for i in 0...(items.count - 1) {
                //itemArray.append(self.itemsArray[i])
                self.itemsArray.append(items[i])
            }
            
            self.itemsArray.append("未分類")
            self.scrollCategorySegment.segmentItems = self.itemsArray
            //self.scrollCategorySegment.createSegment()
            self.selectedIndex = 0
        }
        
        self.scrollCategorySegment.setSelectedIndex(index: self.selectedIndex)
    }
    
    
    @IBAction func clickAbout(_ sender: UIButton) {
        self.delegate?.displayAbout(sender: self)
    }
    
    @IBAction func clickCreateMenu(_ sender: UIButton) {
        self.delegate?.displayCreateMenu(sender: self)
    }
}

extension MenuListCategoryCell: ScrollUISegmentControllerDelegate {
    func selectItemAt(index: Int, onScrollUISegmentController scrollUISegmentController: ScrollUISegmentController) {
        print("select Item At [\(index)] in scrollUISegmentController with tag  \(scrollUISegmentController.tag) ")
        self.delegate?.categoryIndexChanged(sender: self, index: index)
    }
}
