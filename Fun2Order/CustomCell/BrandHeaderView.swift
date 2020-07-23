//
//  BrandHeaderView.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/7/5.
//  Copyright © 2020 JStudio. All rights reserved.
//

import UIKit

protocol BrandHeaderDelegate: class {
    func suggestNewBrand(sender: BrandHeaderView)
    func searchBrandRequest(sender: BrandHeaderView, searchText: String)
}

class BrandHeaderView: UICollectionReusableView, UITextFieldDelegate {
    @IBOutlet weak var searchBrand: UISearchBar!
    @IBOutlet weak var buttonSuggestion: UIButton!
    @IBOutlet weak var segmentBrandCategory: ScrollUISegmentController!
    
    weak var delegate: BrandHeaderDelegate?
    var categoryList: [String] = [String]()

    override func awakeFromNib() {
        super.awakeFromNib()
        self.buttonSuggestion.layer.borderWidth = 1.0
        self.buttonSuggestion.layer.borderColor = UIColor.lightGray.cgColor
        self.buttonSuggestion.layer.cornerRadius = 6
        
        self.searchBrand.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        tap.cancelsTouchesInView = false
        self.addGestureRecognizer(tap)

    }
    
    override func draw(_ rect: CGRect) {
        print("draw self.frame = \(self.frame)")
        print("draw self.segmentBrandCategory.frame = \(self.segmentBrandCategory.frame)")
        let segmentFrame = self.segmentBrandCategory.frame
        self.segmentBrandCategory.reDrawNewFrame(frame: segmentFrame)
        self.segmentBrandCategory.segmentItems = self.categoryList
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
          textField.resignFirstResponder()
          return true
    }
    
    @objc func dismissKeyBoard() {
        self.endEditing(true)
    }

    func setData(items: [String]) {
        self.categoryList = items
    }
    
    @IBAction func suggestNewBrand(_ sender: UIButton) {
        self.delegate?.suggestNewBrand(sender: self)
    }
}

extension BrandHeaderView: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.delegate?.searchBrandRequest(sender: self, searchText: searchText)
    }
}
