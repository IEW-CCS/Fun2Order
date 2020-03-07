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

struct RecipeItem: Codable {
    var sequenceNumber: Int
    var recipeName: String
    var checkedFlag: Bool
    
    init() {
        self.sequenceNumber = 0
        self.recipeName = ""
        self.checkedFlag = false
    }
    
    func toAnyObject() -> Any {
        return [
            "sequenceNumber": sequenceNumber,
            "recipeName": recipeName,
            "checkedFlag": checkedFlag
        ]
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
    var orderOwnerID: String = ""
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
    //var memberImage: UIImage = UIImage()
    var isSelected: Bool = false
}

struct Friend {
    var memberID: String = ""
    var memberName: String = ""
    var memberNickname: String = ""
}

struct MenuInformation: Codable {
    var userID: String = ""
    var userName: String = ""
    var menuNumber: String = ""
    var brandName: String = ""
    var menuDescription: String = ""
    var brandCategory: String = ""
    var menuImageURL: String = ""
    var createTime: String = ""
    var locations: [String]?
    var menuItems :[MenuItem]?
    var menuRecipes: [MenuRecipe]?

    func toAnyObject() -> Any {
        var menuItemsArray: [Any] = [Any]()
        var menuRecipesArray: [Any] = [Any]()
        
        if menuItems != nil {
            for itemData in (menuItems as [MenuItem]?)! {
                menuItemsArray.append(itemData.toAnyObject())
            }
        }

        if menuRecipes != nil {
            for recipeData in (menuRecipes as [MenuRecipe]?)! {
                menuRecipesArray.append(recipeData.toAnyObject())
            }
        }

        return [
            "userID": userID,
            "userName": userName,
            "menuNumber": menuNumber,
            "brandName": brandName,
            "menuDescription": menuDescription,
            "brandCategory": brandCategory,
            "menuImageURL": menuImageURL,
            "locations": locations as Any,
            "menuItems": menuItemsArray,
            "menuRecipes": menuRecipesArray,
            "createTime": createTime
        ]
    }
}

struct MenuItem: Codable {
    var sequenceNumber: Int = 0
    var itemName: String = ""
    var itemPrice: Int = 0
    
    func toAnyObject() -> Any {
        return [
            "sequenceNumber": sequenceNumber,
            "itemName": itemName,
            "itemPrice": itemPrice
        ]
    }
}

struct MenuRecipe: Codable {
    var recipeCategory: String = ""
    var isAllowedMulti: Bool = false
    var sequenceNumber: Int = 0
    var recipeItems: [RecipeItem]?
    
    func toAnyObject() -> Any {
        var recipeItemsArray: [Any] = [Any]()

        if recipeItems != nil {
            for itemData in (recipeItems as [RecipeItem]?)! {
                recipeItemsArray.append(itemData.toAnyObject())
            }
        }
        
        return [
            "recipeCategory": recipeCategory,
            "isAllowedMulti": isAllowedMulti,
            "sequenceNumber": sequenceNumber,
            "recipeItems": recipeItemsArray
        ]
    }
}

struct MenuProductItem: Codable {
    var sequenceNumber: Int = 0
    var itemName: String = ""
    var itemPrice: Int = 0
    var itemQuantity: Int = 0
    var itemComments: String = ""
    var menuRecipes: [MenuRecipe]?
    
    func toAnyObject() -> Any {
        var menuRecipesArray: [Any] = [Any]()

        if menuRecipes != nil {
            for recipeData in (menuRecipes as [MenuRecipe]?)! {
                menuRecipesArray.append(recipeData.toAnyObject())
            }
        }
        
        return [
            "sequenceNumber": sequenceNumber,
            "itemName": itemName,
            "itemPrice": itemPrice,
            "itemQuantity": itemQuantity,
            "itemComments": itemComments,
            "menuRecipes": menuRecipesArray
        ]
    }
}

struct MenuRecipeTemplate: Codable {
    var sequenceNumber: Int = 0
    var templateName: String = ""
    var menuRecipes: [MenuRecipe] = [MenuRecipe]()
    
    func toAnyObject() -> Any {
        var menuRecipesArray: [Any] = [Any]()
        if !menuRecipes.isEmpty {
            for i in 0...menuRecipes.count - 1 {
                menuRecipesArray.append(menuRecipes[i].toAnyObject())
            }
        }
        
        return [
            "sequenceNumber": sequenceNumber,
            "templateName": templateName,
            "menuRecipes": menuRecipesArray
        ]
    }
}

struct MenuOrderContentItem: Codable  {
    var orderNumber: String = ""
    var itemOwnerID: String = ""
    var itemOwnerName: String = ""
    var replyStatus: String = ""
    //var itemProductName: String = ""
    var itemQuantity: Int = 0
    var itemSinglePrice: Int = 0
    var itemFinalPrice: Int = 0
    //var itemComments: String = ""
    var location: String = ""
    var isPayChecked: Bool = false
    var payNumber: Int = 0
    var payTime: String = ""
    var createTime: String = ""
    //var menuItem :MenuItem = MenuItem()
    //var menuRecipes: [MenuRecipe]? = [MenuRecipe]()
    var menuProductItems: [MenuProductItem]?
    //var menuRecipes: [MenuRecipe]?
    
    func toAnyObject() -> Any {
        //var menuRecipesArray: [Any] = [Any]()
        var menuProductsArray: [Any] = [Any]()
        
        //if !menuRecipes.isEmpty {
        //if menuRecipes != nil {
            //for i in 0...menuRecipes!.count - 1 {
        //    for recipeData in (menuRecipes as [MenuRecipe]?)! {
                //menuRecipesArray.append(menuRecipes![i].toAnyObject())
        //        menuRecipesArray.append(recipeData.toAnyObject())
        //    }
        //}
        
        if menuProductItems != nil {
            for productData in (menuProductItems as [MenuProductItem]?)! {
                menuProductsArray.append(productData.toAnyObject())
            }
        }

        return [
            "orderNumber": orderNumber,
            "itemOwnerID": itemOwnerID,
            "itemOwnerName": itemOwnerName,
            "replyStatus": replyStatus,
            //"itemProductName": itemProductName,
            "itemQuantity": itemQuantity,
            "itemSinglePrice": itemSinglePrice,
            "itemFinalPrice": itemFinalPrice,
            //"itemComments": itemComments,
            "location": location,
            "isPayChecked": isPayChecked,
            "payNumber": payNumber,
            "payTime": payTime,
            "createTime": createTime,
            "menuProductItems": menuProductsArray
            //"menuItem": menuItem.toAnyObject(),
            //"menuRecipes": menuRecipesArray
        ]
    }
}

struct MenuOrderMemberContent: Codable {
    var memberID: String = ""
    var orderOwnerID: String = ""
    var memberTokenID: String = ""
    var orderContent: MenuOrderContentItem = MenuOrderContentItem()
    
    func toAnyObject() -> Any {
        return [
            "memberID": memberID,
            "orderOwnerID": orderOwnerID,
            "memberTokenID": memberTokenID,
            "orderContent": orderContent.toAnyObject()
        ]
    }
}

struct MenuOrder: Codable  {
    var orderNumber: String = ""
    var menuNumber: String = ""
    var orderType: String = ""
    var orderStatus: String = ""
    var orderOwnerName: String = ""
    var orderOwnerID: String = ""
    var orderTotalQuantity: Int = 0
    var orderTotalPrice: Int = 0
    var locations: [String]? = [String]()
    var brandName: String = ""
    var createTime: String = ""
    var dueTime: String = ""
    //var dueTime: String?
    var contentItems: [MenuOrderMemberContent] = [MenuOrderMemberContent]()
    
    func toAnyObject() -> Any {
        var itemsArray: [Any] = [Any]()
        if !contentItems.isEmpty {
            for i in 0...contentItems.count - 1 {
                itemsArray.append(contentItems[i].toAnyObject())
            }
        }

        return [
            "orderNumber": orderNumber,
            "menuNumber": menuNumber,
            "orderType": orderType,
            "orderStatus": orderStatus,
            "orderOwnerName": orderOwnerName,
            "orderOwnerID": orderOwnerID,
            "orderTotalQuantity": orderTotalQuantity,
            "orderTotalPrice": orderTotalPrice,
            "locations": locations as Any,
            "brandName": brandName,
            "createTime": createTime,
            "dueTime": dueTime,
            "contentItems": itemsArray
        ]
    }
}

struct MergedContent {
    var location: String = ""
    var mergedRecipe: String = ""
    var comments: String = ""
    var quantity: Int = 0
}

struct NotificationData: Codable {
    var messageID: String = ""
    var messageTitle: String = ""
    var messageBody: String = ""
    var notificationType: String = ""
    var receiveTime: String = ""
    var orderOwnerID: String = ""
    var orderOwnerName: String = ""
    var menuNumber: String = ""
    var orderNumber: String = ""
    var dueTime: String = ""
    var brandName: String = ""
    var attendedMemberCount: Int = 0
    var messageDetail: String = ""
    var isRead: String = ""
    var replyStatus: String = ""
    var replyTime: String = ""
    
    func toAnyObject() -> Any {
        return [
            "messageID": messageID,
            "messageTitle": messageTitle,
            "messageBody": messageBody,
            "notificationType":notificationType,
            "receiveTime": receiveTime,
            "orderOwnerID": orderOwnerID,
            "orderOwnerName": orderOwnerName,
            "menuNumber": menuNumber,
            "orderNumber": orderNumber,
            "dueTime": dueTime,
            "brandName": brandName,
            "attendedMemberCount": attendedMemberCount,
            "messageDetail": messageDetail,
            "isRead": isRead,
            "replyStatus": replyStatus,
            "replyTime": replyTime
        ]
    }
}

struct TestStruct: Codable {
    var messageID: String = ""
    var locations: [String]? = [String]()
    
    func toAnyObject() -> Any {
        return [
            "messageID": messageID,
            "locations": locations as Any
        ]
    }
}
