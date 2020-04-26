//
//  ScrollUISegmentController.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/3/13.
//  Copyright © 2020 JStudio. All rights reserved.
//

import Foundation
import UIKit

protocol ScrollUISegmentControllerDelegate: class {
    func selectItemAt(index :Int, onScrollUISegmentController scrollUISegmentController:ScrollUISegmentController)
}


@IBDesignable
class ScrollUISegmentController: UIScrollView  {
   private var segmentedControl: UISegmentedControl = UISegmentedControl()
    
    weak var segmentDelegate: ScrollUISegmentControllerDelegate?
    

    @IBInspectable
    public var segmentTintColor: UIColor = .systemBlue {
        didSet {
            self.segmentedControl.tintColor = self.segmentTintColor
        }
    }
    
    
    @IBInspectable
    public var itemWidth: CGFloat = 80 {
        didSet {
        }
    }

    public var segmentFont: UIFont = UIFont.systemFont(ofSize: 14) {
        didSet {
            self.segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: self.segmentFont],for: UIControl.State())
        }
    }
    public var itemsCount: Int = 3
    public var segmentheight : CGFloat = 29.0

    
    public var segmentItems: Array = [""] {
        didSet {
            self.itemsCount = segmentItems.count
            self.createSegment()
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        createSegment()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSegment()
        
    }
    
    init(frame: CGRect , andItems items:[String]) {
        super.init(frame: frame)
        self.segmentItems = items
        self.itemsCount = segmentItems.count
        self.createSegment()
    }
    
    func createSegment() {
        self.segmentedControl.removeFromSuperview()
        segmentheight =  self.frame.height
        itemWidth = 80
        var width = CGFloat(self.itemWidth * CGFloat(self.itemsCount))
        if width < self.frame.width {
            itemWidth =  CGFloat(self.frame.width) / CGFloat(itemsCount)
             width = CGFloat(self.itemWidth * CGFloat(self.itemsCount))
        }
        self.segmentedControl = UISegmentedControl(frame: CGRect(x: 0 , y: 0, width: width , height: segmentheight))
        self.addSubview(self.segmentedControl)
        self.backgroundColor = .clear
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        NSLayoutConstraint(item: self.segmentedControl, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self.segmentedControl, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0).isActive = true
        let contentHeight =  self.frame.height
        self.contentSize = CGSize (width: width, height: contentHeight)
        self.segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: self.segmentFont],for: UIControl.State())
        self.segmentedControl.tintColor = self.segmentTintColor
        self.segmentedControl.selectedSegmentIndex = 0;
        insertItems()
        self.segmentedControl.addTarget(self, action: #selector(self.segmentChangeSelectedIndex(_:)), for: .valueChanged)
    }
    
    func insertItems(){
        for item in segmentItems {
            self.segmentedControl.insertSegment(withTitle: item, at: (segmentItems.firstIndex(of: item))!, animated: true)
               }
    }
    
    func removeAllItems() {
        self.segmentedControl.removeAllSegments()
    }
    
    func setSelectedIndex(index: Int) {
        self.segmentedControl.selectedSegmentIndex = index
    }
    
    @objc func segmentChangeSelectedIndex(_ sender: AnyObject) {
        segmentDelegate?.selectItemAt(index: self.segmentedControl.selectedSegmentIndex, onScrollUISegmentController: self)
        print("\(self.segmentedControl.selectedSegmentIndex)")
    }
}
