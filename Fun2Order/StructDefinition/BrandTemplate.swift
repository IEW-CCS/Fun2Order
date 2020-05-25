//
//  BrandTemplate.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2020/5/8.
//  Copyright © 2020 JStudio. All rights reserved.
//

import Foundation
import UIKit

struct BrandTemplate {
    var brandID: Int = 0
    var brandName: String = ""
    var updateTime: String = ""
    var brandCategory: String?
    var version: String?
    var brandIconImageUrl: String?
}

struct StoreDetail {
    var storeID: Int
    var storeName: String
    var deliveryService: String
    var regionCategory: String?
    var regionSubCategory: String?
    var storeDescription: String?
    var storeAddress: String?
    var storePhoneNumber: String?
}

struct ProductSet {
    var setType: String = "" // "SINGLE" or "SET"
    var productSetName: String = ""
    var productSetCategory: String?
    var productSetPrice: Int?
    var productSetImageUrl: String?
    var productSetDescription: String?
    var productSetItemsList: [ProductSetItem]?
    var productSetRecipe: [[MenuRecipe]]?
}

struct ProductSetItem {
    var productID: Int = 0
    var groupNumber: Int = 0
    var productName: String
    var recipeUsageFlag: String = "N" // "Y" or "N"
    var recipeUsageIndex: Int = 0
    var productCategory: String?
    var productPrice: Int?
    var productDescription: String?
    var productImageUrl: String?
}

struct BrandDetail {
    var brandID: Int = 0
    var brandName: String = ""
    var brandIconImage: String?
    var brandCategory: String?
    var brandSubCategory: String?
    var brandDescription: String?
    var brandWebSite: String?
    var storeList: [StoreDetail]?
    var productSetList: [ProductSet]?
    var menuRecipeTemplate: [MenuRecipeTemplate]?
}
