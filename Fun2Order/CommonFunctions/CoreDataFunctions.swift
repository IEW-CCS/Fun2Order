//
//  File.swift
//  Fun2Order
//
//  Created by Lo Fang Chou on 2019/11/19.
//  Copyright © 2019 JStudio. All rights reserved.
//

import Foundation
import UIKit
import CoreData

func retrieveCodeCategory(code_category: String, code_extension: String) -> [CODE_TABLE]? {
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    
    vc = app.persistentContainer.viewContext
    let fetchSortRequest: NSFetchRequest<CODE_TABLE> = CODE_TABLE.fetchRequest()
    let predicateString = "codeCategory == \"\(code_category)\" AND codeExtension == \"\(code_extension)\""
    print("retrieveCodeCategory predicateString = \(predicateString)")
    let predicate = NSPredicate(format: predicateString)
    fetchSortRequest.predicate = predicate
    let sort = NSSortDescriptor(key: "index", ascending: true)
    fetchSortRequest.sortDescriptors = [sort]
    
    do {
        let code_list = try vc.fetch(fetchSortRequest)
        return code_list
    } catch {
        print(error.localizedDescription)
        return nil
    }
}

func retrieveBrandProfile(brand_id: Int) -> BRAND_PROFILE? {

    if brand_id == 0 {
        return nil
    }
    
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    
    vc = app.persistentContainer.viewContext
    let fetchRequest: NSFetchRequest<BRAND_PROFILE> = BRAND_PROFILE.fetchRequest()
    let predicateString = "brandID == \(brand_id)"
    print("retrieveBrandProfile predicateString = \(predicateString)")
    let predicate = NSPredicate(format: predicateString)
    fetchRequest.predicate = predicate

    do {
        let brand_data = try vc.fetch(fetchRequest).first
        return brand_data!
    } catch {
        print(error.localizedDescription)
        return nil
    }
}

func retrieveProductInformation(brand_id: Int, store_id: Int) -> [PRODUCT_INFORMATION]? {

    if brand_id == 0 {
        return nil
    }
    
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    
    vc = app.persistentContainer.viewContext
    let fetchRequest: NSFetchRequest<PRODUCT_INFORMATION> = PRODUCT_INFORMATION.fetchRequest()
    let predicateString = "brandID == \(brand_id) AND storeID == \(store_id)"
    print("retrieveProductInformation predicateString = \(predicateString)")
    let predicate = NSPredicate(format: predicateString)
    fetchRequest.predicate = predicate
    let sort = NSSortDescriptor(key: "productID", ascending: true)
    fetchRequest.sortDescriptors = [sort]


    do {
        let product_list = try vc.fetch(fetchRequest)
        return product_list
    } catch {
        print(error.localizedDescription)
        return nil
    }
}

func retrieveProductRecipe(brand_id: Int, store_id: Int) -> [PRODUCT_RECIPE]? {

    if brand_id == 0 {
        return nil
    }
    
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    
    vc = app.persistentContainer.viewContext
    let fetchRequest: NSFetchRequest<PRODUCT_RECIPE> = PRODUCT_RECIPE.fetchRequest()
    let predicateString = "brandID == \(brand_id) AND storeID == \(store_id)"
    print("retrieveProductRecipe predicateString = \(predicateString)")
    let predicate = NSPredicate(format: predicateString)
    fetchRequest.predicate = predicate
    let sort = NSSortDescriptor(key: "productID", ascending: true)
    fetchRequest.sortDescriptors = [sort]

    do {
        let productRecipe_list = try vc.fetch(fetchRequest)
        return productRecipe_list
    } catch {
        print(error.localizedDescription)
        return nil
    }
}

func deleteAllBrandProfiles() {
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    
    vc = app.persistentContainer.viewContext

    do {
        let profile_list = try vc.fetch(BRAND_PROFILE.fetchRequest())
        for profile_data in profile_list as! [BRAND_PROFILE] {
            vc.delete(profile_data)
        }
    } catch {
        print(error.localizedDescription)
    }

    app.saveContext()
}

func deleteAllCodeTable() {
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    
    vc = app.persistentContainer.viewContext

    do {
        let code_list = try vc.fetch(CODE_TABLE.fetchRequest())
        for code_data in code_list as! [CODE_TABLE] {
            vc.delete(code_data)
        }
    } catch {
        print(error.localizedDescription)
    }

    app.saveContext()
}


func deleteAllStoreInformation() {
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    
    vc = app.persistentContainer.viewContext

    do {
        let store_list = try vc.fetch(STORE_INFORMATION.fetchRequest())
        for store_data in store_list as! [STORE_INFORMATION] {
            vc.delete(store_data)
        }
    } catch {
        print(error.localizedDescription)
    }

    app.saveContext()
}

func deleteAllProductInformation() {
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    
    vc = app.persistentContainer.viewContext

    do {
        let product_list = try vc.fetch(PRODUCT_INFORMATION.fetchRequest())
        for product_data in product_list as! [PRODUCT_INFORMATION] {
            vc.delete(product_data)
        }
    } catch {
        print(error.localizedDescription)
    }

    app.saveContext()
}

func deleteAllProductRecipe() {
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    
    vc = app.persistentContainer.viewContext

    do {
        let productRecipe_list = try vc.fetch(PRODUCT_RECIPE.fetchRequest())
        for productRecipe_data in productRecipe_list as! [PRODUCT_RECIPE] {
            vc.delete(productRecipe_data)
        }
    } catch {
        print(error.localizedDescription)
    }

    app.saveContext()
}

func retrieveFavoriteStoreByID(brand_id: Int, store_id: Int) -> FavoriteStoreInfo? {
    var tmp = FavoriteStoreInfo()
    
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    
    vc = app.persistentContainer.viewContext

    let fetchRequest: NSFetchRequest<FAVORITE_STORE> = FAVORITE_STORE.fetchRequest()
    let predicateString = "brandID == \(brand_id) AND storeID == \(store_id)"

    let predicate = NSPredicate(format: predicateString)
    fetchRequest.predicate = predicate

    do {
        let favorite_data = try vc.fetch(fetchRequest).first
        if favorite_data != nil {
            tmp.brandID = Int(favorite_data!.brandID)
            tmp.storeID = Int(favorite_data!.storeID)
            tmp.brandName = favorite_data!.brandName!
            tmp.storeName = favorite_data!.storeName!
            tmp.storeDescription = favorite_data!.storeDescription!
            tmp.insertDateTime = favorite_data!.insertDateTime!
            tmp.storeBrandImage = UIImage(data: favorite_data!.storeBrandImage!)!
            print("Favorite Store: brand id: \(tmp.brandID), store id: \(tmp.storeID)")
        }
    } catch {
        print(error.localizedDescription)
        return nil
    }

    return tmp
}

func retrieveFavoriteStore() -> [FavoriteStoreInfo] {
    var returnList = [FavoriteStoreInfo]()
    
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    
    vc = app.persistentContainer.viewContext

    let fetchSortRequest: NSFetchRequest<FAVORITE_STORE> = FAVORITE_STORE.fetchRequest()
    let sort = NSSortDescriptor(key: "insertDateTime", ascending: true)
    fetchSortRequest.sortDescriptors = [sort]

    do {
        let favorite_list = try vc.fetch(fetchSortRequest)
        for favorite_data in favorite_list {
            var tmp = FavoriteStoreInfo()
            tmp.brandID = Int(favorite_data.brandID)
            tmp.storeID = Int(favorite_data.storeID)
            tmp.brandName = favorite_data.brandName!
            tmp.storeName = favorite_data.storeName!
            tmp.storeDescription = favorite_data.storeDescription!
            tmp.insertDateTime = favorite_data.insertDateTime!
            tmp.storeBrandImage = UIImage(data: favorite_data.storeBrandImage!)!
            returnList.append(tmp)
            print("Favorite Store: brand id: \(tmp.brandID), store id: \(tmp.storeID)")
        }
    } catch {
        print(error.localizedDescription)
    }

    return returnList
}

func insertFavoriteStore(info: FavoriteStoreInfo) {
    
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    
    vc = app.persistentContainer.viewContext

    let storeData = NSEntityDescription.insertNewObject(forEntityName: "FAVORITE_STORE", into: vc) as! FAVORITE_STORE
    storeData.brandID = Int16(info.brandID)
    storeData.storeID = Int16(info.storeID)
    storeData.brandName = info.brandName
    storeData.storeName = info.storeName
    storeData.storeDescription = info.storeDescription
    storeData.storeBrandImage = info.storeBrandImage.pngData()
    storeData.insertDateTime = Date()
    
    app.saveContext()
}

func deleteFavoriteStore(brand_id: Int, store_id: Int) -> Bool {
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    
    vc = app.persistentContainer.viewContext

    let fetchRequest: NSFetchRequest<FAVORITE_STORE> = FAVORITE_STORE.fetchRequest()
    let predicateString = "brandID == \(brand_id) AND storeID == \(store_id)"

    let predicate = NSPredicate(format: predicateString)
    fetchRequest.predicate = predicate
    
    do {
        let store_data = try vc.fetch(fetchRequest).first
        vc.delete(store_data!)
    } catch {
        print(error.localizedDescription)
        return false
    }

    app.saveContext()
    return true
}

func retrieveFavoriteProductID(brand_id: Int, store_id: Int) -> [FavoriteProduct] {
    var returnList = [FavoriteProduct]()
    
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    
    vc = app.persistentContainer.viewContext

    let fetchRequest: NSFetchRequest<FAVORITE_PRODUCT> = FAVORITE_PRODUCT.fetchRequest()
    let predicateString = "brandID == \(brand_id) AND storeID == \(store_id)"

    let predicate = NSPredicate(format: predicateString)
    fetchRequest.predicate = predicate

    do {
        let product_list = try vc.fetch(fetchRequest)
        for product_data in product_list {
            var tmp = FavoriteProduct()
            tmp.brandID = Int(product_data.brandID)
            tmp.storeID = Int(product_data.storeID)
            tmp.productID = Int(product_data.productID)

            returnList.append(tmp)
        }
    } catch {
        print(error.localizedDescription)
    }

    return returnList
}

func retrieveFavoriteProductRecipe(brand_id: Int, store_id: Int, product_id: Int) -> [FAVORITE_PRODUCT_RECIPE]? {
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    
    vc = app.persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<FAVORITE_PRODUCT_RECIPE> = FAVORITE_PRODUCT_RECIPE.fetchRequest()
    let predicateString = "brandID == \(brand_id) AND storeID == \(store_id) AND productID = \(product_id)"
    print("retrieveFavoriteProductRecipe predicateString = \(predicateString)")
    let predicate = NSPredicate(format: predicateString)
    fetchRequest.predicate = predicate

    do {
        let productRecipe_list = try vc.fetch(fetchRequest)
        return productRecipe_list
    } catch {
        print(error.localizedDescription)
        return nil
    }
}

func retrieveFavoriteProductDetail(brand_id: Int, store_id: Int, product_id: Int) -> FavoriteProductDetail {
    var favoriteProductDetail: FavoriteProductDetail = FavoriteProductDetail()
    
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    
    vc = app.persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<PRODUCT_INFORMATION> = PRODUCT_INFORMATION.fetchRequest()
    let predicateString = "brandID == \(brand_id) AND productID == \(product_id)"

    let predicate = NSPredicate(format: predicateString)
    fetchRequest.predicate = predicate

    do {
        let product_data = try vc.fetch(fetchRequest).first
        if product_data != nil {
            favoriteProductDetail.brandID = brand_id
            favoriteProductDetail.productID = product_id
            favoriteProductDetail.productName = product_data!.productName!
            favoriteProductDetail.productImage = UIImage(data: product_data!.productImage!)!
        }
    } catch {
        print(error.localizedDescription)
    }
    
    let fetchRecipeRequest: NSFetchRequest<FAVORITE_PRODUCT_RECIPE> = FAVORITE_PRODUCT_RECIPE.fetchRequest()
    let predicateRecipeString = "brandID == \(brand_id) AND storeID == \(store_id) AND productID = \(product_id)"
    print("retrieveFavoriteProductRecipe predicateString = \(predicateRecipeString)")
    let predicateRecipe = NSPredicate(format: predicateRecipeString)
    fetchRecipeRequest.predicate = predicateRecipe

    do {
        let recipe_list = try vc.fetch(fetchRecipeRequest)
        var recipeString: String = ""
        for recipe_data in recipe_list {
            recipeString = recipeString + recipe_data.recipeSubCode! + " "
        }
        
        favoriteProductDetail.productRecipeString = recipeString
    } catch {
        print(error.localizedDescription)
    }
    
    return favoriteProductDetail
}

func deleteSingleFavoriteProduct(brand_id: Int, store_id: Int, product_id: Int) -> Bool {
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    
    vc = app.persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<FAVORITE_PRODUCT> = FAVORITE_PRODUCT.fetchRequest()
    let predicateString = "brandID == \(brand_id) AND storeID == \(store_id) AND productID = \(product_id)"

    let predicate = NSPredicate(format: predicateString)
    fetchRequest.predicate = predicate
    
    do {
        let product_data = try vc.fetch(fetchRequest).first
        if product_data != nil {
            vc.delete(product_data!)
        }
    } catch {
        print(error.localizedDescription)
        return false
    }

    let recipeRequest: NSFetchRequest<FAVORITE_PRODUCT_RECIPE> = FAVORITE_PRODUCT_RECIPE.fetchRequest()
    let recipeString = "brandID == \(brand_id) AND storeID == \(store_id) AND productID = \(product_id)"
    
    let recipePredicate = NSPredicate(format: recipeString)
    recipeRequest.predicate = recipePredicate
    
    do {
        let recipe_list = try vc.fetch(recipeRequest)
        for recipe_data in recipe_list {
            vc.delete(recipe_data)
        }
    } catch {
        print(error.localizedDescription)
        return false
    }
    
    app.saveContext()
    
    return true
}

func deleteStoreFavoriteProduct(brand_id: Int, store_id: Int) -> Bool {
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    
    vc = app.persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<FAVORITE_PRODUCT> = FAVORITE_PRODUCT.fetchRequest()
    let predicateString = "brandID == \(brand_id) AND storeID == \(store_id)"

    let predicate = NSPredicate(format: predicateString)
    fetchRequest.predicate = predicate
    
    do {
        let product_list = try vc.fetch(fetchRequest)
        for product_data in product_list {
            let recipeRequest: NSFetchRequest<FAVORITE_PRODUCT_RECIPE> = FAVORITE_PRODUCT_RECIPE.fetchRequest()
            let recipeString = "brandID == \(brand_id) AND storeID == \(store_id) AND productID = \(product_data.productID)"
            
            let recipePredicate = NSPredicate(format: recipeString)
            recipeRequest.predicate = recipePredicate
            
            do {
                let recipe_list = try vc.fetch(recipeRequest)
                for recipe_data in recipe_list {
                    vc.delete(recipe_data)
                }
            } catch {
                print(error.localizedDescription)
                return false
            }
            vc.delete(product_data)
        }
    } catch {
        print(error.localizedDescription)
        return false
    }
    
    app.saveContext()
    
    return true
}

func retrieveFavoriteAddress() -> [FavoriteAddress] {
    var returnList = [FavoriteAddress]()

    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    
    vc = app.persistentContainer.viewContext

    let fetchAddress: NSFetchRequest<FAVORITE_ADDRESS> = FAVORITE_ADDRESS.fetchRequest()

    do {
        let address_list = try vc.fetch(fetchAddress)
        for address_data in address_list {
            var tmpAddress = FavoriteAddress()
            tmpAddress.createTime = address_data.createTime!
            tmpAddress.favoriteAddress = address_data.favoriteAddress!
            returnList.append(tmpAddress)
        }
    } catch {
        print(error.localizedDescription)
    }
    
    return returnList
}

func insertFavoriteAddress(favorite_address: String) {
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    
    vc = app.persistentContainer.viewContext

    let addressData = NSEntityDescription.insertNewObject(forEntityName: "FAVORITE_ADDRESS", into: vc) as! FAVORITE_ADDRESS
    addressData.createTime = Date()
    addressData.favoriteAddress = favorite_address
    app.saveContext()
}

func deleteFavoriteAddress(favorite_address: String) {
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    
    vc = app.persistentContainer.viewContext

    let fetchRequest: NSFetchRequest<FAVORITE_ADDRESS> = FAVORITE_ADDRESS.fetchRequest()
    let predicateString = "favoriteAddress == \"\(favorite_address)\""

    let predicate = NSPredicate(format: predicateString)
    fetchRequest.predicate = predicate
    
    do {
        let address_data = try vc.fetch(fetchRequest).first
        if address_data != nil {
            vc.delete(address_data!)
        }
    } catch {
        print(error.localizedDescription)
    }

    app.saveContext()
}

func retrieveOrderInformation(brand_id: Int, store_id: Int) -> ORDER_INFORMATION? {
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    
    vc = app.persistentContainer.viewContext

    let fetchRequest: NSFetchRequest<ORDER_INFORMATION> = ORDER_INFORMATION.fetchRequest()
    let predicateString = "brandID == \(brand_id) AND storeID == \(store_id) AND orderStatus == \"\(ORDER_STATUS_INIT)\""
    print("retrieveOrderInformation predicateString = \(predicateString)")
    let predicate = NSPredicate(format: predicateString)
    fetchRequest.predicate = predicate

    do {
        let order_data = try vc.fetch(fetchRequest).first
        return order_data
    } catch {
        print(error.localizedDescription)
        return nil
    }
}

func deleteMenuOrderInformation(order_number: String) {
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    vc = app.persistentContainer.viewContext

    let fetchRequest: NSFetchRequest<ORDER_INFORMATION> = ORDER_INFORMATION.fetchRequest()
    let predicateString = "orderNumber == \"\(order_number)\""
    let predicate = NSPredicate(format: predicateString)
    fetchRequest.predicate = predicate
    
    do {
        let orderData = try vc.fetch(fetchRequest).first
        if orderData != nil {
            vc.delete(orderData!)
        }
    } catch {
        print(error.localizedDescription)
    }
    
    app.saveContext()
}

func updateOrderData(brand_id: Int, store_id: Int) {
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    
    vc = app.persistentContainer.viewContext

    let order_data = retrieveOrderInformation(brand_id: brand_id, store_id: store_id)
    var totalPrice: Int = 0
    var totalQuantity: Int = 0
    var orderNumber: String = ""
    
    if order_data != nil {
        orderNumber = order_data!.orderNumber!
        print("updateOrderData -> orderNumber is \(orderNumber)")
        
        let fetchRequest: NSFetchRequest<ORDER_CONTENT_ITEM> = ORDER_CONTENT_ITEM.fetchRequest()
        let predicateString = "orderNumber == \"\(orderNumber)\""
        print("updateOrderData predicateString = \(predicateString)")
        let predicate = NSPredicate(format: predicateString)
        fetchRequest.predicate = predicate

        do {
            let item_list = try vc.fetch(fetchRequest)
            for item_data in item_list {
                totalPrice = totalPrice + Int(item_data.itemFinalPrice)
                totalQuantity = totalQuantity + Int(item_data.itemQuantity)
            }
        } catch {
            print(error.localizedDescription)
        }
        
        order_data?.setValue(Int16(totalPrice), forKey: "orderTotalPrice")
        order_data?.setValue(Int16(totalQuantity), forKey: "orderTotalQuantity")
        app.saveContext()
    }
}


func retrieveGroupList() -> [Group] {
    var returnList = [Group]()

    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    
    vc = app.persistentContainer.viewContext

    let fetchGroup: NSFetchRequest<GROUP_TABLE> = GROUP_TABLE.fetchRequest()

    do {
        let group_list = try vc.fetch(fetchGroup)
        for group_data in group_list {
            var tmpGroup = Group()
            tmpGroup.groupID = Int(group_data.groupID)
            tmpGroup.groupName = group_data.groupName!
            tmpGroup.groupImage = UIImage(data: group_data.groupImage!)!
            tmpGroup.groupDescription = group_data.groupDescription!
            tmpGroup.groupCreateTime = group_data.groupCreateTime!

            returnList.append(tmpGroup)
        }
    } catch {
        print(error.localizedDescription)
    }
    
    return returnList
}

func deleteGroup(group_id: Int) {
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    
    vc = app.persistentContainer.viewContext

    let fetchRequest: NSFetchRequest<GROUP_TABLE> = GROUP_TABLE.fetchRequest()
    let predicateString = "groupID == \"\(group_id)\""

    let predicate = NSPredicate(format: predicateString)
    fetchRequest.predicate = predicate
    
    do {
        let group_data = try vc.fetch(fetchRequest).first
        if group_data != nil {
            vc.delete(group_data!)
        }
    } catch {
        print(error.localizedDescription)
    }

    app.saveContext()
}

func retrieveMemberList(group_id: Int) -> [GroupMember] {
    var returnList = [GroupMember]()

    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    
    vc = app.persistentContainer.viewContext

    let fetchMember: NSFetchRequest<GROUP_MEMBER> = GROUP_MEMBER.fetchRequest()
    let predicateString = "groupID == \(group_id)"

    let predicate = NSPredicate(format: predicateString)
    fetchMember.predicate = predicate

    do {
        let member_list = try vc.fetch(fetchMember)
        for member_data in member_list {
            var tmpMember = GroupMember()
            tmpMember.groupID = Int(member_data.groupID)
            tmpMember.memberID = member_data.memberID!
            tmpMember.memberName = member_data.memberName!
            tmpMember.memberImage = UIImage(data: member_data.memberImage!)!
            tmpMember.isSelected = true
            returnList.append(tmpMember)
        }
    } catch {
        print(error.localizedDescription)
    }
    
    return returnList
}

func insertGroupMember(member_info: GroupMember) {
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    
    vc = app.persistentContainer.viewContext

    let memberData = NSEntityDescription.insertNewObject(forEntityName: "GROUP_MEMBER", into: vc) as! GROUP_MEMBER
    memberData.groupID = Int16(member_info.groupID)
    memberData.memberID = member_info.memberID
    memberData.memberName = member_info.memberName
    memberData.memberImage = member_info.memberImage.pngData()!
    
    app.saveContext()
}

func deleteMember(group_id: Int, member_id: String) {
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    
    vc = app.persistentContainer.viewContext

    let fetchRequest: NSFetchRequest<GROUP_MEMBER> = GROUP_MEMBER.fetchRequest()
    let predicateString = "groupID == \(group_id) AND memberID == \"\(member_id)\""

    let predicate = NSPredicate(format: predicateString)
    fetchRequest.predicate = predicate
    
    do {
        let member_data = try vc.fetch(fetchRequest).first
        if member_data != nil {
            vc.delete(member_data!)
        }
    } catch {
        print(error.localizedDescription)
    }

    app.saveContext()
}

func deleteMemberByGroup(group_id: Int) {
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    
    vc = app.persistentContainer.viewContext

    let fetchRequest: NSFetchRequest<GROUP_MEMBER> = GROUP_MEMBER.fetchRequest()
    let predicateString = "groupID == \(group_id)"

    let predicate = NSPredicate(format: predicateString)
    fetchRequest.predicate = predicate
    
    do {
        let member_list = try vc.fetch(fetchRequest)
        for member_data in member_list {
            vc.delete(member_data)
        }
    } catch {
        print(error.localizedDescription)
    }

    app.saveContext()
}

func deleteOrderProduct(brand_id: Int, store_id: Int, order_number: String, item_number: Int) -> Bool {
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    
    vc = app.persistentContainer.viewContext

    let fetchProduct: NSFetchRequest<ORDER_CONTENT_ITEM> = ORDER_CONTENT_ITEM.fetchRequest()
    let pString = "orderNumber == \"\(order_number)\" AND itemNumber == \(item_number)"
    print("deleteProduct pOrderpStringString = \(pString)")
    let predicate = NSPredicate(format: pString)
    fetchProduct.predicate = predicate

    do {
        let product_data = try vc.fetch(fetchProduct).first
        vc.delete(product_data!)
        //app.saveContext()
    } catch {
        print(error.localizedDescription)
        return false
    }
    
    let fetchRecipe: NSFetchRequest<ORDER_PRODUCT_RECIPE> = ORDER_PRODUCT_RECIPE.fetchRequest()
    let pRecipeString = "orderNumber == \"\(order_number)\" AND itemNumber == \(item_number)"
    print("deleteProduct pOrderpStringString = \(pRecipeString)")
    let predicateRecipe = NSPredicate(format: pRecipeString)
    fetchRecipe.predicate = predicateRecipe
    
    do {
        let recipe_list = try vc.fetch(fetchRecipe)
        for recipe_data in recipe_list {
            vc.delete(recipe_data)
        }
        //app.saveContext()
    } catch {
        print(error.localizedDescription)
        return false
    }
    
    let fetchRequest: NSFetchRequest<ORDER_CONTENT_ITEM> = ORDER_CONTENT_ITEM.fetchRequest()
    let pRequestString = "orderNumber == \"\(order_number)\""
    print("deleteProduct pRequestString = \(pRequestString)")
    let predicateRequest = NSPredicate(format: pRequestString)
    fetchRequest.predicate = predicateRequest

    do {
        let product_list = try vc.fetch(fetchRequest)
        if product_list.count == 0 {
            let fetchOrder: NSFetchRequest<ORDER_INFORMATION> = ORDER_INFORMATION.fetchRequest()
            let pOrderString = "orderNumber == \"\(order_number)\""
            print("deleteProduct pOrderString = \(pOrderString)")
            let predicateOrder = NSPredicate(format: pOrderString)
            fetchOrder.predicate = predicateOrder
            do {
                let order_data = try vc.fetch(fetchOrder).first
                vc.delete(order_data!)
                //app.saveContext()
            } catch {
                print(error.localizedDescription)
                return false
            }
        }
    } catch {
        print(error.localizedDescription)
        return false
    }

    updateOrderData(brand_id: brand_id, store_id: store_id)
    app.saveContext()
    
    return true
}

func getCartBadgeNumber() -> Int {
    var totalCount: Int = 0

    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    vc = app.persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<ORDER_INFORMATION> = ORDER_INFORMATION.fetchRequest()
    let predicateString = "orderStatus == \"\(ORDER_STATUS_INIT)\""

    let predicate = NSPredicate(format: predicateString)
    fetchRequest.predicate = predicate

    do {
        let order_list = try vc.fetch(fetchRequest)
        for order_data in order_list {
            totalCount = totalCount + Int(order_data.orderTotalQuantity)
        }
    } catch {
        print(error.localizedDescription)
    }
    
    print("Cart Order Badge Number = \(totalCount)")
    
    return totalCount
}

func retrieveMenuInformation() -> [MenuInformation] {
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    vc = app.persistentContainer.viewContext

    var menuInfoList: [MenuInformation]  = [MenuInformation]()
    
    let fetchRequest: NSFetchRequest<MENU_INFORMATION> = MENU_INFORMATION.fetchRequest()
    do {
        let infoList = try vc.fetch(fetchRequest)
        for infoData in infoList {
            let menuData = retrieveMenuInformationByID(menu_number: infoData.menuNumber!)
            if menuData != nil {
                menuInfoList.append(menuData!)
            }
        }
    } catch {
        print(error.localizedDescription)
        return menuInfoList
    }
    
    return menuInfoList
}

func retrieveMenuIcon(menu_number: String) -> UIImage {
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    vc = app.persistentContainer.viewContext

    var iconImage: UIImage = UIImage()

    let fetchRequest: NSFetchRequest<MENU_ICON> = MENU_ICON.fetchRequest()
    let predicateString = "menuNumber == \"\(menu_number)\""
    let predicate = NSPredicate(format: predicateString)
    fetchRequest.predicate = predicate
    
    do {
        let menuIcon = try vc.fetch(fetchRequest).first
        if menuIcon == nil {
            iconImage = UIImage(named: "Default_Menu_Image_original.png")!
        } else {
            iconImage = UIImage(data: menuIcon!.menuIcon!)!
        }
    } catch {
        print(error.localizedDescription)
    }
    
    return iconImage
}

func insertMenuIcon(menu_number: String, menu_icon: UIImage) {
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    vc = app.persistentContainer.viewContext

    let menuIcon = NSEntityDescription.insertNewObject(forEntityName: "MENU_ICON", into: vc) as! MENU_ICON
    menuIcon.menuNumber = menu_number
    menuIcon.menuIcon = menu_icon.pngData()!
    
    app.saveContext()
}

func deleteMenuIcon(menu_number: String) {
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    vc = app.persistentContainer.viewContext

    let fetchRequest: NSFetchRequest<MENU_ICON> = MENU_ICON.fetchRequest()
    let predicateString = "menuNumber == \"\(menu_number)\""
    let predicate = NSPredicate(format: predicateString)
    fetchRequest.predicate = predicate
    
    do {
        let menuIcon = try vc.fetch(fetchRequest).first
        if menuIcon != nil {
            vc.delete(menuIcon!)
        }
    } catch {
        print(error.localizedDescription)
    }
    
    app.saveContext()
}

func retrieveMenuInformationByID(menu_number: String) -> MenuInformation? {
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    vc = app.persistentContainer.viewContext
    
    var menuInfo: MenuInformation = MenuInformation()

    let infoRequest: NSFetchRequest<MENU_INFORMATION> = MENU_INFORMATION.fetchRequest()
    let infoString = "menuNumber == \"\(menu_number)\""
    let infoPredicate = NSPredicate(format: infoString)
    infoRequest.predicate = infoPredicate
    
    do {
        let menuData = try vc.fetch(infoRequest).first
        if menuData != nil {
            menuInfo.brandName = menuData!.brandName!
            menuInfo.brandCategory = menuData!.brandCategory!
            menuInfo.createTime = menuData!.createTime!
            menuInfo.menuDescription = menuData!.menuDescription!
            menuInfo.menuImageURL = menuData!.menuImageURL!
            menuInfo.menuNumber = menuData!.menuNumber!
            //menuInfo.menuIcon = UIImage(data: menuData!.menuIcon!) ?? UIImage()
            //if (menuData!.menuIcon == nil || menuData!.menuIcon?.count == 0) {
            //    menuInfo.menuIcon = UIImage(named: "Default_Menu_Image_original.png")!
            //} else {
            //    menuInfo.menuIcon = UIImage(data: menuData!.menuIcon!)!
            //}
            menuInfo.userID = menuData!.userID!
            menuInfo.userName = menuData!.userName ?? ""
        } else {
            return nil
        }
    } catch {
        print(error.localizedDescription)
        return nil
    }

    let fetchLocation: NSFetchRequest<MENU_LOCATION> = MENU_LOCATION.fetchRequest()
    let pLocation = "menuNumber == \"\(menu_number)\""
    let lPredicate = NSPredicate(format: pLocation)
    fetchLocation.predicate = lPredicate
    
    do {
        let locationList = try vc.fetch(fetchLocation)
        for locationData in locationList {
            menuInfo.locations?.append(locationData.locationName!)
        }
    } catch {
        print(error.localizedDescription)
        return nil
    }
    
    let fetchItem: NSFetchRequest<MENU_ITEM> = MENU_ITEM.fetchRequest()
    let pItem = "menuNumber == \"\(menu_number)\""
    let iPredicate = NSPredicate(format: pItem)
    fetchItem.predicate = iPredicate
    let sort = NSSortDescriptor(key: "sequenceNumber", ascending: true)
    fetchItem.sortDescriptors = [sort]

    do {
        let itemList = try vc.fetch(fetchItem)
        for itemData in itemList {
            var tmpData: MenuItem = MenuItem()
            tmpData.sequenceNumber = Int(itemData.sequenceNumber)
            tmpData.itemName = itemData.itemName!
            tmpData.itemPrice = Int(itemData.itemPrice)
            menuInfo.menuItems?.append(tmpData)
        }
    } catch {
        print(error.localizedDescription)
        return nil
    }

    let fetchRecipeCategory: NSFetchRequest<MENU_RECIPE_CATEGORY> = MENU_RECIPE_CATEGORY.fetchRequest()
    let pRecipeCategory = "menuNumber == \"\(menu_number)\""
    let rPredicate = NSPredicate(format: pRecipeCategory)
    fetchRecipeCategory.predicate = rPredicate
    let rSort = NSSortDescriptor(key: "sequenceNumber", ascending: true)
    fetchRecipeCategory.sortDescriptors = [rSort]

    do {
        let recipeCategoryList = try vc.fetch(fetchRecipeCategory)
        for categoryData in recipeCategoryList {
            var menuRecipe: MenuRecipe = MenuRecipe()
            menuRecipe.sequenceNumber = Int(categoryData.sequenceNumber)
            menuRecipe.recipeCategory = categoryData.recipeCategory!
            menuRecipe.isAllowedMulti = categoryData.isAllowedMulti
            
            let fetchRecipeItem: NSFetchRequest<MENU_RECIPE> = MENU_RECIPE.fetchRequest()
            let pRecipeItem = "menuNumber == \"\(menu_number)\" AND recipeCategory == \"\(categoryData.recipeCategory!)\""
            let rtPredicate = NSPredicate(format: pRecipeItem)
            fetchRecipeItem.predicate = rtPredicate
            let rtSort = NSSortDescriptor(key: "sequenceNumber", ascending: true)
            fetchRecipeItem.sortDescriptors = [rtSort]

            do {
                let itemList = try vc.fetch(fetchRecipeItem)
                for itemData in itemList {
                    var iData: RecipeItem = RecipeItem()
                    iData.sequenceNumber = Int(itemData.sequenceNumber)
                    iData.checkedFlag = true
                    iData.recipeName = itemData.recipeName!
                    menuRecipe.recipeItems?.append(iData)
                }
            } catch {
                print(error.localizedDescription)
                return nil
            }
            menuInfo.menuRecipes?.append(menuRecipe)
        }
    } catch {
        print(error.localizedDescription)
        return nil
    }
    
    return menuInfo
}

func insertMenuInformation(menu_info: MenuInformation) {
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    vc = app.persistentContainer.viewContext

    let menuInfo = NSEntityDescription.insertNewObject(forEntityName: "MENU_INFORMATION", into: vc) as! MENU_INFORMATION
    menuInfo.menuNumber = menu_info.menuNumber
    menuInfo.brandName = menu_info.brandName
    menuInfo.brandCategory = menu_info.brandCategory
    menuInfo.menuDescription = menu_info.menuDescription
    menuInfo.menuImageURL = menu_info.menuImageURL
    //if menu_info.menuIcon.imageAsset != nil {
    //    menuInfo.menuIcon = menu_info.menuIcon.pngData()!
    //}
    menuInfo.userID = menu_info.userID
    menuInfo.userName = menu_info.userName
    menuInfo.createTime = menu_info.createTime
    app.saveContext()
    
    if !menu_info.locations!.isEmpty {
        for i in 0...menu_info.locations!.count - 1 {
            let locationData = NSEntityDescription.insertNewObject(forEntityName: "MENU_LOCATION", into: vc) as! MENU_LOCATION
            locationData.menuNumber = menu_info.menuNumber
            locationData.locationName = menu_info.locations![i]
        }
    }
    app.saveContext()
    
    if !menu_info.menuItems!.isEmpty {
        for i in 0...menu_info.menuItems!.count - 1 {
            let itemData = NSEntityDescription.insertNewObject(forEntityName: "MENU_ITEM", into: vc) as! MENU_ITEM
            itemData.menuNumber = menu_info.menuNumber
            itemData.itemName = menu_info.menuItems![i].itemName
            itemData.itemPrice = Int16(menu_info.menuItems![i].itemPrice)
            itemData.sequenceNumber = Int16(menu_info.menuItems![i].sequenceNumber)
        }
    }
    app.saveContext()

    if !menu_info.menuRecipes!.isEmpty {
        for i in 0...menu_info.menuRecipes!.count - 1 {
            let recipeCategory = NSEntityDescription.insertNewObject(forEntityName: "MENU_RECIPE_CATEGORY", into: vc) as! MENU_RECIPE_CATEGORY
            recipeCategory.menuNumber = menu_info.menuNumber
            recipeCategory.sequenceNumber = Int16(menu_info.menuRecipes![i].sequenceNumber)
            recipeCategory.recipeCategory = menu_info.menuRecipes![i].recipeCategory
            recipeCategory.isAllowedMulti = menu_info.menuRecipes![i].isAllowedMulti
        }
    }
    app.saveContext()

    if !menu_info.menuRecipes!.isEmpty {
        for i in 0...menu_info.menuRecipes!.count - 1 {
            for j in 0...menu_info.menuRecipes![i].recipeItems!.count - 1 {
                let recipeData = NSEntityDescription.insertNewObject(forEntityName: "MENU_RECIPE", into: vc) as! MENU_RECIPE
                recipeData.menuNumber = menu_info.menuNumber
                recipeData.sequenceNumber = Int16(menu_info.menuRecipes![i].sequenceNumber)
                recipeData.recipeCategory = menu_info.menuRecipes![i].recipeCategory
                recipeData.recipeName = menu_info.menuRecipes![i].recipeItems![j].recipeName
            }
        }
    }
    app.saveContext()
}

func updateMenuInformation(menu_info: MenuInformation) {
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    vc = app.persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<MENU_INFORMATION> = MENU_INFORMATION.fetchRequest()
    let predicateString = "menuNumber == \"\(menu_info.menuNumber)\""

    let predicate = NSPredicate(format: predicateString)
    fetchRequest.predicate = predicate

    do {
        let menuData = try vc.fetch(fetchRequest).first
        if menuData != nil {
            menuData?.setValue(menu_info.brandName, forKey: "brandName")
            menuData?.setValue(menu_info.brandCategory, forKey: "brandCategory")
            menuData?.setValue(menu_info.menuDescription, forKey: "menuDescription")
            menuData?.setValue(menu_info.menuImageURL, forKey: "menuImageURL")
            //menuData?.setValue(menu_info.menuIcon.jpegData(compressionQuality: 1), forKey: "menuIcon")
            menuData?.setValue(menu_info.userID, forKey: "userID")
            menuData?.setValue(menu_info.createTime, forKey: "createTime")
        }
    } catch {
        print(error.localizedDescription)
        return
    }
    
    app.saveContext()
}

func deleteMenuInformation(menu_info: MenuInformation) {
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    vc = app.persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<MENU_INFORMATION> = MENU_INFORMATION.fetchRequest()
    let predicateString = "menuNumber == \"\(menu_info.menuNumber)\""

    let predicate = NSPredicate(format: predicateString)
    fetchRequest.predicate = predicate

    do {
        let menuData = try vc.fetch(fetchRequest).first
        if menuData != nil {
            vc.delete(menuData!)
        }
    } catch {
        print(error.localizedDescription)
        return
    }
    app.saveContext()
    
    let fetchLocation: NSFetchRequest<MENU_LOCATION> = MENU_LOCATION.fetchRequest()
    let pLocation = "menuNumber == \"\(menu_info.menuNumber)\""
    let lPredicate = NSPredicate(format: pLocation)
    fetchLocation.predicate = lPredicate
    do {
        let locationList = try vc.fetch(fetchLocation)
        for locationData in locationList {
            vc.delete(locationData)
        }
    } catch {
        print(error.localizedDescription)
        return
    }
    app.saveContext()
    
    let fetchItem: NSFetchRequest<MENU_ITEM> = MENU_ITEM.fetchRequest()
    let pItem = "menuNumber == \"\(menu_info.menuNumber)\""
    let iPredicate = NSPredicate(format: pItem)
    fetchItem.predicate = iPredicate
    do {
        let itemList = try vc.fetch(fetchItem)
        for itemData in itemList {
            vc.delete(itemData)
        }
    } catch {
        print(error.localizedDescription)
        return
    }
    app.saveContext()

    let fetchRecipe: NSFetchRequest<MENU_RECIPE> = MENU_RECIPE.fetchRequest()
    let pRecipe = "menuNumber == \"\(menu_info.menuNumber)\""
    let rPredicate = NSPredicate(format: pRecipe)
    fetchRecipe.predicate = rPredicate
    do {
        let recipeList = try vc.fetch(fetchRecipe)
        for recipeData in recipeList {
            vc.delete(recipeData)
        }
    } catch {
        print(error.localizedDescription)
        return
    }
    app.saveContext()
    
    let fetchCategory: NSFetchRequest<MENU_RECIPE_CATEGORY> = MENU_RECIPE_CATEGORY.fetchRequest()
    let pCategory = "menuNumber == \"\(menu_info.menuNumber)\""
    let cPredicate = NSPredicate(format: pCategory)
    fetchCategory.predicate = cPredicate
    do {
        let categoryList = try vc.fetch(fetchCategory)
        for categoryData in categoryList {
            vc.delete(categoryData)
        }
    } catch {
        print(error.localizedDescription)
        return
    }
    app.saveContext()

}

func retrieveMenuBrandCategory() -> [String] {
    var returnList = [String]()
    
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    vc = app.persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<MENU_BRAND_CATEGORY> = MENU_BRAND_CATEGORY.fetchRequest()

    do {
        let category_list = try vc.fetch(fetchRequest)
        for category_data in category_list {
            returnList.append(category_data.categoryName!)
        }
    } catch {
        print(error.localizedDescription)
    }
    
    return returnList
}

func insertMenuBrandCategory(category: String) {
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    vc = app.persistentContainer.viewContext

    let fetchRequest: NSFetchRequest<MENU_BRAND_CATEGORY> = MENU_BRAND_CATEGORY.fetchRequest()
    let predicateString = "categoryName == \"\(category)\""

    let predicate = NSPredicate(format: predicateString)
    fetchRequest.predicate = predicate

    do {
        let categoryData = try vc.fetch(fetchRequest).first
        if categoryData != nil {
            print("Brand Category exists, just return!")
            return
        }
    } catch {
        print(error.localizedDescription)
    }
    
    let menuCategory = NSEntityDescription.insertNewObject(forEntityName: "MENU_BRAND_CATEGORY", into: vc) as! MENU_BRAND_CATEGORY

    menuCategory.categoryName = category
    
    app.saveContext()
}

func deleteMenuBrandCategory(category: String) {
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    vc = app.persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<MENU_BRAND_CATEGORY> = MENU_BRAND_CATEGORY.fetchRequest()
    let predicateString = "categoryName == \"\(category)\""

    let predicate = NSPredicate(format: predicateString)
    fetchRequest.predicate = predicate

    do {
        let categoryData = try vc.fetch(fetchRequest).first
        if categoryData != nil {
            vc.delete(categoryData!)
        }
    } catch {
        print(error.localizedDescription)
    }
    
    app.saveContext()
}

func retrieveMemberImage(user_id: String) -> UIImage {
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    vc = app.persistentContainer.viewContext

    let fetchProduct: NSFetchRequest<GROUP_MEMBER> = GROUP_MEMBER.fetchRequest()
    let pString = "memberID == \"\(user_id)\""
    print("retrieveMemberImage pString = \(pString)")
    let predicate = NSPredicate(format: pString)
    fetchProduct.predicate = predicate

    do {
        let member_data = try vc.fetch(fetchProduct).first
        return UIImage(data: member_data!.memberImage!)!
    } catch {
        print(error.localizedDescription)
        return UIImage()
    }
}

func retrieveNotificationList() -> [NotificationData] {
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    vc = app.persistentContainer.viewContext

    var returnList: [NotificationData] = [NotificationData]()
    
    let fetchRequest: NSFetchRequest<NOTIFICATION_TABLE> = NOTIFICATION_TABLE.fetchRequest()
    let sort = NSSortDescriptor(key: "receiveTime", ascending: false)
    fetchRequest.sortDescriptors = [sort]

    do {
        let notificationList = try vc.fetch(fetchRequest)
        for notificationData in notificationList {
            var tmpData: NotificationData = NotificationData()
            
            let decoder: JSONDecoder = JSONDecoder()
            do {
                let jsonData = notificationData.notificationData!.data(using: .utf8)
                tmpData = try decoder.decode(NotificationData.self, from: jsonData!)
                //print("tmpData in notificationList = \(tmpData)")
                returnList.append(tmpData)
            } catch {
                print("jsonData decode failed: \(error.localizedDescription)")
                continue
            }
        }
    } catch {
        print(error.localizedDescription)
    }
    
    return returnList
}

func retrieveInvitationNotificationList() -> [NotificationData] {
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    vc = app.persistentContainer.viewContext

    var returnList: [NotificationData] = [NotificationData]()
    
    let fetchRequest: NSFetchRequest<NOTIFICATION_TABLE> = NOTIFICATION_TABLE.fetchRequest()
    let sort = NSSortDescriptor(key: "receiveTime", ascending: false)
    fetchRequest.sortDescriptors = [sort]

    do {
        let notificationList = try vc.fetch(fetchRequest)
        for notificationData in notificationList {
            var tmpData: NotificationData = NotificationData()
            
            let decoder: JSONDecoder = JSONDecoder()
            do {
                let jsonData = notificationData.notificationData!.data(using: .utf8)
                tmpData = try decoder.decode(NotificationData.self, from: jsonData!)
                if tmpData.notificationType == NOTIFICATION_TYPE_ACTION_JOIN_ORDER {
                    returnList.append(tmpData)
                }
            } catch {
                print("jsonData decode failed: \(error.localizedDescription)")
                continue
            }
        }
    } catch {
        print(error.localizedDescription)
    }
    
    return returnList
}

func retrieveNotificationBadgeNumber() -> Int {
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    vc = app.persistentContainer.viewContext

    var badgeNumber: Int = 0

    let fetchRequest: NSFetchRequest<NOTIFICATION_TABLE> = NOTIFICATION_TABLE.fetchRequest()

    do {
        let notificationList = try vc.fetch(fetchRequest)
        for notificationData in notificationList {
            if notificationData.isRead == false {
                badgeNumber = badgeNumber + 1
            }
        }
    } catch {
        print(error.localizedDescription)
    }
    
    return badgeNumber
}

func insertNotification(notification: NotificationData) {
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    vc = app.persistentContainer.viewContext

    let notifyData = NSEntityDescription.insertNewObject(forEntityName: "NOTIFICATION_TABLE", into: vc) as! NOTIFICATION_TABLE
    notifyData.isRead = false
    notifyData.messageID = notification.messageID
    notifyData.messageTitle = notification.messageTitle
    notifyData.messageBody = notification.messageBody
    notifyData.receiveTime = Date()
    
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: notification.toAnyObject(), options: [.prettyPrinted])
        let jsonString = String(data: jsonData, encoding: .utf8)!
        print("jsonString = \(jsonString)")
        notifyData.notificationData = jsonString
    } catch {
        print(error.localizedDescription)
        return
    }

    app.saveContext()
}

func deleteAllNotifications() {
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    vc = app.persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<NOTIFICATION_TABLE> = NOTIFICATION_TABLE.fetchRequest()
    
    do {
        let notificationList = try vc.fetch(fetchRequest)
        for notificationData in notificationList {
            vc.delete(notificationData)
        }
    } catch {
        print(error.localizedDescription)
        return
    }
    
    app.saveContext()
}

func deleteNotificationByID(message_id: String) {
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    vc = app.persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<NOTIFICATION_TABLE> = NOTIFICATION_TABLE.fetchRequest()
    let pString = "messageID == \"\(message_id)\""
    let predicate = NSPredicate(format: pString)
    fetchRequest.predicate = predicate

    do {
        let notificationData = try vc.fetch(fetchRequest).first
        if notificationData != nil {
            vc.delete(notificationData!)
        }
    } catch {
        print(error.localizedDescription)
        return
    }
    
    app.saveContext()
}

func updateNotificationReadStatus(message_id: String, status: Bool) {
    let app = UIApplication.shared.delegate as! AppDelegate
    var vc: NSManagedObjectContext!
    vc = app.persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<NOTIFICATION_TABLE> = NOTIFICATION_TABLE.fetchRequest()
    let predicateString = "messageID == \"\(message_id)\""

    let predicate = NSPredicate(format: predicateString)
    fetchRequest.predicate = predicate

    do {
        let notificationData = try vc.fetch(fetchRequest).first
        if notificationData != nil {
            notificationData?.setValue(status, forKey: "isRead")
            let decoder: JSONDecoder = JSONDecoder()
            do {
                let jsonData = notificationData?.notificationData!.data(using: .utf8)
                var tmpData = try decoder.decode(NotificationData.self, from: jsonData!)
                print("updateNotificationReadStatus: tmpData in notificationList = \(tmpData)")
                tmpData.isRead = true
                do {
                    let updatedJSONData = try JSONSerialization.data(withJSONObject: tmpData.toAnyObject(), options: [.prettyPrinted])
                    let jsonString = String(data: updatedJSONData, encoding: .utf8)!
                    print("jsonString = \(jsonString)")
                    notificationData?.setValue(jsonString, forKey: "notificationData")
                } catch {
                    print(error.localizedDescription)
                    return
                }

                
            } catch {
                print("updateNotificationReadStatus: jsonData decode failed: \(error.localizedDescription)")
                return
            }
        }
    } catch {
        print(error.localizedDescription)
        return
    }
    
    app.saveContext()
}
