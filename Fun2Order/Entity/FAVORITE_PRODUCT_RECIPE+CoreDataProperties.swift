//
//  FAVORITE_PRODUCT_RECIPE+CoreDataProperties.swift
//  
//
//  Created by Lo Fang Chou on 2019/11/30.
//
//

import Foundation
import CoreData


extension FAVORITE_PRODUCT_RECIPE {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FAVORITE_PRODUCT_RECIPE> {
        return NSFetchRequest<FAVORITE_PRODUCT_RECIPE>(entityName: "FAVORITE_PRODUCT_RECIPE")
    }

    @NSManaged public var brandID: Int16
    @NSManaged public var storeID: Int16
    @NSManaged public var productID: Int16
    @NSManaged public var recipeCode: String?
    @NSManaged public var recipeSubCode: String?

}
