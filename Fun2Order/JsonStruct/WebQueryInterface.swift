//
//  WebQueryInterface.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/31.
//  Copyright © 2019 JStudio. All rights reserved.
//

import Foundation

struct UpdateInformation: Codable {
    var systemUpdateDateTime: String
}

struct CodeTableList: Codable {
    var CODE_TABLE: [CodeTable]
}

struct CodeTable: Codable {
    var codeCategory: String
    var code: String
    var subCode: String?
    var codeExtension: String?
    var index: Int
    var codeDescription: String?
    var subItem: String?
    var extension1: String?
    var extension2: String?
    var extension3: String?
    var extension4: String?
    var extension5: String?
}

struct BrandProfileList: Codable {
    var BRAND_PROFILE: [BrandProfile]
}

struct BrandProfile: Codable {
    var brandID: Int
    var brandName: String
    var brandIconImage: String
    var brandCategory: String
    var brandSubCategory: String?
    var brandDescription: String?
    var brandUpdateDateTime: String
}

struct ProductInformationList: Codable {
    var PRODUCT_INFORMATION: [ProductInformation]
}

struct ProductInformation: Codable {
    var brandID: Int
    var productID: Int
    var productCategory: String
    var productName: String
    var productDescription: String?
    var productImage: String
    var recommand: String?
    var popularity: String?
    var limit: String?
}

struct StoreInformationList: Codable {
    var STORE_INFORMATION: [StoreInformation]
}

struct StoreInformation: Codable {
    var brandID: Int
    var storeID: Int
    var storeCategory: String
    var storeSubCategory: String
    var storeName: String
    var storeDescription: String
    var storeAddress: String
    var storePhoneNumber: String
    var deliveryService: String
}

struct StoreBusinessHoursList: Codable {
    var STORE_BUSINESS_HOURS: [StoreBusinessHours]
}

struct StoreBusinessHours: Codable {
    var brandID: Int
    var storeID: Int
    var monday: String
    var tuesday: String
    var wednesday: String
    var thursday: String
    var friday: String
    var saturday: String
    var sunday: String
}

struct ProductRecipeList: Codable {
    var PRODUCT_RECIPE: [ProductRecipe]
}

struct ProductRecipe: Codable {
    var brandID: Int
    var storeID: Int
    var productID: Int
    var recipe1: String?
    var recipe2: String?
    var recipe3: String?
    var recipe4: String?
    var recipe5: String?
    var recipe6: String?
    var recipe7: String?
    var recipe8: String?
    var recipe9: String?
    var recipe10: String?
}

struct ProductRecipePriceList: Codable {
    var PRODUCT_RECIPE_PRICE: [ProductRecipePrice]
}

struct ProductRecipePrice: Codable {
    var brandID: Int = 0
    var storeID: Int = 0
    var productID: Int = 0
    var recipeCode: String = ""
    var recipeSubCode: String = ""
    var price: String = ""
}

struct OrderSerialList: Codable {
    var ORDER_SERIAL: [OrderSerial] = [OrderSerial]()
}

struct OrderSerial: Codable {
    var orderType: String = ""
    var brandID: Int = 0
    var storeID: Int = 0
    var dayCode: String = ""
    var serialNumber: Int = 0
}

struct UserProfile: Codable {
    var userID: String = ""
    var userName: String = ""
    var userPhotoUrl: String = ""
    var gender: String = ""
    var birthday: String = ""
    var address: String = ""
}
