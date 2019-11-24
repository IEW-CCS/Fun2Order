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

func deleteFavoriteStore(brand_id: Int, store_id: Int) {
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
    }

    app.saveContext()
}
