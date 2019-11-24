//
//  CommonStruct.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/15.
//  Copyright © 2019 JStudio. All rights reserved.
//

import Foundation
import UIKit

struct FavoriteStoreInfo {
    var brandID: Int
    var storeID: Int
    var brandName: String
    var storeName: String
    var storeDescription: String
    var storeBrandImage: UIImage
    var insertDateTime: Date
    
    init() {
        self.brandID = 0
        self.storeID = 0
        self.brandName = ""
        self.storeName = ""
        self.storeDescription = ""
        self.storeBrandImage = UIImage(named: "Fun2Order_AppStore_Icon.png")!
        self.insertDateTime = Date()
    }
}

struct StoreProductRecipe {
    var brandID: Int
    var storeID: Int
    var productID: Int
    var recipe: [String?]
    var brandName: String
    var storeName: String
    var productCategory: String
    var productName: String
    var productDescription: String?
    var productImage: UIImage?
    var recommand: String?
    var popularity: String?
    var limit: String?
    var favorite: Bool
    
    init() {
        self.brandID = 0
        self.storeID = 0
        self.productID = 0
        self.recipe = [String]()
        self.brandName = ""
        self.storeName = ""
        self.productCategory = ""
        self.productName = ""
        self.productDescription = ""
        self.productImage = UIImage()
        self.recommand = ""
        self.popularity = ""
        self.limit = ""
        self.favorite = false
    }
}

struct FavoriteProduct: Codable {
    var brandID: Int
    var storeID: Int
    var productID: Int
}

struct FavoriteProductRecipe: Codable {
    var brandID: Int
    var storeID: Int
    var productID: Int
    var recipe: [String]
}
