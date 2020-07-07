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
    var multiMenuImageURL: [String]?
    var createTime: String = ""
    var locations: [String]?
    var menuItems :[MenuItem]?
    var menuRecipes: [MenuRecipe]?
    var storeInfo: StoreContactInformation?
    var needContactInfoFlag: Bool?

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
            "multiMenuImageURL": multiMenuImageURL as Any,
            "createTime": createTime,
            "locations": locations as Any,
            "menuItems": menuItemsArray,
            "menuRecipes": menuRecipesArray,
            "storeInfo": storeInfo?.toAnyObject() as Any,
            "needContactInfoFlag": needContactInfoFlag as Any
        ]
    }
}

struct MenuItem: Codable {
    var sequenceNumber: Int = 0
    var itemName: String = ""
    var itemPrice: Int = 0
    var quantityLimitation: Int?
    var quantityRemained: Int?
    
    func toAnyObject() -> Any {
        return [
            "sequenceNumber": sequenceNumber,
            "itemName": itemName,
            "itemPrice": itemPrice,
            "quantityLimitation": quantityLimitation as Any,
            "quantityRemained": quantityRemained as Any
        ]
    }
}

struct MenuRecipe: Codable {
    var recipeCategory: String = ""
    var allowedMultiFlag: Bool = false
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
            "allowedMultiFlag": allowedMultiFlag,
            "sequenceNumber": sequenceNumber,
            "recipeItems": recipeItemsArray
        ]
    }
}

struct StoreContactInformation: Codable {
    var storeName: String?
    var storeAddress: String?
    var storePhoneNumber: String?
    var instagramURL: String?
    var facebookURL: String?

    func toAnyObject() -> Any? {
        return [
            "storeName": storeName as Any,
            "storeAddress": storeAddress as Any,
            "storePhoneNumber": storePhoneNumber as Any,
            "instagramURL": instagramURL as Any,
            "facebookURL": facebookURL as Any
        ]
    }
}

struct UserContactInformation: Codable {
    var userName: String?
    var userAddress: String?
    var userPhoneNumber: String?
    var instagramURL: String?
    var facebookURL: String?
    
    func toAnyObject() -> Any? {
        return [
            "userName": userName as Any,
            "userAddress": userAddress as Any,
            "userPhoneNumber":userPhoneNumber as Any,
            "instagramURL": instagramURL as Any,
            "facebookURL": facebookURL as Any
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
    var itemQuantity: Int = 0
    var itemSinglePrice: Int = 0
    var itemFinalPrice: Int = 0
    var location: String = ""
    var payCheckedFlag: Bool = false
    var payNumber: Int = 0
    var payTime: String = ""
    var createTime: String = ""
    var menuProductItems: [MenuProductItem]?
    var userContactInfo: UserContactInformation?
    var ostype: String?
    
    func toAnyObject() -> Any {
        var menuProductsArray: [Any] = [Any]()
        
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
            "itemQuantity": itemQuantity,
            "itemSinglePrice": itemSinglePrice,
            "itemFinalPrice": itemFinalPrice,
            "location": location,
            "payCheckedFlag": payCheckedFlag,
            "payNumber": payNumber,
            "payTime": payTime,
            "createTime": createTime,
            "menuProductItems": menuProductsArray,
            "userContactInfo": userContactInfo?.toAnyObject() as Any,
            "ostype": ostype as Any
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
    var locations: [String]?
    var brandName: String = ""
    var createTime: String = ""
    var dueTime: String = ""
    var storeInfo: StoreContactInformation?
    var contentItems: [MenuOrderMemberContent] = [MenuOrderMemberContent]()
    var limitedMenuItems: [MenuItem]?
    var needContactInfoFlag: Bool?
    
    func toAnyObject() -> Any {
        var itemsArray: [Any] = [Any]()
        if !contentItems.isEmpty {
            for i in 0...contentItems.count - 1 {
                itemsArray.append(contentItems[i].toAnyObject())
            }
        }

        var menuItemsArray: [Any] = [Any]()
        
        if limitedMenuItems != nil {
            for itemData in (limitedMenuItems as [MenuItem]?)! {
                menuItemsArray.append(itemData.toAnyObject())
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
            "storeInfo": storeInfo?.toAnyObject() as Any,
            "contentItems": itemsArray,
            "limitedMenuItems": menuItemsArray,
            "needContactInfoFlag": needContactInfoFlag as Any
        ]
    }
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
    var shippingDate: String?
    var shippingLocation: String?

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
            "replyTime": replyTime,
            "shippingDate": shippingDate as Any,
            "shippingLocation": shippingLocation as Any
        ]
    }
}

struct UserProfile: Codable {
    var userID: String = ""
    var userName: String = ""
    var phoneNumber: String = ""
    var tokenID: String = ""
    var photoURL: String = ""
    var gender: String?
    var birthday: String?
    var address: String?
    var friendList: [String]?
    var brandCategoryList: [String]?
    var ostype: String?

    func toAnyObject() -> Any {
        return [
            "userID": userID,
            "userName": userName,
            "phoneNumber": phoneNumber,
            "tokenID": tokenID,
            "photoURL": photoURL,
            "gender": gender as Any,
            "birthday": birthday as Any,
            "address": address as Any,
            "friendList": friendList as Any,
            "brandCategoryList": brandCategoryList as Any,
            "ostype": ostype as Any
        ]
    }
}

struct MergedContent {
    var owner: String = ""
    var productName: String = ""
    var location: String = ""
    var mergedRecipe: String = ""
    var comments: String = ""
    var quantity: Int = 0
    var userContactInfo: UserContactInformation?
}

struct ReportDataStruct {
    var numberOfColumns: Int = 0
    var sectionTitle: String = ""
    var columnWidth: [CGFloat] = []
    var columnHeaders: [String] = [String]()
    var rawCellData: [[String]] = [[String]]()
}

struct ReportLayoutStruct {
    var type: String = ""
    var data: String = ""
    var itemIndex: Int = 0
    var sectionIndex: Int = 0
    var columnIndex: Int = 0
    var rowIndex: Int = 0
    var rowCount: Int = 0
    var width: CGFloat = 0
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
