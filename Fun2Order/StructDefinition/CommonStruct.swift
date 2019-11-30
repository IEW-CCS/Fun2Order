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
    var favorite: Bool
    var recipe: [String?]
    var brandName: String
    var storeName: String
    var productCategory: String
    var productName: String
    var productDescription: String?
    var productImage: UIImage?
    var defaultPrice: String
    var recommand: String?
    var popularity: String?
    var limit: String?
    
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
        self.defaultPrice = ""
        self.recommand = ""
        self.popularity = ""
        self.limit = ""
        self.favorite = false
    }
}

struct FavoriteProduct {
    var brandID: Int = 0
    var storeID: Int = 0
    var productID: Int = 0
}

struct FavoriteProductRecipe {
    var brandID: Int = 0
    var storeID: Int = 0
    var productID: Int = 0
    var recipeCode: String = ""
    var recipeSubCode: String = ""
}

struct RecipeItem {
    var recipeName: String
    var checkedFlag: Bool
    
    init() {
        self.recipeName = ""
        self.checkedFlag = false
    }
}

struct RecipeSubCategory {
    var recipeMainCategory: String
    var recipeSubCategory: String
    //var recipeDetail: [String]
    var recipeDetail: [RecipeItem]
    
    init() {
        self.recipeMainCategory = ""
        self.recipeSubCategory = ""
        self.recipeDetail = [RecipeItem]()
    }
}

struct ProductRecipeInformation {
    var brandID: Int
    var storeID: Int
    var productID: Int
    //var favoriteFlag: Bool
    var rowIndex: Int
    var recipeCategory: String
    var recipeSubCategoryDetail: [[RecipeSubCategory]]
    
    init() {
        self.brandID = 0
        self.storeID = 0
        self.productID = 0
        //self.favoriteFlag = false
        self.rowIndex = 0
        self.recipeCategory = ""
        self.recipeSubCategoryDetail = [[RecipeSubCategory]]()
    }
}

struct RecipeItemControl {
    var rowIndex: Int = 0
    var mainCategoryIndex: Int = 0
    var subCategoryIndex: Int = 0
    var itemIndex: Int = 0
}


