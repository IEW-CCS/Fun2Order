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

struct FavoriteAddress {
    var createTime: Date = Date()
    var favoriteAddress: String = ""
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

struct OrderProductRecipe {
    var orderNumber: String = ""
    var itemNumber: Int = 0
    var productID: Int = 0
    var recipeCode: String = ""
    var recipeSubCode: String = ""
}

struct OrderContentItem {
    var orderNumber: String = ""
    var itemNumber: Int = 0
    var productID: Int = 0
    var productName: String = ""
    var itemOwnerName: String = ""
    var itemOwnerImage: UIImage = UIImage()
    var itemCreateTime: Date = Date()
    var itemQuantity: Int = 0
    var itemSinglePrice: Int = 0
    var itemFinalPrice: Int = 0
    var itemComments: String = ""
    var itemRecipe: [OrderProductRecipe] = [OrderProductRecipe]()
}

struct OrderInformation {
    // orderNumber naming rule:
    // Sample: SYYMMDD11112222-333333
    // S: orderType -> S/G
    // YY: Last 2 digit of Year
    // MM: Month
    // DD: Day
    // 1111: Brand ID
    // 2222: Store ID
    // 333333: Order serial number by day
    var orderNumber: String = ""
    var orderType: String = ""
    var orderStatus: String = ""
    var deliveryType: String = ""
    var deliveryAddress: String = ""
    var orderImage: UIImage = UIImage()
    var orderCreateTime: Date = Date()
    var orderOwner: String = ""
    var orderTotalQuantity: Int = 0
    var orderTotalPrice: Int = 0
    var brandID: Int = 0
    var brandName: String = ""
    var storeID: Int = 0
    var storeName: String = ""
    var contentList: [OrderContentItem] = [OrderContentItem]()
}

struct FavoriteProductDetail {
    var brandID: Int = 0
    var productID: Int = 0
    var productName: String = ""
    var productImage: UIImage = UIImage()
    var productRecipeString: String = ""
}

struct Group {
    var groupID: Int = 0
    var groupName: String = ""
    var groupDescription: String = ""
    var groupImage: UIImage = UIImage()
    var groupCreateTime: Date = Date()
}

struct GroupMember {
    var groupID: Int = 0
    var memberID: String = ""
    var memberName: String = ""
    var memberImage: UIImage = UIImage()
}

