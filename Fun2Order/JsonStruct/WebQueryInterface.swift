//
//  WebQueryInterface.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/10/31.
//  Copyright © 2019 JStudio. All rights reserved.
//

import Foundation


struct StoreItem: Codable {
    let storeID: Int
    let storeName: String
    let storeDescription: String
    let storeAddress: String
    let storePhoneNumber: String
}

struct StoreSubCategoryItem: Codable {
    let storeSubCatogory: String
    let storeList: [StoreItem]
}

struct StoreCategoryItem: Codable {
    let storeCategory: String
    let storeSubCategoryList: [StoreSubCategoryItem]
}

struct IngredientItem: Codable {
    let ingredient: String
    let ingredientPrice: Int
    /*
    init(from decoder: Decoder) throws {
        var arrayContrainer = try decoder.unkeyedContainer()
        self.ingredient = try arrayContrainer.decode(String.self)
        self.ingredientPrice = try arrayContrainer.decode(Int.self)
    }*/
}

struct ProductItem: Codable {
    let productCategory: String
    let productDescription: String
    let productImage: String
    let productName: String
    let productPrice: Int
    let availableIngredient: [IngredientItem]
    let availableSize: [String]
    let availableTemperature: [String]
    let availableSuger: [String]
    let availableIce: [String]
    
    /*
    init(from decoder: Decoder) throws {
        var arrayContainer = try decoder.unkeyedContainer()
        self.productCategory = try arrayContainer.decode(String.self)
        self.productDescription = try arrayContainer.decode(String.self)
        self.productImage = try arrayContainer.decode(String.self)
        self.productName = try arrayContainer.decode(String.self)
        self.productPrice = try arrayContainer.decode(Int.self)
        self.availableIngredient = try arrayContainer.decode([IngredientItem].self)
    }*/
}

struct BrandProfile: Codable {
    let brandID: Int
    let brandName: String
    let brandIconImage: String
    let brandDescription: String
    let brandUpdateDateTime: String
    let brandStoreList: [StoreCategoryItem]
    let productList: [ProductItem]
    
    /*
    init(from decoder: Decoder) throws {
        var arrayContainer = try decoder.unkeyedContainer()
        self.brandID = try arrayContainer.decode(Int.self)
        self.brandName = try arrayContainer.decode(String.self)
        self.brandIconImage = try arrayContainer.decode(String.self)
        self.brandDescription = try arrayContainer.decode(String.self)
        self.brandUpdateDateTime = try arrayContainer.decode(String.self)
        self.productList = try arrayContainer.decode([ProductItem].self)
    }*/
}

struct BrandProfileList: Codable {
    //let brandTitle: String
    //let brandProfile: [BrandProfile]
}
