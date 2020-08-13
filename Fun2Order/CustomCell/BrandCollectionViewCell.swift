//
//  BrandCollectionViewCell.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/14.
//  Copyright © 2019 JStudio. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

protocol BrandCollectionCellDelegate: class {
    func getBrandImage(sender: BrandCollectionViewCell, icon: UIImage?, index: Int)
}

class BrandCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var txtLabel: UILabel!
    
    weak var delegate: BrandCollectionCellDelegate?
    var brandImage: UIImage?
    var dataIndex: Int = 0
    var startDate: Date = Date()
    var endDate: Date = Date()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imageIcon.layer.cornerRadius = 8
    }

    func setData(text: String, image: UIImage) {
        self.txtLabel.text = text
        self.imageIcon.image = image
    }

    func receiveBrandImage(image: UIImage?) {
        if image != nil {
            self.endDate = Date()
            print("Image[\(self.txtLabel.text!)]: Start Time = \(String(describing: self.startDate)), Diff time = \(self.endDate.timeIntervalSince1970 - self.startDate.timeIntervalSince1970)")
            self.imageIcon.image = image!
        }
        self.delegate?.getBrandImage(sender: self, icon: image, index: self.dataIndex)
    }
    
    //func setData(brand_name: String, brand_image: String?, index: Int) {
    //    self.txtLabel.text = brand_name
    //    if brand_image != nil {
    //        self.startDate = Date()
            //downloadFBBrandImage(brand_url: brand_image!, completion: receiveBrandImage)
    //        downloadBrandImage(brand_url: brand_image)
    //    }
    //    self.dataIndex = index
    //}
    
    func setData(brand_data: DetailBrandListStruct, index: Int) {
        self.txtLabel.text = brand_data.brandData.brandName
        if brand_data.brandImage == nil && brand_data.brandData.brandIconImage != nil {
            //downloadFBBrandImage(brand_url: brand_data.brandData.brandIconImage!, completion: receiveBrandImage)
            downloadBrandImage(brand_data: brand_data)
        } else {
            self.imageIcon.image = brand_data.brandImage!
        }
        
        self.dataIndex = index
    }
    
    func setData(brand_name: String, icon: UIImage?, index: Int) {
        self.txtLabel.text = brand_name
        if icon != nil {
            self.imageIcon.image = icon!
        }
        self.dataIndex = index
    }
    
    func downloadBrandImage(brand_data: DetailBrandListStruct)  {
        if brand_data.brandData.imageDownloadUrl == nil {
            print("brand_data.brandData.imageDownloadUrl is nil")
            let storageRef = Storage.storage().reference().child(brand_data.brandData.brandIconImage!)
            storageRef.downloadURL(completion: { (url, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                if url == nil {
                    print("downloadURL returns nil")
                    return
                }
                
                print("downloadURL = \(url!)")
                
                self.imageIcon.kf.setImage(with: url)
            })
        } else {
            print("brand_data.brandData.imageDownloadUrl NOT nil")
            let url = URL(string: brand_data.brandData.imageDownloadUrl!)
            self.imageIcon.kf.setImage(with: url) { result in
                switch result {
                case .success(let value):
                    print("Task done for: \(value.source.url?.absoluteString ?? "")")
                    self.delegate?.getBrandImage(sender: self, icon: self.imageIcon.image!, index: self.dataIndex)
                case .failure(let error):
                    print("Job failed: \(error.localizedDescription)")
                }
            }
        }
    }
}
